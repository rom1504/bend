/* v4_leftist_heap_merge.c — Independent C oracle for Persistent Leftist Heap
 * priority queue (rank-balanced merge, insert, delete_min heap-sort) over ADT.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct LNode {
    uint32_t rk;
    uint32_t key;
    uint32_t val;
    struct LNode *l;
    struct LNode *r;
} LNode;

static LNode *pool = NULL;
static uint32_t pool_top = 0;

static inline LNode *alloc_node(uint32_t rk, uint32_t key, uint32_t val, LNode *l, LNode *r) {
    LNode *n = &pool[pool_top++];
    n->rk = rk;
    n->key = key;
    n->val = val;
    n->l = l;
    n->r = r;
    return n;
}

static inline uint32_t heap_rank(const LNode *h) {
    return h ? h->rk : 0u;
}

static inline LNode *make_node(uint32_t key, uint32_t val, LNode *a, LNode *b) {
    uint32_t ra = heap_rank(a);
    uint32_t rb = heap_rank(b);
    if (ra >= rb) {
        return alloc_node(rb + 1u, key, val, a, b);
    } else {
        return alloc_node(ra + 1u, key, val, b, a);
    }
}

static LNode *merge_heap(LNode *h1, LNode *h2) {
    if (!h1) return h2;
    if (!h2) return h1;
    if (h1->key <= h2->key) {
        return make_node(h1->key, h1->val, h1->l, merge_heap(h1->r, h2));
    } else {
        return make_node(h2->key, h2->val, h2->l, merge_heap(h1, h2->r));
    }
}

static inline uint32_t prng(uint32_t x) {
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return x;
}

static uint32_t run_bench(uint32_t rounds, uint32_t count) {
    pool = (LNode *)malloc(sizeof(LNode) * (size_t)count * 64u);
    uint32_t seed = (count == 512u) ? 314159265u : 271828182u;
    uint32_t acc = 2166136261u;

    for (uint32_t rd = 0; rd < rounds; rd++) {
        pool_top = 0;
        LNode *h = NULL;
        for (uint32_t i = 0; i < count; i++) {
            seed = prng(seed);
            uint32_t k = seed & 65535u;
            uint32_t v = (seed >> 16) ^ (i + rd);
            LNode *s = alloc_node(1u, k, v, NULL, NULL);
            h = merge_heap(s, h);
        }
        for (uint32_t i = 0; i < count; i++) {
            if (!h) break;
            acc = (acc * 16777619u) ^ ((h->key << 16) ^ h->val);
            h = merge_heap(h->l, h->r);
        }
    }
    free(pool);
    return acc;
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t rounds = deep ? 60 : 140;
    uint32_t count = deep ? 512 : 256;
    printf("%u\n", run_bench(rounds, count));
    return 0;
}
