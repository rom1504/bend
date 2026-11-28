/* Harness for unmodified Cyan4973/xxHash (XXH32) */
#include <stdint.h>
#include <stdio.h>

#define XXH_INLINE_ALL
#include "../xxHash/xxhash.h"

int main(void) {
  const uint32_t LEN = 4096;
  const uint32_t ROUNDS = 24000;
  uint8_t buf[4096];
  uint32_t s = 0x12345678u;
  for (uint32_t i = 0; i < LEN; i++) {
    s = s * 1664525u + 1013904223u;
    buf[i] = (uint8_t)(s >> 24);
  }

  uint32_t seed = 0x9E3779B1u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    seed = XXH32(buf, LEN, seed);
  }
  printf("%u\n", seed);
  return 0;
}
