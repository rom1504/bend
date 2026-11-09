#include <stdint.h>
#include <stdio.h>

/* Observe the entire 64-bit ABI word, including nominal U32 arguments. */
uint64_t p186ca_cookie = UINT64_C(99);
static unsigned direct_calls, snapshot_calls, six_calls, zero_calls;

uint64_t p186ca_check_direct(uint64_t a, uint64_t b, uint64_t c, uint64_t d,
                           uint64_t cookie, uint64_t fid, uint64_t cid,
                           uint64_t buffer, uint64_t again, uint64_t narrow) {
  ++direct_calls;
  if (a != UINT64_C(0x0123456789abcdef) || b != UINT64_C(0xfedcba9876543210) ||
      c != UINT64_C(0x1122334455667788) || d != 42 ||
      cookie != (uintptr_t)&p186ca_cookie || fid != 7 || cid != 9 ||
      !buffer || *(const uint64_t *)(uintptr_t)buffer != UINT64_C(0x8877665544332211) ||
      again != a || narrow != 42) return 0;
  return 77;
}

uint64_t p186ca_check_snapshot(uint64_t b, uint64_t low_a, uint64_t c, uint64_t low_e,
                             uint64_t d, uint64_t literal, uint64_t a, uint64_t again_b,
                             uint64_t e, uint64_t low_d) {
  ++snapshot_calls;
  if (a != UINT64_C(0x0123456789abcdef) || low_a != UINT64_C(0x89abcdef) ||
      b != UINT64_C(0xfedcba9876543210) || again_b != b ||
      c != UINT64_C(0x1122334455667788) || d != UINT64_C(0xffff0000aaaa5555) ||
      low_d != UINT64_C(0xaaaa5555) || e != UINT64_C(0x8000000000000007) ||
      low_e != 7 || literal != 11) return 0;
  return 88;
}

uint64_t p186ca_check_six(uint64_t a, uint64_t b, uint64_t c,
                        uint64_t d, uint64_t e, uint64_t f) {
  ++six_calls;
  return a == 1 && b == 2 && c == 3 && d == 4 && e == 5 && f == 6 ? 66 : 0;
}

uint64_t p186ca_check_zero(void) { ++zero_calls; return 99; }

extern uint64_t p186ca_direct(void), p186ca_disabled(void), p186ca_snapshot(void);
extern uint64_t p186ca_six(void), p186ca_zero(void);

int main(void) {
  unsigned failures = 0;
  failures += p186ca_direct() != 77;
  failures += p186ca_disabled() != 77;
  failures += p186ca_snapshot() != 88;
  failures += p186ca_six() != 66;
  failures += p186ca_zero() != 99;
  if (direct_calls != 2 || snapshot_calls != 1 || six_calls != 1 || zero_calls != 1 ||
      p186ca_cookie != 99) ++failures;
  if (failures) { fprintf(stderr, "call argument failures: %u\n", failures); return 1; }
  puts("phase186 call argument controls pass: 5/5");
  return 0;
}
