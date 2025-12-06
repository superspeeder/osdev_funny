CC = clang
LD = ld.lld
ZIG := zig
NASM := nasm

.PHONY: build
build:
	$(ZIG) build -Doptimize=ReleaseSafe 

zig-out/bin/kernel.elf: build
