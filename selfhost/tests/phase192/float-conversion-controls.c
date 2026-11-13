/* Independent value oracle uses IEEE-754 integer decomposition for F32->U32;
 * a separate C predicate/cast checks values, and the actual pinned runtime
 * anchors MXCSR exception flags. Candidate instruction selection is never used
 * to obtain expected values. C fenv behavior is compiler-specific; the runtime
 * comparison tests that behavior instead of assuming portable C guarantees.
 * All 16 rounding/DAZ/FTZ settings, raw NaNs/subnormals, 2^31/2^32 neighbors,
 * randomized bit patterns and nonzero upper input/output words are exercised. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <xmmintrin.h>
#include "../../src/runtime/qbe/runtime.h"

/* runtime.h defines the real state layout but intentionally omits this import.
 * Neither unary operation touches heap pointers, but the dispatcher loads e
 * before dispatch, so a valid zero-initialized state (never NULL) is required. */
extern uint64_t p111_rt_op(P111State *, uint32_t, const uint64_t *, uint32_t);

#define DECL(name) extern uint64_t name(uint64_t)
DECL(p192fc_f58); DECL(p192fc_u23); DECL(p192fc_x58); DECL(p192fc_x23);
extern uint64_t p192fc_b58(const uint64_t*);
extern uint64_t p192fc_b23(const uint64_t*);
extern uint64_t p192fc_a58(const uint64_t*);
extern uint64_t p192fc_a23(const uint64_t*);

static uint32_t word_oracle(uint32_t b) {
  unsigned e=(b>>23)&255;
  if((b>>31) || e<127 || e>=159) return 0;
  uint64_t m=UINT64_C(0x800000)|(b&0x7fffff);
  return e>=150 ? (uint32_t)(m<<(e-150)) : (uint32_t)(m>>(150-e));
}
__attribute__((noinline)) static uint64_t float_reference(uint64_t b) {
  volatile uint32_t input=(uint32_t)b;
  uint32_t lo=input; float v; memcpy(&v,&lo,4);
  return v>=0.0f && v<4294967296.0f ? (uint32_t)v : 0;
}
__attribute__((noinline)) static uint64_t uint_reference(uint64_t b) {
  volatile uint32_t lo=(uint32_t)b;
  float f=(float)lo; uint32_t out; memcpy(&out,&f,4); return out;
}
static uint32_t state=0x1ac39107;
static uint32_t random_word(void) { state^=state<<13; state^=state>>17; state^=state<<5;return state; }
static unsigned failures,checks;
static void compare(uint64_t got,uint64_t want,unsigned flags,unsigned expected,
                    unsigned mode,unsigned route,unsigned op,uint64_t in) {
  ++checks;
  if(got!=want || flags!=expected) {
    if(failures++<12) fprintf(stderr,"mode=%x route=%u op=%u input=%016" PRIx64
      " got=%016" PRIx64 " expected=%016" PRIx64 " flags=%x/%x\n",
      mode,route,op,in,got,want,flags,expected);
  }
}
int main(void) {
  const uint32_t edges[]={0,0x80000000,1,0x007fffff,0x00800000,0x80000001,
    0x807fffff,0x80800000,0x3f7fffff,0x3f800000,0x3f800001,0x3fffffff,
    0xbf7fffff,0xbf800000,0xbf800001,0x4affffff,0x4b000000,0x4b800000,
    0x4effffff,0x4f000000,0x4f000001,0x4f7fffff,0x4f800000,0x4f800001,
    0x7f7fffff,0x7f800000,0xff800000,0x7f800001,0x7fbfffff,0x7fc00000,
    0x7fffffff,0xff800001,0xffbfffff,0xffc00000,0xffffffff,
    0x01000001,0x01000003,0x7fffffff,0x80000000};
  P111State runtime_state={0};
  const unsigned saved=_mm_getcsr();
  for(unsigned rounding=0;rounding<4;++rounding) for(unsigned flush=0;flush<4;++flush) {
    unsigned mode=0x1f80 | rounding*0x2000 | ((flush&1)?0x40:0) | ((flush&2)?0x8000:0);
    state=0x1ac39107;
    for(unsigned i=0;i<sizeof(edges)/sizeof(edges[0])+4096;++i) {
      uint32_t low=i<sizeof(edges)/sizeof(edges[0])?edges[i]:random_word();
      uint64_t in=((uint64_t)(i%3==0?0:i%3==1?0xffffffff:0xdeadbeef)<<32)|low;
      for(unsigned op=0;op<2;++op) {
        _mm_setcsr(mode);
        uint64_t expected=op?uint_reference(in):float_reference(in);
        unsigned c_flags=_mm_getcsr()&63;
        _mm_setcsr(mode);
        uint64_t runtime_value=p111_rt_op(&runtime_state,op?23:58,&in,1);
        unsigned expected_flags=_mm_getcsr()&63;
        if(runtime_value!=expected || expected_flags!=c_flags) {
          fprintf(stderr,"Pinned runtime/C oracle mismatch mode=%x op=%u input=%016" PRIx64
            " runtime=%016" PRIx64 " C=%016" PRIx64 " flags=%x/%x\n",
            mode,op,in,runtime_value,expected,expected_flags,c_flags);
          _mm_setcsr(saved);return 4;
        }
        if(!op && expected!=word_oracle(low)) { fprintf(stderr,"Independent value oracles disagree\n");return 2; }
        for(unsigned route=0;route<4;++route) {
          uint64_t cell=in;
          _mm_setcsr(mode);
          uint64_t got=route==0?(op?p192fc_u23(in):p192fc_f58(in)):
            route==1?(op?p192fc_x23(in):p192fc_x58(in)):
            route==2?(op?p192fc_b23(&cell):p192fc_b58(&cell)):
                     (op?p192fc_a23(&cell):p192fc_a58(&cell));
          unsigned flags=_mm_getcsr()&63;
          compare(got,expected,flags,expected_flags,mode,route,op,in);
          if(cell!=in) { fprintf(stderr,"Input cell changed\n");return 3; }
        }
      }
    }
  }
  _mm_setcsr(saved);
  printf("phase192 float conversions: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
