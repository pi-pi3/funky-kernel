
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#include "multiboot2.h"
#include "vga.h"

#define TRY_INIT(msg, expr) \
    log_info(msg); \
    if ((err = (expr))) { \
        log_err(err_msg[err & 0xff]); \
        abort(); \
    } else { \
        log_ok("[OK]\n"); \
    }
/* errors that may occur while initializing the kernel */
#define ERR_INVALID_MBI_MAGIC 1
#define ERR_UNALIGNED_MBI 2

static char *err_msg[] = {
    "no error\n",
    "invalid mbi magic\n",
    "unaligned mbi\n",
[255] =
    "explicit panic\n",
};

// a simple stack smashing guard copied from osdev
#ifdef __funky_x86
#define STACK_CHK_GUARD 0xe2dee396
#else
#define STACK_CHK_GUARD 0x595e9fbd94fda766
#endif

static volatile uintptr_t __stack_chk_guard = STACK_CHK_GUARD;
void __stack_chk_fail(); 

void log_ok(const char *msg);
void log_info(const char *msg);
void log_err(const char *msg);
int init_mbi(uint32_t magic, size_t mbi_addr);
void halt();
void abort();

void kmain(uint32_t magic, size_t mbi_addr) {
    int err = 0;

    init_vga();
    TRY_INIT("vga driver initializing... ", 0);
    TRY_INIT("mbi loading... ", init_mbi(magic, mbi_addr));

    halt();
}

int init_mbi(uint32_t magic, size_t mbi_addr) {
    if (magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        return ERR_INVALID_MBI_MAGIC;
    }

    if (mbi_addr & (MULTIBOOT_INFO_ALIGN - 1)) {
        return ERR_UNALIGNED_MBI;
    }

    struct multiboot_tag *tag = (void *) (mbi_addr + 8);
    while (tag->type != MULTIBOOT_TAG_TYPE_END) {
        // we don't actually do anything with the multiboot tags
        // but if we did, the code would go here:
        /* ... */

        size_t padded_size = ((tag->size + 7) & ~7);
        tag = (void *) ((void *) tag + padded_size);
    }

    return 0;
}

__attribute__((__noreturn__))
void halt() {
    __asm__ __volatile__ (
        "       cli\n"
        ".hlt:  hlt\n"
        "       jmp .hlt\n"
    );
    __builtin_unreachable();
}

__attribute__((__noreturn__))
void abort() {
    vga_setfg(RED);
    vga_print("kernel panic: abort()\n");
    vga_flush();
    halt();
}

__attribute__((__noreturn__))
void __stack_chk_fail() {
    vga_setfg(RED);
    log_err("kernel panic: stack smashed\n");
    vga_flush();
    halt();
}

void log_ok(const char *msg) {
    vga_push();
    vga_setfg(GREEN);
    vga_print(msg);
    vga_flush();
    vga_pop();
}

void log_info(const char *msg) {
    vga_push();
    vga_setfg(LIGHT_GRAY);
    vga_print(msg);
    vga_flush();
    vga_pop();
}

void log_err(const char *msg) {
    vga_push();
    vga_setfg(RED);
    vga_print(msg);
    vga_flush();
    vga_pop();
}
