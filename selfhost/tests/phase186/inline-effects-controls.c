/* Exact bit labels copied from the frozen Phase112 case authority.
 * The operation bodies are unchanged; this oracle additionally observes all
 * five transient homes, pointer homes, overwrite/alias, and fallback barriers.
 * Arithmetic NaNs use the existing NaN-class + zero-upper-word contract.
 * The isolated fallback stub tests call effects, not sqrt implementation.
 * cases.json SHA256: bde39b2e416263ae82219c601ea409afc0e14be42ddb877a4d8aa4c545ce9753 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint64_t f0(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_97_");
extern uint64_t f1(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_98_");
extern uint64_t f2(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_99_");
extern uint64_t f3(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_100_");
extern uint64_t f4(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_101_");
extern uint64_t f5(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_102_");
extern uint64_t f6(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_103_");
extern uint64_t f7(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_104_");
extern uint64_t f8(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_105_");
extern uint64_t f9(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_106_");
extern uint64_t alias(void *, uint64_t *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_107_");
extern uint64_t fallback(void *, uint64_t *, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_108_");
extern uint64_t pointer_reg(void *) __asm__("p111_FID_112_49_56_54_105_109_");
extern uint64_t pointer_stack(void *) __asm__("p111_FID_112_49_56_54_105_110_");
extern uint64_t pressure(void *, uint64_t *, uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_54_105_111_");
typedef uint64_t (*Binary)(void *, uint64_t *, uint64_t, uint64_t, uint64_t);
static Binary functions[10] = {f0,f1,f2,f3,f4,f5,f6,f7,f8,f9};
typedef struct { unsigned op; uint64_t a, b, expected; unsigned nan_class; const char *name; } Case;
static const Case cases[93] = {
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
};
static void *expected_state;
static uint64_t expected_arg;
static unsigned calls, bad_call;
#define STUB_RESULT UINT64_C(0xfedcba9876543210)
#define CANARY UINT64_C(0x1122334455667788)
#define LIVE_XOR UINT64_C(0x5a5a5a5aa5a5a5a5)

uint64_t p111_rt_op(void *state, uint32_t op, const uint64_t *args, uint32_t count) {
  ++calls;
  if (state != expected_state || op != 36 || count != 1 || !args || args[0] != expected_arg) ++bad_call;
  /* Every transient register is caller-clobbered. A real runtime import may
   * use all of them, so the unadmitted call must still split live ranges. */
  __asm__ volatile("xorq %%rdi, %%rdi\n\txorq %%rsi, %%rsi\n\txorq %%rdx, %%rdx\n\t"
                   "xorq %%r8, %%r8\n\txorq %%r9, %%r9"
                   : : : "rdi", "rsi", "rdx", "r8", "r9", "cc", "memory");
  return STUB_RESULT;
}

static int matches(const Case *c, uint64_t word) {
  if (!c->nan_class) return word == c->expected;
  return (word >> 32) == 0 && (word & UINT64_C(0x7f800000)) == UINT64_C(0x7f800000) &&
    (word & UINT64_C(0x007fffff)) != 0;
}
static int canaries(const uint64_t *out, unsigned used) {
  if (out[0] != CANARY) return 0;
  for (unsigned k = used + 1; k < 8; ++k) if (out[k] != CANARY) return 0;
  return 1;
}
static void clear(uint64_t *out) { for (unsigned k = 0; k < 8; ++k) out[k] = CANARY; }

int main(void) {
  const uint64_t markers[5] = {0, 1, UINT64_MAX, UINT64_C(0x8000000000000000), UINT64_C(0x12345678abcdef01)};
  uint64_t state[16], before[16], out[8];
  for (unsigned k = 0; k < 16; ++k) state[k] = CANARY + k;
  expected_state = state;
  unsigned checks = 0;
  for (unsigned i = 0; i < 93; ++i) for (unsigned j = 0; j < 5; ++j) {
    const Case *c = &cases[i];
    const uint64_t marker = markers[j], live = marker ^ LIVE_XOR;
    state[0] = c->a; state[1] = c->b; state[2] = marker;
    memcpy(before, state, sizeof(state));
    clear(out);
    if (functions[c->op - 26](state, out + 1, c->a, c->b, marker) ||
        !matches(c, out[1]) || out[2] != live || out[3] != live + 1 || !canaries(out, 3)) {
      fprintf(stderr, "live-across failure: %s marker=%" PRIx64 "\n", c->name, marker); return 1;
    }
    ++checks;
    if (c->op == 26) {
      clear(out);
      if (alias(state, out + 1, c->a, c->b) || !matches(c, out[1]) || out[2] != c->a || !canaries(out, 2)) return 2;
      ++checks;
      if (!matches(c, pointer_reg(state) ^ marker)) return 3;
      ++checks;
      if (!matches(c, pointer_stack(state) ^ marker)) return 4;
      ++checks;
      clear(out);
      if (pressure(state, out + 1, c->a, c->b, marker) || !matches(c, out[1]) || !canaries(out, 6)) return 5;
      for (unsigned k = 1; k <= 5; ++k) if (out[k + 1] != marker + k) return 6;
      ++checks;
    }
    if (calls || bad_call || memcmp(state, before, sizeof(state))) return 7;
  }
  for (unsigned j = 0; j < 5; ++j) {
    clear(out); expected_arg = markers[j];
    memcpy(before, state, sizeof(state));
    if (fallback(state, out + 1, expected_arg, markers[j]) || out[1] != STUB_RESULT ||
        out[2] != markers[j] + 7 || !canaries(out, 2) || calls != j + 1 || bad_call ||
        memcmp(state, before, sizeof(state))) return 8;
    ++checks;
  }
  printf("phase186 inline effect controls pass: %u\n", checks);
  return 0;
}
