/* Harness for unmodified PolyBench/C 4.2.1 bicg (float / F32) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define DATA_TYPE_IS_FLOAT
#define MEDIUM_DATASET
#define POLYBENCH_NO_FLUSH_CACHE
#define main polybench_orig_main
#include "../PolyBenchC-4.2.1/utilities/polybench.c"
#include "../PolyBenchC-4.2.1/linear-algebra/kernels/bicg/bicg.c"
#undef main

int main(void) {
  int n = N, m = M;
  const int ROUNDS = 40;
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, N, M, n, m);
  POLYBENCH_1D_ARRAY_DECL(s, DATA_TYPE, M, m);
  POLYBENCH_1D_ARRAY_DECL(q, DATA_TYPE, N, n);
  POLYBENCH_1D_ARRAY_DECL(p, DATA_TYPE, M, m);
  POLYBENCH_1D_ARRAY_DECL(r, DATA_TYPE, N, n);

  init_array(m, n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(r), POLYBENCH_ARRAY(p));
  uint32_t acc = 2166136261u;
  for (int rd = 0; rd < ROUNDS; rd++) {
    kernel_bicg(m, n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(s),
                POLYBENCH_ARRAY(q), POLYBENCH_ARRAY(p), POLYBENCH_ARRAY(r));
    /* feed small deterministic perturbation so rounds cannot be hoisted */
    (*p)[rd % m] = (*s)[rd % m] * 0.001f + 0.1f;
    (*r)[rd % n] = (*q)[rd % n] * 0.001f + 0.1f;
  }

  for (int i = 0; i < m; i++) {
    uint32_t bits;
    float v = (*s)[i];
    memcpy(&bits, &v, 4);
    acc = (acc ^ bits) * 16777619u;
  }
  for (int i = 0; i < n; i++) {
    uint32_t bits;
    float v = (*q)[i];
    memcpy(&bits, &v, 4);
    acc = (acc ^ bits) * 16777619u;
  }
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(s);
  POLYBENCH_FREE_ARRAY(q);
  POLYBENCH_FREE_ARRAY(p);
  POLYBENCH_FREE_ARRAY(r);
  printf("%u\n", acc);
  return 0;
}
