#![feature(lang_items)]
#![feature(no_std)]
#![feature(core_str_ext)]
#![feature(asm)]
#![feature(raw)]

#![allow(private_no_mangle_fns)]
#![allow(dead_code)]

#![no_std]

#[macro_use]
extern crate bitflags;

pub mod kernel;
mod drivers;
mod prelude;
mod mm;
