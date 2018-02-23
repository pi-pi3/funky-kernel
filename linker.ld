ENTRY(_start)

SECTIONS {
    . = 1M;

    .boot : {
        *(.multiboot2.*)
        KEEP(*(.multiboot2.*))
    }

    .text ALIGN(0x1000) : {
        *(.text.*)
        KEEP(*(.text.*))
    }

    .rodata ALIGN(0x1000) : {
        *(.rodata.*)
        KEEP(*(.rodata.*))
    }

    .data ALIGN(0x1000) : {
        *(.data.*)
        KEEP(*(.data.*))
    }

    .bss ALIGN(0x1000) : {
        *(.bss.*)
        KEEP(*(.bss.*))
    }
}
