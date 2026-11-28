/* Harness for unmodified PolyBench/C 4.2.1 gemm (float / F32) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define DATA_TYPE_IS_FLOAT
#define MEDIUM_DATASET
#define POLYBENCH_NO_FLUSH_CACHE
#define main polybench_orig_main
#include "../PolyBenchC-4.2.1/utilities/polybench.c"
#include "../PolyBenchC-4.2.1/linear-algebra/blas/gemm/gemm.c"
#undef main

int main(void) {
  int ni = NI, nj = NJ, nk = NK;
  DATA_TYPE alpha, beta;
  POLYBENCH_2D_ARRAY_DECL(C, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, NI, NK, ni, nk);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, NK, NJ, nk, nj);

  init_array(ni, nj, nk, &alpha, &beta,
             POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));
  kernel_gemm(ni, nj, nk, alpha, beta,
              POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  uint32_t acc = 2166136261u;
  for (int i = 0; i < ni; i++) {
    for (int j = 0; j < nj; j++) {
      uint32_t bits;
      float v = (*C)[i][j];
      memcpy(&bits, &v, 4);
      acc = (acc ^ bits) * 16777619u;
    }
  }
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  printf("%u\n", acc);
  return 0;
}
