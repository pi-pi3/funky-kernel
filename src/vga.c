
#include <stddef.h>
#include <stdint.h>

#include "string.h"
#include "sys.h"
#include "vga.h"

#define COLOR_STACK_SIZE 32

static volatile uint16_t *vga;
static uint16_t buffer[VGA_SIZE];
static uint8_t colors[COLOR_STACK_SIZE];
static size_t color_sp;
static int16_t column;
static int16_t row;
static uint16_t bg;
static uint16_t fg;

static void put_raw(volatile uint16_t *dst, uint16_t bg, uint16_t fg, char character) {
    *dst = bg << 12 | fg << 8 | character;
}

static void scroll() {
    size_t offset = VGA_WIDTH;
    size_t end = VGA_SIZE - VGA_WIDTH;
    memmove(buffer, &buffer[offset], end * VGA_BYTES_PER_CHAR);
    memset(&buffer[end], 0, VGA_WIDTH * VGA_BYTES_PER_CHAR);

    // clear last line
    for (size_t i = end; i < VGA_SIZE; i++) {
        put_raw(&buffer[i], BG_DEFAULT, FG_DEFAULT, 0);
    }
}

inline
static size_t offset() {
    return column + row * VGA_WIDTH;
}

static void next_line() {
    ++row;
    if (row == VGA_HEIGHT) {
        scroll();
        row = VGA_HEIGHT - 1;
    }
}

static void prev_line() {
    --row;
    if (row == -1) {
        row = VGA_HEIGHT - 1;
    }
}

static void next_char() {
    ++column;
    if (column == VGA_WIDTH) {
        column = 0;
        next_line();
    }
}

static void prev_char() {
    --column;
    if (column == -1) {
        column = VGA_WIDTH - 1;
        prev_line();
    }
}

inline
static void carret() {
    column = 0;
}

inline
static void linefeed() {
    next_line();
}

void init_vga() {
    vga = (void*) 0xb8000;
    color_sp = 0;
    vga_setbg(BG_DEFAULT);
    vga_setfg(FG_DEFAULT);

    // enable cursor
    // copied from osdev
    outb(0x3d4, 0x0a);
    outb(0x3d5, inb(0x3d5) & 0xc0);
         
    outb(0x3d4, 0x0b);
    outb(0x3d5, (inb(0x3e0) & 0xe0) | 15);

    // reset cursor position
    outb(0x3d4, 0x0f);
    outb(0x3d5, 0);
    outb(0x3d4, 0x0e);
    outb(0x3d5, 0);

    for (size_t i = 0; i < VGA_SIZE; i++) {
        put_raw(&vga[i], BG_DEFAULT, FG_DEFAULT, 0);
        put_raw(&buffer[i], BG_DEFAULT, FG_DEFAULT, 0);
    }
}

void vga_putchar(int c) {
    switch (c) {
        case '\0':
            break;
        case '\b':
            prev_char();
            break;
        case '\n':
            linefeed();
        case '\r':
            carret();
            break;
        default:
            put_raw(&buffer[offset()], bg, fg, c);
            next_char();
    }
}

void vga_print(const char *str) {
    while (*str != 0) {
        vga_putchar(*str);
        ++str;
    }
}

void vga_write(const char *str, size_t size) {
    while (size != 0) {
        vga_putchar(*str);
        ++str;
        --size;
    }
}

void vga_cls() {
    for (size_t i = 0; i < VGA_SIZE; i++) {
        put_raw(&buffer[i], BG_DEFAULT, FG_DEFAULT, 0);
    }
}

void vga_flush() {
    memcpy((void*) vga, buffer, VGA_SIZE * VGA_BYTES_PER_CHAR);

    uint16_t pos = row * VGA_WIDTH + column;
     
    outb(0x3d4, 0x0f);
    outb(0x3d5, pos);
    outb(0x3d4, 0x0e);
    outb(0x3d5, pos >> 8);
}

int vga_push() {
    if (color_sp == COLOR_STACK_SIZE - 1) {
        return 0;
    }

    colors[color_sp++] = bg << 4 | fg;
    return 1;
}

int vga_pop() {
    if (color_sp == 0) {
        return 0;
    }

    uint8_t color = colors[--color_sp];
    bg = color >> 4;
    fg = color & 0xf;

    return 1;
}

inline
void vga_setbg(uint16_t color) {
    bg = color;
}

inline
void vga_setfg(uint16_t color) {
    fg = color;
}
