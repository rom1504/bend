/* p37.list, keep_gt1, dbl, suma and bench from coverage-list-pipeline-128.bend. */
#include <stdint.h>
#include <stdlib.h>

typedef struct List List;
struct List { uint32_t head; List *tail; };

static List *cons(uint32_t head, List *tail) {
    List *node = malloc(sizeof *node);
    if (node == NULL) abort();
    node->head = head;
    node->tail = tail;
    return node;
}

static List *generate(uint32_t count, uint32_t seed) {
    if (count == 0) return NULL;
    uint32_t next = (uint32_t)(seed * UINT32_C(1664525) + UINT32_C(1013904223));
    List *tail = generate(count - UINT32_C(1), next);
    return cons(seed % UINT32_C(16), tail);
}

static List *keep_gt1(List *list) {
    if (list == NULL) return NULL;
    uint32_t head = list->head;
    List *tail = list->tail;
    free(list);
    List *rest = keep_gt1(tail);
    return head > UINT32_C(1) ? cons(head, rest) : rest;
}

static List *double_values(List *list) {
    if (list == NULL) return NULL;
    uint32_t head = list->head;
    List *tail = list->tail;
    free(list);
    List *rest = double_values(tail);
    return cons((uint32_t)(head * UINT32_C(2)), rest);
}

static uint32_t sum(List *list, uint32_t accumulator) {
    while (list != NULL) {
        uint32_t head = list->head;
        List *tail = list->tail;
        free(list);
        accumulator = (uint32_t)(accumulator + head);
        list = tail;
    }
    return accumulator;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    List *generated = generate(a, b);
    List *filtered = keep_gt1(generated);
    List *doubled = double_values(filtered);
    return sum(doubled, 0);
}
