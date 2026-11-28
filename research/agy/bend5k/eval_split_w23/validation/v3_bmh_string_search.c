/* v3_bmh_string_search.c — Independent C oracle for Boyer-Moore-Horspool
 * multi-pattern substring search with bad-character skip table over Array<U32>.
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

static uint32_t run_bench(uint32_t text_len, uint32_t n_pats, uint32_t alpha_mask) {
    uint32_t *text = (uint32_t *)calloc(text_len, sizeof(uint32_t));
    uint32_t pat[16];
    uint32_t skip[16];
    uint32_t seed = (alpha_mask == 3u) ? 777666555u : 444555666u;

    for (uint32_t i = 0; i < text_len; i++) {
        seed = prng(seed);
        text[i] = seed & alpha_mask;
    }

    uint32_t acc = 2166136261u;
    uint32_t matches = 0;

    for (uint32_t rd = 0; rd < n_pats; rd++) {
        uint32_t m = 6u + (rd & 7u); /* pattern length 6..13 */
        /* Plant pattern from text occasionally + random patterns */
        if ((rd & 3u) == 0u) {
            seed = prng(seed);
            uint32_t start = seed & (text_len - 32u);
            for (uint32_t j = 0; j < m; j++) {
                pat[j] = text[start + j];
            }
        } else {
            for (uint32_t j = 0; j < m; j++) {
                seed = prng(seed);
                pat[j] = seed & alpha_mask;
            }
        }

        /* Build bad-character skip table */
        for (uint32_t c = 0; c < 16u; c++) skip[c] = m;
        for (uint32_t j = 0; j + 1u < m; j++) {
            skip[pat[j]] = m - 1u - j;
        }

        /* BMH scan */
        uint32_t limit = text_len - m;
        uint32_t pos = 0;
        uint32_t steps = 0;
        while (pos <= limit && steps < text_len) {
            steps++;
            uint32_t j = m - 1u;
            int hit = 1;
            for (uint32_t k = 0; k < m; k++) {
                if (text[pos + j] != pat[j]) {
                    hit = 0;
                    break;
                }
                if (j == 0u) break;
                j--;
            }
            if (hit) {
                acc = (acc * 16777619u) ^ (pos + rd);
                matches++;
            }
            pos += skip[text[pos + m - 1u]];
        }
        acc = (acc * 2654435761u) ^ steps;
    }

    free(text);
    return acc ^ (matches * 2246822519u);
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t text_len = 16384;
    uint32_t n_pats = skew ? 120 : 280;
    uint32_t alpha_mask = skew ? 3u : 15u;
    printf("%u\n", run_bench(text_len, n_pats, alpha_mask));
    return 0;
}
