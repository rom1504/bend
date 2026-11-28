/* t1_golomb_rice_codec.c — Independent C oracle for Delta + ZigZag + Golomb-Rice
 * bitstream encoder/decoder round-trip over Array<U32>.
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

static uint32_t run_bench(uint32_t rounds, uint32_t k, int skew) {
    const uint32_t N = 1024;
    const uint32_t MASK = (1u << k) - 1u;
    uint32_t *sig = (uint32_t *)calloc(N, sizeof(uint32_t));
    uint32_t *words = (uint32_t *)calloc(2048, sizeof(uint32_t));
    uint32_t *dec = (uint32_t *)calloc(N, sizeof(uint32_t));
    uint32_t seed = skew ? 654321987u : 192837465u;
    uint32_t acc = 2166136261u;

    for (uint32_t rd = 0; rd < rounds; rd++) {
        /* 1. Generate correlated signal */
        uint32_t cur = 1000u + (rd & 63u);
        for (uint32_t i = 0; i < N; i++) {
            seed = prng(seed);
            uint32_t mag;
            if (skew) {
                mag = ((seed & 15u) == 0u) ? ((seed >> 4) & 31u) : ((seed >> 4) & 3u);
            } else {
                mag = (seed >> 4) & 15u;
            }
            if ((seed & 1u) == 0u) {
                cur += mag;
            } else {
                cur = (cur > mag) ? (cur - mag) : (cur + mag);
            }
            sig[i] = cur;
        }

        /* 2. Encode: Delta -> ZigZag -> Golomb-Rice into 32-bit word bitstream */
        uint32_t widx = 0;
        uint32_t bitbuf = 0;
        uint32_t bitcnt = 0;
        uint32_t total_bits = 0;
        uint32_t prev = 1000u + (rd & 63u);

        for (uint32_t i = 0; i < N; i++) {
            uint32_t v = sig[i];
            uint32_t zz = (v >= prev) ? ((v - prev) << 1) : (((prev - v) << 1) - 1u);
            prev = v;

            uint32_t q = zz >> k;
            uint32_t r = zz & MASK;
            /* Emit q ones */
            for (uint32_t u = 0; u < q; u++) {
                bitbuf |= (1u << bitcnt);
                bitcnt++;
                total_bits++;
                if (bitcnt == 32u) {
                    words[widx++] = bitbuf;
                    bitbuf = 0;
                    bitcnt = 0;
                }
            }
            /* Emit terminating 0 */
            bitcnt++;
            total_bits++;
            if (bitcnt == 32u) {
                words[widx++] = bitbuf;
                bitbuf = 0;
                bitcnt = 0;
            }
            /* Emit k remainder bits LSB-first */
            for (uint32_t b = 0; b < k; b++) {
                uint32_t bit = (r >> b) & 1u;
                bitbuf |= (bit << bitcnt);
                bitcnt++;
                total_bits++;
                if (bitcnt == 32u) {
                    words[widx++] = bitbuf;
                    bitbuf = 0;
                    bitcnt = 0;
                }
            }
        }
        if (bitcnt > 0u) {
            words[widx++] = bitbuf;
        }

        /* 3. Decode: Golomb-Rice -> ZigZag -> Delta prefix sum */
        uint32_t rwidx = 0;
        uint32_t rbuf = words[0];
        uint32_t rcnt = 0;
        uint32_t dprev = 1000u + (rd & 63u);

        for (uint32_t i = 0; i < N; i++) {
            /* Read unary quotient (count 1s until 0) */
            uint32_t q = 0;
            for (uint32_t step = 0; step < 64u; step++) {
                uint32_t bit = (rbuf >> rcnt) & 1u;
                rcnt++;
                if (rcnt == 32u) {
                    rwidx++;
                    rbuf = words[rwidx];
                    rcnt = 0;
                }
                if (bit == 0u) break;
                q++;
            }
            /* Read k remainder bits */
            uint32_t r = 0;
            for (uint32_t b = 0; b < k; b++) {
                uint32_t bit = (rbuf >> rcnt) & 1u;
                r |= (bit << b);
                rcnt++;
                if (rcnt == 32u) {
                    rwidx++;
                    rbuf = words[rwidx];
                    rcnt = 0;
                }
            }
            uint32_t zz = (q << k) | r;
            uint32_t v;
            if ((zz & 1u) == 0u) {
                v = dprev + (zz >> 1);
            } else {
                v = dprev - ((zz + 1u) >> 1);
            }
            dprev = v;
            dec[i] = v;
        }

        /* 4. Checksum decoded signal + total_bits */
        acc = (acc * 2654435761u) ^ total_bits;
        for (uint32_t i = 0; i < N; i++) {
            acc = (acc * 16777619u) ^ dec[i];
        }
    }

    free(sig);
    free(words);
    free(dec);
    return acc;
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t rounds = 140;
    uint32_t k = skew ? 2u : 3u;
    printf("%u\n", run_bench(rounds, k, skew));
    return 0;
}
