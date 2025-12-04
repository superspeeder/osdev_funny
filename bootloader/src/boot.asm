[org 0x7c00]
    mov bp, 0x8000   ; Move stack far away
    mov sp, bp

    call print_hello

;    mov bx, 0x9000   ; es:bx = 0x0000:0x9000 = 0x09000
;    mov dh, 2        ; read 2 sectors
;    call disk_load   ; Load from disk

loop:
    jmp loop

%include "src/print.asm"

times 510-($-$$) db 0
dw 0xaa55

