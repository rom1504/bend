#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

typedef struct Node {
    uint32_t head;
    struct Node *tail;
} Node;

static Node *gen_list(uint32_t n, uint32_t seed) {
    Node *acc = NULL;
    for (uint32_t i = 0; i < n; i++) {
        seed = prng(seed);
        Node *nd = (Node *)malloc(sizeof(Node));
        nd->head = seed;
        nd->tail = acc;
        acc = nd;
    }
    return acc;
}

static void split_list(Node *xs, Node *a, Node *b, Node **oa, Node **ob) {
    while (xs != NULL) {
        Node *next = xs->tail;
        xs->tail = a;
        Node *nb = xs;
        a = b;
        b = nb;
        xs = next;
    }
    *oa = a;
    *ob = b;
}

static Node *merge_lists(Node *xs, Node *ys) {
    Node dummy;
    Node *tail = &dummy;
    while (xs != NULL && ys != NULL) {
        if (xs->head <= ys->head) {
            tail->tail = xs;
            tail = xs;
            xs = xs->tail;
        } else {
            tail->tail = ys;
            tail = ys;
            ys = ys->tail;
        }
    }
    tail->tail = (xs != NULL) ? xs : ys;
    return dummy.tail;
}

static Node *msort(uint32_t fuel, Node *xs) {
    if (fuel == 0 || xs == NULL || xs->tail == NULL) return xs;
    Node *x = xs;
    Node *y = xs->tail;
    Node *rest2 = y->tail;
    x->tail = NULL;
    y->tail = NULL;
    Node *a = NULL, *b = NULL;
    split_list(rest2, x, y, &a, &b);
    return merge_lists(msort(fuel - 1, a), msort(fuel - 1, b));
}

int main(void) {
    uint32_t seed = 314159265u;
    uint32_t acc = 2166136261u;
    for (uint32_t r = 0; r < 20; r++) {
        Node *xs = gen_list(8192, seed);
        Node *ys = msort(16, xs);
        while (ys != NULL) {
            acc = (acc * 2654435761u) ^ ys->head;
            Node *nx = ys->tail;
            free(ys);
            ys = nx;
        }
        seed = prng(seed);
    }
    printf("%u\n", acc);
    return 0;
}
