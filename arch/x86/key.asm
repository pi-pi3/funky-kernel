bits 32

extern pic_eoi

section .text
global i_keyboard
i_keyboard:
        pushad
        in      al, 60h ; read information from the keyboard

        push    1h
        call    pic_eoi
        add     esp, 4

        popad
        iretd
