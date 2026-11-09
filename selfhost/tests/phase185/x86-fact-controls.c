#include <stdint.h>
#include <stdio.h>

extern uint64_t return_true(void *) __asm__("p111_FID_112_49_56_53_109_");
extern uint64_t return_false(void *) __asm__("p111_FID_112_49_56_53_110_");
extern uint64_t return_nested(void *) __asm__("p111_FID_112_49_56_53_111_");

int main(void) {
  uint64_t state[8] = {0};
  if (return_true(state) != 1 || return_false(state) != 2 || return_nested(state) != 3) return 1;
  puts("phase185 public return controls pass");
  return 0;
}
