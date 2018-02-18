bits 32

%define BIT_TASK_32 05h
%define INT_GATE_16 06h
%define TRP_GATE_16 07h
%define INT_GATE_32 0eh
%define TRP_GATE_32 0fh

%define PRESENT 10000000b
%define STORAGE 00010000b
%define RING0   00000000b
%define RING3   01100000b

;; exception.asm
extern ex_vector
;; syscall.asm
extern i_syscall
;; pic.asm
extern pic_eoi

section .text
;; void setup_idt()
global setup_idt:function (setup_idt.end - setup_idt)
setup_idt:
        push    ebp
        mov     ebp, esp

        ;; setup exceptions inside an exception vector
        mov     ecx, 20h
.loop:
        push    ecx
        dec     ecx
        ;; load address of the exception handler from exception vector
        lea     eax, [ex_vector + ecx * 5]

        push    PRESENT | RING0 | INT_GATE_32
        push    8h
        push    eax ; function address
        push    ecx ; exception number
        call    add_handler
        add     esp, 16

        pop     ecx
        loop    .loop

        ;; keyboard
        push    PRESENT | RING0 | INT_GATE_32
        push    8h
        push    i_keyboard
        push    21h
        call    add_handler
        add     esp, 16

        ;; syscall
        push    PRESENT | RING3 | INT_GATE_32
        push    8h
        push    i_syscall
        push    80h
        call    add_handler
        add     esp, 16

        mov     word [idt_pointer.size], idt.size - 1
        mov     dword [idt_pointer.offset], idt

        lidt    [idt_pointer]

        pop     ebp
        ret
.end:

;; void add_handler(int num, (void*)() ptr, selector, type)
global add_handler:function (add_handler.end - add_handler)
add_handler:
        push    ebp
        mov     ebp, esp

        push    ebx
        push    edi

        ;; put selector into lower half 16:31
        mov     eax, [ebp + 16]
        shl     eax, 16

        ;; offset bits 0:15
        mov     ebx, [ebp + 12]
        and     ebx, 0xffff
        ;; and put into lower half at 0:15
        or      eax, ebx

        ;; put type 0:7 into higher half 8:15
        mov     edx, [ebp + 16]
        and     edx, 0xff
        shl     edx, 8

        ;; offset bits 16:31
        mov     ebx, [ebp + 12]
        and     ebx, 0xffff0000
        ;; and put into higher half at 16:31
        or      edx, ebx

        mov     edi, [ebp + 8]
        mov     [idt + edi * 8], eax
        mov     [idt + edi * 8 + 4], edx

        pop     edi
        pop     ebx

        pop     ebp
        ret
.end:

i_keyboard:
        push    eax
        in      al, 60h ; read information from the keyboard

        ;; abort on keyboard input
        extern abort
        call    abort

        push    1h
        call    pic_eoi
        add     esp, 4

        pop     eax
        iretd

section .bss
align 16, resb 0
idt_pointer:
.size       resw    1
.offset     resd    1

idt:        resq    256
.size       equ     ($ - idt)
