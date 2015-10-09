#![feature(lang_items)]
#![feature(no_std)]
#![feature(core_str_ext)]
#![feature(asm)]

#![allow(private_no_mangle_fns)]

#![no_std]

mod kernel;
mod drivers;
mod prelude;
mod mm;
