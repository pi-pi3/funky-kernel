bits 32

extern kmain

%define MB2_MAGIC 0e85250d6h
%define MB2_CKSUM(arch) (100000000h - (MB2_MAGIC + (arch) + header_length))

struc mb2_header
.magic  resd    1   ;; magic number
.arch   resd    1   ;; architecture (0 = i386, protected)
.length resd    1   ;; size of the header
.cksum  resd    1   ;; cksum
endstruc

struc mb2_tag
.type   resw    1   ;; type
.flags  resw    1   ;; flags
.size   resd    1   ;; size
endstruc

section .boot
header_start:
align   4, db 0
istruc  mb2_header
    at  mb2_header.magic,   dd  MB2_MAGIC
    at  mb2_header.arch,    dd  0h
    at  mb2_header.length,  dd  header_length
    at  mb2_header.cksum,   dd  MB2_CKSUM(0h)
iend

align   8, db 0
istruc  mb2_tag
    at  mb2_tag.type,       dw  0
    at  mb2_tag.flags,      dw  0
    at  mb2_tag.size,       dd  8
iend
header_end:
header_length   equ     (header_end - header_start)

section .text
global _start:function (_start.end - _start)
_start:
        ;; setup a 16kiB stack
        mov     esp, stack_end

        push    ebx
        push    eax

        ;; this maps the first virtual 2MiB to physical first 2MiB
        ;; and maps the last pde to the pde itself
        call    setup_paging

        ;; sets up a useless gdt
        ;; see below in .rodata
        call    setup_gdt

        call    kmain
        add     esp, 8

        cli
.hang:  hlt
        jmp     .hang
.end:

setup_paging:
        ;; identity map first 2MiB
        mov     eax, page_table
        or      eax, 11b ; r/w | present
        mov     [page_dir], eax

        mov     eax, page_dir
        or      eax, 11b ; r/w | present
        mov     [page_dir + 1023 * 4], eax

        ;; 256 entries, each pointing to a 4kiB page
        ;; makes up 1MiB
        mov     ecx, 0
.loop:
        ;; eax = ecx * 4kiB
        mov     eax, ecx
        ;mul     1000h
        shl     eax, 12
        or      eax, 11b ; r/w | present
        mov     [ecx * 4 + page_table], eax
        inc     ecx
        cmp     ecx, 512
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

setup_gdt:
        cli
        lgdt    [gdt_pointer]
        sti

        jmp     08h:reload_segments

reload_segments:
        mov     ax, 10h
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax
        ret

section .bss
align 16, db 0
stack_bottom:
            resb    16384
stack_end:

align 4096, db 0
page_dir    resd    1024
page_table  resd    1024

section .rodata
%define GDT_ENTRY(base, limit, flags, access) \
        (((limit) & 00ffffh) | \
        (((limit) & 0f0000h) << 32) | \
        (((base) & 000fffffh) << 16) | \
        (((base) & 0ff00000h) << 56) | \
        (((flags) & 0fh) << 52) | \
        (((access) & 0ffh) << 40))

;; it's not a particularly useful gdt, seeing as the code and data segments
;; overlap and they both encompass the entire address space
align 16, db 0
gdt_pointer:
.size       dw      gdt.size - 1
.offset     dd      gdt

align 16, db 0
gdt:
.null       dq      GDT_ENTRY(0, 0, 0, 0)
.code       dq      GDT_ENTRY(0, 0fffffh, 1100b, 10011010b) ; 32bit | present | descr | executable | r/w
.data       dq      GDT_ENTRY(0, 0fffffh, 1100b, 10010010b) ; 32bit | present | descr | r/w
.size       equ     ($ - gdt)
