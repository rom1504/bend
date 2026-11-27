#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

static inline float poly_cos(float x) {
    float x2 = x * x;
    float t3 = fl(0u, 1u) - fl(1u, 720u);
    float t2 = fl(1u, 24u) + x2 * t3;
    float t1 = (fl(0u, 1u) - fl(1u, 2u)) + x2 * t2;
    return fl(1u, 1u) + x2 * t1;
}

static inline float poly_sin(float x) {
    float x2 = x * x;
    float t3 = fl(0u, 1u) - fl(1u, 5040u);
    float t2 = fl(1u, 120u) + x2 * t3;
    float t1 = (fl(0u, 1u) - fl(1u, 6u)) + x2 * t2;
    return x * (fl(1u, 1u) + x2 * t1);
}

static inline uint32_t bitrev(uint32_t x, uint32_t bits) {
    uint32_t r = 0u;
    for (uint32_t i = 0; i < bits; i++) {
        r = (r << 1) | (x & 1u);
        x >>= 1;
    }
    return r;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t LOGN = large ? 10u : 9u;
    uint32_t N = 1u << LOGN;
    uint32_t HALF_N = N >> 1;
    uint32_t QTR_N = N >> 2;
    uint32_t FRAMES = large ? 220u : 440u;

    float *re = (float *)malloc(N * sizeof(float));
    float *im = (float *)malloc(N * sizeof(float));
    float *tw_re = (float *)malloc(HALF_N * sizeof(float));
    float *tw_im = (float *)malloc(HALF_N * sizeof(float));

    float half_pi = fl(1570796u, 1000000u);
    for (uint32_t k = 0; k < HALF_N; k++) {
        if (k < QTR_N) {
            float t = (half_pi * (float)k) / (float)QTR_N;
            tw_re[k] = poly_cos(t);
            tw_im[k] = 0.0f - poly_sin(t);
        } else {
            uint32_t k2 = k - QTR_N;
            float t = (half_pi * (float)k2) / (float)QTR_N;
            tw_re[k] = 0.0f - poly_sin(t);
            tw_im[k] = 0.0f - poly_cos(t);
        }
    }

    for (uint32_t i = 0; i < N; i++) {
        re[i] = fl((i * 13u + 7u) & 255u, 256u) - fl(1u, 2u);
        im[i] = fl((i * 29u + 3u) & 255u, 256u) - fl(1u, 2u);
    }

    float inv_scale = large ? fl(1u, 32u) : fl(1u, 24u);

    for (uint32_t f = 0; f < FRAMES; f++) {
        float drive = fl((f & 7u) + 1u, 64u) - fl(1u, 16u);
        // Bit-reversal permutation
        for (uint32_t i = 0; i < N; i++) {
            uint32_t j = bitrev(i, LOGN);
            if (i < j) {
                float tr = re[i]; re[i] = re[j]; re[j] = tr;
                float ti = im[i]; im[i] = im[j]; im[j] = ti;
            }
        }
        // Butterfly stages
        for (uint32_t s = 0; s < LOGN; s++) {
            uint32_t half = 1u << s;
            uint32_t step = half << 1;
            uint32_t tw_stride = N >> (s + 1u);
            for (uint32_t base = 0; base < N; base += step) {
                for (uint32_t k = 0; k < half; k++) {
                    uint32_t u = base + k;
                    uint32_t v = u + half;
                    uint32_t tidx = k * tw_stride;
                    float wr = tw_re[tidx];
                    float wi = tw_im[tidx];
                    float vr = re[v];
                    float vi = im[v];
                    float tr = wr * vr - wi * vi;
                    float ti = wr * vi + wi * vr;
                    float ur = re[u];
                    float ui = im[u];
                    re[u] = ur + tr;
                    im[u] = ui + ti;
                    re[v] = ur - tr;
                    im[v] = ui - ti;
                }
            }
        }
        // Normalize + drive for next frame
        for (uint32_t i = 0; i < N; i++) {
            re[i] = re[i] * inv_scale + drive;
            im[i] = im[i] * inv_scale - drive;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t qr = (uint32_t)((re[i] + 32.0f) * 32768.0f);
        uint32_t qi = (uint32_t)((im[i] + 32.0f) * 32768.0f);
        h = (h * 2654435761u) ^ qr;
        h = (h * 16777619u) ^ qi;
    }
    printf("%u\n", h);
    free(re); free(im); free(tw_re); free(tw_im);
    return 0;
}
