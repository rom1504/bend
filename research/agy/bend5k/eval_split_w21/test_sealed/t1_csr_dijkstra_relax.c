#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    const uint32_t V = 2048u;
    const uint32_t E = 16384u;
    const uint32_t INF = 1000000000u;
    const uint32_t SOURCES = skew ? 28u : 24u;
    const uint32_t SWEEPS_PER_SRC = 12u;

    uint32_t *row_ptr = (uint32_t *)malloc(V * sizeof(uint32_t));
    uint32_t *row_len = (uint32_t *)malloc(V * sizeof(uint32_t));
    uint32_t *col_idx = (uint32_t *)malloc(E * sizeof(uint32_t));
    uint32_t *weight = (uint32_t *)malloc(E * sizeof(uint32_t));
    uint32_t *dist = (uint32_t *)malloc(V * sizeof(uint32_t));

    uint32_t off = 0u;
    for (uint32_t u = 0; u < V; u++) {
        uint32_t deg;
        if (skew) {
            if ((u & 15u) == 0u) deg = 32u;
            else if ((u & 3u) == 0u) deg = 12u;
            else deg = 4u;
        } else {
            deg = 8u;
        }
        row_ptr[u] = off;
        row_len[u] = deg;
        for (uint32_t k = 0; k < deg; k++) {
            uint32_t e = off + k;
            uint32_t r = prng(((e + 1u) * 2654435761u) ^ (skew ? 97u : 41u));
            uint32_t dst = (u + 1u + (r & 127u)) & 2047u;
            uint32_t w = 1u + ((r >> 8) & 31u);
            col_idx[e] = dst;
            weight[e] = w;
        }
        off += deg;
    }

    uint32_t total_h = 2166136261u;
    uint32_t relax_cnt = 0u;

    for (uint32_t s = 0; s < SOURCES; s++) {
        uint32_t src = (s * 173u) & 2047u;
        for (uint32_t u = 0; u < V; u++) {
            dist[u] = (u == src) ? 0u : INF;
        }
        for (uint32_t sw = 0; sw < SWEEPS_PER_SRC; sw++) {
            for (uint32_t u = 0; u < V; u++) {
                uint32_t du = dist[u];
                if (du < INF) {
                    uint32_t base = row_ptr[u];
                    uint32_t len = row_len[u];
                    for (uint32_t k = 0; k < len; k++) {
                        uint32_t e = base + k;
                        uint32_t v = col_idx[e];
                        uint32_t cand = du + weight[e];
                        if (cand < dist[v]) {
                            dist[v] = cand;
                            relax_cnt += 1u;
                        }
                    }
                }
            }
        }
        for (uint32_t u = 0; u < V; u++) {
            total_h = (total_h * 16777619u) ^ dist[u];
        }
    }

    uint32_t chk = total_h ^ (relax_cnt * 2654435761u);
    printf("%u\n", chk);
    free(row_ptr);
    free(row_len);
    free(col_idx);
    free(weight);
    free(dist);
    return 0;
}
