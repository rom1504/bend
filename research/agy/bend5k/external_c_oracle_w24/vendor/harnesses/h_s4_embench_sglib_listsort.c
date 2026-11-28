/* Harness for unmodified Embench-IoT sglib.h Singly-Linked List Mergesort */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "support.h"
#include "../embench-iot/src/sglib-combined/sglib.h"

typedef struct sl_node {
  uint32_t key;
  struct sl_node *next;
} sl_node;

#define SL_CMP(x, y) (((x)->key > (y)->key) - ((x)->key < (y)->key))

SGLIB_DEFINE_LIST_PROTOTYPES(sl_node, SL_CMP, next)
SGLIB_DEFINE_LIST_FUNCTIONS(sl_node, SL_CMP, next)

int main(void) {
  const uint32_t N = 512;
  const uint32_t ROUNDS = 400;
  sl_node *pool = (sl_node *)malloc(sizeof(sl_node) * N);
  uint32_t seed = 0x13579BDFu;
  uint32_t acc = 2166136261u;

  for (uint32_t r = 0; r < ROUNDS; r++) {
    sl_node *head = NULL;
    for (uint32_t i = 0; i < N; i++) {
      seed = seed * 1664525u + 1013904223u;
      pool[i].key = seed >> 16;
      pool[i].next = head;
      head = &pool[i];
    }
    sglib_sl_node_sort(&head);
    for (sl_node *cur = head; cur != NULL; cur = cur->next) {
      acc = (acc ^ cur->key) * 16777619u;
    }
  }
  free(pool);
  printf("%u\n", acc);
  return 0;
}
