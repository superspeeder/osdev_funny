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


