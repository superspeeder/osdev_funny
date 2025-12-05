NASM := nasm
ASMFLAGS := -felf64

LD := ld.lld
CC = clang
LDFLAGS := -target x86_64-elf -ffreestanding -mno-red-zone -O2 -nostdlib -mmodel=kernel

boot.o: src/boot.asm
	$(NASM) $(ASMFLAGS) $< -o $@

os.bin: boot.o
	$(CC) -T linker.ld -o $@ $^ $(LDFLAGS)

.PHONY: check_multiboot
check_multiboot: os.bin
	grub-file --is-x86-multiboot $<

.PHONY: clean
clean:
	rm -f *.bin

.PHONY: run
run: os.iso
