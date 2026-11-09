#include <stdint.h>
#include <stdio.h>

extern uint64_t body_loop(void *, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_53_101_");
extern uint64_t mutate(void *, uint64_t *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_102_");
extern uint64_t branch(void *, uint64_t *, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_53_103_");
extern uint64_t unique_branch(void *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_104_");
extern uint64_t permute(void *, uint64_t *, uint64_t, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_53_105_");
extern uint64_t setup_snapshot(void *, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_53_106_");
extern uint64_t narrow(void *, uint64_t)
  __asm__("p113d_FID_112_49_56_53_107_");

int main(void) {
  uint64_t state[8] = {0}, out[2] = {0};
  if (body_loop(state, 100001, 10) != 100011) return 1;
  if (mutate(state, out, 10) || out[0] != 10 || out[1] != 11) return 2;
  if (branch(state, out, 0, 20) || out[0] != 0 || out[1] != 20) return 3;
  if (branch(state, out, 10, 20) || out[0] != 10 || out[1] != 11) return 4;
  if (unique_branch(state, 0) != 99 || unique_branch(state, 10) != 10) return 5;
  if (permute(state, out, 100001, 10, 20) || out[0] != 20 || out[1] != 10) return 6;
  if (setup_snapshot(state, 100001, 10) != 10) return 7;
  if (narrow(state, UINT64_C(0xfedcba9876543210)) != UINT64_C(0x76543210)) return 8;
  puts("phase185 copy controls pass");
  return 0;
}
