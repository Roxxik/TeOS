# TeOS
small toy Operating System written in Rust

currently only running on some (virtualized) x64 CPUs

# How to Build
WIP
feel free to contact me for everything related to this repo

you'll need

    rustc (tested only on nightly)

    grub-mkrescue
    libisoburn

copy to the root of this repo:

- [libcore]
- [rlibc]
- [bitflags]

[libcore]: https://github.com/rust-lang/rust/tree/master/src/libcore
[rlibc]: https://github.com/alexcrichton/rlibc
[bitflags]: https://github.com/Roxxik/bitflags

qemu to virtualize the OS, in theory this kernel can be put on a stick with grub and booted but this isn't tested

    make qemu

bochs works, too

    make bochs

# current topic
- get a simple page allocator working

# Todo
- ports in serial.rs are hardcoded
- cursor positioning should not happen after each displayed character
- fixing bochs triple-fault, currently only working in qemu

# Currently working
- line based output with scrolling
- serial output
- basic page table

# Design goals:
- learn something about Rust and OSes

- first of this will be a kernel-only thing hoping that rusts memory protection is enough to get my own code working

I don't know where this is going, but for now i won't go too deep into stuff and just try to get the basics working

in the very far future this might be a micro/nano/exo kernel

# Short-term goals
- get input going/keyboard interrupts
- get an allocator working
- look at libstd and consider getting all of it working

# Longer-term goals
- Disk Access / Filesystem
- maybe networking
- move stuff out of kernel-land
- (graphics) not a first-class target
- (multitasking)

- build the tool chain for my TeOs so that i can start developing on it
