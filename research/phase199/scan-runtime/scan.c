#include "scan.h"
#include <emmintrin.h>
#include <string.h>

static int32_t bits(uint32_t x) { int32_t s; memcpy(&s,&x,4); return s; }

uint64_t p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
                         uint64_t index, uint64_t incoming) {
  if (!fuel) return incoming;
  uint32_t i=(uint32_t)index, carry=(uint32_t)incoming;
  /* Tiny rings repeat addresses inside a SIMD group. Keep their scalar order.
   * A non-power-of-two mask also takes this defensive scalar path. Caller
   * bounds/layout validity remains a precondition, exactly as for the old loop.
   */
  if (mask < 3 || (mask & (mask+1)) != 0) {
    do {
      carry += data[(uint64_t)i & mask];
      data[(uint64_t)i & mask] = carry ^ i;
      ++i;
    } while (--fuel);
    return carry;
  }
  while (fuel && (i & 3u)) {
    carry += data[(uint64_t)i & mask];
    data[(uint64_t)i & mask] = carry ^ i;
    ++i; --fuel;
  }
  __m128i c=_mm_set1_epi32(bits(carry));
  __m128i ix=_mm_add_epi32(_mm_set1_epi32(bits(i)),_mm_setr_epi32(0,1,2,3));
  while (fuel >= 4) {
    uint32_t *p=data+((uint64_t)i & mask);
    __m128i sum=_mm_loadu_si128((const __m128i *)p);
    sum=_mm_add_epi32(sum,_mm_slli_si128(sum,4));
    sum=_mm_add_epi32(sum,_mm_slli_si128(sum,8));
    sum=_mm_add_epi32(sum,c);
    _mm_storeu_si128((__m128i *)p,_mm_xor_si128(sum,ix));
    c=_mm_shuffle_epi32(sum,255);
    ix=_mm_add_epi32(ix,_mm_set1_epi32(4));
    i+=4; fuel-=4;
  }
  carry=(uint32_t)_mm_cvtsi128_si32(c);
  while (fuel) {
    carry+=data[(uint64_t)i & mask];
    data[(uint64_t)i & mask]=carry^i;
    ++i; --fuel;
  }
  return carry;
}
