/* Independent frozen Phase112 bit oracles, restricted to binary IDs 26..35.
 * No host floating arithmetic computes expected answers. Five arithmetic NaNs
 * use the original class+zero-upper-word contract; all other words are exact.
 * Only routing controls 23/36 may call the isolated runtime stub below. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint64_t f0(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_97_");
extern uint64_t f1(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_98_");
extern uint64_t f2(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_99_");
extern uint64_t f3(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_100_");
extern uint64_t f4(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_101_");
extern uint64_t f5(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_102_");
extern uint64_t f6(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_103_");
extern uint64_t f7(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_104_");
extern uint64_t f8(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_105_");
extern uint64_t f9(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_106_");
extern uint64_t f10(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_107_");
extern uint64_t f11(void *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_53_102_108_");
typedef uint64_t (*Binary)(void *, uint64_t, uint64_t);
static Binary functions[12] = {f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11};
typedef struct {
  unsigned op;
  uint64_t a, b, expected;
  unsigned nan_class;
  const char *name;
} Case;
static const Case cases[93] = {
/* BEGIN FROZEN CASES */
  {26, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x000000003fc00000), 0, "add"},
  {27, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "sub-cancel"},
  {27, UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), 0, "sub-negative-zero"},
  {28, UINT64_C(0x0000000040000000), UINT64_C(0x000000003f000000), UINT64_C(0x000000003f800000), 0, "mul"},
  {28, UINT64_C(0x000000007f7fffff), UINT64_C(0x0000000040000000), UINT64_C(0x000000007f800000), 0, "mul-overflow"},
  {28, UINT64_C(0x0000000000800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000400000), 0, "mul-normal-to-subnormal"},
  {28, UINT64_C(0x0000000000000001), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000002), 0, "mul-min-subnormal"},
  {29, UINT64_C(0x0000000000000001), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000000), 0, "div-subnormal-tie-zero"},
  {29, UINT64_C(0x0000000000000003), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000002), 0, "div-subnormal-tie-even"},
  {29, UINT64_C(0x0000000080000000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000080000000), 0, "div-negative-zero"},
  {29, UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), UINT64_C(0x000000007f800000), 0, "div-positive-infinity"},
  {29, UINT64_C(0x00000000bf800000), UINT64_C(0x0000000000000000), UINT64_C(0x00000000ff800000), 0, "div-negative-infinity"},
  {29, UINT64_C(0x000000003f800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000080000000), 0, "div-negative-zero-from-infinity"},
  {26, UINT64_C(0x000000003f800000), UINT64_C(0x0000000033800000), UINT64_C(0x000000003f800000), 0, "add-tie-even-down"},
  {26, UINT64_C(0x000000003f800001), UINT64_C(0x0000000033800000), UINT64_C(0x000000003f800002), 0, "add-tie-even-up"},
  {26, UINT64_C(0xdeadbeef3f800000), UINT64_C(0xffffffff3f000000), UINT64_C(0x000000003fc00000), 0, "upper-words-discarded"},
  {29, UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), UINT64_C(0x000000007fc00000), 1, "zero-div-zero"},
  {26, UINT64_C(0x000000007f800000), UINT64_C(0x00000000ff800000), UINT64_C(0x000000007fc00000), 1, "infinity-cancel"},
  {28, UINT64_C(0x0000000000000000), UINT64_C(0x000000007f800000), UINT64_C(0x000000007fc00000), 1, "zero-times-infinity"},
  {26, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc00000), 1, "quiet-nan-add"},
  {28, UINT64_C(0x000000007f801234), UINT64_C(0x0000000040000000), UINT64_C(0x000000007fc00000), 1, "signaling-nan-mul"},
  {30, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-30"},
  {31, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-31"},
  {32, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-32"},
  {33, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-33"},
  {34, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-34"},
  {35, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-35"},
  {30, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-30"},
  {31, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-31"},
  {32, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-32"},
  {33, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-33"},
  {34, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-34"},
  {35, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-35"},
  {30, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-30"},
  {31, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-31"},
  {32, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-32"},
  {33, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-33"},
  {34, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-34"},
  {35, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-35"},
  {30, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-30"},
  {31, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-left-nan-31"},
  {32, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-32"},
  {33, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-33"},
  {34, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-34"},
  {35, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-35"},
  {30, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-30"},
  {31, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000001), 0, "compare-right-nan-31"},
  {32, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-32"},
  {33, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-33"},
  {34, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-34"},
  {35, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-35"},
  {30, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-30"},
  {31, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000001), 0, "compare-two-nans-31"},
  {32, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-32"},
  {33, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-33"},
  {34, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-34"},
  {35, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-35"},
  {30, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-30"},
  {31, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-31"},
  {32, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-32"},
  {33, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-33"},
  {34, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-34"},
  {35, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-35"},
  {30, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-30"},
  {31, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-31"},
  {32, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-32"},
  {33, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-33"},
  {34, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-34"},
  {35, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-35"},
  {30, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-30"},
  {31, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-31"},
  {32, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-32"},
  {33, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-33"},
  {34, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-34"},
  {35, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-35"},
  {30, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-30"},
  {31, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-31"},
  {32, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-32"},
  {33, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-33"},
  {34, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-34"},
  {35, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-35"},
  {30, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-30"},
  {31, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-31"},
  {32, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-32"},
  {33, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-33"},
  {34, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-34"},
  {35, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-35"},
  {30, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-30"},
  {31, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-31"},
  {32, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-32"},
  {33, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-33"},
  {34, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-34"},
  {35, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-35"},
/* END FROZEN CASES */
};
static unsigned calls, bad_call, allowed_op;
static void *expected_state;
static uint64_t expected_argument;
static const uint64_t sentinel23 = UINT64_C(0x5a17ca11c0000017);
static const uint64_t sentinel36 = UINT64_C(0x5a17ca11c0000024);
uint64_t p111_rt_op(void *state, uint32_t op, const uint64_t *args, uint32_t count) {
  ++calls;
  if ((op != 23 && op != 36) || op != allowed_op || count != 1 ||
      state != expected_state || !args || args[0] != expected_argument) {
    ++bad_call;
    return 0;
  }
  return op == 23 ? sentinel23 : sentinel36;
}
static int is_nan_word(uint64_t word) {
  return (word >> 32) == 0 && (word & UINT64_C(0x7f800000)) == UINT64_C(0x7f800000) &&
    (word & UINT64_C(0x007fffff)) != 0;
}
int main(void) {
  uint64_t state[261], before[261];
  for (unsigned i=0; i<261; ++i) state[i] = UINT64_C(0xaabbaaaa00000000) + i;
  memcpy(before,state,sizeof(state)); expected_state=state;
  unsigned checks=0;
  for (unsigned i=0; i<93; ++i) {
    const Case *c=&cases[i]; calls=0; bad_call=0; allowed_op=0;
    const uint64_t actual=functions[c->op-26](state,c->a,c->b);
    if ((c->nan_class ? !is_nan_word(actual) : actual != c->expected) || calls || bad_call ||
        memcmp(state,before,sizeof(state))) {
      fprintf(stderr,"%s: got %016" PRIx64 ", expected %016" PRIx64 ", nan=%u calls=%u bad=%u\n",
        c->name,actual,c->expected,c->nan_class,calls,bad_call);
      return 1;
    }
    ++checks;
  }
  const uint64_t arguments[2]={UINT64_C(0xfedcba9880000001),UINT64_C(0x123456787f800001)};
  for (unsigned i=0; i<2; ++i) {
    allowed_op=i?36:23; expected_argument=arguments[i]; calls=0; bad_call=0;
    const uint64_t actual=functions[10+i](state,arguments[i],UINT64_C(0xdeadbeef01234567));
    if (actual != (i?sentinel36:sentinel23) || calls != 1 || bad_call || memcmp(state,before,sizeof(state))) return 2;
    ++checks;
  }
  printf("phase185 floating controls pass: %u\n",checks);
  return 0;
}
