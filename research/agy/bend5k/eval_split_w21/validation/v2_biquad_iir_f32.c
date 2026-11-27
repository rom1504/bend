#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t N = large ? 16384u : 4096u;
    uint32_t S = large ? 8u : 4u;
    uint32_t BLOCKS = large ? 65u : 360u;

    float *sig = (float *)malloc(N * sizeof(float));
    float *st_z1 = (float *)malloc(S * sizeof(float));
    float *st_z2 = (float *)malloc(S * sizeof(float));

    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = prng(((i + 1u) * 2654435761u) ^ 29u) & 255u;
        sig[i] = fl(q, 256u) - fl(1u, 2u);
    }
    for (uint32_t s = 0; s < S; s++) {
        st_z1[s] = 0.0f;
        st_z2[s] = 0.0f;
    }

    for (uint32_t blk = 0; blk < BLOCKS; blk++) {
        float drive = fl((blk & 7u) + 1u, 32u) - fl(1u, 8u);
        for (uint32_t s = 0; s < S; s++) {
            float b0 = fl(8u + (s & 3u), 32u);
            float b1 = fl(4u + (s & 1u), 32u);
            float b2 = fl(2u, 32u);
            float a1 = fl(s & 3u, 16u) - fl(6u, 16u);
            float a2 = fl(4u + (s & 1u), 32u);
            float z1 = st_z1[s];
            float z2 = st_z2[s];
            float add_d = (s == 0u) ? drive : 0.0f;
            for (uint32_t i = 0; i < N; i++) {
                float x = sig[i] + add_d;
                float y = b0 * x + z1;
                float nz1 = (b1 * x - a1 * y) + z2;
                float nz2 = b2 * x - a2 * y;
                sig[i] = y;
                z1 = nz1;
                z2 = nz2;
            }
            st_z1[s] = z1;
            st_z2[s] = z2;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = (uint32_t)((sig[i] + 16.0f) * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(sig);
    free(st_z1);
    free(st_z2);
    return 0;
}
