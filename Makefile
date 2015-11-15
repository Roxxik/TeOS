RUSTC = rustc
ARCH = x86_64

LD = ld
AS = as


RUSTFLAGS = -g --cfg arch__$(ARCH) --target=$(TARGET)

LINKFLAGS  = -nostdlib
LINKFLAGS += -T $(LINKSCRIPT)
LINKFLAGS += --gc-sections
LINKFLAGS += -z max-page-size=0x1000

ASFLAGS = --64


TARGET = src/target.json
LINKSCRIPT = src/link.ld

#LIBCORE
LIBCORESRC=libcore/lib.rs
LIBCORE=libcore.rlib

#RLIBC
RLIBCSRC=rlibc/src/lib.rs
RLIBC=librlibc.rlib

#BITFLAGS
BITFLAGSSRC = bitflags/src/lib.rs
BITFLAGS = libbitflags.rlib

#KERNEL SOURCES
SRCS=$(wildcard src/*.rs src/**/*.rs)

#BOOT ASSEMBLY
BOOTSRC=src/boot/boot.s
BOOT = boot.o

MAIN=src/mod.rs

OBJS=kernel.o $(BOOT) $(LIBCORE) $(RLIBC) $(BITFLAGS)

BIN = teos.kernel

#ISO
GRUBCFG=src/boot/grub.cfg
ISO=teos.iso
BUILDDIR=build/

#QEMU
QEMU=qemu-system-x86_64
QEMUFLAGS=-serial stdio -m 1G

#BOCHS
BOCHS = bochs

.PHONY: all iso run debug clean qemu bochs

#from http://wiki.osdev.org/Makefile
#todolist:
#	-@for file in $(ALLFILES:Makefile=); do fgrep -H -e TODO -e FIXME $$file; done; true


all: $(BIN)

iso: $(ISO)

run: qemu

qemu: iso
	$(QEMU) $(QEMUFLAGS) $(ISO)

bochs: iso
	$(BOCHS)

$(ISO): $(BIN) $(GRUBCFG)
	mkdir -p $(BUILDDIR)boot/grub
	cp $(BIN) $(BUILDDIR)boot/
	cp $(GRUBCFG) $(BUILDDIR)boot/grub/
	grub-mkrescue -d /usr/lib/grub/i386-pc/ -o $(ISO) $(BUILDDIR)

$(BIN): $(OBJS) $(LINKSCRIPT)
	$(LD) -o $@ $(LINKFLAGS) $(OBJS)

$(LIBCORE): $(LIBCORESRC) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $(LIBCORESRC)

$(RLIBC): $(RLIBCSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(RLIBCSRC)

$(BITFLAGS): $(BITFLAGSSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(BITFLAGSSRC)

kernel.o: $(SRCS) $(LIBCORE) $(RLIBC) $(BITFLAGS) $(TARGET)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj --extern core=$(LIBCORE) --extern bitflags=$(BITFLAGS) $(MAIN)

$(BOOT): $(BOOTSRC)
	$(AS) $(ASFLAGS) -o $@ $<


clean:
	rm -f $(OBJS) $(BIN) $(ISO)
	rm -rf $(BUILDDIR)
