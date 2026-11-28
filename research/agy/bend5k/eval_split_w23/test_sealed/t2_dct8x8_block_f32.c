/* t2_dct8x8_block_f32.c — Independent C oracle for 8x8 2D Separable DCT-II
 * + Quantization + IDCT-II in F32 (bit-identical Taylor cos basis).
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

static inline float poly_cos(float x) {
    float x2 = x * x;
    float t3 = 0.0f - fl(1, 720);
    float t2 = fl(1, 24) + x2 * t3;
    float t1 = (0.0f - fl(1, 2)) + x2 * t2;
    return fl(1, 1) + x2 * t1;
}

static inline float cos_approx(float x) {
    float pi = fl(3141593, 1000000);
    float hpi = fl(1570796, 1000000);
    /* Reduce x in [0, 8*pi] into [0, 2*pi] then [0, pi] then [0, pi/2] */
    float two_pi = pi + pi;
    for (int i = 0; i < 6; i++) {
        if (x >= two_pi) x = x - two_pi;
    }
    if (x > pi) x = two_pi - x;
    if (x > hpi) {
        return 0.0f - poly_cos(pi - x);
    }
    return poly_cos(x);
}

static uint32_t run_bench(uint32_t blocks, uint32_t qscale) {
    float C[64];
    float B[64];
    float T[64];
    float Y[64];
    float pi = fl(3141593, 1000000);
    float s0 = fl(353553, 1000000); /* 1/sqrt(8) */
    float s1 = fl(5, 10);           /* sqrt(2/8) = 0.5 */

    /* Build 8x8 DCT-II basis matrix C[u][x] */
    for (uint32_t u = 0; u < 8u; u++) {
        float alpha = (u == 0u) ? s0 : s1;
        for (uint32_t x = 0; x < 8u; x++) {
            float angle = (pi * (float)((2u * x + 1u) * u)) / 16.0f;
            C[u * 8u + x] = alpha * cos_approx(angle);
        }
    }

    uint32_t acc = 2166136261u;
    float inv_q = fl(1, qscale);
    float fq = (float)qscale;

    for (uint32_t blk = 0; blk < blocks; blk++) {
        /* Fill 8x8 spatial block */
        for (uint32_t r = 0; r < 8u; r++) {
            for (uint32_t c = 0; c < 8u; c++) {
                uint32_t v = ((r * 19u + c * 31u + blk * 7u) & 255u);
                B[r * 8u + c] = (float)v - 128.0f;
            }
        }

        /* Forward 2D DCT: T = C * B */
        for (uint32_t i = 0; i < 8u; i++) {
            for (uint32_t j = 0; j < 8u; j++) {
                float s = 0.0f;
                for (uint32_t k = 0; k < 8u; k++) {
                    s = s + C[i * 8u + k] * B[k * 8u + j];
                }
                T[i * 8u + j] = s;
            }
        }

        /* Forward 2D DCT: Y = T * C^T */
        for (uint32_t i = 0; i < 8u; i++) {
            for (uint32_t j = 0; j < 8u; j++) {
                float s = 0.0f;
                for (uint32_t k = 0; k < 8u; k++) {
                    s = s + T[i * 8u + k] * C[j * 8u + k];
                }
                /* Frequency-dependent scaling (quantize-like) */
                float w = inv_q / (float)(1u + i + j);
                Y[i * 8u + j] = (s * w) * (fq * (float)(1u + i + j));
            }
        }

        /* Inverse 2D DCT: T = C^T * Y */
        for (uint32_t i = 0; i < 8u; i++) {
            for (uint32_t j = 0; j < 8u; j++) {
                float s = 0.0f;
                for (uint32_t k = 0; k < 8u; k++) {
                    s = s + C[k * 8u + i] * Y[k * 8u + j];
                }
                T[i * 8u + j] = s;
            }
        }

        /* Inverse 2D DCT: B = T * C */
        for (uint32_t i = 0; i < 8u; i++) {
            for (uint32_t j = 0; j < 8u; j++) {
                float s = 0.0f;
                for (uint32_t k = 0; k < 8u; k++) {
                    s = s + T[i * 8u + k] * C[k * 8u + j];
                }
                B[i * 8u + j] = s;
            }
        }

        /* Quantized FNV-1a checksum */
        for (uint32_t i = 0; i < 64u; i++) {
            uint32_t q = (uint32_t)((B[i] + 512.0f) * 256.0f);
            acc = (acc * 16777619u) ^ q;
        }
    }

    return acc;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t blocks = large ? 3000u : 2200u;
    uint32_t qscale = large ? 6u : 4u;
    printf("%u\n", run_bench(blocks, qscale));
    return 0;
}
