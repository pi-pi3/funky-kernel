#ifndef STRING_H
#define STRING_H 1

void* memcpy(void* dst, const void* src, size_t num);
void* memmove(void* dst, const void* src, size_t num);
void* memset(void* dst, int value, size_t num);
int memcmp(const void* ptr1, const void* ptr2, size_t num);

int snprintf(char *str, size_t size, const char *format, ...);

#endif /* ifndef STRING_H */
