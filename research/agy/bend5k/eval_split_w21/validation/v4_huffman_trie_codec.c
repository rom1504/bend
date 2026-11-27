#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

typedef struct Trie {
    int is_leaf;
    uint32_t sym;
    struct Trie *l;
    struct Trie *r;
} Trie;

static Trie *mk_leaf(uint32_t sym) {
    Trie *t = (Trie *)malloc(sizeof(Trie));
    t->is_leaf = 1;
    t->sym = sym;
    t->l = NULL;
    t->r = NULL;
    return t;
}

static Trie *mk_node(Trie *l, Trie *r) {
    Trie *t = (Trie *)malloc(sizeof(Trie));
    t->is_leaf = 0;
    t->sym = 0u;
    t->l = l;
    t->r = r;
    return t;
}

static void free_trie(Trie *t) {
    if (!t) return;
    free_trie(t->l);
    free_trie(t->r);
    free(t);
}

// Balanced binary prefix tree of depth d (2^d leaves)
static Trie *build_balanced(uint32_t depth, uint32_t base_sym, uint32_t salt) {
    if (depth == 0u) {
        return mk_leaf((base_sym ^ salt) & 255u);
    }
    uint32_t half = 1u << (depth - 1u);
    Trie *l = build_balanced(depth - 1u, base_sym, salt);
    Trie *r = build_balanced(depth - 1u, base_sym + half, salt);
    return mk_node(l, r);
}

// Skewed / Huffman-like spine prefix tree of depth d
static Trie *build_skewed(uint32_t depth, uint32_t sym, uint32_t salt) {
    if (depth == 0u) {
        return mk_leaf((sym ^ salt) & 255u);
    }
    if ((depth & 3u) == 0u) {
        Trie *l = build_balanced(2u, sym, salt);
        Trie *r = build_skewed(depth - 1u, sym + 4u, salt);
        return mk_node(l, r);
    } else {
        Trie *l = mk_leaf(((sym + depth) ^ salt) & 255u);
        Trie *r = build_skewed(depth - 1u, sym + 1u, salt);
        return mk_node(l, r);
    }
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t ROUNDS = deep ? 40u : 45u;
    uint32_t WORDS = deep ? 1536u : 2048u;

    uint32_t h = 2166136261u;
    uint32_t total_syms = 0u;
    uint32_t seed = deep ? 777777771u : 246813579u;

    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        Trie *root = deep ? build_skewed(14u, rd, rd * 17u) : build_balanced(6u, rd, rd * 31u);
        const Trie *cur = root;
        uint32_t plen = 0u;
        for (uint32_t w = 0; w < WORDS; w++) {
            seed = prng(seed);
            uint32_t bits = seed;
            for (uint32_t b = 0; b < 32u; b++) {
                uint32_t bit = bits & 1u;
                bits >>= 1;
                cur = bit ? cur->r : cur->l;
                plen += 1u;
                if (cur->is_leaf) {
                    h = (h * 16777619u) ^ cur->sym ^ (plen << 8);
                    total_syms += 1u;
                    cur = root;
                    plen = 0u;
                }
            }
        }
        h = (h * 2654435761u) ^ plen;
        free_trie(root);
    }

    uint32_t chk = h ^ (total_syms * 2654435761u);
    printf("%u\n", chk);
    return 0;
}
