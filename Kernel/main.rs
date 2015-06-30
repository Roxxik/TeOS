#![feature(lang_items)]
#![feature(no_std)]
#![feature(core)]
#![feature(core_prelude)]
#![feature(core_str_ext)]
#![feature(asm)]

#![no_std]

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] fn panic_fmt() -> ! { loop {} }

#[macro_use]
extern crate core;

pub use core::prelude::*;

#[no_mangle]
pub extern "C" fn main(magic: u32, info: *mut u8) -> ! {
    let mut i = 0;
    while i < 80 * 25 {
        unsafe {
            *((0xb8000 + i * 2) as *mut u16) = (12 as u16) << 12;
        }
        i += 1;
    }
    loop {}
}
