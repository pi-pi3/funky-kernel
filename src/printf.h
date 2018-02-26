
#ifndef PRINTF
# error printf.h requires the 'PRINTF' macro
#endif /* ifndef PRINTF */

#ifndef WRITE_CHAR
# error printf.h requires the 'WRITE_CHAR' macro
#endif /* ifndef WRITE_CHAR */

// formats an integer
static int fmti(
#ifdef SPRINTF
        char *str,
#endif
#ifdef NPRINTF
        size_t size,
#endif
        int fill_num,
        char fill,
        int base,
        int _signed,
        const char *const digits,
        unsigned int i) {
#ifdef NPRINTF
    if (size == 0) {
        return 0;
    }
#endif

    int idx = 0;
    int n = 0;
    int sign = 0;
    char buf[TMP_BUF_MAX];

    if (_signed && ((int) i) < 0) {
        sign = 1;
        i = -i;
    }

    do {
        int digit = i % base;
        i = i / base;
        buf[idx] = digits[digit];
        ++idx;
    } while (i);

    if (fill == '0') {
        if (
                sign
#ifdef NPRINTF
                && size > 0
#endif
                ) {
            WRITE_CHAR('-');
#ifdef SPRINTF
            ++str;
#endif
#ifdef NPRINTF
            --size;
#endif
            ++n;
            --sign;
        }
    }

    // pad
    for (int c = 0; c < (fill_num - idx - sign); c++) {
#ifdef NPRINTF
        if (!size) {
            break;
        }
#endif

        WRITE_CHAR(fill);
#ifdef SPRINTF
        ++str;
#endif
#ifdef NPRINTF
        --size;
#endif
        ++n;
    }

    if (
                sign
#ifdef NPRINTF
                && size > 0
#endif
) {
        WRITE_CHAR('-');
#ifdef SPRINTF
        ++str;
#endif
#ifdef NPRINTF
        --size;
#endif
        ++n;
    }

    while ( 
            idx--
#ifdef NPRINTF
            && size--
#endif
            ) {
        WRITE_CHAR(buf[idx]);
#ifdef SPRINTF
        ++str;
#endif
#ifdef NPRINTF
        --size;
#endif
        ++n;
    }

    return n;
}

int PRINTF(
#ifdef SPRINTF
        char *str,
#endif /* ifdef SPRINTF */
#ifdef NPRINTF
        size_t size,
#endif /* ifdef NPRINTF */
        const char *format,
        ...) {
#define ARG(type, name) \
    type name = * (type *) args; \
    args += 4; \

#ifdef NPRINTF
    if (size == 0) {
        return 0;
    }
    --size; // we need to add a trailing \0
#endif

#ifdef PRINTF_PRELUDE
    PRINTF_PRELUDE;
#endif

    void *args = (void*) &format + 4;

    int n = 0;
    char fch;
    int fmt = 0;

    const char *digits = digits0;
    int length = 32; // bits(dword)
    int base = 10;
    int _signed = 1;
    int fill_num = 0;
    char fill = ' ';

    while ((fch = *format)) {
#ifdef NPRINTF
        if (!size) {
            break;
        }
#endif

        if (fmt) {
            if (fch >= '0' && fch <= '9') {
                if (fch == '0' && fill_num == 0) {
                    fill = '0';
                } else {
                    fill_num = fill_num * 10 + (fch - '0');
                }
            } else if (fch == '%') {
                WRITE_CHAR('%');
#ifdef SPRINTF
                ++str;
#endif
#ifdef NPRINTF
                --size;
#endif
                ++n;
                fmt = 0;
            } else if (fch == 's') {
                ARG(char*, string);
                char ch;
                while ((ch = *string)) {
#ifdef NPRINTF
                    if (!size) {
                        break;
                    }
#endif

                    WRITE_CHAR(ch);
#ifdef SPRINTF
                    ++str;
#endif
#ifdef NPRINTF
                    --size;
#endif
                    ++n;
                    ++string;
                }
                fmt = 0;
            } else if (fch == 'c') {
                ARG(char, ch);
                WRITE_CHAR(ch);
#ifdef SPRINTF
                ++str;
#endif
#ifdef NPRINTF
                --size;
#endif
                ++n;
                fmt = 0;
            } else if (fch == 'u') {
                _signed = 0;
                digits = digits0;
                base = 8;
            } else if (fch == 'o') {
                _signed = 0;
                digits = digits0;
                base = 8;
            } else if ((fch == 'd') || (fch == 'i')) {
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

            if ((fch == 'u') || (fch == 'o') || (fch == 'd') || (fch == 'i') || (fch == 'x') || (fch == 'X')) {
                ARG(int, i);
                // i = i & ((1 << length) - 1); TODO: length
                int n_ = fmti(
#ifdef SPRINTF
                        str,
#endif
#ifdef NPRINTF
                        size,
#endif
                        fill_num, fill, base, _signed, digits, i);
                n += n_;
#ifdef SPRINTF
                str += n_;
#endif
#ifdef NPRINTF
                size -= n_;
#endif
                fmt = 0;
            }
        } else {
            if (fch == '%') {
                fmt = 1;
            } else {
                WRITE_CHAR(fch);
#ifdef SPRINTF
                ++str;
#endif
#ifdef NPRINTF
                --size;
#endif
                ++n;
            }
        }

        ++format;
    }

    WRITE_CHAR(0);
    ++n;

    return n;
}

#undef ARG
#undef WRITE_CHAR
#undef NPRINTF
#undef SPRINTF
#undef PRINTF
