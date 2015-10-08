pub use prelude::*;


#[cfg(target_arch="x86_64")]
#[lang="start"]
#[no_mangle]
extern fn kmain() {
    log_serial!("{}", "Hello");
    loop{}
}
