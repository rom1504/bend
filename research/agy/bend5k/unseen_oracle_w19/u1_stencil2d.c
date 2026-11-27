#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(void) {
    float *src = (float *)calloc(4096, sizeof(float));
    float *dst = (float *)calloc(4096, sizeof(float));
    for (uint32_t i = 0; i < 4096; i++) {
        uint32_t x = i & 63u;
        uint32_t y = i >> 6;
        if (x > 0 && x < 63 && y > 0 && y < 63) {
            uint32_t q = prng(i * 2654435761u + 17u) & 1023u;
            src[i] = (float)q / 1024.0f;
        } else {
            src[i] = 0.0f;
        }
    }
    for (uint32_t s = 0; s < 4000; s++) {
        for (uint32_t y = 1; y < 63; y++) {
            uint32_t base = y * 64u;
            for (uint32_t x = 1; x < 63; x++) {
                uint32_t i = base + x;
                float c = src[i];
                float l = src[i - 1];
                float ri = src[i + 1];
                float u = src[i - 64];
                float d = src[i + 64];
                dst[i] = (0.5f * c) + (0.125f * ((l + ri) + (u + d)));
            }
        }
        float *tmp = src;
        src = dst;
        dst = tmp;
    }
    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < 4096; i++) {
        uint32_t q = (uint32_t)(src[i] * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(src);
    free(dst);
    return 0;
}
