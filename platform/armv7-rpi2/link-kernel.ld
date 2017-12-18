ENTRY(_start)

SECTIONS
{
    . = 0x8000;

    __text_start__ = .;
    .text :
    {
        KEEP(*(.text.boot))
        *(.text)
    }
    . = ALIGN(4096);
    __text_end__ = .;

    __rodata_start__ = .;
    .rodata :
    {
        *(.rodata)
    }
    . = ALIGN(4096);
    __rodata_end__ = .;

    __data_start__ = .;
    .data :
    {
        *(.data)
    }
    . = ALIGN(4096);
    __data__end__ = .;

    __bss_start__ = .;
    .bss :
    {
        bss = .;
        *(.bss)
    }
    . = ALIGN(4096);
    __bss_end__ = .;
    _end = .;
}
