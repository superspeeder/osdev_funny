ZIG := zig

.PHONY: all
all: build

# kernel/zig-out/bin/kernel.elf:
# 	$(MAKE) -C kernel/
# dist/kernel.bin: $(ASM_OBJECTS) kernel/zig-out/bin/kernel.elf linker.ld
# 	$(LD) -n -o %@ -T linker.ld $(ASM_OBJECTS) kernel/zig-out/bin/kernel.elf


.PHONY: kernel/zig-out/bin/kernel.elf
kernel/zig-out/bin/kernel.elf:
	$(MAKE) -C kernel/

iso/boot/kernel.elf: kernel/zig-out/bin/kernel.elf
	cp $< $@



dist/os.iso: iso/boot/kernel.elf iso/boot/grub/grub.cfg
	grub-mkrescue -o $@ iso

.PHONY: build
build: dist/os.iso

.PHONY: run
run: dist/os.iso
	qemu-system-x86_64 -cdrom dist/os.iso
