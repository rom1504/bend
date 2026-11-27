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
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t S = large ? 32u : 16u;
    uint32_t LOGS = large ? 5u : 4u;
    uint32_t T = large ? 512u : 1024u;
    uint32_t SEQS = large ? 20u : 36u;

    uint32_t *trans = (uint32_t *)malloc(S * S * sizeof(uint32_t));
    uint32_t *emit = (uint32_t *)malloc(S * 16u * sizeof(uint32_t));
    uint32_t *prev = (uint32_t *)malloc(S * sizeof(uint32_t));
    uint32_t *cur = (uint32_t *)malloc(S * sizeof(uint32_t));

    for (uint32_t i = 0; i < S * S; i++) {
        uint32_t r = prng(((i + 1u) * 2654435761u) ^ 53u);
        trans[i] = 1u + (r & 63u);
    }
    for (uint32_t i = 0; i < S * 16u; i++) {
        uint32_t r = prng(((i + 1u) * 2246822519u) ^ 89u);
        emit[i] = 1u + (r & 127u);
    }

    uint32_t seed = large ? 555123457u : 135792468u;
    uint32_t total_h = 2166136261u;
    uint32_t bp_h = 2166136261u;

    for (uint32_t sq = 0; sq < SEQS; sq++) {
        for (uint32_t j = 0; j < S; j++) {
            prev[j] = j * 7u;
        }
        for (uint32_t t = 0; t < T; t++) {
            seed = prng(seed);
            uint32_t obs = seed & 15u;
            for (uint32_t j = 0; j < S; j++) {
                uint32_t em = emit[(j << 4) | obs];
                uint32_t best = 0x7FFFFFFFu;
                uint32_t best_i = 0u;
                for (uint32_t i = 0; i < S; i++) {
                    uint32_t cand = prev[i] + trans[(i << LOGS) | j];
                    if (cand < best) {
                        best = cand;
                        best_i = i;
                    }
                }
                cur[j] = best + em;
                bp_h = (bp_h * 16777619u) ^ best_i;
            }
            uint32_t *tmp = prev;
            prev = cur;
            cur = tmp;
        }
        for (uint32_t j = 0; j < S; j++) {
            total_h = (total_h * 2654435761u) ^ prev[j];
        }
    }

    uint32_t chk = total_h ^ bp_h;
    printf("%u\n", chk);
    free(trans);
    free(emit);
    free(prev);
    free(cur);
    return 0;
}
