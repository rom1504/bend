#include <stdint.h>
#include <stdio.h>

extern uint64_t dead_math(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_100_97_");
extern uint64_t dead_memory(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_100_98_");
extern uint64_t dead_branch(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_100_99_");
extern uint64_t dead_callee(void *, uint64_t *, uint64_t) __asm__("p113d_FID_112_49_56_53_100_100_");
extern uint64_t dead_calls(void *, uint64_t) __asm__("p113d_FID_112_49_56_53_100_101_");
extern uint64_t setup_carried(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_100_102_");
extern uint64_t dead_offset(void *) __asm__("p111_FID_112_49_56_53_100_103_");

int main(void) {
  uint64_t state[8] = {0}, out[2] = {0};
  if (dead_math(state, UINT64_MAX, 17) != UINT64_C(0xffffffffffffffee)) return 1;
  if (dead_memory(state, 7, UINT64_C(0xfedcba9876543210)) != UINT64_C(0xfedcba9876543210)) return 2;
  if (dead_branch(state, 0, 20) != 20 || dead_branch(state, 10, 20) != 10) return 3;
  if (dead_callee(state, out, UINT64_MAX) || out[0] != UINT64_MAX || out[1] != 0) return 4;
  if (dead_calls(state, 10) != 41) return 5;
  if (setup_carried(state, 100001, 10) != 100011) return 6;
  if (setup_carried(state, 1, UINT64_MAX) != 0) return 7;
  if (dead_offset(state) != 5) return 8;
  puts("phase185 dead assignment controls pass");
  return 0;
}
