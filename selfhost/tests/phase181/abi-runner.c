/* Phase181 observer only. All tested arithmetic/control/memory code comes from
 * abi-controls.bend through the Bend emitter. These aliases are fixed identity
 * spellings, not a host implementation of IR lowering. No runtime is needed.
 * Link this file, abi-preserve.s and the 17 emitted functions, then run once.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define TWO(name, symbol) \
  extern uint64_t name(void *, uint64_t, uint64_t) __asm__(symbol)
#define TWO_OUT(name, symbol) \
  extern uint64_t name(void *, uint64_t *, uint64_t, uint64_t) __asm__(symbol)
#define EIGHT(name, symbol) \
  extern uint64_t name(void *, uint64_t, uint64_t, uint64_t, uint64_t, \
    uint64_t, uint64_t, uint64_t, uint64_t) __asm__(symbol)

TWO(add64, "p113d_FID_112_49_56_49_97_");
TWO(sub64, "p113d_FID_112_49_56_49_98_");
TWO(mul64, "p113d_FID_112_49_56_49_99_");
TWO_OUT(bits64, "p113d_FID_112_49_56_49_100_");
TWO_OUT(arith32, "p113d_FID_112_49_56_49_101_");
TWO_OUT(shift64, "p113d_FID_112_49_56_49_102_");
TWO_OUT(shift32, "p113d_FID_112_49_56_49_103_");
TWO_OUT(compare64, "p113d_FID_112_49_56_49_104_");
TWO_OUT(compare32, "p113d_FID_112_49_56_49_105_");
EIGHT(weighted8, "p113d_FID_112_49_56_49_106_");
EIGHT(call8, "p113d_FID_112_49_56_49_107_");
extern uint64_t triple5(void *, uint64_t *, uint64_t, uint64_t, uint64_t,
  uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_49_108_");
extern uint64_t multi8(void *, uint64_t *, uint64_t, uint64_t, uint64_t,
  uint64_t, uint64_t, uint64_t, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_49_109_");
extern uint64_t tail9(void *, uint64_t, uint64_t, uint64_t, uint64_t,
  uint64_t, uint64_t, uint64_t, uint64_t, uint64_t)
  __asm__("p113d_FID_112_49_56_49_110_");
TWO_OUT(memory_words, "p113d_FID_112_49_56_49_111_");
extern uint64_t branch_join(void *, uint64_t)
  __asm__("p113d_FID_112_49_56_49_112_");
extern uint64_t multi_again(void *, uint64_t *, uint64_t, uint64_t, uint64_t,
  uint64_t, uint64_t, uint64_t) __asm__("p113d_FID_112_49_56_49_113_");
extern uint64_t p181_preserve(void *);

typedef struct {
  uint64_t before;
  uint64_t words[8];
  uint64_t after;
} Output;

static const uint64_t untouched = UINT64_C(0x9b7d5f311357ace0);

static void reset(Output *out) {
  out->before = UINT64_C(0x0123456789abcdef);
  out->after = UINT64_C(0xfedcba9876543210);
  for (unsigned i = 0; i < 8; ++i) out->words[i] = untouched;
}

static int word(const char *label, uint64_t actual, uint64_t expected) {
  if (actual == expected) return 1;
  fprintf(stderr, "%s: got %016" PRIx64 ", expected %016" PRIx64 "\n",
    label, actual, expected);
  return 0;
}

static int vector(const char *label, uint64_t status, const Output *out,
                  const uint64_t *expected, unsigned count) {
  if (!word(label, status, 0) ||
      !word("result prefix canary", out->before, UINT64_C(0x0123456789abcdef)) ||
      !word("result suffix canary", out->after, UINT64_C(0xfedcba9876543210))) return 0;
  for (unsigned i = 0; i < 8; ++i) {
    if (!word(label, out->words[i], i < count ? expected[i] : untouched)) {
      fprintf(stderr, "result slot %u\n", i);
      return 0;
    }
  }
  return 1;
}

#define SCALAR(label, call, expected) \
  do { if (!word(label, (call), (expected))) return 1; } while (0)
#define VECTOR(label, count, call, ...) \
  do { \
    reset(&out); \
    const uint64_t expected[] = {__VA_ARGS__}; \
    const uint64_t status = (call); \
    if (!vector(label, status, &out, expected, count)) return 1; \
  } while (0)

int main(void) {
  _Alignas(16) unsigned char state[2088];
  memset(state, 0xa5, sizeof state);
  Output out;

  SCALAR("add carry", add64(state, UINT64_C(0xffffffff), 1), UINT64_C(0x100000000));
  SCALAR("add wrap", add64(state, UINT64_MAX, 1), 0);
  SCALAR("add high", add64(state, UINT64_C(0x100000001), UINT64_C(0x200000003)), UINT64_C(0x300000004));
  SCALAR("sub wrap", sub64(state, 0, 1), UINT64_MAX);
  SCALAR("sub borrow", sub64(state, UINT64_C(0x100000000), 1), UINT64_C(0xffffffff));
  SCALAR("mul high", mul64(state, UINT64_C(0xffffffff), UINT64_C(0xffffffff)), UINT64_C(0xfffffffe00000001));
  SCALAR("mul wrap", mul64(state, UINT64_C(0x100000001), UINT64_C(0x100000001)), UINT64_C(0x200000001));
  SCALAR("mul negative word", mul64(state, UINT64_MAX, 2), UINT64_C(0xfffffffffffffffe));
  VECTOR("bit operations", 3, bits64(state, out.words, UINT64_C(0x100000001), UINT64_C(0xffffffff)),
    1, UINT64_C(0x1ffffffff), UINT64_C(0x1fffffffe));

  VECTOR("u32 wrap and ignore high", 3, arith32(state, out.words, UINT64_C(0x12345678ffffffff), UINT64_C(0xfedcba9800000001)),
    0, UINT64_C(0xfffffffe), UINT64_C(0xffffffff));
  VECTOR("u32 subtract wrap", 3, arith32(state, out.words, 0, 1), 1, UINT64_C(0xffffffff), 0);
  VECTOR("u32 multiply truncate", 3, arith32(state, out.words, UINT64_C(0x80000000), 2),
    UINT64_C(0x80000002), UINT64_C(0x7ffffffe), 0);

  VECTOR("u64 count32", 4, shift64(state, out.words, UINT64_C(0x100000001), 32),
    UINT64_C(0x100000000), 1, 1, UINT64_C(0x100000001));
  VECTOR("u64 count40", 4, shift64(state, out.words, 1, 40), UINT64_C(0x10000000000), 0, 0, 1);
  VECTOR("u64 count63", 4, shift64(state, out.words, UINT64_C(0x8000000000000000), 63),
    0, 1, UINT64_MAX, UINT64_C(0x8000000000000000));
  VECTOR("u64 signed shift", 4, shift64(state, out.words, UINT64_C(0x8000000000000001), 1),
    2, UINT64_C(0x4000000000000000), UINT64_C(0xc000000000000000), UINT64_C(0x8000000000000001));
  VECTOR("u64 count zero", 4, shift64(state, out.words, UINT64_C(0xdeadbeef01234567), 0),
    UINT64_C(0xdeadbeef01234567), UINT64_C(0xdeadbeef01234567),
    UINT64_C(0xdeadbeef01234567), UINT64_C(0xdeadbeef01234567));
  VECTOR("u32 signed shift and live high", 4, shift32(state, out.words, UINT64_C(0x1234567880000001), 1),
    2, UINT64_C(0x40000000), UINT64_C(0xc0000000), UINT64_C(0x1234567880000001));
  VECTOR("u32 count31", 4, shift32(state, out.words, 1, 31), UINT64_C(0x80000000), 0, 0, 1);
  VECTOR("u32 sign fill", 4, shift32(state, out.words, UINT64_C(0x80000000), 31),
    0, 1, UINT64_C(0xffffffff), UINT64_C(0x80000000));
  VECTOR("u32 count zero", 4, shift32(state, out.words, UINT64_C(0xfedcba9880000001), 0),
    UINT64_C(0x80000001), UINT64_C(0x80000001), UINT64_C(0x80000001), UINT64_C(0xfedcba9880000001));

  VECTOR("u64 compare equal", 8, compare64(state, out.words, UINT64_MAX, UINT64_MAX), 1,0,0,1,0,1,0,1);
  VECTOR("u64 positive low all ones", 8, compare64(state, out.words, UINT64_C(0xffffffff), 1), 0,1,0,0,1,1,0,1);
  VECTOR("u64 minimum signed", 8, compare64(state, out.words, UINT64_C(0x8000000000000000), 1), 0,1,0,0,1,1,1,0);
  VECTOR("u64 unsigned below signed above", 8, compare64(state, out.words, 1, UINT64_MAX), 0,1,1,1,0,0,0,1);
  VECTOR("u64 below", 8, compare64(state, out.words, 0, 1), 0,1,1,1,0,0,1,0);
  VECTOR("u32 negative low all ones", 8, compare32(state, out.words, UINT64_C(0xffffffff), 1), 0,1,0,0,1,1,1,0);
  VECTOR("u32 equality ignores high", 8, compare32(state, out.words, UINT64_C(0x1234567800000001), 1), 1,0,0,1,0,1,0,1);
  VECTOR("u32 unsigned below signed above", 8, compare32(state, out.words, 1, UINT64_C(0x80000000)), 0,1,1,1,0,0,0,1);
  VECTOR("u32 signed extremes", 8, compare32(state, out.words, UINT64_C(0x80000000), UINT64_C(0x7fffffff)), 0,1,0,0,1,1,1,0);

  SCALAR("weighted eight", weighted8(state,1,2,3,4,5,6,7,8), 204);
  SCALAR("weighted reverse", weighted8(state,8,7,6,5,4,3,2,1), 120);
  SCALAR("first stack argument", weighted8(state,0,0,0,0,0,1,0,0), 6);
  SCALAR("second stack argument", weighted8(state,0,0,0,0,0,0,1,0), 7);
  SCALAR("third stack argument", weighted8(state,0,0,0,0,0,0,0,1), 8);
  SCALAR("nested eight live arguments", call8(state,1,2,3,4,5,6,7,8), 213);
  SCALAR("nested eight reverse", call8(state,8,7,6,5,4,3,2,1), 129);
  VECTOR("multi hidden argument spill", 3, triple5(state,out.words,1,2,3,4,5), 5,5,UINT64_C(0x100000001));
  VECTOR("multi high and wrap", 3, triple5(state,out.words,UINT64_MAX,2,3,1,UINT64_C(0x8000000000000001)),
    UINT64_C(0x8000000000000001),0,UINT64_C(0x100000001));
  VECTOR("two multi calls retain first result", 3, multi8(state,out.words,1,2,3,4,5,6,7,8), 13,16,UINT64_C(0x200000002));
  VECTOR("two multi calls reverse", 3, multi8(state,out.words,8,7,6,5,4,3,2,1), 5,20,UINT64_C(0x200000002));
  SCALAR("tail zero", tail9(state,0,1,2,3,4,5,6,7,8), 204);
  SCALAR("tail one swap", tail9(state,1,1,2,3,4,5,6,7,8), 155);
  SCALAR("tail two swaps", tail9(state,2,1,2,3,4,5,6,7,8), 204);
  SCALAR("tail bounded long", tail9(state,100001,1,2,3,4,5,6,7,8), 155);
  VECTOR("multi tail zero", 3, multi_again(state,out.words,0,1,2,3,4,5), 1,2,3);
  VECTOR("multi tail one and aliased call results", 3,
    multi_again(state,out.words,1,1,2,3,4,5), 5,5,UINT64_C(0x100000001));
  VECTOR("multi tail two and stack permutation", 3,
    multi_again(state,out.words,2,1,2,3,4,5), 10,4,UINT64_C(0x100000001));
  VECTOR("multi tail bounded long", 3,
    multi_again(state,out.words,100001,1,2,3,4,5), 450005,5,UINT64_C(0x100000001));

  /* The unchanged direct verifier forbids pointer escape. Observe typed memory
   * contents and canaries; the requested alloca alignment is not observed. */
  VECTOR("typed stores and offset", 3,
    memory_words(state,out.words,UINT64_C(0x1122334455667788),UINT64_C(0x99887766aabbccdd)),
    UINT64_C(0xaabbccdd55667788), UINT64_C(0xaabbccdd), UINT64_C(0xfedcba9876543210));
  VECTOR("zero upper store", 3, memory_words(state,out.words,UINT64_MAX,0),
    UINT64_C(0xffffffff), 0, UINT64_C(0xfedcba9876543210));
  SCALAR("terminal arm", branch_join(state,0), 99);
  SCALAR("join lower", branch_join(state,1), 8);
  SCALAR("join boundary lower", branch_join(state,127), 134);
  SCALAR("join boundary upper", branch_join(state,128), 139);
  SCALAR("join wrap", branch_join(state,UINT64_MAX), 10);
  SCALAR("callee saved registers and stack canary", p181_preserve(state), 1);
  for (unsigned i = 0; i < sizeof state; ++i) {
    if (state[i] != 0xa5) {
      fprintf(stderr,"state unexpectedly changed at byte %u\n",i);
      return 1;
    }
  }
  puts("controls pass");
  return 0;
}
