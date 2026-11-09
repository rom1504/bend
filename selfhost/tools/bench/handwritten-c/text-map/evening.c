#include "base.h"

typedef struct FloatArray {
    bool leaf;
    float value;
    struct FloatArray *lo, *hi;
} FloatArray;

static FloatArray *float_leaf(float value) {
    FloatArray *p = tm_alloc(sizeof *p); *p = (FloatArray){true, value, NULL, NULL}; return p;
}
static uint32_t float_size(const FloatArray *a) {
    return a->leaf ? 1 : float_size(a->lo) + float_size(a->hi);
}
static float float_swap(FloatArray *a, uint32_t index, float value) {
    uint32_t size = float_size(a); index &= size - 1;
    while (!a->leaf) {
        size >>= 1;
        if (index < size) a = a->lo;
        else { index -= size; a = a->hi; }
    }
    float previous = a->value; a->value = value; return previous;
}
static void float_free(FloatArray *a) {
    if (!a->leaf) { float_free(a->lo); float_free(a->hi); }
    free(a);
}
static uint32_t fpart(void) {
    FloatArray *array = tm_alloc(sizeof *array);
    *array = (FloatArray){false, 0, float_leaf(0.5f), float_leaf(1.5f)};
    float v0 = float_swap(array, 0, 2.0f);
    float v1 = float_swap(array, 1, 0.25f);
    float sum = v0 + v1, difference = 6.25f - 2.25f;
    uint32_t result = (uint32_t)(sum * difference); float_free(array); return result;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    (void)a; (void)b;
    TMMap *set = tm_set(tm_set(NULL, tm_show(12), 0), tm_show(3), 0);
    TMStr *twelve = tm_utf8("12"); uint32_t c0 = tm_lookup(set, twelve).found;
    tm_free(twelve); tm_map_free(set);
    TMMap *map = tm_set(NULL, tm_append(tm_utf8("k"), tm_show(7)), 70);
    TMStr *key = tm_utf8("k7"); uint32_t value = tm_get(map, key, 0);
    tm_free(key); tm_map_free(map);
    uint32_t c1 = value == 70;
    TMStr *text_u = tm_utf8("29"), *text_n = tm_utf8("13");
    TMMaybe read_u = tm_read(text_u);
    uint32_t ru = read_u.found ? read_u.value : 999;
    uint32_t rn = (uint32_t)tm_nat_read(text_n);
    tm_free(text_u); tm_free(text_n);
    uint32_t c2 = ru + rn == 42;
    struct { uint32_t first, second; } pair = {3, 4};
    uint32_t c3 = pair.first + pair.second == 7;
    return fpart() * UINT32_C(10000) + c0 * 1000 + c1 * 100 + c2 * 10 + c3;
}
