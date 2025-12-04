NASM := nasm
ASMFLAGS := -f bin

boot.bin: src/boot.asm src/print.asm src/disk.asm
	$(NASM) $(ASMFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -f boot.bin

.PHONY: run
run: boot.bin
	qemu-system-x86_64 -drive file=boot.bin,format=raw,index=0,media=disk

