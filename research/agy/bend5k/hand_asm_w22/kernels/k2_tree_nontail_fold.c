#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

typedef struct BTree {
    int is_leaf;
    uint32_t v;
    uint32_t w;
    uint32_t tag;
    struct BTree *l;
    struct BTree *r;
} BTree;

static BTree *build_tree(uint32_t depth, uint32_t base) {
    BTree *n = (BTree *)malloc(sizeof(BTree));
    if (depth == 0u) {
        n->is_leaf = 1;
        n->v = ((base + 1u) * 2654435761u) ^ base;
        n->w = 0u;
        n->tag = 0u;
        n->l = NULL;
        n->r = NULL;
        return n;
    }
    uint32_t half = 1u << (depth - 1u);
    n->is_leaf = 0;
    n->v = 0u;
    n->w = base * 17u + (half << 3);
    n->tag = (base ^ half) & 255u;
    n->l = build_tree(depth - 1u, base);
    n->r = build_tree(depth - 1u, base + half);
    return n;
}

static uint32_t fold_tree(const BTree *t, uint32_t salt) {
    if (t->is_leaf) {
        return ((t->v ^ salt) * 16777619u) ^ t->v;
    }
    uint32_t fl = fold_tree(t->l, salt + t->tag);
    uint32_t fr = fold_tree(t->r, salt ^ t->w);
    return ((fl * 16777619u) ^ fr) + t->w;
}

static void free_tree(BTree *t) {
    if (!t) return;
    free_tree(t->l);
    free_tree(t->r);
    free(t);
}

int main(void) {
    BTree *root = build_tree(10u, 0u);
    uint32_t seed = 987654321u;
    uint32_t acc = 2166136261u;
    for (uint32_t i = 0; i < 12000u; i++) {
        seed = prng(seed);
        uint32_t v = fold_tree(root, seed);
        acc = (acc * 16777619u) ^ v;
    }
    printf("%u\n", acc);
    free_tree(root);
    return 0;
}
