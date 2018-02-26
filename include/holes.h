#ifndef HOLES_H
#define HOLES_H 1

#include <stddef.h>

#define HOLE_MIN_SIZE (2*sizeof(size_t))

typedef struct hole_s hole_t;
typedef struct hole_s hole_list;

struct hole_s {
    size_t size;
    hole_t *next;
};

void holes_init(hole_list *holes, size_t addr, size_t size);
void *hole_alloc(hole_list *holes, size_t *size_ptr, size_t align);
void hole_dealloc(hole_list *holes, void *ptr, size_t size);

#endif /* ifndef HOLES_H */
