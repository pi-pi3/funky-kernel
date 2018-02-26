
#include "alloc.h"
#include "string.h"

#define HOLE_MIN_SIZE (2*sizeof(size_t))

typedef struct hole_s hole_t;

struct hole_s {
    size_t size;
    hole_t *next;
};

typedef struct heap_s {
    size_t addr;
    size_t size;
    hole_t hole;
} heap_t;

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

static size_t align_down(const size_t n, const size_t align);
static size_t align_up(const size_t n, const size_t align);
static int hole_merge(hole_t *hole);

void heap_init(heap_t *heap, size_t addr, size_t size) {
    heap->addr = addr;
    heap->size = size;
    heap->hole.size = 0;
    heap->hole.next = (void *) addr;
    heap->hole.next->size = size;
    heap->hole.next->next = NULL;
}

// TODO: align
void *heap_alloc(heap_t *heap, size_t *size_ptr, size_t align) {
    void *ptr = NULL;
    size_t size = *size_ptr;
    size = align_up(size, align);

    hole_t *prev = &heap->hole;
    hole_t *hole;
    for (hole = heap->hole.next; hole != NULL; hole = hole->next) {
        if ((hole->size >= size &&
            (hole->size - size) < HOLE_MIN_SIZE)) {
            // allocate entire hole
            prev->next = hole->next;
            ptr = hole;
            size = hole->size;
            break;
        } else if (hole->size > size) {
            // split hole
            hole_t new;
            new.size = hole->size - size;
            new.next = hole->next;
            prev->next = hole + size;
            *prev->next = new;
            ptr = hole;
            break;
        } // else: the hole is not big enough

        prev = hole;
    }

    *size_ptr = size;
    return ptr;
}

void heap_dealloc(heap_t *heap, void *ptr, size_t size) {
    if (ptr == NULL) {
        return;
    }

    hole_t *hole;
    for (hole = &heap->hole; hole != NULL; hole = hole->next) {
        if (hole->next == NULL) {
            // it's somewhere at the end
            hole->next = ptr;
            hole->next->size = size;
            hole->next->next = NULL;
            hole_merge(hole);
            hole = hole->next;
            break;
        } else if ((size_t) hole->next > (size_t) ptr) {
            // found it
            hole_t *old = hole->next;
            hole->next = ptr;
            hole->next->size = size;
            hole->next->next = old;
            hole_merge(hole); // merge this hole with the newly created
            hole = hole->next;
            break;
        }
    }

    hole_merge(hole); // merge the newly created hole with the next hole
}

static size_t align_down(const size_t n, const size_t align) {
    return n & ~(align - 1);
}

static size_t align_up(const size_t n, const size_t align) {
    return align_down(n + align - 1, align);
}

static int hole_merge(hole_t *hole) {
    if (!hole || !hole->next) {
        return 0;
    }

    size_t diff = (size_t) hole->next - (size_t) hole;
    if (diff - hole->size < HOLE_MIN_SIZE) {
        // the difference between this and the next hole is too small for
        // anything to be there
        size_t size = hole->next->size + diff;
        hole_t *next = hole->next->next;

        hole->size = size;
        hole->next = next;

        return 1;
    }

    return 0;
}
