bits 32

extern setup_paging
extern setup_gdt
extern kmain
extern _init

section .text
global _start:function (_start.end - _start)
_start:
        ;; setup a 16kiB stack
        mov     esp, stack_end

        push    ebx
        push    eax

        ;; this maps the first virtual 4MiB to physical first 4MiB
        ;; and maps the last pde to the pde itself
        call    setup_paging

        ;; sets up a useful gdt
        ;; see below in setup_gdt and .bss
        call    setup_gdt

        ;; global constructors
        call    _init

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
