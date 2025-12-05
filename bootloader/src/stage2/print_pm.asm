[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

pm_print:
    pusha
    mov edx, VIDEO_MEMORY

pm_print_loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK

    cmp al, 0
    je pm_print_done

    mov [edx], ax
    add ebx, 1
    add edx, 2

    jmp pm_print_loop

pm_print_done:
    popa
    ret

pm_clear_screen:
    pusha

    mov al, ' '
    mov ah, WHITE_ON_BLACK
    mov edx, VIDEO_MEMORY

    mov ecx, 80 * 25
    .loop:
        mov [edx], ax
        add edx, 2
        loop .loop
    
    popa
    ret
