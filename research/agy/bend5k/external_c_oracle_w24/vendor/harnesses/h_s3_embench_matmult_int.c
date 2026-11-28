/* Harness for unmodified Embench-IoT matmult-int (matmult-int.c) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/matmult-int/matmult-int.c"

int main(void) {
  const uint32_t ROUNDS = 2000;
  initialise_benchmark();
  memcpy(ArrayA, ArrayA_ref, sizeof(ArrayA));
  memcpy(ArrayB, ArrayB_ref, sizeof(ArrayB));

  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    Multiply(ArrayA, ArrayB, ResultArray);
    uint32_t diag = (uint32_t)ResultArray[r % UPPERLIMIT][r % UPPERLIMIT];
    acc = (acc ^ diag) * 16777619u;
    ArrayA[r % UPPERLIMIT][(r + 3) % UPPERLIMIT] = (long)((diag & 0xFFu) + 1u);
  }
  for (int i = 0; i < UPPERLIMIT; i++) {
    for (int j = 0; j < UPPERLIMIT; j++) {
      acc = (acc ^ (uint32_t)ResultArray[i][j]) * 16777619u;
    }
  }
  printf("%u\n", acc);
  return 0;
}
