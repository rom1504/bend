/* v2_cholesky_solve_f32.c — Independent C oracle for Dense Cholesky LL^T factorization
 * + forward/backward triangular solves on SPD matrices in F32 (Newton-Raphson sqrt).
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

static inline float nr_sqrt(float x) {
    float half = fl(1, 2);
    float y = x * half + half;
    for (int it = 0; it < 6; it++) {
        y = half * (y + x / y);
    }
    return y;
}

static uint32_t run_bench(uint32_t n, uint32_t rounds) {
    float *A = (float *)calloc(n * n, sizeof(float));
    float *L = (float *)calloc(n * n, sizeof(float));
    float *b = (float *)calloc(n, sizeof(float));
    float *x = (float *)calloc(n, sizeof(float));
    uint32_t acc = 2166136261u;

    for (uint32_t rd = 0; rd < rounds; rd++) {
        /* Build symmetric positive-definite diagonally dominant matrix A and RHS b */
        float shift = fl((rd & 15u) + 1u, 32u);
        for (uint32_t i = 0; i < n; i++) {
            b[i] = fl(((i * 7u + rd * 3u) & 63u) + 1u, 16u);
            for (uint32_t j = 0; j < n; j++) {
                if (i == j) {
                    A[i * n + j] = (float)n + fl(4, 1) + shift + fl(i & 7u, 8u);
                } else {
                    uint32_t d = (i > j) ? (i - j) : (j - i);
                    A[i * n + j] = fl(1, d + 2u) + fl(((i + j + rd) & 7u), 64u);
                }
                L[i * n + j] = 0.0f;
            }
        }

        /* Cholesky factorization: A = L * L^T */
        for (uint32_t i = 0; i < n; i++) {
            for (uint32_t j = 0; j <= i; j++) {
                float sum = A[i * n + j];
                for (uint32_t k = 0; k < j; k++) {
                    sum = sum - L[i * n + k] * L[j * n + k];
                }
                if (i == j) {
                    L[i * n + i] = nr_sqrt(sum);
                } else {
                    L[i * n + j] = sum / L[j * n + j];
                }
            }
        }

        /* Forward solve: L * y = b (stored in x) */
        for (uint32_t i = 0; i < n; i++) {
            float sum = b[i];
            for (uint32_t k = 0; k < i; k++) {
                sum = sum - L[i * n + k] * x[k];
            }
            x[i] = sum / L[i * n + i];
        }

        /* Backward solve: L^T * x = y (in-place on x) */
        for (uint32_t rev = 0; rev < n; rev++) {
            uint32_t i = n - 1u - rev;
            float sum = x[i];
            for (uint32_t k = i + 1u; k < n; k++) {
                sum = sum - L[k * n + i] * x[k];
            }
            x[i] = sum / L[i * n + i];
        }

        /* Quantized FNV-1a checksum */
        for (uint32_t i = 0; i < n; i++) {
            uint32_t q = (uint32_t)((x[i] + 16.0f) * 32768.0f);
            acc = (acc * 16777619u) ^ q;
        }
    }

    free(A);
    free(L);
    free(b);
    free(x);
    return acc;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t n = large ? 48 : 32;
    uint32_t rounds = large ? 220 : 520;
    printf("%u\n", run_bench(n, rounds));
    return 0;
}
