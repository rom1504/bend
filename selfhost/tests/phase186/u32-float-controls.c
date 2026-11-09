/* Exact bit labels copied from the frozen Phase112 case authority.
 * cases.json SHA256: bde39b2e416263ae82219c601ea409afc0e14be42ddb877a4d8aa4c545ce9753
 * Each case is observed under five forced placements and three upper words.
 * Expected results are fixed integers, with no host floating-point oracle. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

typedef struct { uint64_t input, expected; const char *name; } Case;
static const Case cases[7] = {
  {UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), "u32-to-f32-zero"},
  {UINT64_C(0x0000000000000001), UINT64_C(0x000000003f800000), "u32-to-f32-one"},
  {UINT64_C(0x0000000001000001), UINT64_C(0x000000004b800000), "u32-to-f32-tie-even-down"},
  {UINT64_C(0x0000000001000003), UINT64_C(0x000000004b800002), "u32-to-f32-tie-even-up"},
  {UINT64_C(0x00000000ffffffff), UINT64_C(0x000000004f800000), "u32-to-f32-maximum"},
  {UINT64_C(0x0000000080000000), UINT64_C(0x000000004f000000), "u32-to-f32-high-bit"},
  {UINT64_C(0xffffffff00000001), UINT64_C(0x000000003f800000), "u32-to-f32-upper-word"},
};
typedef uint64_t (*Function)(void *, uint64_t *, uint64_t);
extern uint64_t p186uf_0(void *, uint64_t *, uint64_t);
extern uint64_t p186uf_1(void *, uint64_t *, uint64_t);
extern uint64_t p186uf_2(void *, uint64_t *, uint64_t);
extern uint64_t p186uf_3(void *, uint64_t *, uint64_t);
extern uint64_t p186uf_4(void *, uint64_t *, uint64_t);
static Function functions[5] = {p186uf_0,p186uf_1,p186uf_2,p186uf_3,p186uf_4};

int main(void) {
  unsigned checks = 0, failures = 0;
  const uint64_t canary = UINT64_C(0xfedcba9876543210);
  uint64_t state[4] = {0, 0, canary, canary};
  for (unsigned f = 0; f < 5; ++f) for (unsigned i = 0; i < 7; ++i) for (unsigned h = 0; h < 3; ++h) {
    uint64_t input = h == 0 ? cases[i].input : (uint32_t)cases[i].input |
      (h == 1 ? UINT64_C(0xffffffff00000000) : UINT64_C(0xdeadbeef00000000));
    uint64_t out[4] = {canary, canary, canary, canary};
    uint64_t status = functions[f](state, out, input);
    ++checks;
    if (status || out[0] != cases[i].expected || out[1] != input || out[2] != input ||
        out[3] != canary || state[0] || state[1] || state[2] != canary || state[3] != canary) {
      ++failures;
      fprintf(stderr, "u32-float mode=%u case=%s high=%u result=%016" PRIx64 " expected=%016" PRIx64 "\n",
              f, cases[i].name, h, out[0], cases[i].expected);
    }
  }
  if (failures || checks != 105) return 1;
  puts("phase186 u32 float controls pass: 105/105");
  return 0;
}
