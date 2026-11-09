#include <stdint.h>
#include <stdio.h>

extern uint64_t setup_score(void *, uint64_t, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_53_108_");

int main(void) {
  uint64_t state[8] = {0};
  if (setup_score(state, 100001, 10, UINT64_MAX) != 30) return 1;
  if (setup_score(state, 0, UINT64_MAX, 7) != UINT64_C(0xfffffffffffffffd)) return 2;
  puts("phase185 setup scoring controls pass");
  return 0;
}
