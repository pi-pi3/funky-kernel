
bits 32

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

global outb
global outw
global outd
 
global inb
global inw
global ind

global outsb
global insb

outb:
    mov     dx, [esp + 8]
    mov     al, [esp + 12]
    out     dx, al
    ret

outw:
    mov     dx, [esp + 8]
    mov     ax, [esp + 12]
    out     dx, ax
    ret

outd:
    mov     dx, [esp + 8]
    mov     eax, [esp + 12]
    out     dx, eax
    ret

inb:
    mov     dx, [esp + 8]
    in      al, dx
    movzx   eax, al
    ret

inw:
    mov     dx, [esp + 8]
    in      ax, dx
    movzx   eax, ax
    ret

ind:
    mov     dx, [esp + 8]
    in      eax, dx
    ret

outsb:
    mov     dx, [esp + 8]
    mov     esi, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep outsb
    ret

outsw:
    mov     dx, [esp + 8]
    mov     esi, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep outsw
    ret

outsd:
    mov     dx, [esp + 8]
    mov     esi, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep outsd
    ret

insb:
    mov     edi, [esp + 8]
    mov     dx, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep insb
    ret

insw:
    mov     edi, [esp + 8]
    mov     dx, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep insw
    ret

insd:
    mov     edi, [esp + 8]
    mov     dx, [esp + 12]
    mov     ecx, [esp + 16]
    cld
    rep insd
    ret
