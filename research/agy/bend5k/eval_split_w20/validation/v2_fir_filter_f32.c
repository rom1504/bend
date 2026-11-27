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
    uint32_t N = large ? 8192u : 2048u;
    uint32_t K = large ? 64u : 32u;
    uint32_t ITERS = large ? 50u : 280u;
    uint32_t mask = N - 1u;

    float *sig = (float *)malloc(N * sizeof(float));
    float *out = (float *)malloc(N * sizeof(float));
    float *kern = (float *)malloc(K * sizeof(float));

    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = prng(((i + 1u) * 2654435761u) ^ 17u) & 255u;
        sig[i] = fl(q, 256u) - fl(1u, 2u);
        out[i] = 0.0f;
    }
    for (uint32_t k = 0; k < K; k++) {
        uint32_t q = prng(((k + 1u) * 2654435761u) ^ 91u) & 63u;
        kern[k] = (fl(q, 64u) - fl(1u, 2u)) * fl(1u, K);
    }

    for (uint32_t it = 0; it < ITERS; it++) {
        for (uint32_t i = 0; i < N; i++) {
            float acc = 0.0f;
            for (uint32_t k = 0; k < K; k++) {
                uint32_t idx = (i + k) & mask;
                acc = acc + sig[idx] * kern[k];
            }
            out[i] = acc * fl(7u, 8u) + fl(1u, 16u);
        }
        float *tmp = sig;
        sig = out;
        out = tmp;
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = (uint32_t)((sig[i] + 16.0f) * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(sig);
    free(out);
    free(kern);
    return 0;
}
