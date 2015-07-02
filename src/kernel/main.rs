#![feature(lang_items)]
#![feature(no_std)]
#![feature(core)]
#![feature(core_prelude)]
#![feature(core_str_ext)]
#![feature(asm)]

#![no_std]

#[macro_use]
extern crate core;

#[macro_use]
mod macros;

mod prelude;
pub mod unwind;
mod screen;

pub use prelude::*;

#[no_mangle]
#[allow(unused_variables)]
pub extern "C" fn kmain(magic: u32, info: *mut u8) -> ! {
    screen::clear();
    screen::print_at("1",Some((0,0)));
    screen::print_at("2",Some((0,1)));
    screen::print_at("3",Some((0,2)));
    screen::print_at("4",Some((0,3)));
    screen::print("\n");
    log!("HELLO");
    for i in 0..30 {
        log!("{}",i);
    }
    loop{}
}
