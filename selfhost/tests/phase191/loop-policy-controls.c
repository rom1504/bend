/* Independent unsigned arithmetic oracle. The fixture has nine loop-state
 * words, stack ABI inputs, four exit-only handles and transient pressure.
 * Build the same driver against separately emitted assembly and ELF objects. */
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

extern uint64_t p191lp_pressure(void *, uint64_t, uint64_t,
  uint64_t, uint64_t, uint64_t, uint64_t, uint64_t, uint64_t, uint64_t);

static uint64_t expected(uint64_t n, uint64_t acc, const uint64_t handles[4],
                         uint64_t base, uint64_t mask, uint64_t salt) {
  /* Ascending traversal and delayed exit reduction are independent of the
   * emitted fixture's descending Again transfers. Unsigned wrap is defined. */
  for (uint64_t j = 1; j <= n; ++j)
    acc += (((j + base) & mask) * UINT64_C(8)) + salt;
  for (unsigned h = 0; h < 4; ++h) acc += handles[h];
  return acc;
}

int main(void) {
  const uint64_t values[8] = {
    0, 1, UINT64_MAX, UINT64_C(0x8000000000000000),
    UINT64_C(0x123456789abcdef0), UINT32_MAX,
    UINT64_C(0xffffffffffffffe0), UINT64_C(0xfedcba9876543210)
  };
  for (unsigned v = 0; v < 128; ++v) {
    const uint64_t n = v % 32;
    const unsigned group = v / 32;
    const uint64_t handles[4] = {
      values[(v + 1) % 8], values[(v + 3) % 8],
      values[(v + 4) % 8], values[(v + 6) % 8]
    };
    const uint64_t acc = values[v % 8];
    const uint64_t base = values[(v + group + 2) % 8];
    const uint64_t mask = group == 0 ? UINT64_C(15) :
      (group == 1 ? UINT64_MAX : values[(v + 5) % 8]);
    const uint64_t salt = values[(v + 2 * group + 7) % 8];
    const uint64_t want = expected(n, acc, handles, base, mask, salt);
    const uint64_t got = p191lp_pressure(NULL, n, acc,
      handles[0], handles[1], handles[2], handles[3], base, mask, salt);
    if (got != want) {
      fprintf(stderr, "loop-policy vector=%u n=%" PRIu64
        " expected=%" PRIu64 " actual=%" PRIu64 "\n", v, n, want, got);
      return 1;
    }
  }
  puts("loop-policy-runtime=1");
  return 0;
}
