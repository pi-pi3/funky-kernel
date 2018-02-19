
#include <stddef.h>

#include "string.h"
#include "vga.h"

extern const char *const digits0;
extern const char *const digits1;

#define PRINTF errprintf
#define SPRINTF
#define NPRINTF
#define WRITE_CHAR(ch) \
    *str = 0x04; \
    str++; \
    *str = ch;
#define TMP_BUF_MAX 256
#include "printf.h"
