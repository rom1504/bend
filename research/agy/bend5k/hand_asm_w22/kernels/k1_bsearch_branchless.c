#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(void) {
    const uint32_t N = 16384u;
    uint32_t *arr = (uint32_t *)malloc(N * sizeof(uint32_t));
    uint32_t seed = 2463534242u;
    uint32_t prev = 0u;
    for (uint32_t i = 0; i < N; i++) {
        seed = prng(seed);
        prev += 1u + (seed & 15u);
        arr[i] = prev;
    }

    uint32_t acc = 2166136261u;
    const uint32_t mask = 131071u;
    for (uint32_t q = 0; q < 1000000u; q++) {
        seed = prng(seed);
        uint32_t key = seed & mask;
        uint32_t lo = 0u;
        for (uint32_t step = 8192u; step > 0u; step >>= 1) {
            uint32_t cand = lo + step;
            if (arr[cand] <= key) {
                lo = cand;
            }
        }
        uint32_t v = arr[lo];
        acc = (acc * 16777619u) ^ (lo ^ v);
    }

    printf("%u\n", acc);
    free(arr);
    return 0;
}
