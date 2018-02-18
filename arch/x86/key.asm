bits 32

extern pic_eoi

global i_keyboard
i_keyboard:
        pusha
        in      al, 60h ; read information from the keyboard

        ;; breakpoint
        extern panic
        push    3h
        call    panic

        push    1h
        call    pic_eoi
        add     esp, 4

        popa
        iretd
