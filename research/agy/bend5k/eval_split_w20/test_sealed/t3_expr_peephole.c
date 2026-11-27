#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    E_LIT = 0,
    E_VAR = 1,
    E_ADD = 2,
    E_MUL = 3,
    E_XOR = 4,
    E_NEG = 5
} ExprTag;

typedef struct Expr {
    ExprTag tag;
    uint32_t val;
    struct Expr *a;
    struct Expr *b;
} Expr;

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static Expr *mk_lit(uint32_t v) {
    Expr *e = (Expr *)malloc(sizeof(Expr));
    e->tag = E_LIT; e->val = v; e->a = NULL; e->b = NULL;
    return e;
}

static Expr *mk_var(uint32_t id) {
    Expr *e = (Expr *)malloc(sizeof(Expr));
    e->tag = E_VAR; e->val = id; e->a = NULL; e->b = NULL;
    return e;
}

static Expr *mk_bin(ExprTag tag, Expr *a, Expr *b) {
    Expr *e = (Expr *)malloc(sizeof(Expr));
    e->tag = tag; e->val = 0; e->a = a; e->b = b;
    return e;
}

static Expr *mk_neg(Expr *a) {
    Expr *e = (Expr *)malloc(sizeof(Expr));
    e->tag = E_NEG; e->val = 0; e->a = a; e->b = NULL;
    return e;
}

static void free_expr(Expr *e) {
    if (!e) return;
    free_expr(e->a);
    free_expr(e->b);
    free(e);
}

static Expr *build_expr(uint32_t depth, uint32_t seed, int deep_mode) {
    if (depth == 0u) {
        if ((seed & 1u) == 0u) {
            uint32_t v = deep_mode ? (seed & 3u) : (seed & 7u);
            return mk_lit(v);
        } else {
            return mk_var((seed >> 1) & 3u);
        }
    }
    uint32_t s1 = prng(seed);
    uint32_t s2 = prng(s1 ^ 2654435761u);
    uint32_t op = seed & 3u;
    if (op == 0u) {
        return mk_bin(E_ADD, build_expr(depth - 1u, s1, deep_mode), build_expr(depth - 1u, s2, deep_mode));
    } else if (op == 1u) {
        return mk_bin(E_MUL, build_expr(depth - 1u, s1, deep_mode), build_expr(depth - 1u, s2, deep_mode));
    } else if (op == 2u) {
        return mk_bin(E_XOR, build_expr(depth - 1u, s1, deep_mode), build_expr(depth - 1u, s2, deep_mode));
    } else {
        return mk_neg(build_expr(depth - 1u, s1, deep_mode));
    }
}

static Expr *simplify(Expr *e) {
    switch (e->tag) {
        case E_LIT:
        case E_VAR:
            return e;
        case E_NEG: {
            Expr *sa = simplify(e->a);
            free(e);
            if (sa->tag == E_LIT) {
                sa->val = 0u - sa->val;
                return sa;
            }
            if (sa->tag == E_NEG) {
                Expr *inner = sa->a;
                free(sa);
                return inner;
            }
            return mk_neg(sa);
        }
        case E_ADD: {
            Expr *sa = simplify(e->a);
            Expr *sb = simplify(e->b);
            free(e);
            if (sa->tag == E_LIT && sb->tag == E_LIT) {
                uint32_t v = sa->val + sb->val;
                free(sa); free(sb);
                return mk_lit(v);
            }
            if (sa->tag == E_LIT && sa->val == 0u) {
                free(sa);
                return sb;
            }
            if (sb->tag == E_LIT && sb->val == 0u) {
                free(sb);
                return sa;
            }
            return mk_bin(E_ADD, sa, sb);
        }
        case E_MUL: {
            Expr *sa = simplify(e->a);
            Expr *sb = simplify(e->b);
            free(e);
            if (sa->tag == E_LIT && sb->tag == E_LIT) {
                uint32_t v = sa->val * sb->val;
                free(sa); free(sb);
                return mk_lit(v);
            }
            if (sa->tag == E_LIT && sa->val == 0u) {
                free(sa); free_expr(sb);
                return mk_lit(0u);
            }
            if (sa->tag == E_LIT && sa->val == 1u) {
                free(sa);
                return sb;
            }
            if (sb->tag == E_LIT && sb->val == 0u) {
                free_expr(sa); free(sb);
                return mk_lit(0u);
            }
            if (sb->tag == E_LIT && sb->val == 1u) {
                free(sb);
                return sa;
            }
            return mk_bin(E_MUL, sa, sb);
        }
        case E_XOR: {
            Expr *sa = simplify(e->a);
            Expr *sb = simplify(e->b);
            free(e);
            if (sa->tag == E_LIT && sb->tag == E_LIT) {
                uint32_t v = sa->val ^ sb->val;
                free(sa); free(sb);
                return mk_lit(v);
            }
            if (sa->tag == E_LIT && sa->val == 0u) {
                free(sa);
                return sb;
            }
            if (sb->tag == E_LIT && sb->val == 0u) {
                free(sb);
                return sa;
            }
            return mk_bin(E_XOR, sa, sb);
        }
    }
    return e;
}

static uint32_t eval_expr(Expr *e, uint32_t x0, uint32_t x1, uint32_t x2, uint32_t x3) {
    uint32_t res = 0u;
    switch (e->tag) {
        case E_LIT: res = e->val; break;
        case E_VAR:
            if (e->val == 0u) res = x0;
            else if (e->val == 1u) res = x1;
            else if (e->val == 2u) res = x2;
            else res = x3;
            break;
        case E_NEG: res = 0u - eval_expr(e->a, x0, x1, x2, x3); break;
        case E_ADD: res = eval_expr(e->a, x0, x1, x2, x3) + eval_expr(e->b, x0, x1, x2, x3); break;
        case E_MUL: res = eval_expr(e->a, x0, x1, x2, x3) * eval_expr(e->b, x0, x1, x2, x3); break;
        case E_XOR: res = eval_expr(e->a, x0, x1, x2, x3) ^ eval_expr(e->b, x0, x1, x2, x3); break;
    }
    free(e);
    return res;
}

int main(int argc, char **argv) {
    int deep = (argc > 1 && strcmp(argv[1], "deep") == 0);
    uint32_t depth = deep ? 13u : 11u;
    uint32_t rounds = deep ? 360u : 1120u;
    uint32_t seed = deep ? 777777771u : 135792468u;
    uint32_t acc = 2166136261u;
    for (uint32_t r = 0; r < rounds; r++) {
        Expr *e = build_expr(depth, seed, deep);
        Expr *se = simplify(e);
        uint32_t v = eval_expr(se, r + 3u, r * 7u + 1u, (r ^ 13u) + 5u, r + 19u);
        acc = (acc * 2654435761u) ^ v;
        seed = prng(seed);
    }
    printf("%u\n", acc);
    return 0;
}
