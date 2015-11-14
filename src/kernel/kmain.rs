pub use prelude::*;

use mm::paging;
use super::multiboot;

extern {
    static kernel_base: u64; /* from boot.s */
}

fn print_mem(base: u64, length: u64, mem_type: multiboot::MemType) {
    log!("base: 0x{:X}, len: 0x{:X}, type: {:?}", base, length, mem_type);
}

#[lang="start"]
#[no_mangle]
extern "C" fn kmain(mboot_sig: u64, mboot_ptr: u64, pml4t_ptr: u64) {
    log!("Hello World, this is kernel");
    log!("Hello {0}, this is kernel with println parameter \"{0}\"", "World");
    log!("kernel loaded at 0x{:X}", kernel_base);

    
    if multiboot::SIGNATURE_RAX != mboot_sig {
        log!("not booted by multiboot!");
        log!("excpected: 0x{:X}, was: 0x{:X}", multiboot::SIGNATURE_RAX, mboot_sig);
        hang();
    }
    
    log!("");
    log!("memory map:");    
    let mboot = multiboot::Multiboot::new(mboot_ptr, paging::paddr_to_vaddr);
    mboot.find_memory(print_mem);
    
    //unsafe {
    //    let pml4t = ::core::slice::from_raw_parts(pml4t_ptr as *const paging::PML4Entry, 512);
    //}
    
    loop{}
}

fn hang() -> ! {
    loop {}
}
