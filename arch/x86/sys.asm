bits 32

; void io_wait();

; void outb(uint16_t port, uint8_t value);
; void outw(uint16_t port, uint16_t value);
; void outd(uint16_t port, uint32_t value);
 
; uint8_t inb(uint16_t port);
; uint16_t inw(uint16_t port);
; uint32_t ind(uint16_t port);

; void outsb(uint16_t port, const void *src, size_t num);
; void outsw(uint16_t port, const void *src, size_t num);
; void outsd(uint16_t port, const void *src, size_t num);

; void insb(void *dst, uint16_t port, size_t num);
; void insw(void *dst, uint16_t port, size_t num);
; void insd(void *dst, uint16_t port, size_t num);

global io_wait:function (io_wait.end - io_wait)

global outb:function (outb.end - outb)
global outw:function (outw.end - outw)
global outd:function (outd.end - outd)
 
global inb:function (inb.end - inb)
global inw:function (inw.end - inw)
global ind:function (ind.end - ind)

global outsb:function (outsb.end - outsb)
global outsw:function (outsw.end - outsw)
global outsd:function (outsd.end - outsd)

global insb:function (insb.end - insb)
global insw:function (insw.end - insw)
global insd:function (insd.end - insd)

section .text
io_wait:
    mov     al, 0
    out     80h, al
    ret
.end:

outb:
    mov     dx, [esp + 4]
    mov     al, [esp + 8]
    out     dx, al
    ret
.end:

outw:
    mov     dx, [esp + 4]
    mov     ax, [esp + 8]
    out     dx, ax
    ret
.end:

outd:
    mov     dx, [esp + 4]
    mov     eax, [esp + 8]
    out     dx, eax
    ret
.end:

inb:
    mov     dx, [esp + 4]
    in      al, dx
    movzx   eax, al
    ret
.end:

inw:
    mov     dx, [esp + 4]
    in      ax, dx
    movzx   eax, ax
    ret
.end:

ind:
    mov     dx, [esp + 4]
    in      eax, dx
    ret
.end:

outsb:
    mov     dx, [esp + 4]
    mov     esi, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep outsb
    ret
.end:

outsw:
    mov     dx, [esp + 4]
    mov     esi, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep outsw
    ret
.end:

outsd:
    mov     dx, [esp + 4]
    mov     esi, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep outsd
    ret
.end:

insb:
    mov     edi, [esp + 4]
    mov     dx, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep insb
    ret
.end:

insw:
    mov     edi, [esp + 4]
    mov     dx, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep insw
    ret
.end:

insd:
    mov     edi, [esp + 4]
    mov     dx, [esp + 8]
    mov     ecx, [esp + 12]
    cld
    rep insd
    ret
.end:
