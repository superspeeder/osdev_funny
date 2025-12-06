CC = clang
LD = ld.lld
NASM := nasm

ASM_SOURCES := $(shell find boot/ -name *.asm)
ASM_OBJECTS := $(patsubst boot/%.asm,build/boot/%.o, $(ASM_SOURCES))

.PHONY: all
all: build

$(ASM_OBJECTS): build/boot/%.o : boot/%.asm
	mkdir -p $(dir $@)
	$(NASM) -f elf64 $(patsubst build/boot/%.o, boot/%.asm, $@) -o $@

kernel/zig-out/bin/kernel.elf:

dist/kernel.bin: $(ASM_OBJECTS) linker.ld
	mkdir -p $(dir $@)
	$(LD) -n -o %@ -T linker.ld $(ASM_OBJECTS)

iso/boot/kernel.bin: dist/kernel.bin
	cp $< $@


dist/os.iso: iso/boot/kernel.bin iso/boot/grub/grub.cfg
	grub-mkrescue -o $@ iso

.PHONY: build
build: dist/os.iso

.PHONY: run
run: dist/os.iso
	qemu-system-x86_64 -cdrom dist/os.iso
