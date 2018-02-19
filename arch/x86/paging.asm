bits 32

section .text
global setup_paging:function (setup_paging.end - setup_paging)
setup_paging:
        ;; identity map first 4MiB
        mov     eax, page_table
        or      eax, 11b ; r/w | present
        mov     [page_dir], eax

        mov     eax, page_dir
        or      eax, 11b ; r/w | present
        mov     [page_dir + 1023 * 4], eax

        ;; 1024 entries, each pointing to a 4kiB page
        ;; makes up 4MiB
        mov     ecx, 0
.loop:
        ;; eax = ecx * 4kiB
        mov     eax, ecx
        ;mul     1000h
        shl     eax, 12
        or      eax, 11b ; r/w | present
        mov     [ecx * 4 + page_table], eax
        inc     ecx
        cmp     ecx, 1024
        jne     .loop

        ;; physical page address of base directory
        mov     eax, page_dir
        mov     cr3, eax

        ;; enable paging && write protect
        mov     eax, cr0
        ;; pg | wp
        or      eax, (1 << 31) | (1 << 16)
        mov     cr0, eax

        ret
.end:

section .bss
align 4096, resb 0
page_dir    resd    1024
page_table  resd    1024
