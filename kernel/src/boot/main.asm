global start

section .text
[bits 32]

VIDEO_MEMORY equ 0xb8000

start:
    ; print "OK"
    mov dword [VIDEO_MEMORY], 0x2f4b2f4f

    .hang: hlt
        jmp .hang
