#![feature(lang_items)]
#![feature(no_std)]
#![feature(core)]
#![feature(core_prelude)]
#![feature(core_str_ext)]
#![feature(asm)]

#![no_std]

#[macro_use]
extern crate core;

pub mod kernel;
mod drivers;
mod prelude;
