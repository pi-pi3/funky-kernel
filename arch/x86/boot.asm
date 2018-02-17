bits 32

extern kmain
extern _init

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

%define GDT_ENTRY(base, limit, flags, access) \
        (((limit) & 00ffffh) | \
        (((limit) & 0f0000h) << 32) | \
        (((base) & 000fffffh) << 16) | \
        (((base) & 0ff00000h) << 56) | \
        (((flags) & 0fh) << 52) | \
        (((access) & 0ffh) << 40))

setup_gdt:
        ;; null entry
        mov     dword [gdt + gdt.null], 0
        mov     dword [gdt + gdt.null + 4], 0
        ;; kernel segments
        mov     edx, GDT_ENTRY(0h, 400h, 1100b, 10011010b) >> 32 ; page granularity | 32bit, present | descr | executable | r/w
        mov     eax, GDT_ENTRY(0h, 400h, 1100b, 10011010b) & 0xffffffff ; page granularity | 32bit, present | descr | executable | r/w
        mov     [gdt + gdt.kcode], eax
        mov     [gdt + gdt.kcode + 4], edx

        mov     edx, GDT_ENTRY(0h, 400h, 1100b, 10010010b) >> 32 ; page granularity | 32bit, present | descr | r/w
        mov     eax, GDT_ENTRY(0h, 400h, 1100b, 10010010b) & 0xffffffff ; page granularity | 32bit, present | descr | r/w
        mov     [gdt + gdt.kdata], eax
        mov     [gdt + gdt.kdata + 4], edx

        ;; userspace segments
        mov     edx, GDT_ENTRY(400000h, 600h, 1100b, 11111010b) >> 32 ; page granularity | 32bit, present | ring = 3 | descr | executable | r/w
        mov     eax, GDT_ENTRY(400000h, 600h, 1100b, 11111010b) & 0xffffffff ; page granularity | 32bit, present | ring = 3 | descr | executable | r/w
        mov     [gdt + gdt.ucode], eax
        mov     [gdt + gdt.ucode + 4], edx

        mov     edx, GDT_ENTRY(600000h, 800h, 1100b, 11110010b) >> 32 ; page granularity | 32bit, present | ring = 3 | descr | r/w
        mov     eax, GDT_ENTRY(600000h, 800h, 1100b, 11110010b) & 0xffffffff ; page granularity | 32bit, present | ring = 3 | descr | r/w
        mov     [gdt + gdt.udata], eax
        mov     [gdt + gdt.udata + 4], edx
        ;; task state segment
        ;; higher half of tss entry
        mov     edx, GDT_ENTRY(0, 0, 0100b, 10011001b) >> 32 ; 32bit, present | executable | accessed

        ;; base 16:23
        mov     eax, tss
        shr     eax, 16
        and     eax, 0xff
        ;; and store in higher byte at 0:7 (32:39)
        or      edx, eax

        ;; base 24:31
        mov     eax, tss
        and     eax, 0xff000000
        ;; and store in higher byte at 24:31 (56:63)
        or      edx, eax

        ;; limit 16:19
        mov     eax, tss.end
        and     eax, 0xf00
        ;; and store in higher byte at 16:19 (48:51)
        or      edx, eax

        ;; base 0:15
        mov     ebx, tss
        shl     ebx, 16
        ;; limit 0:15
        mov     eax, tss.end
        and     eax, 0xff
        or      eax, ebx
        ;; little endian: store low half first
        mov     [gdt + gdt.tss], eax
        mov     [gdt + gdt.tss + 4], edx

        mov     word [gdt_pointer.size], gdt.size - 1
        mov     dword [gdt_pointer.offset], gdt

        cli
        lgdt    [gdt_pointer]
        sti

        jmp     gdt.kcode:reload_segments

reload_segments:
        mov     ax, gdt.kdata
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax
        ret

section .bss
align 16, resb 0
stack_bottom:
            resb    16384
stack_end:

align 4096, resb 0
page_dir    resd    1024
page_table  resd    1024

align 16, resb 0
gdt_pointer:
.size       resw    1
.offset     resd    1

align 16, resb 0
gdt:
;; inaccessible null segment
.null       equ     ($ - gdt)
            resq    1
;; kernel segments
.kcode      equ     ($ - gdt)
            resq    1
.kdata      equ     ($ - gdt)
            resq    1
;; userspace segments
.ucode      equ     ($ - gdt)
            resq    1
.udata      equ     ($ - gdt)
            resq    1
;; task state segment
.tss        equ     ($ - gdt)
            resq    1
.size       equ     ($ - gdt)

;; task state segment
tss:
            resw    1 ; reserved
.link:      resw    1 ; LINK
.esp0:      resd    1 ; ESP0
            resw    1 ; reserved
.ss0:       resd    1 ; SS0
.esp1:      resd    1 ; ESP1
            resw    1 ; reserved
.ss1:       resd    1 ; SS1
.esp2:      resd    1 ; ESP2
            resw    1 ; reserved
.ss2:       resd    1 ; SS2
.cr3:       resd    1 ; CR3
.eip:       resd    1 ; EIP
.ef:        resd    1 ; EFLAGS
.eax:       resd    1 ; EAX
.ecx:       resd    1 ; ECX
.edx:       resd    1 ; EDX
.ebx:       resd    1 ; EBX
.esp:       resd    1 ; ESP
.ebp:       resd    1 ; EBP
.esi:       resd    1 ; ESI
.edi:       resd    1 ; EDI
            resw    1 ; reserved
.es:        resd    1 ; ES
            resw    1 ; reserved
.cs:        resd    1 ; CS
            resw    1 ; reserved
.ss:        resd    1 ; SS
            resw    1 ; reserved
.ds:        resd    1 ; DS
            resw    1 ; reserved
.fs:        resd    1 ; FS
            resw    1 ; reserved
.gs:        resd    1 ; GS
            resw    1 ; reserved
.ldtr:      resd    1 ; LDTR
.iopb:      resw    1 ; IOPB offset
            resd    1 ; reserved 
.end:
