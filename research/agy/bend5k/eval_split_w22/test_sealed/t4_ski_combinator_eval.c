#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { TAG_S = 0, TAG_K = 1, TAG_I = 2, TAG_SUCC = 3, TAG_NUM = 4, TAG_APP = 5 };

typedef struct Term {
    uint32_t tag;
    uint32_t val;
    struct Term *f;
    struct Term *x;
} Term;

typedef struct Spine {
    Term *arg;
    struct Spine *rest;
} Spine;

static Term *tpool;
static uint32_t ttop;
static Spine *spool;
static uint32_t stop;

static inline Term *mk_atom(uint32_t tag, uint32_t val) {
    Term *t = &tpool[ttop++];
    t->tag = tag; t->val = val; t->f = NULL; t->x = NULL;
    return t;
}

static inline Term *mk_app(Term *f, Term *x) {
    Term *t = &tpool[ttop++];
    t->tag = TAG_APP; t->val = 0; t->f = f; t->x = x;
    return t;
}

static inline Spine *mk_cons(Term *arg, Spine *rest) {
    Spine *s = &spool[stop++];
    s->arg = arg; s->rest = rest;
    return s;
}

static Term *comb_B(void) {
    Term *S = mk_atom(TAG_S, 0);
    Term *K = mk_atom(TAG_K, 0);
    return mk_app(mk_app(S, mk_app(K, S)), K);
}

static Term *church_num(uint32_t n) {
    Term *cur = mk_app(mk_atom(TAG_K, 0), mk_atom(TAG_I, 0));
    Term *succ = mk_app(mk_atom(TAG_S, 0), comb_B());
    for (uint32_t i = 0; i < n; i++) {
        cur = mk_app(succ, cur);
    }
    return cur;
}

static uint32_t eval_ski(uint32_t fuel, Term *t, Spine *sp) {
    while (fuel > 0u) {
        fuel--;
        switch (t->tag) {
            case TAG_APP:
                sp = mk_cons(t->x, sp);
                t = t->f;
                break;
            case TAG_I:
                if (!sp) return 0u;
                t = sp->arg;
                sp = sp->rest;
                break;
            case TAG_K:
                if (!sp || !sp->rest) return 0u;
                t = sp->arg;
                sp = sp->rest->rest;
                break;
            case TAG_S: {
                if (!sp || !sp->rest || !sp->rest->rest) return 0u;
                Term *f = sp->arg;
                Term *g = sp->rest->arg;
                Term *x = sp->rest->rest->arg;
                sp = sp->rest->rest->rest;
                t = mk_app(mk_app(f, x), mk_app(g, x));
                break;
            }
            case TAG_SUCC:
                if (!sp) return 0u;
                return 1u + eval_ski(fuel, sp->arg, sp->rest);
            case TAG_NUM:
                return t->val;
            default:
                return 0u;
        }
    }
    return 0u;
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t ROUNDS = deep ? 1260u : 2700u;

    tpool = (Term *)malloc(262144u * sizeof(Term));
    spool = (Spine *)malloc(262144u * sizeof(Spine));

    uint32_t acc = 2166136261u;
    for (uint32_t rd = 0; rd < ROUNDS; rd++) {
        ttop = 0u;
        stop = 0u;
        uint32_t a = 3u + (rd & 3u);
        uint32_t b = 3u + ((rd >> 2) & 3u);
        uint32_t base = rd & 15u;
        Term *ca = church_num(a);
        Term *cb = church_num(b);
        Term *expr;
        if (deep) {
            uint32_t c = 2u + ((rd >> 4) & 3u);
            Term *cc = church_num(c);
            Term *prod1 = mk_app(mk_app(comb_B(), ca), cb);
            expr = mk_app(mk_app(comb_B(), prod1), cc);
        } else {
            expr = mk_app(mk_app(comb_B(), ca), cb);
        }
        Term *applied = mk_app(mk_app(expr, mk_atom(TAG_SUCC, 0)), mk_atom(TAG_NUM, base));
        uint32_t v = eval_ski(40000u, applied, NULL);
        acc = (acc * 16777619u) ^ v;
    }

    printf("%u\n", acc);
    free(tpool);
    free(spool);
    return 0;
}
