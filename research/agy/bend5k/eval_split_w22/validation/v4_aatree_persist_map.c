#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct AANode {
    uint32_t lvl;
    uint32_t key;
    uint32_t val;
    struct AANode *l;
    struct AANode *r;
} AANode;

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static AANode *pool;
static uint32_t pool_top = 0;

static inline AANode *mk_node(uint32_t lvl, uint32_t key, uint32_t val, AANode *l, AANode *r) {
    AANode *n = &pool[pool_top++];
    n->lvl = lvl;
    n->key = key;
    n->val = val;
    n->l = l;
    n->r = r;
    return n;
}

static inline AANode *aa_skew(AANode *t) {
    if (!t || !t->l) return t;
    if (t->l->lvl == t->lvl) {
        AANode *l = t->l;
        return mk_node(l->lvl, l->key, l->val, l->l, mk_node(t->lvl, t->key, t->val, l->r, t->r));
    }
    return t;
}

static inline AANode *aa_split(AANode *t) {
    if (!t || !t->r || !t->r->r) return t;
    if (t->lvl == t->r->r->lvl) {
        AANode *r = t->r;
        return mk_node(r->lvl + 1u, r->key, r->val, mk_node(t->lvl, t->key, t->val, t->l, r->l), r->r);
    }
    return t;
}

static AANode *aa_insert(AANode *t, uint32_t k, uint32_t v) {
    if (!t) return mk_node(1u, k, v, NULL, NULL);
    AANode *res;
    if (k < t->key) {
        res = mk_node(t->lvl, t->key, t->val, aa_insert(t->l, k, v), t->r);
    } else if (k > t->key) {
        res = mk_node(t->lvl, t->key, t->val, t->l, aa_insert(t->r, k, v));
    } else {
        return mk_node(t->lvl, k, v, t->l, t->r);
    }
    return aa_split(aa_skew(res));
}

static uint32_t aa_lookup(AANode *t, uint32_t k) {
    while (t) {
        if (k < t->key) t = t->l;
        else if (k > t->key) t = t->r;
        else return t->val;
    }
    return 0u;
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t ROUNDS = deep ? 80u : 140u;
    uint32_t INSERTS = deep ? 512u : 256u;
    uint32_t QUERIES = deep ? 512u : 512u;

    pool = (AANode *)malloc(262144u * sizeof(AANode));
    uint32_t seed = deep ? 135792468u : 246813579u;
    uint32_t acc = 2166136261u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        pool_top = 0u;
        AANode *root = NULL;
        for (uint32_t i = 0; i < INSERTS; i++) {
            seed = prng(seed);
            uint32_t k = deep ? ((i * 3u) ^ (seed & 15u)) : (seed & 1023u);
            uint32_t v = (seed >> 10) ^ (i + rd);
            root = aa_insert(root, k, v);
        }
        for (uint32_t q = 0; q < QUERIES; q++) {
            seed = prng(seed);
            uint32_t k = deep ? ((q * 3u) ^ (seed & 15u)) : (seed & 1023u);
            uint32_t val = aa_lookup(root, k);
            acc = (acc * 16777619u) ^ val;
        }
    }

    printf("%u\n", acc);
    free(pool);
    return 0;
}
