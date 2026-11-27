#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
    uint32_t val;
    struct Node *next;
} Node;

typedef struct Tree {
    uint32_t key;
    uint32_t cnt;
    struct Tree *l;
    struct Tree *r;
} Tree;

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static Node *gen_list(uint32_t n, uint32_t seed, int skew) {
    Node *acc = NULL;
    for (uint32_t i = 0; i < n; i++) {
        seed = prng(seed);
        uint32_t v = skew ? (seed & 63u) : seed;
        Node *nd = (Node *)malloc(sizeof(Node));
        nd->val = v;
        nd->next = acc;
        acc = nd;
    }
    return acc;
}

static uint32_t hash_list(Node *xs, uint32_t acc) {
    while (xs) {
        Node *nxt = xs->next;
        acc = (acc * 2654435761u) ^ xs->val;
        free(xs);
        xs = nxt;
    }
    return acc;
}

static Tree *build_tree(uint32_t fuel, Node *xs) {
    if (!xs) return NULL;
    if (fuel == 0u) {
        uint32_t h = hash_list(xs, 1u);
        Tree *t = (Tree *)malloc(sizeof(Tree));
        t->key = h;
        t->cnt = 1u;
        t->l = NULL;
        t->r = NULL;
        return t;
    }
    uint32_t piv = xs->val;
    Node *rest = xs->next;
    free(xs);
    Node *lt = NULL;
    Node *gt = NULL;
    uint32_t cnt = 1u;
    while (rest) {
        Node *cur = rest;
        rest = rest->next;
        if (cur->val < piv) {
            cur->next = lt;
            lt = cur;
        } else if (cur->val > piv) {
            cur->next = gt;
            gt = cur;
        } else {
            cnt++;
            free(cur);
        }
    }
    Tree *t = (Tree *)malloc(sizeof(Tree));
    t->key = piv;
    t->cnt = cnt;
    t->l = build_tree(fuel - 1u, lt);
    t->r = build_tree(fuel - 1u, gt);
    return t;
}

static uint32_t fold_tree(Tree *t, uint32_t acc) {
    if (!t) return acc;
    uint32_t a1 = fold_tree(t->l, acc);
    uint32_t a2 = ((a1 * 2654435761u) ^ t->key) + t->cnt;
    uint32_t a3 = fold_tree(t->r, a2);
    free(t);
    return a3;
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t n = skew ? 8192u : 4096u;
    uint32_t rounds = skew ? 45u : 45u;
    uint32_t seed = skew ? 271828183u : 314159265u;
    uint32_t acc = 2166136261u;
    for (uint32_t r = 0; r < rounds; r++) {
        Node *xs = gen_list(n, seed, skew);
        Tree *t = build_tree(64u, xs);
        acc = fold_tree(t, acc);
        seed = prng(seed);
    }
    printf("%u\n", acc);
    return 0;
}
