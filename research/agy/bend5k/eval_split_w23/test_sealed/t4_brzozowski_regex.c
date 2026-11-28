/* t4_brzozowski_regex.c — Independent C oracle for Brzozowski Derivative
 * Regular Expression Matcher over recursive Data ADT Regex.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { RE_EMPTY = 0, RE_EPS = 1, RE_LIT = 2, RE_SEQ = 3, RE_ALT = 4, RE_STAR = 5 };

typedef struct Re {
    uint32_t tag;
    uint32_t ch;
    struct Re *a;
    struct Re *b;
} Re;

static Re *pool = NULL;
static uint32_t pool_top = 0;

static inline Re *alloc_re(uint32_t tag, uint32_t ch, Re *a, Re *b) {
    Re *r = &pool[pool_top++];
    r->tag = tag;
    r->ch = ch;
    r->a = a;
    r->b = b;
    return r;
}

static Re RE_EMPTY_NODE = { RE_EMPTY, 0, NULL, NULL };
static Re RE_EPS_NODE   = { RE_EPS,   0, NULL, NULL };

static inline Re *mk_seq(Re *a, Re *b) {
    if (a->tag == RE_EMPTY || b->tag == RE_EMPTY) return &RE_EMPTY_NODE;
    if (a->tag == RE_EPS) return b;
    if (b->tag == RE_EPS) return a;
    return alloc_re(RE_SEQ, 0, a, b);
}

static inline Re *mk_alt(Re *a, Re *b) {
    if (a->tag == RE_EMPTY) return b;
    if (b->tag == RE_EMPTY) return a;
    return alloc_re(RE_ALT, 0, a, b);
}

static uint32_t nullable(const Re *r) {
    switch (r->tag) {
        case RE_EMPTY: return 0u;
        case RE_EPS:   return 1u;
        case RE_LIT:   return 0u;
        case RE_SEQ:   return nullable(r->a) & nullable(r->b);
        case RE_ALT:   return nullable(r->a) | nullable(r->b);
        case RE_STAR:  return 1u;
    }
    return 0u;
}

static Re *deriv(uint32_t c, Re *r) {
    switch (r->tag) {
        case RE_EMPTY: return &RE_EMPTY_NODE;
        case RE_EPS:   return &RE_EMPTY_NODE;
        case RE_LIT:   return (r->ch == c) ? &RE_EPS_NODE : &RE_EMPTY_NODE;
        case RE_ALT:   return mk_alt(deriv(c, r->a), deriv(c, r->b));
        case RE_STAR:  return mk_seq(deriv(c, r->a), r);
        case RE_SEQ: {
            Re *da = mk_seq(deriv(c, r->a), r->b);
            if (nullable(r->a)) {
                return mk_alt(da, deriv(c, r->b));
            }
            return da;
        }
    }
    return &RE_EMPTY_NODE;
}

static inline uint32_t prng(uint32_t x) {
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return x;
}

static Re *build_regex(uint32_t rd, int deep) {
    uint32_t c0 = rd & 3u;
    uint32_t c1 = (rd + 1u) & 3u;
    uint32_t c2 = (rd + 2u) & 3u;
    uint32_t c3 = (rd + 3u) & 3u;

    Re *l0 = alloc_re(RE_LIT, c0, NULL, NULL);
    Re *l1 = alloc_re(RE_LIT, c1, NULL, NULL);
    Re *l2 = alloc_re(RE_LIT, c2, NULL, NULL);
    Re *l3 = alloc_re(RE_LIT, c3, NULL, NULL);

    /* (c0 | c1)* . (c0 . c2 | c1 . c3) . (c2 | c3)* */
    Re *p1 = alloc_re(RE_STAR, 0, mk_alt(l0, l1), NULL);
    Re *p2 = mk_alt(mk_seq(l0, l2), mk_seq(l1, l3));
    Re *p3 = alloc_re(RE_STAR, 0, mk_alt(l2, l3), NULL);
    Re *base = mk_seq(p1, mk_seq(p2, p3));
    if (!deep) return base;

    /* Deep: base . (c0 | c2 | c1.c0)* . (c3 | c1) */
    Re *p4 = alloc_re(RE_STAR, 0, mk_alt(mk_alt(l0, l2), mk_seq(l1, l0)), NULL);
    Re *p5 = mk_alt(l3, l1);
    return mk_seq(base, mk_seq(p4, p5));
}

static uint32_t run_bench(uint32_t rounds, uint32_t n_str, uint32_t slen, int deep) {
    pool = (Re *)malloc(sizeof(Re) * 2000000u);
    uint32_t seed = deep ? 424242421u : 123123127u;
    uint32_t acc = 2166136261u;
    uint32_t hits = 0;

    for (uint32_t rd = 0; rd < rounds; rd++) {
        pool_top = 0;
        Re *pat = build_regex(rd, deep);
        for (uint32_t s = 0; s < n_str; s++) {
            Re *cur = pat;
            for (uint32_t i = 0; i < slen; i++) {
                seed = prng(seed);
                uint32_t ch = seed & 3u;
                cur = deriv(ch, cur);
            }
            uint32_t ok = nullable(cur);
            hits += ok;
            acc = (acc * 16777619u) ^ ((ok << 8) ^ (s + rd));
        }
    }
    free(pool);
    return acc ^ (hits * 2246822519u);
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t rounds = deep ? 150u : 420u;
    uint32_t n_str  = 64u;
    uint32_t slen   = deep ? 14u : 10u;
    printf("%u\n", run_bench(rounds, n_str, slen, deep));
    return 0;
}
