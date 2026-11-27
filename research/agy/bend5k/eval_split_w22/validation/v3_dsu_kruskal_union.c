#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static inline uint32_t dsu_find(uint32_t *par, uint32_t x) {
    for (uint32_t s = 0; s < 16u; s++) {
        uint32_t px = par[x];
        if (px == x) return x;
        uint32_t ppx = par[px];
        par[x] = ppx;
        x = ppx;
    }
    return x;
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t N = 4096u;
    uint32_t ROUNDS = 80u;
    uint32_t EDGES = 8192u;

    uint32_t *par = (uint32_t *)malloc(N * sizeof(uint32_t));
    uint32_t *rnk = (uint32_t *)malloc(N * sizeof(uint32_t));

    uint32_t seed = skew ? 987654321u : 123456789u;
    uint32_t acc = 2166136261u;
    uint32_t merges = 0u;
    uint32_t cycles = 0u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        for (uint32_t i = 0; i < N; i++) {
            par[i] = i;
            rnk[i] = 0u;
        }
        uint32_t salt = rd * 10007u;
        for (uint32_t e = 0; e < EDGES; e++) {
            seed = prng(seed);
            uint32_t u, v;
            if (skew) {
                uint32_t base = (e + salt) & 4095u;
                if ((seed & 7u) != 0u) {
                    u = base;
                    v = (base + 1u + (seed & 3u)) & 4095u;
                } else {
                    u = seed & 4095u;
                    v = (seed >> 12) & 4095u;
                }
            } else {
                u = (seed ^ salt) & 4095u;
                v = ((seed >> 12) ^ (salt * 3u)) & 4095u;
            }
            uint32_t ru = dsu_find(par, u);
            uint32_t rv = dsu_find(par, v);
            if (ru == rv) {
                cycles++;
                acc = (acc * 16777619u) ^ ru;
            } else {
                merges++;
                uint32_t rku = rnk[ru];
                uint32_t rkv = rnk[rv];
                if (rku < rkv) {
                    par[ru] = rv;
                } else if (rku > rkv) {
                    par[rv] = ru;
                } else {
                    par[rv] = ru;
                    rnk[ru] = rku + 1u;
                }
                acc = ((acc * 2654435761u) ^ ru) ^ (rv << 12);
            }
        }
    }

    uint32_t chk = (acc ^ (merges * 2654435761u)) + (cycles * 2246822519u);
    printf("%u\n", chk);
    free(par);
    free(rnk);
    return 0;
}
