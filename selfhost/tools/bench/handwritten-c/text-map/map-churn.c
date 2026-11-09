#include "base.h"

static TMStr *key(uint32_t i) { return tm_append(tm_utf8("key"), tm_show(i)); }

uint32_t bench_u32(uint32_t size, uint32_t seed) {
    TMMap *map = NULL;
    uint32_t i = 0;
    for (uint32_t n = size; n; --n, ++i)
        map = tm_set(map, key(i), seed + i * UINT32_C(17));
    i = 0;
    for (uint32_t n = (size + UINT32_C(2)) / 3; n; --n, i += 3)
        map = tm_set(map, key(i), seed ^ (i * UINT32_C(31)));
    i = 0;
    for (uint32_t n = (size + UINT32_C(3)) / 4; n; --n, i += 4) {
        TMStr *k = key(i); map = tm_del(map, k); tm_free(k);
    }
    TMEntry *entries = tm_to_list_go(map, NULL);
    uint32_t digest = UINT32_C(2166136261);
    while (entries) {
        TMEntry *next = entries->next;
        for (const TMStr *p = entries->key; p; p = p->next)
            digest = digest * UINT32_C(31) + p->chr;
        digest = (digest * UINT32_C(16777619)) ^ entries->value;
        tm_free(entries->key); free(entries); entries = next;
    }
    return digest;
}
