#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

enum Op { OP_ADD, OP_SUB, OP_MUL, OP_XOR, OP_SHR, OP_SHL, OP_ROT, OP_MIX };

typedef struct InstNode {
    uint32_t op;
    uint32_t k;
    struct InstNode *next;
} InstNode;

static InstNode *build_prog(uint32_t n, uint32_t seed) {
    InstNode *acc = NULL;
    for (uint32_t i = 0; i < n; i++) {
        uint32_t s1 = prng(seed);
        uint32_t s2 = prng(s1);
        InstNode *node = (InstNode *)malloc(sizeof(InstNode));
        uint32_t op = s1 & 7u;
        node->op = op;
        if (op == OP_MUL) node->k = s2 | 1u;
        else if (op == OP_XOR || op == OP_MIX) node->k = s2;
        else if (op == OP_SHR || op == OP_SHL) node->k = (s2 & 7u) + 1u;
        else node->k = 0;
        node->next = acc;
        acc = node;
        seed = s2;
    }
    return acc;
}

int main(void) {
    InstNode *prog = build_prog(256, 123456789u);
    uint32_t r0 = 1, r1 = 2, r2 = 3, r3 = 4;
    for (uint32_t it = 0; it < 100000; it++) {
        for (const InstNode *p = prog; p != NULL; p = p->next) {
            switch (p->op) {
                case OP_ADD: r0 = r0 + r1; break;
                case OP_SUB: r0 = r0 - r2; break;
                case OP_MUL: r0 = r0 * p->k; break;
                case OP_XOR: r0 = r0 ^ p->k; break;
                case OP_SHR: r0 = r0 ^ (r1 >> p->k); break;
                case OP_SHL: r0 = r0 ^ (r2 << p->k); break;
                case OP_ROT: {
                    uint32_t t = r0;
                    r0 = r1; r1 = r2; r2 = r3; r3 = t;
                    break;
                }
                default: {
                    uint32_t nr0 = (r0 ^ r3) + p->k;
                    uint32_t nr1 = r1 + r0;
                    uint32_t nr3 = r3 ^ r1;
                    r0 = nr0; r1 = nr1; r3 = nr3;
                    break;
                }
            }
        }
    }
    printf("%u\n", (r0 ^ r1) ^ (r2 ^ r3));
    while (prog) {
        InstNode *n = prog->next;
        free(prog);
        prog = n;
    }
    return 0;
}
