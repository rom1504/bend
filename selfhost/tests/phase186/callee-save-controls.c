/* Observation only. The 32 functions are emitted by the Bend fixture, each
 * returning 77 after writing only the callee-saved homes selected by its mask.
 * Call exclusively through the assembly shim so a preservation failure cannot
 * corrupt the C observer's own live callee-saved registers before it is tested.
 */
#include <stdint.h>
#include <stdio.h>

typedef uint64_t (*p186_saved_function)(void);
extern uint64_t p186_sv_preserve(p186_saved_function);

#define DECLARE_MASK(n) extern uint64_t p186_sv_##n(void)
DECLARE_MASK(0);  DECLARE_MASK(1);  DECLARE_MASK(2);  DECLARE_MASK(3);
DECLARE_MASK(4);  DECLARE_MASK(5);  DECLARE_MASK(6);  DECLARE_MASK(7);
DECLARE_MASK(8);  DECLARE_MASK(9);  DECLARE_MASK(10); DECLARE_MASK(11);
DECLARE_MASK(12); DECLARE_MASK(13); DECLARE_MASK(14); DECLARE_MASK(15);
DECLARE_MASK(16); DECLARE_MASK(17); DECLARE_MASK(18); DECLARE_MASK(19);
DECLARE_MASK(20); DECLARE_MASK(21); DECLARE_MASK(22); DECLARE_MASK(23);
DECLARE_MASK(24); DECLARE_MASK(25); DECLARE_MASK(26); DECLARE_MASK(27);
DECLARE_MASK(28); DECLARE_MASK(29); DECLARE_MASK(30); DECLARE_MASK(31);
#undef DECLARE_MASK

static const p186_saved_function functions[] = {
  p186_sv_0,  p186_sv_1,  p186_sv_2,  p186_sv_3,
  p186_sv_4,  p186_sv_5,  p186_sv_6,  p186_sv_7,
  p186_sv_8,  p186_sv_9,  p186_sv_10, p186_sv_11,
  p186_sv_12, p186_sv_13, p186_sv_14, p186_sv_15,
  p186_sv_16, p186_sv_17, p186_sv_18, p186_sv_19,
  p186_sv_20, p186_sv_21, p186_sv_22, p186_sv_23,
  p186_sv_24, p186_sv_25, p186_sv_26, p186_sv_27,
  p186_sv_28, p186_sv_29, p186_sv_30, p186_sv_31
};
_Static_assert(sizeof functions / sizeof functions[0] == 32,
               "Every five-register mask must be observed");

int main(void) {
  for (unsigned mask = 0; mask < 32; ++mask) {
    if (p186_sv_preserve(functions[mask]) != 1) {
      fprintf(stderr, "callee-save mask %u failed\n", mask);
      return 1;
    }
  }
  puts("phase186 callee-save controls pass: 32/32");
  return 0;
}
