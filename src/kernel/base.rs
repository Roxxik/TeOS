pub use prelude::*;

#[no_mangle]
#[allow(unused_variables)]
pub extern "C" fn kmain(magic: u32, info: *mut u8) -> ! {
    ::drivers::screen::clear();
    log!("Hello");
    loop{}
}
