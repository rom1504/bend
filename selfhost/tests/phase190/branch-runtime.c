/* Independent public-source oracle. Unsigned arithmetic has the U32 modulo
 * semantics; no host signed casts or overflow are needed. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

static uint32_t branch_score(uint32_t a, uint32_t b) {
  int less = a < b;
  uint32_t bits = (a == b ? 1u : 0u) + (a != b ? 2u : 0u)
    + (less ? 4u : 0u) + (a <= b ? 8u : 0u)
    + (a > b ? 16u : 0u) + (a >= b ? 32u : 0u) + 64u;
  uint32_t nested = less ? (a == 0 ? 101u : 103u)
                         : (a == b ? 107u : 109u);
  uint32_t reused = (less ? 131u : 137u) + (unsigned)less;
  return bits + nested + reused;
}

static uint32_t branch_loop(uint32_t n, uint32_t a, uint32_t b, uint32_t acc) {
  while (n--) {
    acc = acc * 33u + branch_score(a, b);
    b ^= a;
    a += UINT32_C(2147483649);
  }
  return acc;
}

int main(void) {
  const uint32_t result[] = {
    branch_score(0, 0), branch_score(0, UINT32_MAX),
    branch_score(UINT32_MAX, 0), branch_score(UINT32_C(2147483647), UINT32_C(2147483648)),
    branch_score(UINT32_C(2147483648), UINT32_C(2147483647)), branch_score(UINT32_MAX, UINT32_MAX),
    branch_loop(0, UINT32_C(2147483648), 1, 19),
    branch_loop(1, UINT32_C(2147483648), 1, 19),
    branch_loop(257, UINT32_C(2147483648), 1, 19)
  };
  putchar('[');
  for (unsigned i = 0; i < sizeof result / sizeof *result; ++i)
    printf("%s%" PRIu32, i ? ", " : "", result[i]);
  puts("]");
  return 0;
}
