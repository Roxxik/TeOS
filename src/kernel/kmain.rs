pub use prelude::*;


#[cfg(target_arch="x86_64")]
#[lang="start"]
#[no_mangle]
extern "C" fn kmain(pml4t: u64) {
    log_serial!("Hello {}!", "World");
    log_serial!("pml4t: 0x{:X}", pml4t);
    loop{}
}
