[org 0x7c00]
    mov bp, 0x8000  ; Move stack far away
    mov sp, bp

    call print_hello

    mov bx, 0x9000  ; es:bx = 0x0000:0x9000 = 0x09000
    mov dh, 8       ; read 2 sectors
    call disk_load  ; Load from disk

    call enter_pm   ; enter 32-bit protected mode
    jmp $

; ; code for enabling the a20 gate from real mode: not sure if this should be done or not yet leaving it for later.
; enable_a20:
;     in al, 0x92
;     test al, 2
;     jnz with_a20_enabled
;     or al, 2
;     and al, 0xFE
;     out 0x92, al
; 
; with_a20_enabled:


%include "src/print.asm"
%include "src/disk.asm"
%include "src/gdt.asm"
%include "src/pm.asm"
%include "src/print_pm.asm"

[bits 32]
BEGIN_PM:
    mov ebx, PM_HELLO
    call pm_print
    jmp $

PM_HELLO db "Loaded 32-bit protected mode", 0

times 510-($-$$) db 0
dw 0xaa55

times 2048 dw 0x0000

