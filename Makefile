RUSTC = rustc
ARCH = x86_64
LD=ld -melf_i386 -nostdlib
AS=as -march=i386 --32
TARGET = Kernel/arch/$(ARCH)/target.json
LINKSCRIPT = Kernel/arch/$(ARCH)/link.ld

LINKFLAGS = -T $(LINKSCRIPT)
LINKFLAGS += --gc-sections
LINKFLAGS += -z max-page-size=0x1000

RUSTFLAGS = -O -g --cfg arch__$(ARCH) --target=$(TARGET)

LIBCORESRC=libcore/lib.rs
LIBCORE=libcore.rlib

OBJS=kernel.o boot.o $(LIBCORE)
MAIN=Kernel/main.rs
BOOT=Kernel/arch/$(ARCH)/boot.s


QEMU=qemu-system-i386
QEMUFLAGS=-serial stdio

BIN = kernel.bin

.PHONY: all run clean

all: $(BIN)

run: all
	$(QEMU) -kernel $(BIN) $(QEMUFLAGS)

clean:
	rm -f $(OBJS) $(BIN)


$(BIN): $(OBJS) $(LINKSCRIPT) $(TARGET)
	$(LD) -o $@ $(LINKFLAGS) $(OBJS)

$(LIBCORE): $(LIBCORESRC) $(TARGETSPEC)
	$(RUSTC) $(RUSTFLAGS) -o $@ --crate-type=lib --emit=link $<

kernel.o: $(MAIN) $(LIBCORE) $(TARGET)
	$(RUSTC) $(RUSTFLAGS) -o $@ --emit=obj --extern core=$(LIBCORE) $(MAIN)

boot.o: $(BOOT)
	$(AS) $(ASFLAGS) -o $@ $<
