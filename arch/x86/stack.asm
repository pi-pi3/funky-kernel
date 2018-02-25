bits 32

extern snprintf

section .text
;; void stack_trace(void *dst, int max_frames)
global stack_trace:function (stack_trace.end - stack_trace)
stack_trace:
        push    ebp
        mov     ebp, esp
        sub     esp, 81 ; char tmp[81] = ebp - 85
        push    edi
        push    esi
        push    ebx

        push    trace0
        push    80
        push    dword [ebp + 8]
        call    nprinte
        add     esp, 12

        add     dword [ebp + 8], 160

        mov     ebx, ebp
        mov     ecx, [ebp + 12]

.trace:
        ;; print eip
        mov     eax, [ebx + 4]
        sub     eax, 5 ; call instruction is 5 bytes long on x86

        lea     edi, [ebp - 85]
        push    eax
        push    trace_fmt
        push    81
        push    edi
        call    snprintf
        add     esp, 16

        ;; print trace
        push    ecx

        lea     esi, [ebp - 85]
        push    esi
        push    80
        push    dword [ebp + 8]
        call    nprinte
        add     esp, 12

        add     dword [ebp + 8], 160
        
        pop     ecx

        ;; previous frame
        mov     ebx, [ebx]
        test    ebx, ebx
        loopnz  .trace
.trace_done:

        pop     ebx
        pop     esi
        pop     edi
        add     esp, 81
        pop     ebp
        ret
.end:

;; void nprinte(void *dst, size_t count, const char *src)
nprinte:
        push    ebp
        mov     ebp, esp
        push    edi
        push    esi

        mov     edi, [ebp + 8]
        mov     ecx, [ebp + 12]
        mov     esi, [ebp + 16]
        mov     ah, 04h ; red fg, black bg
.print:
        lodsb

        test    al, al
        jz      .print_done

        stosw
        loop    .print
.print_done:

        pop     esi
        pop     edi
        pop     ebp
        ret

section .data
trace0:     db  'stack trace:',0
trace_fmt:  db  '  at 0x%08x',0
