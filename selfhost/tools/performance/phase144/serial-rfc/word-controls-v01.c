/* Source-only focused controls over the actual frozen candidate runtime.
 * Build with -I <serial-rfc01> and the explicit mode. No copied helper bodies.
 * This is not a concurrent-runtime test or a term_drop lifetime qualification.
 */
#include "runtime.c"

_Static_assert(sizeof(u32) == 4 && sizeof(u64) == 8, "word-control widths");

static int control_words(void) {
  const u32 lows[] = {0, 1, 2, RFC_CNT-2, RFC_CNT-1, RFC_CNT,
                      UINT32_C(0xff000001), UINT32_MAX};
  const u32 highs[] = {0, 1, UINT32_C(0xdeadbeef), UINT32_MAX};
  const u32 amounts[] = {0, 1, 2, 7, RFC_CNT, UINT32_MAX};
  unsigned observations = 0;
  for (unsigned l = 0; l < sizeof lows / sizeof *lows; ++l)
    for (unsigned h = 0; h < sizeof highs / sizeof *highs; ++h)
      for (unsigned k = 0; k < sizeof amounts / sizeof *amounts; ++k)
        for (unsigned subtract = 0; subtract < 2; ++subtract) {
          u64 actual = ((u64)highs[h] << 32) | lows[l];
          u64 reference = actual;
          u32 got = subtract ? p144_rfc_sub((u32 *)&actual, amounts[k])
                             : p144_rfc_add((u32 *)&actual, amounts[k]);
          u32 expected = subtract ? a32_sub_rel((u32 *)&reference, amounts[k])
                                  : a32_add((u32 *)&reference, amounts[k]);
          if (got != expected || got != lows[l] || actual != reference ||
              (u32)(actual >> 32) != highs[h]) {
            fprintf(stderr, "word mismatch %u %u %u %u\n", l, h, k, subtract);
            return 2;
          }
          ++observations;
        }
  printf("p144 RFC words: %u PASS\n", observations);
  return 0;
}

int main(int argc, char **argv) {
  if (argc != 2) return 2;
  if (strcmp(argv[1], "words") == 0) return control_words();
  if (strcmp(argv[1], "bump-safe") == 0) {
    u64 cell = (UINT64_C(0x12345678) << 32) | UINT32_C(0x5a000000) | (RFC_CNT-2);
    u64 original = cell;
    Env e = {&cell, NULL};
    rfc_bump(e, 0, 1);
    if (cell != original + 1) return 2;
    puts("p144 RFC safe boundary: PASS");
    return 0;
  }
  if (strcmp(argv[1], "overflow") == 0) {
    u64 cell = (UINT64_C(0x12345678) << 32) | UINT32_C(0x5a000000) | (RFC_CNT-1);
    Env e = {&cell, NULL};
    rfc_bump(e, 0, 1);
    fputs("overflow unexpectedly returned\n", stderr);
    return 2;
  }
  if (strcmp(argv[1], "pool") == 0) {
#if P144_SINGLE_MUTATOR_RFC
    pool_open();
    fputs("pool unexpectedly returned\n", stderr);
#endif
    return 2;
  }
  return 2;
}
