#include "base.h"

typedef struct Record { TMStr *key, *amount; struct Record *next; } Record;

static Record *records(uint32_t size, uint32_t seed) {
    Record *result = NULL, **tail = &result;
    uint32_t i = 0;
    for (uint32_t n = size; n; --n, ++i) {
        Record *r = tm_alloc(sizeof *r);
        r->key = tm_append(tm_utf8("部門"), tm_show((i + seed) % 16));
        r->amount = tm_show((i * UINT32_C(37) + seed) % 1000);
        r->next = NULL; *tail = r; tail = &r->next;
    }
    return result;
}

static TMStr *render(TMEntry *entries) {
    if (!entries) return NULL;
    TMStr *key = entries->key;
    uint32_t value = entries->value;
    TMEntry *next = entries->next; free(entries);
    TMStr *rest = render(next);
    return tm_append(key, tm_append(tm_utf8("="),
        tm_append(tm_show(value), tm_append(tm_utf8(";"), rest))));
}

char *bench_text(uint32_t size, uint32_t seed) {
    /* Materialize all textual records before the separate parse/aggregate pass. */
    Record *rows = records(size, seed);
    TMMap *map = NULL;
    while (rows) {
        Record *next = rows->next;
        uint32_t old = tm_get(map, rows->key, 0);
        TMMaybe amount = tm_read(rows->amount);
        map = tm_set(map, rows->key, old + (amount.found ? amount.value : 0));
        tm_free(rows->amount); free(rows); rows = next;
    }
    TMStr *text = render(tm_to_list_go(map, NULL));
    char *result = tm_encode(text); tm_free(text); return result;
}
