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


SRCS=$(wildcard src/kernel/*.rs)

OBJS=kernel.o boot.o $(LIBCORE) $(RLIBC)
MAIN=src/kernel/main.rs
BOOT=src/boot/boot.s

QEMU=qemu-system-i386
QEMUFLAGS=

BOCHS=bochs

BIN = kernel.bin

.PHONY: all run debug clean

all: $(BIN)

run: all
	$(QEMU) -kernel $(BIN) $(QEMUFLAGS)

clean:
	rm -f $(OBJS) $(BIN)


$(BIN): $(OBJS) $(LINKSCRIPT) $(TARGET)
	$(LD) -o $@ $(LINKFLAGS) $(OBJS)

$(LIBCORESRC):
	cp -r ../rust/src/libcore .

$(LIBCORE): $(LIBCORESRC) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $(LIBCORESRC)

$(RLIBC): $(RLIBCSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(RLIBCSRC)

kernel.o: $(MAIN) $(LIBCORE) $(SRCS) $(TARGET)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj --extern core=$(LIBCORE) $(MAIN)

boot.o: $(BOOT)
	$(AS) $(ASFLAGS) -o $@ $<
