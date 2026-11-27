#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static inline uint32_t make_byte(uint32_t i) {
    uint32_t r = prng((i + 1u) * 2654435761u + 83u);
    if ((i & 3u) == 0u || (r & 3u) == 0u) {
        return r & 127u;
    }
    return 128u | (r & 127u);
}

static inline uint32_t mix32(uint32_t h, uint32_t v) {
    uint32_t x = (h ^ v) * 2246822519u;
    uint32_t y = (x << 13) | (x >> 19);
    return (y ^ (y >> 15)) * 3266489917u;
}

int main(void) {
    const uint32_t N = 65536u;
    const uint32_t ROUNDS = 180u;
    uint32_t *buf = (uint32_t *)malloc(N * sizeof(uint32_t));
    for (uint32_t i = 0; i < N; i++) {
        buf[i] = make_byte(i);
    }

    uint32_t h = 2166136261u;
    uint32_t count = 0u;
    for (uint32_t r = 0; r < ROUNDS; r++) {
        uint32_t acc = 0u;
        uint32_t shift = 0u;
        for (uint32_t i = 0; i < N; i++) {
            uint32_t b = buf[i];
            uint32_t nacc = acc | ((b & 127u) << (shift & 31u));
            if ((b & 128u) == 0u) {
                h = mix32(h, nacc);
                count++;
                acc = 0u;
                shift = 0u;
            } else {
                acc = nacc;
                shift += 7u;
            }
        }
    }
    printf("%u\n", h ^ (count * 2654435761u));
    free(buf);
    return 0;
}
