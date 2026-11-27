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
    uint32_t N = 8192u;
    uint32_t M = 32u;
    uint32_t ROUNDS = 140u;

    uint32_t *text = (uint32_t *)malloc(N * sizeof(uint32_t));
    uint32_t *pat = (uint32_t *)malloc(M * sizeof(uint32_t));
    uint32_t *pi = (uint32_t *)malloc(M * sizeof(uint32_t));

    uint32_t seed = skew ? 777888999u : 333444555u;
    for (uint32_t i = 0; i < N; i++) {
        seed = prng(seed);
        if (skew) {
            text[i] = ((seed & 7u) == 0u) ? 1u : 0u;
        } else {
            text[i] = seed & 3u;
        }
    }

    uint32_t acc = 2166136261u;
    uint32_t total_matches = 0u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        uint32_t plen = skew ? (8u + (rd & 7u)) : (6u + (rd & 3u));
        for (uint32_t i = 0; i < plen; i++) {
            seed = prng(seed);
            if (skew) {
                pat[i] = ((seed & 7u) == 0u) ? 1u : 0u;
            } else {
                pat[i] = seed & 3u;
            }
        }

        // Build KMP prefix function pi[0..plen-1]
        pi[0] = 0u;
        uint32_t k = 0u;
        for (uint32_t i = 1u; i < plen; i++) {
            uint32_t pi_ch = pat[i];
            while (k > 0u && pat[k] != pi_ch) {
                k = pi[k - 1u];
            }
            if (pat[k] == pi_ch) {
                k++;
            }
            pi[i] = k;
        }

        // Scan haystack
        uint32_t q = 0u;
        for (uint32_t i = 0; i < N; i++) {
            uint32_t ch = text[i];
            while (q > 0u && pat[q] != ch) {
                q = pi[q - 1u];
            }
            if (pat[q] == ch) {
                q++;
            }
            if (q == plen) {
                total_matches++;
                acc = (acc * 16777619u) ^ (i + rd);
                q = pi[q - 1u];
            }
        }
        acc = (acc * 2654435761u) ^ q;
    }

    uint32_t chk = acc ^ (total_matches * 2246822519u);
    printf("%u\n", chk);
    free(text); free(pat); free(pi);
    return 0;
}
