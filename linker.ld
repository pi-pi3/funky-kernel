ENTRY(_start)

SECTIONS {
    . = 1M;

    .boot : {
        *(.multiboot2.*)
        KEEP(*(.multiboot2.*))
    }

    .text : {
        *(.text.*)
        KEEP(*(.text.*))
    }

    .rodata : {
        *(.rodata.*)
        KEEP(*(.rodata.*))
    }

    .data : {
        *(.data.*)
        KEEP(*(.data.*))
    }

    .bss : {
        *(.bss.*)
        KEEP(*(.bss.*))
    }
}
