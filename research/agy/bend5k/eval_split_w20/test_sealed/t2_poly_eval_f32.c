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

static inline float newton_step(float x, float bias) {
    /* P(x) = (1/64)x^7 + (1/256)x^6 + (1/16)x^5 + (1/128)x^4 + (1/4)x^3 + (1/16)x^2 + 4x - bias */
    float c7 = fl(1u, 64u);
    float c6 = fl(1u, 256u);
    float c5 = fl(1u, 16u);
    float c4 = fl(1u, 128u);
    float c3 = fl(1u, 4u);
    float c2 = fl(1u, 16u);
    float c1 = fl(4u, 1u);

    float p = ((((((c7 * x + c6) * x + c5) * x + c4) * x + c3) * x + c2) * x + c1) * x - bias;
    float dp = (((((fl(7u, 64u) * x + fl(6u, 256u)) * x + fl(5u, 16u)) * x + fl(4u, 128u)) * x + fl(3u, 4u)) * x + fl(2u, 16u)) * x + c1;
    return x - p / dp;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t N = large ? 65536u : 16384u;
    uint32_t SWEEPS = large ? 30u : 120u;

    float *xs = (float *)malloc(N * sizeof(float));
    float *out = (float *)malloc(N * sizeof(float));

    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = prng(((i + 1u) * 2654435761u) ^ (large ? 53u : 29u)) & 1023u;
        if (large) {
            xs[i] = fl(q, 256u) - fl(2u, 1u); /* [-2.0, 2.0) */
        } else {
            xs[i] = fl(q, 512u) + fl(1u, 2u); /* [0.5, 2.5) */
        }
        out[i] = 0.0f;
    }

    for (uint32_t sw = 0; sw < SWEEPS; sw++) {
        float bias = fl((sw & 15u) + 1u, 16u);
        for (uint32_t i = 0; i < N; i++) {
            float x0 = xs[i];
            float x1 = newton_step(x0, bias);
            float x2 = newton_step(x1, bias);
            float x3 = newton_step(x2, bias);
            float x4 = newton_step(x3, bias);
            out[i] = x4 * fl(1u, 2u) + fl(1u, 4u);
        }
        float *tmp = xs;
        xs = out;
        out = tmp;
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = (uint32_t)((xs[i] + 16.0f) * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(xs);
    free(out);
    return 0;
}
