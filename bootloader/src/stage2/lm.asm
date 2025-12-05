[bits 32]
%include "src/stage2/gdt64.asm"

;; Check for CPUID support
EFLAGS_ID equ 1 << 21

check_cpuid:
    pushfd
    pop eax

    mov ecx, eax
    xor eax, EFLAGS_ID

    push eax
    popfd
    pushfd
    pop eax

    xor eax, ecx
    jnz .supported
    .not_supported:
        mov ax, 1
        ret

    .supported:
        mov ax, 0
        ret


;; Check for long mode support
CPUID_EXTENSIONS        equ 0x80000000
CPUID_EXT_FEATURES      equ 0x80000001
CPUID_EDX_EXT_FEAT_LM   equ 1 << 29

check_long_mode_support:
    ; Check if we can query if long mode exists
    mov eax, CPUID_EXTENSIONS
    cpuid
    cmp eax, CPUID_EXT_FEATURES
    jb .not_supported

    mov eax, CPUID_EXT_FEATURES
    cpuid
    test edx, CPUID_EDX_EXT_FEAT_LM
    jz .not_supported

    .supported:
        mov ax, 0
        ret

    .not_supported:
        mov ax, 1
        ret

;; Enable paging

CR0_PAGING equ 1 << 31

disable_paging_32:
    mov eax, cr0
    and eax, ~CR0_PAGING
    mov cr0, eax
    ret

; Conveniently, this address is before we loaded our stage 2 bootloader so we actually do know the memory is available right now
PML4T_ADDR equ 0x1000
PDPT_ADDR equ 0x2000
PDT_ADDR equ 0x3000
PT_ADDR equ 0x4000

PT_ADDR_MASK equ 0xffffffffff000
PT_PRESENT equ 1
PT_READABLE equ 2

SIZEOF_PAGE_TABLE equ 4096
ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000
CR4_PAE_ENABLE equ 1 << 5

setup_page_table:
    mov edi, PML4T_ADDR
    mov cr3, edi            ; CR3 tells the CPU where to find the page tables

    xor eax, eax
    mov ecx, SIZEOF_PAGE_TABLE
    rep stosd

    mov edi, cr3

    mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDPT_ADDR
    mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDT_ADDR
    mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PT_ADDR
    mov ebx, PT_PRESENT | PT_READABLE
    mov ecx, ENTRIES_PER_PT      ; 1 full page table addresses 2MiB

    .set_entry:
        mov DWORD [edi], ebx
        add ebx, PAGE_SIZE
        add edi, SIZEOF_PT_ENTRY
        loop .set_entry
    
    ret

enable_pae:
    mov eax, cr4
    or eax, CR4_PAE_ENABLE
    mov cr4, eax

    ret

;; Switch to Long Mode
EFER_MSR equ 0xC0000080
EFER_LM_ENABLE equ 1 << 8
CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31

enable_lm:
    cli

    call check_cpuid
    cmp ax, 0
    jnz .error

    call check_long_mode_support
    cmp ax, 0
    jnz .error

    
	mov ax, 0x2401
	int 0x15

    mov ax, 0x03
    int 0x10

    call disable_paging_32
    call setup_page_table
    call enable_pae

    .compat_mode:
        mov ecx, EFER_MSR
        rdmsr
        or eax, EFER_LM_ENABLE
        wrmsr

        mov eax, cr0
        or eax, CR0_PG_ENABLE | CR0_PM_ENABLE

    .load_64bit_gdt:
        lgdt [gdt64_descriptor]
        ; jmp CODE_SEG64:init_lm
        jmp CODE_SEG64:init_lm

    ; return 1, error
    .error:
        mov ax, 1
        ret


[bits 64]
init_lm:
    cli
    mov ax, gdt64_data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp BEGIN_LM
