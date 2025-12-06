global long_mode_start

section .text
bits 64

extern kernel_main

VIDEO_MEMORY equ 0xb8000

long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call kernel_main

    .hang:
        hlt
        jmp .hang
