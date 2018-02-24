bits 32

extern stack_trace

section .text
global ex_vector
ex_vector:
.ex_00h:    jmp     ex_00h
.ex_01h:    jmp     ex_01h
.ex_02h:    jmp     ex_08h ; double fault
.ex_03h:    jmp     ex_03h
.ex_04h:    jmp     ex_04h
.ex_05h:    jmp     ex_05h
.ex_06h:    jmp     ex_06h
.ex_07h:    jmp     ex_07h
.ex_08h:    jmp     ex_08h
.ex_09h:    jmp     ex_08h
.ex_0ah:    jmp     ex_0ah
.ex_0bh:    jmp     ex_0bh
.ex_0ch:    jmp     ex_0ch
.ex_0dh:    jmp     ex_0dh
.ex_0eh:    jmp     ex_0eh
.ex_0fh:    jmp     ex_08h
.ex_10h:    jmp     ex_10h
.ex_11h:    jmp     ex_11h
.ex_12h:    jmp     ex_12h
.ex_13h:    jmp     ex_13h
.ex_14h:    jmp     ex_14h
.ex_15h:    jmp     ex_08h ; double fault
.ex_16h:    jmp     ex_08h ; double fault
.ex_17h:    jmp     ex_08h ; double fault
.ex_18h:    jmp     ex_08h ; double fault
.ex_19h:    jmp     ex_08h ; double fault
.ex_1ah:    jmp     ex_08h ; double fault
.ex_1bh:    jmp     ex_08h ; double fault
.ex_1ch:    jmp     ex_08h ; double fault
.ex_1dh:    jmp     ex_08h ; double fault
.ex_1eh:    jmp     ex_1eh
.ex_1fh:    jmp     ex_1fh

print:
        mov     ah, 04h
.loop:  lodsb
        test    al, al
        jz      .done
        stosw
        jmp     .loop
.done:
        ret

;; eax is expected to have the exception number
print_err:
        push    eax

        mov     edi, 0b8000h ; vga
        mov     esi, panic_msg
        call    print

        pop     eax

        mov     esi, [err_msg + eax * 4]
        call    print
        
        ret

global panic
panic:
        mov     eax, [esp + 4]
        call    print_err

        push    15
        push    0b8000h + 160
        call    stack_trace
        add     esp, 8

        cli
.halt:  hlt
        jmp     .halt

%macro ex_handler 2
%1:
        pushad
        push    %2
        call    panic
        popad
        iretd
%endmacro

ex_handler  ex_00h, 00h
ex_handler  ex_01h, 01h
ex_handler  ex_03h, 03h
ex_handler  ex_04h, 04h
ex_handler  ex_05h, 05h
ex_handler  ex_06h, 06h
ex_handler  ex_07h, 07h
ex_handler  ex_08h, 08h
ex_handler  ex_0ah, 0ah
ex_handler  ex_0bh, 0bh
ex_handler  ex_0ch, 0ch
ex_handler  ex_0dh, 0dh
ex_handler  ex_0eh, 0eh
ex_handler  ex_10h, 10h
ex_handler  ex_11h, 11h
ex_handler  ex_12h, 12h
ex_handler  ex_13h, 13h
ex_handler  ex_14h, 14h
ex_handler  ex_1eh, 1eh
ex_handler  ex_1fh, 1fh

section .data
panic_msg:  db  'kernel panic: ',0

err_msg:
.de:    dd  exception.de    ; 00h     Divide-by-zero Error
.db:    dd  exception.db    ; 01h     Debug
times 1 dd  0               ; 02h     Non-maskable Interrupt
.bp:    dd  exception.bp    ; 03h     Breakpoint
.of:    dd  exception.of    ; 04h     Overflow
.br:    dd  exception.br    ; 05h     Bound Range Exceeded
.ud:    dd  exception.ud    ; 06h     Invalid Opcode
.nm:    dd  exception.nm    ; 07h     Device Not Available
.df:    dd  exception.df    ; 08h     Double Fault
times 1 dd  0               ; 09h     Coprocessor Segment Overrun
.ts:    dd  exception.ts    ; 0ah     Invalid TSS
.np:    dd  exception.np    ; 0bh     Segment Not Present
.ss:    dd  exception.ss    ; 0ch     Stack-Segment Fault
.gp:    dd  exception.gp    ; 0dh     General Protection Fault
.pf:    dd  exception.pf    ; 0eh     Page Fault
times 1 dd  0               ; 0fh     Reserved
.mf:    dd  exception.mf    ; 10h     x87
.ac:    dd  exception.ac    ; 11h     Alignment Check
.mc:    dd  exception.mc    ; 12h     Machine Check
.xm:    dd  exception.xm    ; 13h     SIMD Floating-Point Exception
.ve:    dd  exception.ve    ; 14h     Virtualization Exception
times 9 dd  0               ; 15h-1dh Reserved
.sx:    dd  exception.sx    ; 1eh     Security Exception
times 1 dd  0               ; 1fh     Reserved

exception:
.de:    db  'divide-by-zero error',0 ;    0 (0x0)     Fault   #DE     No
.db:    db  'debug',0 ;   1 (0x1)     Fault/Trap  #DB     No
.bp:    db  'breakpoint',0 ;  3 (0x3)     Trap    #BP     No
.of:    db  'overflow',0 ;    4 (0x4)     Trap    #OF     No
.br:    db  'bound range exceeded',0 ;    5 (0x5)     Fault   #BR     No
.ud:    db  'invalid opcode',0 ;  6 (0x6)     Fault   #UD     No
.nm:    db  'device not available',0 ;    7 (0x7)     Fault   #NM     No
.df:    db  'double fault',0 ;    8 (0x8)     Abort   #DF     Yes (Zero)
.ts:    db  'invalid tss',0 ;     10 (0xA)    Fault   #TS     Yes
.np:    db  'segment not present',0 ;     11 (0xB)    Fault   #NP     Yes
.ss:    db  'stack-segment fault',0 ;     12 (0xC)    Fault   #SS     Yes
.gp:    db  'general protection fault',0 ;    13 (0xD)    Fault   #GP     Yes
.pf:    db  'page fault',0 ;  14 (0xE)    Fault   #PF     Yes
.mf:    db  'x87',0 ; Floating-Point Exception    16 (0x10)   Fault   #MF     No
.ac:    db  'alignment check',0 ;     17 (0x11)   Fault   #AC     Yes
.mc:    db  'machine check',0 ;   18 (0x12)   Abort   #MC     No
.xm:    db  'simd floating-point exception',0 ;   19 (0x13)   Fault   #XM/#XF     No
.ve:    db  'virtualization exception',0 ;    20 (0x14)   Fault   #VE     No
.sx:    db  'security exception',0 ;  30 (0x1E)   -   #SX     Yes
