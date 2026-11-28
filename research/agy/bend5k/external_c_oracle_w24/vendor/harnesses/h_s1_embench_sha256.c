/* Harness for unmodified Embench-IoT nettle-sha256 (nettle-sha256.c) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/nettle-sha256/nettle-sha256.c"

int main(void) {
  const uint32_t ROUNDS = 24000;
  uint8_t state[32];
  for (int i = 0; i < 32; i++) state[i] = (uint8_t)(i * 7 + 3);

  struct sha256_ctx ctx;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    nettle_sha256.init(&ctx);
    nettle_sha256.update(&ctx, 32, state);
    nettle_sha256.digest(&ctx, 32, state);
  }

  uint32_t acc = 2166136261u;
  for (int i = 0; i < 32; i++) {
    acc = (acc ^ (uint32_t)state[i]) * 16777619u;
  }
  printf("%u\n", acc);
  return 0;
}
