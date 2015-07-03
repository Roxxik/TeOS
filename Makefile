RUSTC = rustc
ARCH = x86
LD=ld -melf_i386 -nostdlib
AS=as -march=i386 --32
TARGET = src/target.json
LINKSCRIPT = src/link.ld

LINKFLAGS = -T $(LINKSCRIPT)
LINKFLAGS += --gc-sections
LINKFLAGS += -z max-page-size=0x1000

RUSTFLAGS = -g -O --cfg arch__$(ARCH) --target=$(TARGET)

LIBCORESRC=libcore/lib.rs
LIBCORE=libcore.rlib

RLIBCSRC=rlibc/src/lib.rs
RLIBC=librlibc.rlib


SRCS=$(wildcard src/*.rs src/drivers/*.rs src/kernel/*.rs)

OBJS=kernel.o boot.o $(LIBCORE) $(RLIBC)
MAIN=src/mod.rs
BOOT=src/boot/boot.s

QEMU=qemu-system-i386
QEMUFLAGS=

BIN = teos.kernel

.PHONY: all run debug clean

#from http://wiki.osdev.org/Makefile
#todolist:
#	-@for file in $(ALLFILES:Makefile=); do fgrep -H -e TODO -e FIXME $$file; done; true

#for image

#mkdir -p iso/boot/grub
#cp $(BIN) iso/boot/
#cp $(GRUBCFG) iso/boot/grub/
#grub-mkrescue -d /usr/lib/grub/i386-pc/ -o teos.iso iso/


all: $(BIN)

run: all
	$(QEMU) -kernel $(BIN) $(QEMUFLAGS)

clean:
	rm -f $(OBJS) $(BIN)

$(BIN): $(OBJS) $(LINKSCRIPT) $(TARGET)
	$(LD) -o $@ $(LINKFLAGS) $(OBJS)

$(LIBCORE): $(LIBCORESRC) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $(LIBCORESRC)

$(RLIBC): $(RLIBCSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(RLIBCSRC)

kernel.o: $(MAIN) $(LIBCORE) $(SRCS) $(TARGET)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj --extern core=$(LIBCORE) $(MAIN)

boot.o: $(BOOT)
	$(AS) $(ASFLAGS) -o $@ $<
