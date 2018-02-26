
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#include "stdlib.h"
#include "unistd.h"
#include "string.h"
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

typedef struct {
    size_t kernel_start;
    size_t kernel_end;
    size_t heap_start;
    size_t heap_end;
} kernel_info;

void log_ok(const char *msg);
void log_info(const char *msg);
void log_err(const char *msg);
int init_kernel(kernel_info *kinfo, uint32_t magic, size_t mbi_addr);
void pause();
void halt();
void abort();
void panic(unsigned int num);

__attribute__((__noreturn__))
void kmain(uint32_t magic, size_t mbi_addr, size_t kernel_start, size_t kernel_end) {
    int err = 0;
    kernel_info kinfo;
    kinfo.kernel_start = kernel_start;
    kinfo.kernel_end = kernel_end;

    init_vga();
    TRY_INIT("kernel pages initialized... ", 0);
    TRY_INIT("gdt initialized... ", 0);
    TRY_INIT("idt initialized... ", 0);
    TRY_INIT("pic initialized... ", 0);
    TRY_INIT("entering kmain... ", 0);
    TRY_INIT("vga driver initialized... ", 0);
    TRY_INIT("mbi loading... ", init_kernel(&kinfo, magic, mbi_addr));

    pause();
}

int init_kernel(kernel_info *kinfo, uint32_t magic, size_t mbi_addr) {
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

        size_t padded_size = ((tag->size + 7) & ~7);
        tag = (void *) ((void *) tag + padded_size);
    }

    return 0;
}

__attribute__((__noreturn__))
void pause() {
    __asm__ __volatile__ (
        "pause.hlt:\n"
        "   hlt\n"
        "   jmp pause.hlt\n"
    );
    __builtin_unreachable();
}

__attribute__((__noreturn__))
void halt() {
    __asm__ __volatile__ (
        "   cli\n"
        "halt.hlt:\n"
        "   hlt\n"
        "   jmp halt.hlt\n"
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

void log_ok(const char *msg) {
    vga_push();
    vga_setfg(GREEN);
    printf(msg);
    vga_flush();
    vga_pop();
}

void log_info(const char *msg) {
    vga_push();
    vga_setfg(LIGHT_GRAY);
    printf(msg);
    vga_flush();
    vga_pop();
}

void log_err(const char *msg) {
    vga_push();
    vga_setfg(RED);
    printf(msg);
    vga_flush();
    vga_pop();
}
