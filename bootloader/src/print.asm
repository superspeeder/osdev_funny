print_hello:
    pusha

    mov ah, 0x0e   ; Set tty mode
    
    mov al, 'H'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10

    popa
    ret

print:
    pusha

print_start:
    mov al, [bx]
    cmp al, 0
    je print_done
    
    mov ah, 0x0e
    int 0x10

    add bx, 1
    jmp print_start

print_done:
    popa
    ret


print_nl:
    pusha
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    popa
    ret


print_hex:
    pusha
    mov cx, 0

printhex_loop:
    cmp cx, 4
    je printhex_end

    mov ax, dx
    and ax, 0x000f
    add al, 0x30
    cmp al, 0x39
    jle printhex_step2
    add al, 7

printhex_step2:
    mov bx, HEX_OUT + 5
    sub bx, cx
    mov [bx], al
    ror dx, 4
    add cx, 1
    jmp printhex_loop

printhex_end:
    mov bx, HEX_OUT
    call print

    popa
    ret

HEX_OUT:
    db '0x0000',0
