#ifndef MEM_H
#define MEM_H 1

#include <stddef.h>

typedef size_t page_t;
typedef size_t frame_t;

int init_mem(frame_t frame_start, frame_t frame_end, size_t heap_start, size_t heap_end);
void map_page(frame_t frame, page_t page);

void init_frames(frame_t frame_start, frame_t frame_end);
frame_t next_frame_create();

page_t page_with_addr(size_t addr);
size_t addr_at_page(page_t page);

size_t align_down(const size_t n, const size_t align);
size_t align_up(const size_t n, const size_t align);

#endif /* ifndef MEM_H */
