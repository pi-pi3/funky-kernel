
#include <stddef.h>
#include "string.h"

#define TMP_BUF_MAX 256

static char digits0[] = {
    '0', '1', '2', '3', '4',
    '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e',
    'f', 'g', 'h', 'i', 'j',
    'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't',
    'u', 'v', 'w', 'x', 'y',
    'z',
};

static char digits1[] = {
    '0', '1', '2', '3', '4',
    '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E',
    'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y',
    'Z',
};

// formats an integer
static int snfmti(
        char *str,
        size_t size,
        int fill_num,
        char fill,
        int base,
        int _signed,
        char *digits,
        unsigned int i) {
    if (size == 0) {
        return 0;
    }

    int idx = 0;
    int n = 0;
    int sign = 0;
    char buf[TMP_BUF_MAX];

    if (_signed && ((int) i) < 0) {
        sign = 1;
        i = -i;
    }

    while (i) {
        int digit = i % base;
        i = i / base;
        buf[idx] = digits[digit];
        ++idx;
    }

    if (fill == '0') {
        if (sign && size > 0) {
            *str = '-';
            ++str;
            ++n;
            --size;
            --sign;
        }
    }

    // pad
    for (int c = 0; c < (fill_num - idx - n - sign); c++) {
        if (!size) {
            break;
        }

        *str = fill;
        ++str;
        ++n;
        --size;
    }

    if (sign && size > 0) {
        *str = '-';
        ++str;
        ++n;
        --size;
    }

    while (buf[--idx] && size--) {
        *str = buf[idx];
        ++str;
        ++n;
    }

    return n;
}

int snprintf(char *str, size_t size, const char *format, ...) {
#define WRITE_CHAR(ch) \
    *str = ch; \
    ++str; \
    ++n; \
    --size;
#define ARG(type, name) \
    type name = * (type *) args; \
    args += 4; \

    void *args = (void*) &format + 4;

    if (size == 0) {
        return 0;
    }
    --size; // we need to add a trailing \0

    int n = 0;
    char fch;
    int fmt = 0;

    char *digits = NULL;
    int length = 32; // bits(dword)
    int base = 10;
    int _signed = 1;
    int fill_num = 0;
    char fill = ' ';

    while ((fch = *format)) {
        if (!size) {
            break;
        }

        if (fmt) {
            if (fch >= '0' && fch <= '9') {
                if (fch == '0' && fill_num == 0) {
                    fill = '0';
                } else {
                    fill_num = fill_num * 10 + (fch - '0');
                }
            } else if (fch == '%') {
                WRITE_CHAR('%');
                fmt = 0;
            } else if (fch == 's') {
                ARG(char*, string);
                char ch;
                while ((ch = *string)) {
                    if (!size) {
                        break;
                    }

                    WRITE_CHAR(ch);
                    ++string;
                }
                fmt = 0;
            } else if (fch == 'c') {
                ARG(char, ch);
                WRITE_CHAR(ch);
                fmt = 0;
            } else if (fch == 'u') {
                _signed = 0;
                digits = digits0;
                base = 8;
            } else if (fch == 'o') {
                _signed = 0;
                digits = digits0;
                base = 8;
            } else if ((fch == 'd') | (fch == 'i')) {
                _signed = 1;
                digits = digits0;
                base = 10;
            } else if (fch == 'x') {
                _signed = 0;
                digits = digits0;
                base = 16;
            } else if (fch == 'X') {
                _signed = 0;
                digits = digits1;
                base = 16;
            } else {
                return -fch;
            }

            if ((fch == 'u') | (fch == 'o') | (fch == 'd') | (fch == 'i') | (fch == 'x') | (fch == 'X')) {
                ARG(int, i);
                // i = i & ((1 << length) - 1); TODO: length
                int n_ = snfmti(str, size, fill_num, fill, base, _signed, digits, i);
                n += n_;
                size -= n_;
                str += n_;
                fmt = 0;
            }
        } else {
            if (fch == '%') {
                fmt = 1;
            } else {
                WRITE_CHAR(fch);
            }
        }

        ++format;
    }

    *str = 0;
    ++n;

    return n;
#undef WRITE_CHAR
}
