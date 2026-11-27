#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const uint32_t B64_LUT[64] = {
    65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
    81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,
    103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,
    119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47
};

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static inline uint32_t fold_ch(uint32_t h, uint32_t c) {
    return (h ^ c) * 16777619u;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t N = large ? 65536u : 16384u;
    uint32_t GROUPS = large ? 21845u : 5461u; /* floor(N / 3) */
    uint32_t ROUNDS = large ? 55u : 220u;

    uint32_t *buf = (uint32_t *)malloc(N * sizeof(uint32_t));
    for (uint32_t i = 0; i < N; i++) {
        uint32_t r = prng((i + 1u) * 2654435761u + (large ? 99u : 37u));
        if (large) {
            buf[i] = 32u + (r & 95u); /* ASCII-heavy */
        } else {
            buf[i] = r & 255u;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t r = 0; r < ROUNDS; r++) {
        uint32_t salt = r & 255u;
        for (uint32_t g = 0; g < GROUPS; g++) {
            uint32_t idx = g * 3u;
            uint32_t b0 = (buf[idx] ^ salt) & 255u;
            uint32_t b1 = buf[idx + 1u];
            uint32_t b2 = buf[idx + 2u];
            uint32_t w = (b0 << 16) | (b1 << 8) | b2;
            uint32_t c0 = B64_LUT[(w >> 18) & 63u];
            uint32_t c1 = B64_LUT[(w >> 12) & 63u];
            uint32_t c2 = B64_LUT[(w >> 6) & 63u];
            uint32_t c3 = B64_LUT[w & 63u];
            h = fold_ch(fold_ch(fold_ch(fold_ch(h, c0), c1), c2), c3);
        }
    }
    printf("%u\n", h);
    free(buf);
    return 0;
}
