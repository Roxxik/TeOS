pub use prelude::*;

#[lang="start"]
#[no_mangle]
extern "C" fn kmain(mboot_sig: u64, mboot_ptr: u64, pml4t_ptr: u64) {
    log_serial!("Hello {}!", "World");
    log_serial!("Hello {}!", "World");
    log_serial!("pml4t_ptr: 0x{:X}", pml4t_ptr);
    log_serial!("mboot_sig: 0x{:X}", mboot_sig);
    log_serial!("mboot_ptr: 0x{:X}", mboot_ptr);
    //map the multiboot info to the 3rd page
    loop{}
}
