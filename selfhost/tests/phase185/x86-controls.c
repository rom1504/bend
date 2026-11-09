#include <stdint.h>
#include <stdio.h>

extern uint64_t mask64(void *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_97_");
extern uint64_t shift64(void *, uint64_t *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_98_");
extern uint64_t immediate32(void *, uint64_t *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_99_");
extern uint64_t large64(void *, uint64_t *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_100_");

static int equal(const uint64_t *actual, const uint64_t *expected, unsigned n) {
  for (unsigned i = 0; i != n; ++i) if (actual[i] != expected[i]) return 0;
  return 1;
}

int main(void) {
  uint64_t state[8] = {0}, out[8] = {0};
  const uint64_t shifts[6] = {
    UINT64_C(0x8000000100000001), 1, UINT64_MAX,
    UINT64_C(0x8000000000000000), UINT64_C(0x80000001),
    UINT64_C(0xffffffff80000001)
  };
  const uint64_t words[8] = {
    UINT64_C(0x7fffffff), UINT64_C(0x80000001), 1,
    UINT64_C(0xffffffff), 1, 1, UINT64_C(0x80000001), 0
  };
  const uint64_t large_positive[4] = {0, 0, 0, UINT64_C(0x8000000000000000)};
  const uint64_t large_negative[4] = {
    0, 1, UINT64_C(0x80000000), UINT64_C(0xffffffff80000000)
  };
  if (mask64(state, UINT64_C(0xfedcba9876543210)) != UINT64_C(0x76543210)) return 1;
  if (shift64(state, out, UINT64_C(0x8000000100000001)) || !equal(out, shifts, 6)) return 2;
  if (immediate32(state, out, UINT64_C(0xfedcba9880000001)) || !equal(out, words, 8)) return 3;
  if (large64(state, out, UINT64_C(0x100000000)) || !equal(out, large_positive, 4)) return 4;
  if (large64(state, out, UINT64_MAX) || !equal(out, large_negative, 4)) return 5;
  puts("phase185 immediate controls pass");
  return 0;
}
