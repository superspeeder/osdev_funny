NASM := nasm
ASMFLAGS := -f bin

boot.bin: stage1.bin stage2.bin
	cat $^ > $@

stage1.bin: src/stage1/boot.asm
	$(NASM) $(ASMFLAGS) $< -o $@

stage2.bin: src/stage2/boot.asm src/stage2/gdt64.asm src/stage2/lm.asm  src/stage2/print_pm.asm
	$(NASM) $(ASMFLAGS) $< -o $@


.PHONY: clean
clean:
	rm -f boot.bin

.PHONY: run
run: boot.bin
	qemu-system-x86_64 -drive file=boot.bin,format=raw,index=0,media=disk

