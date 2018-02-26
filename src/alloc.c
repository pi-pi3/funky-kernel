
#include "alloc.h"
#include "holes.h"
#include "string.h"

struct heap_s {
    size_t addr;
    size_t size;
    hole_list holes;
};

static heap_t heap = {0};

void *malloc(size_t size) {
    if (size == 0) {
        return NULL;
    }

    size += sizeof(size_t);
    void *ptr = heap_alloc(&heap, &size, 0);

    if (ptr != NULL) {
        *((size_t*) ptr) = size;
        ptr += sizeof(size_t);
    }

    return ptr;
}

void free(void *ptr) {
    size_t size;
    if (ptr != NULL) {
        ptr -= sizeof(size_t);
        size = *((size_t*) ptr);
    }

    heap_dealloc(&heap, ptr, size);
}

void *calloc(size_t nmemb, size_t size) {
    void *ptr = malloc(nmemb * size);
    if (ptr != NULL) {
        memset(ptr, 0, nmemb * size);
    }

    return ptr;
}

void *realloc(void *ptr, size_t size) {
    free(ptr);
    return malloc(size);
}

void heap_init(heap_t *heap, size_t addr, size_t size) {
    heap->addr = addr;
    heap->size = size;
    holes_init(&heap->holes, addr, size);
}

// TODO: align
void *heap_alloc(heap_t *heap, size_t *size_ptr, size_t align) {
    return hole_alloc(&heap->holes, size_ptr, align);
}

void heap_dealloc(heap_t *heap, void *ptr, size_t size) {
    hole_dealloc(&heap->holes, ptr, size);
}
