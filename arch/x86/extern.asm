;; extern.asm
;; fast versions of the memcpy, memmove, memset, memcmp functions

bits 32

global memcpy:function (memcpy.end - memcpy)
global memmove:function (memmove.end - memmove)
global memset:function (memset.end - memset)
global memcmp:function (memcmp.end - memcmp)

section .text
memcpy:
    push    ebp
    mov     ebp, esp
    push    edi
    push    esi

    mov     edi, [ebp + 8]
    mov     esi, [ebp + 12]
    mov     ecx, [ebp + 16]

    cld
    rep movsb

    mov     eax, [ebp + 8]
    pop     esi
    pop     edi
    pop     ebp
    ret
.end:

memmove:
    push    ebp
    mov     ebp, esp
    push    edi
    push    esi

    mov     edi, [ebp + 8]
    mov     esi, [ebp + 12]
    mov     ecx, [ebp + 16]

    cmp     edi, esi
    jg      .rev

.norm:
    cld
    rep movsb
    jmp     .done
.rev:
    std
    lea     edi, [edi + ecx - 1]
    lea     esi, [esi + ecx - 1]
    rep movsb
.done:

    mov     eax, [ebp + 8]
    pop     esi
    pop     edi
    pop     ebp
    ret
.end:

memset:
    push    ebp
    mov     ebp, esp
    push    edi

    mov     edi, [ebp + 8]
    mov     eax, [ebp + 12]
    mov     ecx, [ebp + 16]

    cld
    rep stosd

    mov     eax, [ebp + 8]
    pop     edi
    pop     ebp
    ret
.end:

memcmp:
    push    ebp
    mov     ebp, esp
    push    edi
    push    esi

    mov     edi, [ebp + 8]
    mov     esi, [ebp + 12]
    mov     ecx, [ebp + 16]

    cld
    repe cmpsb

    pop     esi
    pop     edi
    pop     ebp
    ret
.end:
