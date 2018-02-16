#ifndef VGA_H
#define VGA_H 1

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_BYTES_PER_CHAR 2
#define VGA_SIZE (VGA_WIDTH * VGA_HEIGHT)

#define BLACK           0x00
#define BLUE            0x01
#define GREEN           0x02
#define CYAN            0x03
#define RED             0x04
#define MAGENTA         0x05
#define BROWN           0x06
#define LIGHT_GRAY      0x07
#define DARK_GRAY       0x08
#define LIGHT_BLUE      0x09
#define LIGHT_GREEN     0x0a
#define LIGHT_CYAN      0x0b
#define LIGHT_RED       0x0c
#define LIGHT_MAGENTA   0x0d
#define YELLOW          0x0e
#define WHITE           0x0f
#define BG_DEFAULT      BLACK
#define FG_DEFAULT      LIGHT_GRAY

void init_vga();
void vga_putchar(int c);
void vga_print(const char *str);
void vga_write(const char *str, size_t size);
void vga_cls();
void vga_flush();
void vga_setbg(uint16_t color);
void vga_setfg(uint16_t color);
int vga_push();
int vga_pop();

#endif /* ifndef VGA_H */
