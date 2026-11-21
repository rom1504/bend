#include <stdint.h>
uint64_t p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
                         uint64_t index, uint64_t incoming) {
  if (!fuel) return incoming;
  uint32_t i=(uint32_t)index, carry=(uint32_t)incoming;
  do { carry += data[(uint64_t)i & mask];
       data[(uint64_t)i & mask] = carry ^ i;
       ++i;
  } while (--fuel);
  return carry;
}
