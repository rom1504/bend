/* Harness for unmodified Embench-IoT edn (libedn.c) DSP filterbank */
#include <stdint.h>
#include <stdio.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/edn/libedn.c"

int main(void) {
  const uint32_t ROUNDS = 1200;
  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    benchmark_body(1, 1);
    acc = (acc ^ (uint32_t)c) * 16777619u;
    acc = (acc ^ (uint32_t)d) * 16777619u;
    acc = (acc ^ (uint32_t)e) * 16777619u;
    acc = (acc ^ (uint32_t)output[r % 101]) * 16777619u;
  }
  for (int i = 0; i < 101; i++) {
    acc = (acc ^ (uint32_t)output[i]) * 16777619u;
  }
  printf("%u\n", acc);
  return 0;
}
