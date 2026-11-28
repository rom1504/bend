/* Harness for unmodified Embench-IoT nettle-aes (nettle-aes.c) */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GLOBAL_SCALE_FACTOR 1
#include "../embench-iot/support/beebsc.c"
#include "../embench-iot/src/nettle-aes/nettle-aes.c"

int main(void) {
  const uint32_t ROUNDS = 3000;
  uint8_t buf[256];
  uint8_t out[256];
  memcpy(buf, plaintext, 256);

  struct aes_ctx ctx;
  aes_set_encrypt_key(&ctx, 32, key);
  for (uint32_t r = 0; r < ROUNDS; r++) {
    aes_encrypt(&ctx, 256, out, buf);
    memcpy(buf, out, 256);
  }

  uint32_t acc = 2166136261u;
  for (int i = 0; i < 256; i++) {
    acc = (acc ^ (uint32_t)buf[i]) * 16777619u;
  }
  printf("%u\n", acc);
  return 0;
}
