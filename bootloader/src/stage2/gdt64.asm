PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5

; https://stackoverflow.com/questions/43438363/triple-fault-when-jumping-to-64-bit-longmode

align 8
gdt64_start:
    dq 0

gdt64_code:
    dw 0xffff                           ; segment length, bits 0-15,
    dw 0x0000                           ; segment base, bits 0-15
    db 0x00                             ; segment base, bits 16-23
    db 10011010b                        ; flags (8 bits)
    db 10101111b                         ; flags (4 bits) + segment length, bits 16-19
    db 0x00                             ; segment base, bits 24-31

gdt64_data:
    dw 0xffff                           ; segment length, bits 0-15,
    dw 0x0000                           ; segment base, bits 0-15
    db 0x00                             ; segment base, bits 16-23
    db 10010010b                        ; flags (8 bits)
    db 11001111b                        ; flags (4 bits) + segment length, bits 16-19
    db 0x00                             ; segment base, bits 24-31

gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1  ; size (16 bit), always one less of its true size
    dq gdt64_start                  ; address (64 bit)

; constants for later use
CODE_SEG64 equ gdt64_code - gdt64_start
DATA_SEG64 equ gdt64_data - gdt64_start

