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
    uint32_t ROUNDS = 40u;
    uint32_t BYTES = 16384u;
    uint32_t HTSIZE = 8192u;
    uint32_t HTMASK = HTSIZE - 1u;

    uint32_t *ht_key = (uint32_t *)malloc(HTSIZE * sizeof(uint32_t));
    uint32_t *ht_val = (uint32_t *)malloc(HTSIZE * sizeof(uint32_t));

    uint32_t seed = skew ? 555666777u : 111222333u;
    uint32_t acc = 2166136261u;
    uint32_t emitted = 0u;
    uint32_t resets = 0u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        for (uint32_t i = 0; i < HTSIZE; i++) {
            ht_key[i] = 0u;
            ht_val[i] = 0u;
        }
        uint32_t next_code = 256u;
        seed = prng(seed);
        uint32_t prefix = skew ? (seed & 7u) : (seed & 31u);

        for (uint32_t b = 1u; b < BYTES; b++) {
            seed = prng(seed);
            uint32_t ch;
            if (skew) {
                if ((seed & 3u) != 0u) {
                    ch = ((b + rd) & 7u);
                } else {
                    ch = (seed >> 8) & 7u;
                }
            } else {
                if ((seed & 7u) < 5u) {
                    ch = ((b * 3u + rd) & 15u);
                } else {
                    ch = (seed >> 8) & 31u;
                }
            }

            uint32_t key = ((prefix << 8) | ch) | 0x80000000u;
            uint32_t slot = ((key * 2654435761u) >> 19) & HTMASK;
            uint32_t found = 0u;
            uint32_t found_code = 0u;
            uint32_t empty_slot = slot;
            uint32_t has_empty = 0u;

            for (uint32_t p = 0; p < 16u; p++) {
                uint32_t cur = ht_key[slot];
                if (cur == key) {
                    found = 1u;
                    found_code = ht_val[slot];
                    break;
                }
                if (cur == 0u) {
                    empty_slot = slot;
                    has_empty = 1u;
                    break;
                }
                slot = (slot + 1u) & HTMASK;
            }

            if (found) {
                prefix = found_code;
            } else {
                acc = (acc * 16777619u) ^ prefix;
                emitted++;
                if (has_empty && next_code < 4096u) {
                    ht_key[empty_slot] = key;
                    ht_val[empty_slot] = next_code;
                    next_code++;
                } else if (next_code >= 4096u) {
                    for (uint32_t i = 0; i < HTSIZE; i++) {
                        ht_key[i] = 0u;
                    }
                    next_code = 256u;
                    resets++;
                }
                prefix = ch;
            }
        }
        acc = (acc * 16777619u) ^ prefix;
        emitted++;
    }

    uint32_t chk = (acc ^ (emitted * 2654435761u)) + (resets * 2246822519u);
    printf("%u\n", chk);
    free(ht_key);
    free(ht_val);
    return 0;
}
