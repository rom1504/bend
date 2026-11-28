/* Harness for unmodified PolyBench/C 4.2.1 nussinov (int) */
#include <stdint.h>
#include <stdio.h>

#define MEDIUM_DATASET
#define POLYBENCH_NO_FLUSH_CACHE
#define main polybench_orig_main
#include "../PolyBenchC-4.2.1/utilities/polybench.c"
#include "../PolyBenchC-4.2.1/medley/nussinov/nussinov.c"
#undef main

int main(void) {
  int n = N;
  POLYBENCH_1D_ARRAY_DECL(seq, base, N, n);
  POLYBENCH_2D_ARRAY_DECL(table, DATA_TYPE, N, N, n, n);

  init_array(n, POLYBENCH_ARRAY(seq), POLYBENCH_ARRAY(table));
  kernel_nussinov(n, POLYBENCH_ARRAY(seq), POLYBENCH_ARRAY(table));

  uint32_t acc = 2166136261u;
  for (int i = 0; i < n; i++) {
    for (int j = i; j < n; j++) {
      acc = (acc ^ (uint32_t)(*table)[i][j]) * 16777619u;
    }
  }
  POLYBENCH_FREE_ARRAY(seq);
  POLYBENCH_FREE_ARRAY(table);
  printf("%u\n", acc);
  return 0;
}
