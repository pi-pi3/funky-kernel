
#include "holes.h"

static size_t align_down(const size_t n, const size_t align);
static size_t align_up(const size_t n, const size_t align);
static int hole_merge(hole_t *hole);

void holes_init(hole_list *holes, size_t addr, size_t size) {
    holes->size = 0;
    holes->next = (void *) addr;
    holes->next->size = size;
    holes->next->next = NULL;
}

// TODO: align
void *hole_alloc(hole_list *holes, size_t *size_ptr, size_t align) {
    void *ptr = NULL;
    size_t size = *size_ptr;
    size = align_up(size, align);

    hole_t *prev = holes;
    hole_t *hole = hole->next;
    for (; hole != NULL; hole = hole->next) {
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

void hole_dealloc(hole_list *holes, void *ptr, size_t size) {
    if (ptr == NULL) {
        return;
    }

    hole_t *hole = holes;
    for (hole = holes; hole != NULL; hole = hole->next) {
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
