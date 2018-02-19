bits 32

;; paging.asm
extern setup_paging
;; gdt.asm
extern setup_gdt
;; idt.asm
extern setup_idt

;; pic.asm
extern init_pic
extern pic_clearmask
extern pic_clearall
extern pic_setall
extern pic_eoi

;; kernel.c
extern kmain
;; crt*.c
extern _init

section .text
global _start:function (_start.end - _start)
_start:
        ;; setup a 16kiB stack
        mov     esp, stack_end

        push    ebx ; mbi addr
        push    eax ; mb2 magic

        cli
        ;; this maps the first virtual 4MiB to physical first 4MiB
        ;; and maps the last pde to the pde itself
        call    setup_paging

        ;; sets up a useful gdt
        ;; see below in setup_gdt and .bss
        call    setup_gdt

        ;; sets up idt and isr
        call    setup_idt

        ;; sets up 8259 pic
        push    28h
        push    20h
        call    init_pic
        add     esp, 8

        ;; set all masks
        call    pic_setall
        ;; clear keyboard mask
        push    1
        call    pic_clearmask
        add     esp, 4
        ;; acknowledge
        call    pic_eoi

        sti

        ;; global constructors
        call    _init

        pop     eax
        pop     ebx

        mov     ebp, 0
        push    ebp

        push    ebx ; mbi addr
        push    eax ; mb2 magic

        call    kmain
        add     esp, 8

        cli
.hang:  hlt
        jmp     .hang
.end:

section .bss
align 16, resb 0
stack_bottom:
            resb    16384
stack_end:
