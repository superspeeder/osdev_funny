[org 0x7c00]
    mov bp, 0x8000  ; Move stack far away
    mov sp, bp

    call print_hello

    mov bx, 0x9000  ; es:bx = 0x0000:0x9000 = 0x09000
    mov dh, 8       ; read 2 sectors
    call disk_load  ; Load from disk

    jmp enter_pm   ; enter 32-bit protected mode
    jmp $

;; PRINT
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



;; DISK
disk_load:
    pusha

    push dx

    mov ah, 0x02
    mov al, dh
    mov cl, 0x02
    mov ch, 0x00
    mov dh, 0x00

    int 0x13
    jc disk_error

    pop dx
    cmp al, dh
    jne sectors_error
    popa
    ret

disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah
    call print_hex
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0


;; GDT
gdt_start:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff       ; segment length, bits 0-15,
    dw 0x0000       ; segment base, bits 0-15
    db 0x00         ; segment base, bits 16-23
    db 10011010b    ; flags (8 bits)
    db 11001111b    ; flags (4 bits) + segment length, bits 16-19
    db 0x00         ; segment base, bits 24-31

gdt_data:
    dw 0xffff       ; segment length, bits 0-15,
    dw 0x0000       ; segment base, bits 0-15
    db 0x00         ; segment base, bits 16-23
    db 10010010b    ; flags (8 bits)
    db 11001111b    ; flags (4 bits) + segment length, bits 16-19
    db 0x00         ; segment base, bits 24-31

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; size (16 bit), always one less of its true size
    dd gdt_start                ; address (32 bit)

; constants for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;; PM
[bits 16]
enter_pm:
    cli                     ; disable interrupts
    .disable_nmi:           ; Intel suggests disabling NMI before entering protected mode
        in ax, 0x70
        mov bx, ax

        .iowait:
            mov ax, 0
            out 0x80, ax

        mov ax, bx
        or ax, 0x80
        out 0x70, ax

        .iowait2:
            mov ax, 0
            out 0x80, ax

        in ax, 0x71
        
        ; code for enabling the a20 gate from real mode: not sure if this should be done or not yet leaving it for later.
    .enable_a20:
        in al, 0x92
        test al, 2
        jnz .with_a20_enabled
        or al, 2
        and al, 0xFE
        out 0x92, al

.with_a20_enabled:


    lgdt [gdt_descriptor]   ; load gdt
    mov eax, cr0
    or eax, 0x1             ; set 32-bit mode bit in cr0
    mov cr0, eax
    jmp CODE_SEG:init_pm    ; far jump using a different segment

[bits 32]
init_pm:
    mov ax, DATA_SEG        ; update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; setup stack at top of free space
    mov esp, ebp

    call BEGIN_PM           ; call well known label for start of protected mode code

[bits 32]
BEGIN_PM:
    jmp 0x9000

    jmp $

times 510-($-$$) db 0
dw 0xaa55

; [bits 32]
; setup_stage2:
;     ; Load a GDT for code so we can 

;     mov ebx, PM_HELLO
;     call pm_print

; .h: hlt
;     jmp .h


; %include "src/print_pm.asm"

; PM_HELLO db "Loaded 32-bit protected mode", 0

; ; %include "src/gdt64.asm"

; times (512 * 8) + $-$$-512 db 0

