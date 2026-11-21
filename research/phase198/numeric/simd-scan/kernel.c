#define _POSIX_C_SOURCE 200809L
#include <emmintrin.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef uint32_t (*kernel)(uint32_t *, uint64_t, uint32_t, uint32_t);

__attribute__((noinline))
uint32_t scalar(uint32_t *a, uint64_t n, uint32_t i, uint32_t acc) {
  for (; n; --n, ++i) {
    acc += a[i & 127u];
    a[i & 127u] = acc ^ i;
  }
  return acc;
}

static int32_t bits(uint32_t x) { int32_t s; memcpy(&s, &x, 4); return s; }

__attribute__((noinline))
uint32_t simd4(uint32_t *a, uint64_t n, uint32_t i, uint32_t acc) {
  /* Prefix and tail preserve all U32 index values, including UINT32_MAX. */
  while (n && (i & 3u)) {
    acc += a[i & 127u]; a[i & 127u] = acc ^ i; ++i; --n;
  }
  __m128i carry = _mm_set1_epi32(bits(acc));
  __m128i index = _mm_add_epi32(_mm_set1_epi32(bits(i)),
                               _mm_setr_epi32(0, 1, 2, 3));
  for (; n >= 4; n -= 4, i += 4) {
    /* i%4==0 implies no ring wrap within the four distinct locations. */
    __m128i v = _mm_loadu_si128((const __m128i *)(a + (i & 127u)));
    v = _mm_add_epi32(v, _mm_slli_si128(v, 4));
    v = _mm_add_epi32(v, _mm_slli_si128(v, 8));
    v = _mm_add_epi32(v, carry);
    _mm_storeu_si128((__m128i *)(a + (i & 127u)), _mm_xor_si128(v, index));
    carry = _mm_shuffle_epi32(v, 255);
    index = _mm_add_epi32(index, _mm_set1_epi32(4));
  }
  acc = (uint32_t)_mm_cvtsi128_si32(carry);
  for (; n; --n, ++i) {
    acc += a[i & 127u]; a[i & 127u] = acc ^ i;
  }
  return acc;
}

static uint32_t rng(uint32_t *s) { *s = *s * 1664525u + 1013904223u; return *s; }
static uint64_t ns(void) {
  struct timespec t;
  if (clock_gettime(CLOCK_MONOTONIC, &t)) abort();
  return (uint64_t)t.tv_sec * UINT64_C(1000000000) + (uint64_t)t.tv_nsec;
}
static void array_json(const uint32_t *a) {
  putchar('[');
  for (unsigned j = 0; j < 128; ++j) printf("%s%" PRIu32, j ? "," : "", a[j]);
  putchar(']');
}

static int check(void) {
  const uint64_t counts[] = {0,1,2,3,4,5,7,15,31,63,64,65,126,127,128,129,130,131,255,256,257,4096,65539};
  const uint32_t starts[] = {0,1,2,3,124,125,126,127,128,129,0xffffff7d,0xfffffffc,0xfffffffd,0xfffffffe,0xffffffff};
  uint64_t cases = 0;
  for (unsigned seed = 0; seed < 64; ++seed)
    for (unsigned si = 0; si < sizeof(starts)/sizeof(*starts); ++si)
      for (unsigned ni = 0; ni < sizeof(counts)/sizeof(*counts); ++ni) {
        uint32_t original[136], left[136], right[136];
        unsigned offset = 1 + seed % 4;
        uint32_t state = seed ^ 0x9e3779b9u, acc = rng(&state);
        for (unsigned j=0;j<136;++j) original[j] = rng(&state);
        if (seed % 3 == 0)
          for (unsigned j=0;j<128;++j) original[j+offset] = seed == 0 ? 0 : UINT32_MAX-seed;
        memcpy(left, original, sizeof(left)); memcpy(right, original, sizeof(right));
        uint32_t l = scalar(left+offset, counts[ni], starts[si], acc);
        uint32_t r = simd4(right+offset, counts[ni], starts[si], acc);
        if (l != r || memcmp(left,right,sizeof(left))) return 2;
        for (unsigned j=0;j<136;++j)
          if ((j < offset || j >= offset+128) && (left[j] != original[j] || right[j] != original[j])) return 3;
        ++cases;
        /* Complete initial/final states for an independently implemented oracle. */
        if (seed == 7 && (si == 0 || si == 14) && (ni == 0 || ni == 15 || ni == 22)) {
          printf("{\"kind\":\"vector\",\"n\":%" PRIu64 ",\"i\":%" PRIu32 ",\"acc\":%" PRIu32 ",\"initial\":",counts[ni],starts[si],acc);
          array_json(original+offset); printf(",\"final\":"); array_json(right+offset);
          printf(",\"result\":%" PRIu32 "}\n",r);
        }
      }
  uint32_t a[128]; for(unsigned j=0;j<128;++j) a[j]=17;
  if (simd4(a,4096,0,0) != 2339999928u) return 4;
  printf("{\"kind\":\"checks\",\"cases\":%" PRIu64 ",\"ordinary\":2339999928}\n",cases);
  return 0;
}

static int timing(kernel f, uint64_t reps, uint64_t n, uint32_t seed) {
  uint32_t a[128], expected;
  for(unsigned j=0;j<128;++j) a[j]=seed;
  expected=scalar(a,n,0,0);
  uint64_t success=0, start=ns();
  for(uint64_t r=0;r<reps;++r) {
    for(unsigned j=0;j<128;++j) a[j]=seed;
    success += f(a,n,0,0) == expected;
  }
  uint64_t elapsed=ns()-start, hash=0;
  for(unsigned j=0;j<128;++j) hash=hash*UINT64_C(1099511628211)+a[j];
  printf("{\"kind\":\"timing\",\"ns\":%" PRIu64 ",\"reps\":%" PRIu64 ",\"success\":%" PRIu64 ",\"result\":%" PRIu32 ",\"arrayHash\":%" PRIu64 "}\n",elapsed,reps,success,expected,hash);
  return success==reps ? 0 : 5;
}

int main(int argc,char **argv) {
  if(argc==2 && !strcmp(argv[1],"check")) return check();
  if(argc!=5) return 1;
  kernel f = !strcmp(argv[1],"scalar") ? scalar : !strcmp(argv[1],"simd4") ? simd4 : NULL;
  if(!f) return 1;
  return timing(f,strtoull(argv[2],NULL,10),strtoull(argv[3],NULL,10),(uint32_t)strtoul(argv[4],NULL,10));
}
