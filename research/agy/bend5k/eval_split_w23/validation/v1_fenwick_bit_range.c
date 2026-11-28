/* v1_fenwick_bit_range.c — Independent C oracle for Fenwick Tree (BIT) point-update,
 * prefix-sum, and binary-lifting order-statistic lower_bound over Array<U32>.
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

static void bit_add(uint32_t *bit, uint32_t n, uint32_t idx, uint32_t delta) {
    uint32_t i = idx;
    for (int step = 0; step < 14 && i <= n; step++) {
        bit[i] += delta;
        i += (i & (0u - i));
    }
}

static uint32_t bit_sum(const uint32_t *bit, uint32_t idx) {
    uint32_t s = 0;
    uint32_t i = idx;
    for (int step = 0; step < 14 && i > 0; step++) {
        s += bit[i];
        i -= (i & (0u - i));
    }
    return s;
}

static uint32_t bit_lower_bound(const uint32_t *bit, uint32_t n, uint32_t target) {
    uint32_t pos = 0;
    uint32_t acc = 0;
    for (uint32_t k = 2048; k > 0; k >>= 1) {
        uint32_t nxt = pos + k;
        if (nxt <= n) {
            uint32_t cand = acc + bit[nxt];
            if (cand < target) {
                pos = nxt;
                acc = cand;
            }
        }
    }
    return pos + 1;
}

static uint32_t run_bench(uint32_t rounds, uint32_t ops, int skew) {
    const uint32_t N = 4096;
    uint32_t *bit = (uint32_t *)calloc(N + 1, sizeof(uint32_t));
    uint32_t seed = skew ? 987654321u : 135792468u;
    uint32_t acc = 2166136261u;
    uint32_t total = 0;

    for (uint32_t rd = 0; rd < rounds; rd++) {
        memset(bit, 0, (N + 1) * sizeof(uint32_t));
        total = 0;
        for (uint32_t i = 1; i <= N; i++) {
            seed = prng(seed);
            uint32_t v = (seed & 31u) + 1u;
            bit_add(bit, N, i, v);
            total += v;
        }
        for (uint32_t q = 0; q < ops; q++) {
            seed = prng(seed);
            uint32_t idx;
            if (skew && ((seed & 3u) != 0u)) {
                idx = (seed & 255u) + 1u;
            } else {
                idx = (seed & 4095u) + 1u;
            }
            uint32_t op = (seed >> 12) & 3u;
            if (op == 0u) {
                uint32_t delta = ((seed >> 16) & 15u) + 1u;
                bit_add(bit, N, idx, delta);
                total += delta;
            } else if (op == 1u) {
                uint32_t s = bit_sum(bit, idx);
                acc = (acc * 16777619u) ^ s;
            } else if (op == 2u) {
                uint32_t l = (idx & 2047u) + 1u;
                uint32_t r = l + ((seed >> 16) & 1023u);
                if (r > N) r = N;
                uint32_t sr = bit_sum(bit, r);
                uint32_t sl = bit_sum(bit, l - 1u);
                acc = (acc * 2654435761u) ^ (sr - sl);
            } else {
                uint32_t tgt = ((seed >> 14) & 32767u) + 1u;
                uint32_t pos = bit_lower_bound(bit, N, tgt);
                acc = (acc * 2246822519u) ^ pos;
            }
        }
        acc = (acc * 16777619u) ^ total;
    }
    free(bit);
    return acc;
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t rounds = 24;
    uint32_t ops = 16384;
    printf("%u\n", run_bench(rounds, ops, skew));
    return 0;
}
