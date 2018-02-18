bits 32

%define pic1_com 020h
%define pic1_dat 021h
%define pic2_com 0a0h
%define pic2_dat 0a1h

extern io_wait

section .text
;; void init_pic(offset1, offset2)
global init_pic:function (init_pic.end - init_pic)
init_pic:
        push    ebp
        mov     ebp, esp
        sub     esp, 8

        ;; save masks
        in      al, pic1_dat
        mov     [ebp - 4], al
        in      al, pic2_dat
        mov     [ebp - 8], al

        ;; starts the initialization sequence (in cascade mode)
        mov     al, 11h
        out     pic1_com, al
        call    io_wait

        mov     al, 11h
        out     pic2_com, al
        call    io_wait

        ;; offset both pics
        mov     al, [ebp + 8]
        out     pic1_dat, al
        call    io_wait

        mov     al, [ebp + 12]
        out     pic2_dat, al
        call    io_wait

        ;; icw3: tell master pic that there is a slave pic at irq2 (0000 0100)
        mov     al, 100b
        out     pic1_dat, al
        call    io_wait

        ;; icw3: tell slave pic its cascade identity (0000 0010)
        mov     al, 10b
        out     pic2_dat, al
        call    io_wait
         
        ;; 8086/88 mode
        mov     al, 1h
        out     pic1_dat, al
        call    io_wait

        mov     al, 1h
        out     pic2_dat, al
        call    io_wait

        ;; eoi
        mov     al, 20h
        out     pic1_com, al
        call    io_wait

        mov     al, 20h
        out     pic2_com, al
        call    io_wait

        mov     al, [ebp - 4]
        out     pic1_dat, al
        mov     al, [ebp - 8]
        out     pic2_dat, al

        add     esp, 8
        pop     ebp
        ret
.end:

; void pic_setmask(char line)
global pic_setmask:function (pic_setmask.end - pic_setmask)
pic_setmask:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     cl, [ebp + 8]
        cmp     cl, 8h
        jge     .slave
.master:
        mov     dx, pic1_dat
        jmp     .endif
.slave:
        mov     dx, pic2_dat
        sub     cl, 8
.endif:

        in      al, dx
        mov     bl, 1
        shl     bl, cl
        or      al, bl
        out     dx, al

        pop     ebx
        pop     ebp
        ret
.end:

; void pic_clearmask(int line)
global pic_clearmask:function (pic_clearmask.end - pic_clearmask)
pic_clearmask:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     cl, [ebp + 8]
        cmp     cl, 8h
        jge     .slave
.master:
        mov     dx, pic1_dat
        jmp     .endif
.slave:
        mov     dx, pic2_dat
        sub     cl, 8
.endif:

        in      al, dx
        mov     bl, 1
        shl     bl, cl
        not     bl
        and     al, bl
        out     dx, al

        pop     ebx
        pop     ebp
        ret
.end:

; void pic_setall()
global pic_setall:function (pic_setall.end - pic_setall)
pic_setall:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     al, 0ffh
        out     pic1_dat, al
        out     pic2_dat, al

        pop     ebx
        pop     ebp
        ret
.end:

; void pic_clearall()
global pic_clearall:function (pic_clearall.end - pic_clearall)
pic_clearall:
        push    ebp
        mov     ebp, esp
        push    ebx

        mov     al, 0h
        out     pic1_dat, al
        out     pic2_dat, al

        pop     ebx
        pop     ebp
        ret
.end:

; void pic_eoi(int number)
global pic_eoi:function (pic_eoi.end - pic_eoi)
pic_eoi:
        push    ebp
        mov     ebp, esp

        mov     al, 20h
        cmp     byte [ebp + 8], 8
        jl      .master
        out     pic2_com, al
.master:
        out     pic1_com, al

        pop     ebp
        ret
.end:
