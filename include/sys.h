#ifndef SYS_H
#define SYS_H 1

#include <stdint.h>

void outb(uint16_t port, uint8_t value);
void outw(uint16_t port, uint16_t value);
void outd(uint16_t port, uint32_t value);

uint8_t inb(uint16_t port);
uint16_t inw(uint16_t port);
uint32_t ind(uint16_t port);

void outsb(uint16_t port, const void *src, size_t num);
void outsw(uint16_t port, const void *src, size_t num);
void outsd(uint16_t port, const void *src, size_t num);

void insb(void *dst, uint16_t port, size_t num);
void insw(void *dst, uint16_t port, size_t num);
void insd(void *dst, uint16_t port, size_t num);

#endif /* ifndef SYS_H */
