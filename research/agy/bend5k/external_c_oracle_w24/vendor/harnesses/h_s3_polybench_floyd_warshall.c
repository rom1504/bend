/* Harness for unmodified PolyBench/C 4.2.1 floyd-warshall (int) */
#include <stdint.h>
#include <stdio.h>

#define SMALL_DATASET
#define POLYBENCH_NO_FLUSH_CACHE
#define main polybench_orig_main
#include "../PolyBenchC-4.2.1/utilities/polybench.c"
#include "../PolyBenchC-4.2.1/medley/floyd-warshall/floyd-warshall.c"
#undef main

int main(void) {
  int n = N;
  POLYBENCH_2D_ARRAY_DECL(path, DATA_TYPE, N, N, n, n);

  init_array(n, POLYBENCH_ARRAY(path));
  kernel_floyd_warshall(n, POLYBENCH_ARRAY(path));

  uint32_t acc = 2166136261u;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      acc = (acc ^ (uint32_t)(*path)[i][j]) * 16777619u;
    }
  }
  POLYBENCH_FREE_ARRAY(path);
  printf("%u\n", acc);
  return 0;
}
