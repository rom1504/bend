/* Expr, p37.expr.pick, p37.expr and eval from coverage-expression-32.bend. */
#include <stdint.h>
#include <stdlib.h>

enum Kind { LITERAL, ADD, MULTIPLY, SUBTRACT };
typedef struct Expr Expr;
struct Expr {
    enum Kind kind;
    union {
        uint32_t literal;
        struct { Expr *left, *right; } binary;
    } value;
};

static Expr *literal(uint32_t value) {
    Expr *expression = malloc(sizeof *expression);
    if (expression == NULL) abort();
    expression->kind = LITERAL;
    expression->value.literal = value;
    return expression;
}

static Expr *binary(enum Kind kind, Expr *left, Expr *right) {
    Expr *expression = malloc(sizeof *expression);
    if (expression == NULL) abort();
    expression->kind = kind;
    expression->value.binary.left = left;
    expression->value.binary.right = right;
    return expression;
}

static Expr *generate(uint32_t count, uint32_t seed) {
    if (count == 0) return literal(seed);
    Expr *recursive = generate(count - UINT32_C(1), (uint32_t)(seed + UINT32_C(1)));
    switch (seed % UINT32_C(3)) {
    case 0:
        return binary(ADD, recursive, binary(MULTIPLY, literal(seed), literal(UINT32_C(3))));
    case 1:
        return binary(MULTIPLY, recursive,
                      binary(ADD, literal(seed % UINT32_C(5)), literal(UINT32_C(1))));
    default:
        return binary(SUBTRACT, recursive, binary(ADD, literal(seed), literal(UINT32_C(7))));
    }
}

static uint32_t evaluate(Expr *expression) {
    enum Kind kind = expression->kind;
    if (kind == LITERAL) {
        uint32_t result = expression->value.literal;
        free(expression);
        return result;
    }
    Expr *left = expression->value.binary.left;
    Expr *right = expression->value.binary.right;
    free(expression);
    uint32_t a = evaluate(left);
    uint32_t b = evaluate(right);
    switch (kind) {
    case ADD: return (uint32_t)(a + b);
    case MULTIPLY: return (uint32_t)(a * b);
    case SUBTRACT: return (uint32_t)(a - b);
    default: abort();
    }
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    Expr *expression = generate(a, b);
    return evaluate(expression);
}
