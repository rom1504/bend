#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t rotr(uint32_t x, uint32_t n) {
    return (x >> n) | (x << (32u - n));
}

static inline uint32_t s0(uint32_t x) {
    return rotr(x, 7u) ^ rotr(x, 18u) ^ (x >> 3u);
}

static inline uint32_t s1(uint32_t x) {
    return rotr(x, 17u) ^ rotr(x, 19u) ^ (x >> 10u);
}

static inline uint32_t S0(uint32_t x) {
    return rotr(x, 2u) ^ rotr(x, 13u) ^ rotr(x, 22u);
}

static inline uint32_t S1(uint32_t x) {
    return rotr(x, 6u) ^ rotr(x, 11u) ^ rotr(x, 25u);
}

static const uint32_t K[64] = {
    0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u,
    0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
    0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u,
    0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
    0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu,
    0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
    0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u,
    0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
    0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u,
    0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
    0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u,
    0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
    0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u,
    0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
    0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u,
    0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u
};

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t BLOCKS = large ? 48000u : 24000u;
    uint32_t salt = large ? 0x9e3779b9u : 0x517cc1b7u;

    uint32_t h0 = 0x6a09e667u, h1 = 0xbb67ae85u, h2 = 0x3c6ef372u, h3 = 0xa54ff53au;
    uint32_t h4 = 0x510e527fu, h5 = 0x9b05688cu, h6 = 0x1f83d9abu, h7 = 0x5be0cd19u;
    uint32_t W[64];

    for (uint32_t blk = 0; blk < BLOCKS; blk++) {
        uint32_t mix = (blk * 2654435761u) ^ h0 ^ salt;
        for (uint32_t i = 0; i < 16u; i++) {
            mix = (mix * 1664525u) + 1013904223u + i;
            W[i] = mix ^ h4;
        }
        for (uint32_t i = 16u; i < 64u; i++) {
            W[i] = W[i - 16u] + s0(W[i - 15u]) + W[i - 7u] + s1(W[i - 2u]);
        }

        uint32_t a = h0, b = h1, c = h2, d = h3;
        uint32_t e = h4, f = h5, g = h6, h = h7;

        for (uint32_t i = 0; i < 64u; i++) {
            uint32_t ch = (e & f) ^ ((~e) & g);
            uint32_t temp1 = h + S1(e) + ch + K[i] + W[i];
            uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            uint32_t temp2 = S0(a) + maj;
            h = g;
            g = f;
            f = e;
            e = d + temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 + temp2;
        }

        h0 += a; h1 += b; h2 += c; h3 += d;
        h4 += e; h5 += f; h6 += g; h7 += h;
    }

    uint32_t chk = 2166136261u;
    chk = (chk * 16777619u) ^ h0;
    chk = (chk * 16777619u) ^ h1;
    chk = (chk * 16777619u) ^ h2;
    chk = (chk * 16777619u) ^ h3;
    chk = (chk * 16777619u) ^ h4;
    chk = (chk * 16777619u) ^ h5;
    chk = (chk * 16777619u) ^ h6;
    chk = (chk * 16777619u) ^ h7;
    printf("%u\n", chk);
    return 0;
}
