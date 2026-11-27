#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

typedef struct INode {
    uint32_t lo;
    uint32_t hi;
    uint32_t max_hi;
    struct INode *l;
    struct INode *r;
} INode;

static INode *insert_iv(INode *t, uint32_t lo, uint32_t hi) {
    if (!t) {
        INode *n = (INode *)malloc(sizeof(INode));
        n->lo = lo;
        n->hi = hi;
        n->max_hi = hi;
        n->l = NULL;
        n->r = NULL;
        return n;
    }
    if (hi > t->max_hi) t->max_hi = hi;
    if (lo < t->lo || (lo == t->lo && hi < t->hi)) {
        t->l = insert_iv(t->l, lo, hi);
    } else {
        t->r = insert_iv(t->r, lo, hi);
    }
    return t;
}

static uint32_t query_overlap(const INode *t, uint32_t qlo, uint32_t qhi, uint32_t acc) {
    if (!t) return acc;
    if (t->max_hi < qlo) return acc;
    uint32_t a1 = query_overlap(t->l, qlo, qhi, acc);
    if (t->lo <= qhi) {
        uint32_t a2 = (t->hi >= qlo) ? ((a1 * 16777619u) ^ (t->lo + (t->hi << 16))) : a1;
        return query_overlap(t->r, qlo, qhi, a2);
    }
    return a1;
}

static void free_tree(INode *t) {
    if (!t) return;
    free_tree(t->l);
    free_tree(t->r);
    free(t);
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t N = 512u;
    uint32_t QUERIES = 512u;
    uint32_t ROUNDS = deep ? 30u : 65u;

    uint32_t seed = deep ? 918273645u : 314159265u;
    uint32_t acc = 2166136261u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        INode *root = NULL;
        for (uint32_t i = 0; i < N; i++) {
            seed = prng(seed);
            uint32_t lo, hi;
            if (deep) {
                // Nested / skewed intervals with heavy overlap
                lo = (i * 23u + (seed & 255u)) & 8191u;
                hi = lo + 128u + ((seed >> 8) & 1023u);
            } else {
                lo = seed & 32767u;
                hi = lo + 16u + ((seed >> 16) & 255u);
            }
            root = insert_iv(root, lo, hi);
        }
        for (uint32_t q = 0; q < QUERIES; q++) {
            seed = prng(seed);
            uint32_t qlo, qhi;
            if (deep) {
                qlo = seed & 8191u;
                qhi = qlo + 64u + ((seed >> 16) & 255u);
            } else {
                qlo = seed & 32767u;
                qhi = qlo + 64u + ((seed >> 16) & 511u);
            }
            acc = query_overlap(root, qlo, qhi, acc);
        }
        free_tree(root);
    }

    printf("%u\n", acc);
    return 0;
}
