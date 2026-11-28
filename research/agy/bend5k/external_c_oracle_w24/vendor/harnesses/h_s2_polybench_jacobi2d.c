/* Harness for unmodified PolyBench/C 4.2.1 jacobi-2d (float / F32) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define DATA_TYPE_IS_FLOAT
#define MEDIUM_DATASET
#define POLYBENCH_NO_FLUSH_CACHE
#define main polybench_orig_main
#include "../PolyBenchC-4.2.1/utilities/polybench.c"
#include "../PolyBenchC-4.2.1/stencils/jacobi-2d/jacobi-2d.c"
#undef main

int main(void) {
  int n = N, tsteps = TSTEPS;
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, N, N, n, n);

  init_array(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));
  kernel_jacobi_2d(tsteps, n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  uint32_t acc = 2166136261u;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      uint32_t bits;
      float v = (*A)[i][j];
      memcpy(&bits, &v, 4);
      acc = (acc ^ bits) * 16777619u;
    }
  }
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  printf("%u\n", acc);
  return 0;
}
