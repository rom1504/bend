#include "base.h"

static TMMap *m3(void) {
    return tm_from_list(tm_entry(tm_utf8("apple"), 1,
        tm_entry(tm_utf8("app"), 2, tm_entry(tm_utf8("banana"), 3, NULL))), NULL);
}
static uint32_t get(const TMMap *map, const char *key, uint32_t fallback) {
    TMStr *k = tm_utf8(key); uint32_t value = tm_get(map, k, fallback); tm_free(k); return value;
}
static bool has(const TMMap *map, const char *key) {
    TMStr *k = tm_utf8(key); bool value = tm_lookup(map, k).found; tm_free(k); return value;
}
static TMMap *pop(TMMap *map, const char *key, TMMaybe *value) {
    TMStr *k = tm_utf8(key); map = tm_pop(map, k, value); tm_free(k); return map;
}
static TMStr *join_keys(TMMap *map) {
    TMStr *comma = tm_utf8(","); TMStr *r = tm_join(tm_keys_go(map, NULL), comma); tm_free(comma); return r;
}
static uint32_t check_get(void) {
    TMMap *map = m3(); uint32_t a = get(map, "apple", 0), b = get(map, "app", 0);
    uint32_t c = get(map, "nope", 99); bool hb = has(map, "banana"); tm_map_free(map);
    return (uint32_t)(a == 1) * (uint32_t)(b == 2) * (uint32_t)(c == 99) * (uint32_t)hb;
}
static uint32_t check_del(void) {
    TMMap *map = m3(); TMMaybe ignored, first, second;
    map = pop(map, "app", &ignored); bool present = has(map, "app");
    uint32_t apple = get(map, "apple", 0);
    map = pop(map, "banana", &first); map = pop(map, "banana", &second); tm_map_free(map);
    return (uint32_t)!present * (uint32_t)(apple == 1) * (uint32_t)(first.found && first.value == 3) * (uint32_t)!second.found;
}
static uint32_t check_union(void) {
    TMMap *left = tm_from_list(tm_entry(tm_utf8("a"), 1, tm_entry(tm_utf8("b"), 2, NULL)), NULL);
    TMMap *right = tm_from_list(tm_entry(tm_utf8("b"), 20, tm_entry(tm_utf8("c"), 30, NULL)), NULL);
    TMMap *map = tm_union(left, right);
    uint32_t x = get(map, "a", 0), y = get(map, "b", 0), z = get(map, "c", 0);
    tm_map_free(map); return (uint32_t)(x == 1) * (uint32_t)(y == 20) * (uint32_t)(z == 30);
}
static uint32_t check_order(void) {
    TMStr *keys = join_keys(m3()); bool order = tm_equals_utf8(keys, "app,apple,banana"); tm_free(keys);
    TMWords *values = tm_values_go(m3(), NULL); uint32_t digits = 0;
    while (values) { TMWords *next = values->next; digits = digits * 10 + values->value; free(values); values = next; }
    return (uint32_t)order * (uint32_t)(digits == 213);
}
static uint32_t check_set(void) {
    TMMap *set = tm_set(tm_set(tm_set(NULL, tm_utf8("x"), 0), tm_utf8("y"), 0), tm_utf8("x"), 0);
    bool hx = has(set, "x"), hz = has(set, "z");
    TMStr *keys = join_keys(set);
    TMMap *next = tm_set(tm_set(NULL, tm_utf8("x"), 0), tm_utf8("y"), 0);
    TMMaybe ignored; next = pop(next, "y", &ignored);
    bool hy = has(next, "y"), hx2 = has(next, "x"), ordered = tm_equals_utf8(keys, "x,y");
    tm_free(keys); tm_map_free(next);
    return (uint32_t)hx * (uint32_t)!hz * (uint32_t)ordered * (uint32_t)!hy * (uint32_t)hx2;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    (void)a; (void)b;
    uint32_t get_check = check_get(), del_check = check_del(), union_check = check_union();
    uint32_t order_check = check_order(), set_check = check_set();
    return get_check * 10000 + del_check * 1000 + union_check * 100 + order_check * 10 + set_check;
}
