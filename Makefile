RUSTC = rustc
ARCH = x86_64
LD=ld -nostdlib
AS=as --64
TARGET = src/target.json
LINKSCRIPT = src/link.ld

LINKFLAGS = -T $(LINKSCRIPT)
LINKFLAGS += --gc-sections
LINKFLAGS += -z max-page-size=0x1000

ASFLAGS=

RUSTFLAGS = -g --cfg arch__$(ARCH) --target=$(TARGET)

LIBCORESRC=libcore/lib.rs
LIBCORE=libcore.rlib

RLIBCSRC=rlibc/src/lib.rs
RLIBC=librlibc.rlib

BITFLAGSSRC = bitflags/src/lib.rs
BITFLAGS = libbitflags.rlib

SRCS=$(wildcard src/*.rs src/drivers/*.rs src/kernel/*.rs)

OBJS=kernel.o boot.o $(LIBCORE) $(RLIBC) $(BITFLAGS)
MAIN=src/mod.rs
BOOT=src/boot/boot.s

QEMU=qemu-system-x86_64
QEMUFLAGS=-serial stdio

GRUBCFG=src/boot/grub.cfg

ISO=teos.iso
BUILDDIR=build/

BIN = teos.kernel

.PHONY: all iso run debug clean

#from http://wiki.osdev.org/Makefile
#todolist:
#	-@for file in $(ALLFILES:Makefile=); do fgrep -H -e TODO -e FIXME $$file; done; true


all: $(BIN)

iso: $(ISO)

$(ISO): $(BIN) $(GRUBCFG)
	@mkdir -p $(BUILDDIR)boot/grub
	cp $(BIN) $(BUILDDIR)boot/
	cp $(GRUBCFG) $(BUILDDIR)boot/grub/
	grub-mkrescue -d /usr/lib/grub/i386-pc/ -o $(ISO) $(BUILDDIR)

run: $(ISO)
	$(QEMU) $(QEMUFLAGS) $(ISO)
#bochs
#$(QEMU) -kernel $(BIN) $(QEMUFLAGS)

clean:
	rm -f $(OBJS) $(BIN) $(ISO)
	rm -rf $(BUILDDIR)

$(BIN): $(OBJS) $(LINKSCRIPT) $(TARGET)
	$(LD) -o $@ $(LINKFLAGS) $(OBJS)

$(LIBCORE): $(LIBCORESRC) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $(LIBCORESRC)

$(RLIBC): $(RLIBCSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(RLIBCSRC)

$(BITFLAGS): $(RBITFLAGSSRC) $(LIBCORE) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link --extern core=$(LIBCORE) $(BITFLAGSSRC)

kernel.o: $(MAIN) $(LIBCORE) $(RLIBC) $(BITFLAGS) $(SRCS) $(TARGET)
	$(RUSTC) -O $(RUSTFLAGS) -o $@ --emit=obj --extern core=$(LIBCORE) --extern bitflags=$(BITFLAGS) $(MAIN)

boot.o: $(BOOT)
	$(AS) $(ASFLAGS) -o $@ $<
