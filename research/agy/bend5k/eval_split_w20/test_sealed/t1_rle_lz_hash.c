#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t N = skew ? 32768u : 16384u;
    uint32_t STEPS = N - 2u;
    uint32_t ROUNDS = skew ? 130u : 260u;
    uint32_t HT_SIZE = 4096u;

    uint32_t *src = (uint32_t *)malloc(N * sizeof(uint32_t));
    uint32_t *ht = (uint32_t *)calloc(HT_SIZE, sizeof(uint32_t));

    for (uint32_t i = 0; i < N; i++) {
        uint32_t r = prng((i + 1u) * 2654435761u + (skew ? 73u : 19u));
        if (skew) {
            /* High repetition with RLE-like runs */
            src[i] = ((i >> 2) ^ r) & 7u;
        } else {
            src[i] = r & 63u;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t r = 0; r < ROUNDS; r++) {
        uint32_t salt = r * 16777619u;
        for (uint32_t i = 0; i < STEPS; i++) {
            uint32_t s0 = src[i];
            uint32_t s1 = src[i + 1u];
            uint32_t s2 = src[i + 2u];
            uint32_t hv = (((s0 * 2654435761u) ^ (s1 * 2246822519u) ^ (s2 * 3266489917u)) >> 20) & 4095u;
            uint32_t prev = ht[hv];
            ht[hv] = i;
            uint32_t sp = src[prev];
            if (sp == s0) {
                uint32_t dist = i - prev;
                h = ((h ^ (dist + 1u)) * 16777619u) ^ (s1 + salt);
            } else {
                h = (h ^ (s0 + 17u)) * 16777619u;
            }
        }
    }
    printf("%u\n", h);
    free(src);
    free(ht);
    return 0;
}
