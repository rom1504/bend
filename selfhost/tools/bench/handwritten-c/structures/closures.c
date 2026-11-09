/* compose, chain and bench from native45/fixtures/coverage-closures-64.bend. */
#include <stdint.h>
#include <stdlib.h>

typedef struct Closure Closure;
struct Closure {
    uint32_t (*apply)(Closure *, uint32_t);
    union {
        uint32_t addend;
        struct { Closure *first, *second; } compose;
    } captured;
};

static Closure *allocate_closure(uint32_t (*apply)(Closure *, uint32_t)) {
    Closure *closure = malloc(sizeof *closure);
    if (closure == NULL) abort();
    closure->apply = apply;
    return closure;
}

/* Every application consumes its closure and all owned captures exactly once. */
static uint32_t apply_identity(Closure *closure, uint32_t value) {
    free(closure);
    return value;
}

static uint32_t apply_add(Closure *closure, uint32_t value) {
    uint32_t addend = closure->captured.addend;
    free(closure);
    return (uint32_t)(value + addend);
}

static uint32_t apply_compose(Closure *closure, uint32_t value) {
    Closure *first = closure->captured.compose.first;
    Closure *second = closure->captured.compose.second;
    free(closure);
    uint32_t intermediate = first->apply(first, value);
    return second->apply(second, intermediate);
}

static Closure *chain(uint32_t count) {
    if (count == 0) return allocate_closure(apply_identity);
    Closure *add = allocate_closure(apply_add);
    add->captured.addend = count;
    Closure *rest = chain(count - UINT32_C(1));
    Closure *composed = allocate_closure(apply_compose);
    composed->captured.compose.first = add;
    composed->captured.compose.second = rest;
    return composed;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    Closure *closure = chain(a);
    return closure->apply(closure, b);
}
