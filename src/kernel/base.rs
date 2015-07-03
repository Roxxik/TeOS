pub use prelude::*;


#[cfg(target_arch="x86_64")]
#[lang="start"]
#[no_mangle]
pub fn kmain() {
    log_serial!("Hello");
    loop{}
}
