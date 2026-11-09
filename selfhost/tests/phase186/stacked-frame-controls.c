#include "../../src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef STACKED_MODE
#define STACKED_MODE 0
#endif
extern uint64_t p186stack(P111State *, uint64_t, uint64_t);

/* Only the unreachable invalid-case route needs this symbol. No success
 * computation, allocation, capture, or dispatch is implemented by this stub. */
uint64_t p111_rt_fail(P111State *state, uint32_t code) {
  (void)state;
  fprintf(stderr, "unexpected private-region failure: %u\n", code);
  abort();
}

static uint64_t expected(uint64_t n, uint64_t seed) {
  uint64_t value = seed + 3 * n;
  for (uint64_t k = 1; k <= n; ++k) {
    uint64_t captured = seed + 3 * (n - k);
    if (STACKED_MODE == 0) value = (value + 17 * k) ^ captured;
    else value = (k & 1) ? (value ^ captured) + 17 * k : value ^ captured;
  }
  return value;
}

int main(void) {
  static const uint64_t counts[] = {0, 1, 2, 3, 17, 128, 100001};
  static const uint64_t seeds[] = {0, 1, UINT32_MAX, UINT64_C(0x100000000),
    UINT64_C(0x8000000000000000), UINT64_MAX};
  const uint64_t guard = UINT64_C(0x8d4a391bcf726e05);
  unsigned observations = 0;
  for (unsigned n = 0; n < sizeof(counts) / sizeof(*counts); ++n) {
    size_t capacity = 4 * (size_t)counts[n] + 16;
    uint64_t *stack = malloc(capacity * sizeof(*stack));
    if (!stack) return 2;
    for (unsigned s = 0; s < sizeof(seeds) / sizeof(*seeds); ++s) {
      for (size_t i = 0; i < capacity; ++i) stack[i] = guard;
      P111State state = {0};
      state.sp = stack + 4;
      state.seq = 1;
      state.rn = 73;
      state.next = 97;
      for (unsigned i = 0; i < P111_REG_CAP; ++i) state.regs[i] = guard;
      uint64_t actual = p186stack(&state, counts[n], seeds[s]);
      uint64_t want = expected(counts[n], seeds[s]);
      if (actual != want || state.sp != stack + 4 || state.rn != 73 || state.next != 97 || state.seq != 1) {
        fprintf(stderr, "stacked mode=%d n=%" PRIu64 " seed=%016" PRIx64 " got=%016" PRIx64 " expected=%016" PRIx64 "\n",
          STACKED_MODE, counts[n], seeds[s], actual, want);
        return 1;
      }
      for (unsigned i = 0; i < P111_REG_CAP; ++i) if (state.regs[i] != guard) return 3;
      for (unsigned i = 0; i < 4; ++i)
        if (stack[i] != guard || stack[capacity - 1 - i] != guard) return 4;
      ++observations;
    }
    free(stack);
  }
  printf("phase186 stacked mode%d controls pass: %u\n", STACKED_MODE, observations);
  return 0;
}
