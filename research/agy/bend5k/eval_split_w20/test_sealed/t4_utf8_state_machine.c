#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 32-entry byte-class table indexed by (byte >> 3):
 * 0: ASCII (0x00..0x7F)
 * 1: cont low (0x80..0x9F)
 * 2: cont high (0xA0..0xBF)
 * 3: 2-byte lead (0xC8..0xDF)
 * 4: 3-byte lead (0xE0..0xEF)
 * 5: 4-byte lead (0xF0..0xF7)
 * 6: invalid (0xC0..0xC7 overlong/reserved, 0xF8..0xFF)
 */
static const uint32_t CLS_LUT[32] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,1,2,2,2,2,6,3,3,3,4,4,5,6
};

/* 32-entry DFA transition table indexed by (state * 8 + cls):
 * states: 0=ACCEPT, 1=NEED1, 2=NEED2, 3=NEED3, 4=ERROR
 */
static const uint32_t TRANS_LUT[32] = {
    /* state 0 (ACCEPT) */ 0, 4, 4, 1, 2, 3, 4, 4,
    /* state 1 (NEED1)  */ 4, 0, 0, 4, 4, 4, 4, 4,
    /* state 2 (NEED2)  */ 4, 1, 1, 4, 4, 4, 4, 4,
    /* state 3 (NEED3)  */ 4, 2, 2, 4, 4, 4, 4, 4
};

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static uint32_t gen_byte(uint32_t i, int skew) {
    uint32_t r = prng((i + 1u) * 2654435761u + (skew ? 101u : 61u));
    uint32_t m = r & 15u;
    if (skew) {
        /* 12/16 ASCII, 2/16 valid cont/lead, 2/16 error-triggering */
        if (m < 12u) return r & 127u;
        if (m == 12u) return 0xC8u | (r & 15u);
        if (m == 13u) return 0x80u | (r & 63u);
        return 0xF8u | (r & 7u);
    } else {
        /* Mixed structured UTF-8 stream */
        uint32_t phase = i & 3u;
        if (phase == 0u) {
            if (m < 6u) return r & 127u;
            if (m < 10u) return 0xC8u | (r & 23u);
            if (m < 14u) return 0xE0u | (r & 15u);
            return 0xF0u | (r & 7u);
        } else {
            return 0x80u | (r & 63u);
        }
    }
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t N = skew ? 65536u : 32768u;
    uint32_t ROUNDS = skew ? 65u : 125u;

    uint32_t *buf = (uint32_t *)malloc(N * sizeof(uint32_t));
    for (uint32_t i = 0; i < N; i++) {
        buf[i] = gen_byte(i, skew);
    }

    uint32_t h = 2166136261u;
    uint32_t valid = 0u;
    uint32_t errs = 0u;
    for (uint32_t r = 0; r < ROUNDS; r++) {
        uint32_t st = 0u;
        uint32_t cp = 0u;
        for (uint32_t i = 0; i < N; i++) {
            uint32_t b = buf[i];
            uint32_t cls = CLS_LUT[(b >> 3) & 31u];
            uint32_t nst = TRANS_LUT[(st << 3) | cls];
            uint32_t ncp = (st == 0u) ? (b & 127u) : ((cp << 6) | (b & 63u));
            if (nst == 0u) {
                h = (h ^ ncp) * 16777619u;
                valid++;
                st = 0u;
                cp = 0u;
            } else if (nst == 4u) {
                errs++;
                st = 0u;
                cp = 0u;
            } else {
                st = nst;
                cp = ncp;
            }
        }
    }
    uint32_t out = (h ^ valid) + (errs * 2654435761u);
    printf("%u\n", out);
    free(buf);
    return 0;
}
