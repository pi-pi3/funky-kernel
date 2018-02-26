#ifndef ALLOC_H
#define ALLOC_H 1

#include <stddef.h>

typedef struct heap_s heap_t;

void *malloc(size_t size);
void free(void *ptr);
void *calloc(size_t nmemb, size_t size);
void *realloc(void *ptr, size_t size);

void heap_init(heap_t *heap, size_t addr, size_t size);
void *heap_alloc(heap_t *heap, size_t *size_ptr, size_t align);
void heap_dealloc(heap_t *heap, void *ptr, size_t size);

#endif /* ifndef ALLOC_H */
