/* t3_kahn_toposort_dag.c — Independent C oracle for Kahn's Topological Sort
 * + Critical-Path Longest-Path DP on a CSR Directed Acyclic Graph.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return x;
}

static uint32_t run_bench(uint32_t rounds, int skew) {
    const uint32_t V = 2048;
    const uint32_t MAXE = 16384;
    uint32_t *rptr = (uint32_t *)calloc(V, sizeof(uint32_t));
    uint32_t *rlen = (uint32_t *)calloc(V, sizeof(uint32_t));
    uint32_t *col  = (uint32_t *)calloc(MAXE, sizeof(uint32_t));
    uint32_t *wt   = (uint32_t *)calloc(MAXE, sizeof(uint32_t));
    uint32_t *indeg0 = (uint32_t *)calloc(V, sizeof(uint32_t));
    uint32_t *indeg  = (uint32_t *)calloc(V, sizeof(uint32_t));
    uint32_t *queue  = (uint32_t *)calloc(V, sizeof(uint32_t));
    uint32_t *dist   = (uint32_t *)calloc(V, sizeof(uint32_t));

    /* Build deterministic CSR DAG (all edges u -> v satisfy u < v) */
    uint32_t seed = skew ? 888777666u : 555666777u;
    uint32_t epos = 0;
    for (uint32_t u = 0; u < V; u++) {
        rptr[u] = epos;
        uint32_t deg;
        if (u + 1u >= V) {
            deg = 0;
        } else if (skew) {
            deg = ((u & 15u) == 0u) ? 12u : 3u;
        } else {
            deg = 6u;
        }
        uint32_t rem = V - 1u - u;
        if (deg > rem) deg = rem;
        rlen[u] = deg;
        for (uint32_t k = 0; k < deg; k++) {
            seed = prng(seed);
            uint32_t span = (rem > 64u) ? 64u : rem;
            uint32_t v = u + 1u + (seed % span);
            uint32_t w = ((seed >> 8) & 31u) + 1u;
            col[epos] = v;
            wt[epos] = w;
            indeg0[v]++;
            epos++;
        }
    }

    uint32_t acc = 2166136261u;
    for (uint32_t rd = 0; rd < rounds; rd++) {
        uint32_t qhead = 0, qtail = 0;
        for (uint32_t u = 0; u < V; u++) {
            uint32_t d = indeg0[u];
            indeg[u] = d;
            dist[u] = (d == 0u) ? ((u + rd) & 15u) : 0u;
            if (d == 0u) {
                queue[qtail++] = u;
            }
        }

        uint32_t visited = 0;
        while (qhead < qtail && visited < V) {
            uint32_t u = queue[qhead++];
            visited++;
            uint32_t du = dist[u];
            uint32_t e0 = rptr[u];
            uint32_t len = rlen[u];
            for (uint32_t k = 0; k < len; k++) {
                uint32_t e = e0 + k;
                uint32_t v = col[e];
                uint32_t cand = du + wt[e] + (rd & 3u);
                if (cand > dist[v]) {
                    dist[v] = cand;
                }
                uint32_t nd = indeg[v] - 1u;
                indeg[v] = nd;
                if (nd == 0u) {
                    queue[qtail++] = v;
                }
            }
            acc = (acc * 16777619u) ^ (u ^ (du << 8));
        }
        acc = (acc * 2654435761u) ^ visited;
    }

    free(rptr); free(rlen); free(col); free(wt);
    free(indeg0); free(indeg); free(queue); free(dist);
    return acc;
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t rounds = skew ? 70u : 50u;
    printf("%u\n", run_bench(rounds, skew));
    return 0;
}
