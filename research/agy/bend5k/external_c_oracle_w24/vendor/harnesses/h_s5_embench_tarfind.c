/* Harness for unmodified Embench-IoT tarfind (tarfind.c) */
#include <stdint.h>
#include <stdio.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/tarfind/tarfind.c"

int main(void) {
  const uint32_t ROUNDS = 800;
  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    srand_beebs(r);
    int ok = benchmark_body(1, 1);
    acc = (acc ^ (uint32_t)ok) * 16777619u;
    acc = (acc ^ (uint32_t)rand_beebs()) * 16777619u;
  }
  printf("%u\n", acc);
  return 0;
}
