#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern uint64_t __real_p199_rt_u32_scan4(uint32_t *, uint64_t, uint64_t, uint64_t, uint64_t);
uint64_t __wrap_p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
                                 uint64_t index, uint64_t carry) {
  const uint64_t after = __real_p199_rt_u32_scan4(data, mask, fuel, index, carry);
  fprintf(stderr, "%" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 "\n",
          mask, fuel, index, carry, after);
  return after;
}
