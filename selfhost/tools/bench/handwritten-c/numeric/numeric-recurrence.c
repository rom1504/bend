#include <float.h>
#include <stdint.h>

#pragma STDC FP_CONTRACT OFF

_Static_assert(FLT_RADIX == 2 && FLT_MANT_DIG == 24 && FLT_MAX_EXP == 128,
               "The fixture requires IEEE binary32 float");

static uint32_t f32_to_u32(float value) {
  /* Match the runtime outside C's defined float-to-unsigned conversion range. */
  return value >= 0.0f && value < 4294967296.0f ? (uint32_t)value : UINT32_C(0);
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  const uint32_t initial = b % UINT32_C(97) + UINT32_C(1);
  float x = (float)initial / 100.0f;
  uint32_t hash = b;
  uint32_t remaining = a;
  while (remaining != 0) {
    /* Each assignment is a separate F32 operation, in source dependency order.
       Compile without fast-math and with -ffp-contract=off. */
    const float left = 3.75f * x;
    const float right = 1.0f - x;
    const float y = left * right;
    const float scaled = y * 1000000.0f;
    hash = (hash * UINT32_C(16777619)) ^ f32_to_u32(scaled);
    x = y;
    --remaining;
  }
  return hash;
}
