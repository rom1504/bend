#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
uint64_t p198_frame_test(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
__attribute__((noinline)) uint64_t p198_frame_external(uint64_t a,uint64_t b,uint64_t c,uint64_t d,
                                                       uint64_t e,uint64_t f,uint64_t g) {
  return (a+3*b)^(c+7*d)^(e+11*f)^g;
}
int main(void) {
  uint64_t seed=UINT64_C(0x17a6d3);
  const uint64_t edges[]={0,1,UINT64_MAX,UINT64_C(0x100000000),UINT64_C(0x8000000000000000)};
  for (unsigned i=0;i<512;i++) {
    seed=seed*UINT64_C(6364136223846793005)+1;
    uint64_t a=i<5?edges[i]:seed, b=~seed, c=seed>>7, d=seed*13, e=seed+17, f=seed<<11, g=seed^UINT64_C(0x38c3);
    uint64_t expected=((a+3*b)^(c+7*d)^(e+11*f)^g)+a+b;
    register uint64_t sentinel __asm__("rbp")=UINT64_C(0x035718446809387a);
    __asm__ volatile("" : "+r"(sentinel));
    uint64_t actual=p198_frame_test(a,b,c,d,e,f,g);
    __asm__ volatile("" : "+r"(sentinel));
    if (actual!=expected||sentinel!=UINT64_C(0x035718446809387a)) return 1;
  }
  puts("512 complete results and preserved caller RBP");
  return 0;
}
