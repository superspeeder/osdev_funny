CC := clang
LD := ld.lld
NASM := nasm

ASM_SOURCES := $(shell find src/ -name *.asm)
ASM_OBJECTS := $(patsubst src/%.asm,build/%.o, $(ASM_SOURCES))

.PHONY: all
all: build

$(ASM_OBJECTS): build/%.o : src/%.asm
	mkdir -p $(dir $@)
	$(NASM) -f elf64 $(patsubst build/%.o, src/%.asm, $@) -o $@

dist/kernel.bin: $(ASM_OBJECTS) linker.ld
	mkdir -p dist
	$(LD) -n -o dist/kernel.bin -T linker.ld $(ASM_OBJECTS)

iso/boot/kernel.bin: dist/kernel.bin
	cp $< $@

dist/os.iso: iso/boot/kernel.bin iso/boot/grub/grub.cfg
	grub-mkrescue -o $@ iso

.PHONY: build
build: dist/os.iso

