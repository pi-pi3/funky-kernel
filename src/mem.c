
#include "alloc.h"
#include "holes.h"
#include "mem.h"

extern heap_t heap;

// TODO: frames

int init_mem(frame_t frame_start, frame_t frame_end, size_t heap_start, size_t heap_end) {
    init_frames(frame_start, frame_end);

    page_t page_start = page_with_addr(heap_start);
    page_t page_end = page_with_addr(heap_end);

    for (page_t page = page_start; page < page_end; page++) {
        map_page(next_frame_create(), page);
    }

    heap_init(&heap, heap_start, heap_end);

    return 0;
}

void map_page(frame_t frame, page_t page) {
    /* TODO */
}

size_t page_with_addr(size_t addr) {
    return addr >> 12;
}

size_t addr_at_page(size_t page) {
    return page << 12;
}

size_t align_down(const size_t n, const size_t align) {
    return n & ~(align - 1);
}

size_t align_up(const size_t n, const size_t align) {
    return align_down(n + align - 1, align);
}
