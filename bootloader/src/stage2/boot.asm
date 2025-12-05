[org 0x9000]
[bits 32]
VGA_WIDTH equ 80
VGA_HEIGHT equ 25
VGA_SIZE equ VGA_WIDTH * VGA_HEIGHT
VGA_MEMORY equ 0xb8000

start:
    ; now that we are in protected mode proper, turn back on NMIs
    .enable_nmi:
        in ax, 0x70
        and ax, 0x7f
        out 0x70, ax
        in ax, 0x71

    mov ecx, VGA_SIZE
    mov edx, VGA_MEMORY
    mov al, ' '
    mov ah, 0x0f
    .csl:
        mov [edx], ax
        add edx, 2
        loop .csl

    mov ebx, PM_HELLO
    call pm_print

    call enable_lm
    
    cmp ax, 0
    jz halt

    mov ebx, PM_ERROR
    call pm_print


halt:
    cli
    .inner:
        hlt
        jmp .inner

PM_HELLO db "Hello from stage 2 bootloader.", 0
PM_ERROR db "Error entering long mode.     ", 0

%include "src/stage2/print_pm.asm"
%include "src/stage2/lm.asm"

[bits 64]
VGA_TEXT_BUFFER_ADDR equ 0xb8000
COLS equ 80
ROWS equ 25
BYTES_PER_CHARACTER equ 2
VGA_TEXT_BUFFER_SIZE equ BYTES_PER_CHARACTER * COLS * ROWS

BEGIN_LM:
    mov rdi, VGA_TEXT_BUFFER_ADDR
    mov rax, 0
    mov rcx, VGA_TEXT_BUFFER_SIZE / 8
    rep stosq

    .hcf:
        hlt
        jmp .hcf


times (512 * 8) - ($-$$) db 0