pub use prelude::*;

use mm::paging;

#[lang="start"]
#[no_mangle]
extern "C" fn kmain(mboot_sig: u64, mboot_ptr: u64, pml4t_ptr: u64) {
    log_serial!("Hello {}!", "World");
    log_serial!("Hello {}!", "World");
    log_serial!("pml4t_ptr: 0x{:X}", pml4t_ptr);
    log_serial!("mboot_sig: 0x{:X}", mboot_sig);
    log_serial!("mboot_ptr: 0x{:X}", mboot_ptr);
    //map the multiboot info to the 3rd page
    unsafe {
        let pml4t = ::core::slice::from_raw_parts(pml4t_ptr as *const paging::PML4Entry, 512);

        if pml4t[paging::pml4_index(mboot_ptr as usize)].is_present() {
            let pdpt = pml4t[paging::pml4_index(mboot_ptr as usize)].get_address();
            if pdpt[paging::pdpt_index(mboot_ptr as usize)].is_present() {
                log_serial!("have pdpt");
            }
        }
    }
    loop{}
}
