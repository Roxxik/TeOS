# TeOS
small toy os

# How to Build
WIP
feel free to contact me for everything related to this repo

you'll need

    rustc

    grub-mkrescue
    libisoburn

    libcore
    rlibc

    qemu

//TODO add links or put those as submodules into git

and qemu to virtualize the OS
in theory this kernel can be put on a stick with grub and booted but this isn't tested

//TODO add the specific commands to do so

# current topic
- doing stuff to set up page tables

# Todo
- ports in screen.rs are hardcoded
- cursor positioning should not happen after each displayed character

# Currently working
- (line based output with scrolling) if i get paging to work

# Design goals:
- learn something about Rust and OSes

- first of this will be a kernel only thing hoping that rusts memory protection is enough to get my own code working

I don't know where this is going, but for now i won't go too low on stuff and just try to get the basics working

in the very far future this might be a micro/nano kernel

# Short-term goals
- get input going/keyboard interrupts
- get an allocator working
- look at libstd and consider getting all of it working

# Longer-term goals
- Disk Access / Filesystem
- maybe networking
- graphics
- (multitasking)
- move stuff out of kernel land

- build the tool chain for my TeOs so that i can start developing on it
