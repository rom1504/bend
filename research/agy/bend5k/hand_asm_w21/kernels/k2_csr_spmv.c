#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(void) {
    const uint32_t ROWS = 4096u;
    const uint32_t EDGES = 32768u;
    const uint32_t ROUNDS = 160u;

    uint32_t *row_ptr = (uint32_t *)malloc(ROWS * sizeof(uint32_t));
    uint32_t *col_idx = (uint32_t *)malloc(EDGES * sizeof(uint32_t));
    uint32_t *vals = (uint32_t *)malloc(EDGES * sizeof(uint32_t));
    uint32_t *x = (uint32_t *)malloc(ROWS * sizeof(uint32_t));

    uint32_t off = 0u;
    for (uint32_t i = 0; i < ROWS; i++) {
        row_ptr[i] = off;
        uint32_t deg = 4u + (prng((i + 1u) * 2654435761u + 17u) & 7u);
        off += deg;
    }
    for (uint32_t i = 0; i < EDGES; i++) {
        col_idx[i] = prng((i + 1u) * 2246822519u + 31u) & 4095u;
        vals[i] = 1u + (prng((i + 1u) * 3266489917u + 47u) & 255u);
    }
    for (uint32_t i = 0; i < ROWS; i++) {
        x[i] = prng((i + 1u) * 668265263u + 59u) & 65535u;
    }

    uint32_t h = 2166136261u;
    for (uint32_t r = 0; r < ROUNDS; r++) {
        uint32_t salt = r * 2654435761u;
        for (uint32_t row = 0; row < ROWS - 1u; row++) {
            uint32_t start = row_ptr[row];
            uint32_t end = row_ptr[row + 1u];
            uint32_t sum = salt;
            for (uint32_t e = start; e < end; e++) {
                uint32_t ei = e & 32767u;
                sum += vals[ei] * x[col_idx[ei]];
            }
            h = (h ^ sum) * 16777619u;
        }
    }
    printf("%u\n", h);
    free(row_ptr);
    free(col_idx);
    free(vals);
    free(x);
    return 0;
}
