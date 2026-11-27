#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(void) {
    float *mat = (float *)malloc(262144 * sizeof(float));
    float *x = (float *)malloc(512 * sizeof(float));
    float *y = (float *)malloc(512 * sizeof(float));
    for (uint32_t i = 0; i < 262144; i++) {
        uint32_t q = prng(((i + 1u) * 2654435761u) ^ 11u) & 255u;
        mat[i] = ((float)q / 256.0f) - 0.5f;
    }
    for (uint32_t i = 0; i < 512; i++) {
        uint32_t q = prng(((i + 1u) * 2654435761u) ^ 97u) & 255u;
        x[i] = ((float)q / 256.0f) - 0.5f;
        y[i] = 0.0f;
    }
    for (uint32_t it = 0; it < 180; it++) {
        for (uint32_t r = 0; r < 512; r++) {
            float acc = 0.0f;
            const float *row = mat + (r * 512u);
            for (uint32_t c = 0; c < 512; c++) {
                acc = acc + (row[c] * x[c]);
            }
            y[r] = (acc * (1.0f / 64.0f)) + 0.125f;
        }
        float *tmp = x;
        x = y;
        y = tmp;
    }
    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < 512; i++) {
        uint32_t q = (uint32_t)((x[i] + 16.0f) * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(mat);
    free(x);
    free(y);
    return 0;
}
