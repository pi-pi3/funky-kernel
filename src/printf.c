
#include <stddef.h>

#include "string.h"
#include "vga.h"

extern const char digits0[36];
extern const char digits1[36];

#define PRINTF printf
#define WRITE_CHAR(ch) vga_putchar(ch)
#define TMP_BUF_MAX 256
#include "printf.h"
