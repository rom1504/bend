/* Harness for unmodified Embench-IoT sglib.h Red-Black Tree */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "support.h"
#include "../embench-iot/src/sglib-combined/sglib.h"

typedef struct rb_node {
  uint32_t key;
  char color_field;
  struct rb_node *left;
  struct rb_node *right;
} rb_node;

#define RB_CMP(x, y) (((x)->key > (y)->key) - ((x)->key < (y)->key))

SGLIB_DEFINE_RBTREE_PROTOTYPES(rb_node, left, right, color_field, RB_CMP)
SGLIB_DEFINE_RBTREE_FUNCTIONS(rb_node, left, right, color_field, RB_CMP)

int main(void) {
  const uint32_t N = 512;
  const uint32_t ROUNDS = 300;
  rb_node *pool = (rb_node *)malloc(sizeof(rb_node) * N);
  uint32_t seed = 0xCAFEBABEu;
  uint32_t acc = 2166136261u;

  for (uint32_t r = 0; r < ROUNDS; r++) {
    rb_node *tree = NULL;
    for (uint32_t i = 0; i < N; i++) {
      seed = seed * 1664525u + 1013904223u;
      uint32_t k = seed & 0x3FFu;
      rb_node probe;
      probe.key = k;
      if (sglib_rb_node_find_member(tree, &probe) == NULL) {
        pool[i].key = k;
        sglib_rb_node_add(&tree, &pool[i]);
      }
    }
    struct sglib_rb_node_iterator it;
    for (rb_node *te = sglib_rb_node_it_init_inorder(&it, tree);
         te != NULL;
         te = sglib_rb_node_it_next(&it)) {
      acc = (acc ^ te->key) * 16777619u;
    }
  }
  free(pool);
  printf("%u\n", acc);
  return 0;
}
