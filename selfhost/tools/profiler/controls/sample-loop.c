/* Independent sampler plumbing control, not a Bend compiler benchmark.
 * Sum 0..1999999999 = 2000000000*1999999999/2 = 1999999999000000000.
 * Volatile storage preserves work without deriving an oracle from execution.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

__attribute__((noinline)) static uint64_t sample_loop(void) {
  volatile uint64_t sum = 0;
  for (uint64_t i = 0; i < UINT64_C(2000000000); ++i) sum += i;
  return sum;
}

int main(void) {
  printf("%" PRIu64 "\n", sample_loop());
  return 0;
}
