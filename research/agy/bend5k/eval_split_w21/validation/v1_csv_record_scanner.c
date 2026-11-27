#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static uint32_t gen_byte_std(uint32_t i) {
    uint32_t r = prng(((i + 1u) * 2654435761u) + 37u);
    uint32_t m = r & 63u;
    if (m < 6u) return 44u;       // ','
    if (m < 10u) return 34u;      // '"'
    if (m < 12u) return 10u;      // '\n'
    if (m == 12u) return 13u;     // '\r'
    return 48u + ((r >> 6) & 31u);
}

static uint32_t gen_byte_skew(uint32_t i) {
    uint32_t r = prng(((i + 1u) * 2654435761u) + 73u);
    uint32_t m = r & 63u;
    if (m < 14u) return 34u;      // heavy '"' and escaped '""'
    if (m < 22u) return 44u;      // ','
    if (m < 25u) return 10u;      // '\n'
    if (m < 28u) return 13u;      // '\r'
    return 48u + ((r >> 6) & 31u);
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    const uint32_t N = 32768u;
    const uint32_t ROUNDS = 220u;

    uint32_t *buf = (uint32_t *)malloc(N * sizeof(uint32_t));
    for (uint32_t i = 0; i < N; i++) {
        buf[i] = skew ? gen_byte_skew(i) : gen_byte_std(i);
    }

    uint32_t h = 2166136261u;
    uint32_t fields = 0u;
    uint32_t rows = 0u;
    uint32_t qfields = 0u;
    uint32_t escapes = 0u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        uint32_t st = 0u; // 0=Start, 1=Unq, 2=Quote, 3=QEnd, 4=Cr
        uint32_t fhash = 2166136261u;
        for (uint32_t i = 0; i < N; i++) {
            uint32_t b = buf[i];
            if (st == 0u) {
                if (b == 34u) {
                    st = 2u;
                    qfields += 1u;
                } else if (b == 44u) {
                    st = 0u;
                    fields += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = 2166136261u;
                } else if (b == 10u) {
                    st = 0u;
                    fields += 1u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash ^ rows;
                    fhash = 2166136261u;
                } else if (b == 13u) {
                    st = 4u;
                } else {
                    st = 1u;
                    fhash = (fhash * 16777619u) ^ b;
                }
            } else if (st == 1u) {
                if (b == 44u) {
                    st = 0u;
                    fields += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = 2166136261u;
                } else if (b == 10u) {
                    st = 0u;
                    fields += 1u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash ^ rows;
                    fhash = 2166136261u;
                } else if (b == 13u) {
                    st = 4u;
                } else {
                    st = 1u;
                    fhash = (fhash * 16777619u) ^ b;
                }
            } else if (st == 2u) {
                if (b == 34u) {
                    st = 3u;
                } else {
                    st = 2u;
                    fhash = (fhash * 16777619u) ^ b;
                }
            } else if (st == 3u) {
                if (b == 34u) {
                    st = 2u;
                    escapes += 1u;
                    fhash = (fhash * 16777619u) ^ 34u;
                } else if (b == 44u) {
                    st = 0u;
                    fields += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = 2166136261u;
                } else if (b == 10u) {
                    st = 0u;
                    fields += 1u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash ^ rows;
                    fhash = 2166136261u;
                } else if (b == 13u) {
                    st = 4u;
                } else {
                    st = 1u;
                    fhash = (fhash * 16777619u) ^ b;
                }
            } else { // st == 4u (Cr)
                if (b == 10u) {
                    st = 0u;
                    fields += 1u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash ^ rows;
                    fhash = 2166136261u;
                } else if (b == 34u) {
                    st = 2u;
                    fields += 1u;
                    rows += 1u;
                    qfields += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = 2166136261u;
                } else if (b == 44u) {
                    st = 0u;
                    fields += 2u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = 2166136261u;
                } else {
                    st = 1u;
                    fields += 1u;
                    rows += 1u;
                    h = (h * 2654435761u) ^ fhash;
                    fhash = (2166136261u * 16777619u) ^ b;
                }
            }
        }
        h = (h * 2654435761u) ^ fhash;
    }

    uint32_t chk = (h ^ (fields * 2654435761u)) + (rows * 2246822519u) + (qfields * 3266489917u) + (escapes * 668265263u);
    printf("%u\n", chk);
    free(buf);
    return 0;
}
