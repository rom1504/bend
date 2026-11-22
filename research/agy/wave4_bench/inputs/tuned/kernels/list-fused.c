#include <stdint.h>

static uint32_t fold(uint32_t n, uint32_t seed, uint32_t total) {
    for (uint32_t i = 0; i < n; ++i) {
        uint32_t value = seed & 15u;
        if (value > 1) total += value * 2;
        seed = seed * 1664525u + 1013904223u;
    }
    return total;
}

uint32_t bench_u32(uint32_t n, uint32_t seed) {
    return fold(n, seed, 0);
}
