#include <stdint.h>
#include <stdio.h>

extern uint64_t chain(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_48_");
extern uint64_t pressure(void *, uint64_t *, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_49_");
extern uint64_t deadwrite(void *, uint64_t *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_50_");
extern uint64_t branch(void *, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_51_");
extern uint64_t calling(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_52_");
extern uint64_t again(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_54_");
extern uint64_t setup(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_55_");
extern uint64_t memory(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_116_114_56_");

int main(void) {
  uint64_t state[16] = {0}, out[6] = {0};
  const uint64_t words[] = {0, 1, 17, UINT64_C(0xffffffff), UINT64_C(0xfedcba9876543210), UINT64_MAX};
  unsigned checks = 0;
  for (unsigned i = 0; i < 6; ++i) for (unsigned j = 0; j < 6; ++j) {
    const uint64_t a = words[i], b = words[j];
    if (chain(state, a, b) != (((a + b) ^ b) + 7)) return 1;
    if (deadwrite(state, out, a, b) || out[0] != b + 9 || out[1] != a + 2) return 2;
    if (calling(state, a, b) != 9 * (b + 2) + 12 * (a + 1) + (a ^ b)) return 3;
    if (memory(state, a, b) != (uint32_t)((uint32_t)a << ((uint32_t)b & 31))) return 4;
    checks += 4;
  }
  for (unsigned i = 0; i < 6; ++i) {
    const uint64_t a = words[i];
    if (pressure(state, out, a)) return 5;
    for (unsigned k = 0; k < 6; ++k) if (out[k] != a + k + 1) return 6;
    if (branch(state, a) != (a == 0 ? 3 : a + 4)) return 7;
    if (setup(state, 1001, a) != a + 5) return 8;
    uint64_t x = a, y = 17;
    for (unsigned n = 0; n < 1001; ++n) { const uint64_t next = y + 1; y = x + 2; x = next; }
    if (again(state, out, 1001, a, 17) || out[0] != x || out[1] != y) return 9;
    checks += 4;
  }
  for (unsigned i = 0; i < 16; ++i) if (state[i] != 0) return 10;
  printf("phase185 transient controls pass: %u\n", checks);
  return 0;
}
