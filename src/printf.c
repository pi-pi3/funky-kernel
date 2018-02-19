
#include <stddef.h>

#include "string.h"
#include "vga.h"

extern const char *const digits0;
extern const char *const digits1;

#define PRINTF printf
#define WRITE_CHAR(ch) vga_putchar(ch)
#define TMP_BUF_MAX 256
#include "printf.h"
