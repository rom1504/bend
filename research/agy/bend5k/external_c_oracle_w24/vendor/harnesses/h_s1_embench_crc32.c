/* Harness for unmodified Embench-IoT crc32 (crc_32.c) */
#include <stdint.h>
#include <stdio.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/crc32/crc_32.c"

int main(void) {
  const uint32_t ROUNDS = 3000;
  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    srand_beebs(r);
    uint32_t c = (uint32_t)crc32pseudo();
    acc = (acc ^ c) * 16777619u;
  }
  printf("%u\n", acc);
  return 0;
}
