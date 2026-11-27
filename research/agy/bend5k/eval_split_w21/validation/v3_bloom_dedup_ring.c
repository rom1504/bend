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
    const uint32_t B = 1024u;
    const uint32_t R = 1024u;
    const uint32_t ROUNDS = 24u;
    const uint32_t M = 65536u;

    uint32_t *bloom = (uint32_t *)calloc(B, sizeof(uint32_t));
    uint32_t *ring = (uint32_t *)calloc(R, sizeof(uint32_t));

    uint32_t head = 0u;
    uint32_t hits = 0u;
    uint32_t uniques = 0u;
    uint32_t acc = 2166136261u;
    uint32_t seed = skew ? 987654321u : 123456789u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        uint32_t salt = rd * 10007u;
        for (uint32_t i = 0; i < M; i++) {
            seed = prng(seed);
            uint32_t k;
            if (skew) {
                k = ((seed & 7u) < 6u) ? ((seed >> 3) & 511u) : ((seed >> 3) & 65535u);
            } else {
                k = seed & 16383u;
            }
            k = k ^ salt;

            uint32_t h1 = (k * 2654435761u) ^ (k >> 16);
            uint32_t h2 = ((k * 2246822519u) ^ (k >> 13)) | 1u;

            uint32_t p0 = h1 & 32767u;
            uint32_t p1 = (h1 + h2) & 32767u;
            uint32_t p2 = (h1 + (h2 << 1)) & 32767u;

            uint32_t w0 = p0 >> 5;
            uint32_t m0 = 1u << (p0 & 31u);
            uint32_t old0 = bloom[w0];
            bloom[w0] = old0 | m0;
            uint32_t hit0 = (old0 & m0) != 0u;

            uint32_t w1 = p1 >> 5;
            uint32_t m1 = 1u << (p1 & 31u);
            uint32_t old1 = bloom[w1];
            bloom[w1] = old1 | m1;
            uint32_t hit1 = (old1 & m1) != 0u;

            uint32_t w2 = p2 >> 5;
            uint32_t m2 = 1u << (p2 & 31u);
            uint32_t old2 = bloom[w2];
            bloom[w2] = old2 | m2;
            uint32_t hit2 = (old2 & m2) != 0u;

            if (hit0 && hit1 && hit2) {
                hits += 1u;
                acc = (acc * 16777619u) ^ k;
            } else {
                uint32_t ev = ring[head];
                ring[head] = k;
                head = (head + 1u) & 1023u;
                uniques += 1u;
                acc = (acc * 2654435761u) ^ ev ^ k;
            }
        }
        // Periodic Bloom decay (clear half the bitset each round)
        uint32_t mask = (rd & 1u) ? 0x55555555u : 0xAAAAAAAAu;
        for (uint32_t w = 0; w < B; w++) {
            bloom[w] &= mask;
        }
    }

    uint32_t chk = (acc ^ (hits * 2654435761u)) + (uniques * 2246822519u) + head;
    printf("%u\n", chk);
    free(bloom);
    free(ring);
    return 0;
}
