pub use prelude::*;

use mm::paging;
use super::multiboot;

fn print_mem(base: u64, length: u64, mem_type: multiboot::MemType) {
    log!("base: 0x{:X}, len: 0x{:X}, type: {:?}",
         base,
         length,
         mem_type);
}

#[lang="start"]
#[no_mangle]
#[allow(unused_variables)]
extern "C" fn kmain(mboot_sig: u64, mboot_ptr: u64, pml4t_ptr: u64) -> ! {
    log!("Hello World, this is kernel");
    log!("Hello {0}, with println parameter \"{0}\"", "World");
    log!("kernel base address 0x{:X}", paging::kernel_base);
    //log!("blub                0x{:X}", kernel_end);


    if multiboot::SIGNATURE_RAX != mboot_sig {
        log!("not booted by multiboot!");
        log!("excpected: 0x{:X}, was: 0x{:X}",
             multiboot::SIGNATURE_RAX,
             mboot_sig);
        hang();
    }

    log!("");
    log!("memory map:");
    let mboot = multiboot::Multiboot::new(mboot_ptr, paging::phys_to_virt);
    mboot.find_memory(print_mem);

    // unsafe {
    //    let pml4t = ::core::slice::from_raw_parts(pml4t_ptr as *const paging::PML4Entry, 512);
    // }

    hang();
}

fn hang() -> ! {
    log!("system hangs now");
    loop {}
}
