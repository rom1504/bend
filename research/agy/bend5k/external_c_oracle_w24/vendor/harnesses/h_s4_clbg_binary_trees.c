/* Harness for unmodified CLBG binarytrees (bench/algorithm/binarytrees/2.c) */
#include <stdint.h>
#include <stdio.h>

#define main clbg_bt_orig_main
#include "../clbg/bench/algorithm/binarytrees/2.c"
#undef main

int main(void) {
  const intnative_t min_depth = 4;
  const intnative_t max_depth = 14;
  apr_initialize();
  apr_pool_t *pool;
  apr_pool_create_unmanaged(&pool);

  uint32_t acc = 2166136261u;
  tree_node *stretch = create_Tree(max_depth + 1, pool);
  acc = (acc ^ (uint32_t)compute_Tree_Checksum(stretch)) * 16777619u;
  apr_pool_clear(pool);

  tree_node *long_lived = create_Tree(max_depth, pool);

  apr_pool_t *tpool;
  apr_pool_create_unmanaged(&tpool);
  for (intnative_t d = min_depth; d <= max_depth; d += 2) {
    intnative_t iters = 1 << (max_depth - d + min_depth);
    uint32_t chk = 0;
    for (intnative_t i = 0; i < iters; i++) {
      apr_pool_clear(tpool);
      chk += (uint32_t)compute_Tree_Checksum(create_Tree(d, tpool));
    }
    acc = (acc ^ chk) * 16777619u;
  }
  apr_pool_destroy(tpool);

  acc = (acc ^ (uint32_t)compute_Tree_Checksum(long_lived)) * 16777619u;
  apr_pool_destroy(pool);
  apr_terminate();
  printf("%u\n", acc);
  return 0;
}
