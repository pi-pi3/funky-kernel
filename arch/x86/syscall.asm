bits 32

section .text
kernel:
        int     80h
        ret

global syscall:function (syscall.end - syscall)
syscall:
        push    ebp
        mov     ebp, esp

        mov     eax, [ebp + 8]
        call    kernel

        pop     ebp
        ret
.end:

;; syscall number is assumed to be in eax
;; all other parameters ase passed on the stack
;; the return value is returned in eax
global i_syscall:function (i_syscall.end - i_syscall)
i_syscall:
        pushad
        popad
        iretd
.end:
