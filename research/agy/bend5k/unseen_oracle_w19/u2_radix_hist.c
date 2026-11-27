#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static void radix_pass(uint32_t sh, const uint32_t * restrict src,
                       uint32_t * restrict dst, uint32_t * restrict h) {
    for (uint32_t i = 0; i < 256; i++) h[i] = 0;
    for (uint32_t i = 0; i < 65536; i++) {
        uint32_t b = (src[i] >> sh) & 255u;
        h[b]++;
    }
    uint32_t acc = 0;
    for (uint32_t i = 0; i < 256; i++) {
        uint32_t c = h[i];
        h[i] = acc;
        acc += c;
    }
    for (uint32_t i = 0; i < 65536; i++) {
        uint32_t v = src[i];
        uint32_t b = (v >> sh) & 255u;
        uint32_t pos = h[b];
        h[b] = pos + 1u;
        dst[pos] = v;
    }
}

int main(void) {
    uint32_t *src = (uint32_t *)calloc(65536, sizeof(uint32_t));
    uint32_t *dst = (uint32_t *)calloc(65536, sizeof(uint32_t));
    uint32_t *h = (uint32_t *)calloc(256, sizeof(uint32_t));
    uint32_t acc = 2166136261u;
    for (uint32_t r = 1; r <= 60; r++) {
        uint32_t salt = r * 7919u + 13u;
        for (uint32_t i = 0; i < 65536; i++) {
            src[i] = prng(((i + 1u) * 2654435761u) ^ salt) & 65535u;
        }
        radix_pass(0, src, dst, h);
        radix_pass(8, dst, src, h);
        for (uint32_t i = 0; i < 65536; i++) {
            acc = (acc * 2654435761u) ^ (src[i] + i);
        }
    }
    printf("%u\n", acc);
    free(src);
    free(dst);
    free(h);
    return 0;
}
