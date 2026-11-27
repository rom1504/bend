#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t rotl32(uint32_t x, uint32_t n) {
    return (x << n) | (x >> (32u - n));
}

static inline void qr(uint32_t *a, uint32_t *b, uint32_t *c, uint32_t *d) {
    *a += *b; *d = rotl32(*d ^ *a, 16u);
    *c += *d; *b = rotl32(*b ^ *c, 12u);
    *a += *b; *d = rotl32(*d ^ *a, 8u);
    *c += *d; *b = rotl32(*b ^ *c, 7u);
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t BLOCKS = large ? 96000u : 48000u;

    uint32_t k0 = 0x03020100u, k1 = 0x07060504u, k2 = 0x0b0a0908u, k3 = 0x0f0e0d0cu;
    uint32_t k4 = 0x13121110u, k5 = 0x17161514u, k6 = 0x1b1a1918u, k7 = 0x1f1e1d1cu;
    uint32_t n0 = 0x09000000u, n1 = 0x4a000000u, n2 = 0x00000000u;
    uint32_t h = 2166136261u;

    for (uint32_t ctr = 0; ctr < BLOCKS; ctr++) {
        uint32_t o0 = 0x61707865u, o1 = 0x3320646eu, o2 = 0x79622d32u, o3 = 0x6b206574u;
        uint32_t o4 = k0, o5 = k1, o6 = k2, o7 = k3;
        uint32_t o8 = k4, o9 = k5, o10 = k6, o11 = k7;
        uint32_t o12 = ctr, o13 = n0, o14 = n1, o15 = n2;

        uint32_t x0 = o0, x1 = o1, x2 = o2, x3 = o3;
        uint32_t x4 = o4, x5 = o5, x6 = o6, x7 = o7;
        uint32_t x8 = o8, x9 = o9, x10 = o10, x11 = o11;
        uint32_t x12 = o12, x13 = o13, x14 = o14, x15 = o15;

        for (uint32_t dr = 0; dr < 10u; dr++) {
            qr(&x0, &x4, &x8, &x12);
            qr(&x1, &x5, &x9, &x13);
            qr(&x2, &x6, &x10, &x14);
            qr(&x3, &x7, &x11, &x15);

            qr(&x0, &x5, &x10, &x15);
            qr(&x1, &x6, &x11, &x12);
            qr(&x2, &x7, &x8, &x13);
            qr(&x3, &x4, &x9, &x14);
        }

        uint32_t w0 = x0 + o0, w1 = x1 + o1, w2 = x2 + o2, w3 = x3 + o3;
        uint32_t w4 = x4 + o4, w5 = x5 + o5, w6 = x6 + o6, w7 = x7 + o7;
        uint32_t w8 = x8 + o8, w9 = x9 + o9, w10 = x10 + o10, w11 = x11 + o11;
        uint32_t w12 = x12 + o12, w13 = x13 + o13, w14 = x14 + o14, w15 = x15 + o15;

        uint32_t fold = (w0 ^ w1 ^ w2 ^ w3) + (w4 ^ w5 ^ w6 ^ w7) + (w8 ^ w9 ^ w10 ^ w11) + (w12 ^ w13 ^ w14 ^ w15);
        h = (h * 16777619u) ^ fold;

        if (large) {
            k0 ^= w0;
            k4 ^= w8;
            n2 ^= w15;
        }
    }

    printf("%u\n", h);
    return 0;
}
