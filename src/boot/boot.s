/* Originally from https://github.com/thepowersgang/rust-barebones-kernel */

/* --- Constants ------------------------------------------------------------ */

/* The kernel is linked to run at -2GB. This allows efficient addressing */
KERNEL_BASE = 0xFFFFFFFF80000000

/* === Multiboot Header === */
MULTIBOOT_PAGE_ALIGN  =  (1<<0)
MULTIBOOT_MEMORY_INFO =  (1<<1)
MULTIBOOT_HEADER_MAGIC =  0x1BADB002
MULTIBOOT_HEADER_FLAGS = (MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO)
MULTIBOOT_CHECKSUM     = -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

/* --- Multiboot Header ----------------------------------------------------- */

.section .multiboot, "a"
mboot:
    .long MULTIBOOT_HEADER_MAGIC
    .long MULTIBOOT_HEADER_FLAGS
    .long MULTIBOOT_CHECKSUM
    .long mboot
    /* a.out kludge (not used, the kernel is elf) */
    .long 0, 0, 0, 0    /* load_addr, load_end_addr, bss_end_addr, entry_addr */
    /* Video mode */
    .long 0     /* Mode type (0: LFB) */
    .long 0     /* Width (no preference) */
    .long 0     /* Height (no preference) */
    .long 0     /* Depth (32-bit preferred) */

/* --- 32-Bit Code ---------------------------------------------------------- */
.section .inittext, "ax"
.globl start
.code32
start:
    /* The kernel starts in protected mode (32-bit mode, we want to switch to long mode) */

    /* 1. Save multiboot state */
    mov %eax, mboot_sig - KERNEL_BASE
    mov %ebx, mboot_ptr - KERNEL_BASE

    /* 2. Ensure that the CPU support long mode */
    mov $0x80000000, %eax
    cpuid
    /* - Check if CPUID supports the field we want to query */
    cmp $0x80000001, %eax
    jbe not64bitCapable
    /* - Test the IA-32e bit */
    mov $0x80000001, %eax
    cpuid
    test $0x20000000, %edx /* bit 29 = */
    jz not64bitCapable

    /* 3. Set up state for long mode */
    /* Enable:
        0x80: PGE (Page Global Enable)
      + 0x20: PAE (Physical Address Extension)
      + 0x10: PSE (Page Size Extensions)
    */
    mov %cr4, %eax
    or $(0x80|0x20|0x10), %eax
    mov %eax, %cr4

    /* Load PML4 */
    mov $(init_pml4t - KERNEL_BASE), %eax
    mov %eax, %cr3

    /* Enable IA-32e mode (Also enables SYSCALL and NX) */
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 11)|(1 << 8)|(1 << 0), %eax     /* NXE, LME, SCE */
    wrmsr

    /* 4. Enable paging and enter long mode */
    mov %cr0, %eax
    or $0x80010000, %eax      /* PG & WP */
    mov %eax, %cr0
    lgdt GDTPtr_low - KERNEL_BASE
    ljmp $0x08, $start64


not64bitCapable:
    /* If the CPU isn't 64-bit capable, print a message to serial/b8000 then busy wait */
    mov $0x3f8, %dx
    mov $'N', %al ; outb %al, %dx
    movw $0x100|'N', 0xb8000
    mov $'o', %al ; outb %al, %dx
    movw $0x100|'o', 0xb8002
    mov $'t', %al ; outb %al, %dx
    movw $0x100|'t', 0xb8004
    mov $'6', %al ; outb %al, %dx
    movw $0x100|'6', 0xb8006
    mov $'4', %al ; outb %al, %dx
    movw $0x100|'4', 0xb8008

not64bitCapable.loop:
    hlt
    jmp not64bitCapable.loop

/* --- 64-Bit Code ---------------------------------------------------------- */
.code64
start64:
    /* Running in 64-bit mode, jump to high memory */
    lgdt GDTPtr
    mov $start64_high, %rax
    jmp *%rax

.section .text
.extern kmain
start64_high:
    /* and clear low-memory mapping */
    mov $0, %rax
    mov %rax, init_pml4t + 0

    /* Set up segment registers */
    mov $0x10, %ax
    mov %ax, %ss
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    /* Set up stack pointer */
    mov $init_stack, %rsp

    /* call the rust code */
    mov (mboot_sig), %rdi
    mov (mboot_ptr), %rsi
    mov $(init_pml4t), %rdx
    call kmain

    /* and if that returns (it shouldn't) loop forever */
start64.loop:
    hlt
    jmp start64.loop

/* --- Page Table ----------------------------------------------------------- */
.section .padata
/* Initial paging structures, four levels */
/* only using 2 levels, because of 1GB pages
/* The +3 for sub-pages indicates "present (1) + writable (2)" */
init_pml4t:
    .quad low_pdpt - KERNEL_BASE + 3     /* low map for startup, will be cleared before rust code runs */
    .rept 512 - 2
       .quad 0
    .endr
    .quad init_pdpt - KERNEL_BASE + 3    /* Final mapping */
low_pdpt:
    .quad 0x0 + 0x80 + 3                 /* early identity map */
    .rept 512 - 1
        .quad 0
    .endr
init_pdpt:                               /* covers the top 512GB, 1GB each entry */
    .rept 512 - 2
       .quad 0
    .endr
    .quad 0x0 + 0x80 + 3
    .quad 0
/* --- Stack ---------------------------------------------------------------- */
init_stack_base:
    .rept 0x1000 * 60
        .byte 0
    .endr
init_stack:

/* --- Multiboot Data ------------------------------------------------------- */
.section .data
.globl kernel_base
kernel_base:  .quad KERNEL_BASE
.globl kernel_end
kernel_end:   .quad kernel_endPTR - KERNEL_BASE
mboot_sig:    .quad 0
mboot_ptr:    .quad 0

/* --- Global Descriptor Table ---------------------------------------------- */
GDTPtr_low:
    .word GDT - GDTEnd
    .long GDT - KERNEL_BASE
GDTPtr:
    .word GDT - GDTEnd
    .quad GDT
GDT:
        .long 0, 0
        .long 0x00000000, 0x00209A00    /* 0x08: 64-bit Code */
        .long 0x00000000, 0x00009200    /* 0x10: 64-bit Data */
        .long 0x00000000, 0x0040FA00    /* 0x18: 32-bit User Code */
        .long 0x00000000, 0x0040F200    /* 0x20: User Data        */
        .long 0x00000000, 0x0020FA00    /* 0x28: 64-bit User Code       */
        .long 0x00000000, 0x0000F200    /* 0x30: User Data (64 version) */
GDTEnd:
kernel_endPTR:
