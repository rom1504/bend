#include <stdint.h>
#include <stdio.h>
extern uint64_t worker(void *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t) __asm__("p113d_FID_112_97_105_114_");
extern uint64_t caller(void *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t) __asm__("p113d_FID_99_97_108_108_");
int main(void) {
  uint64_t state[261]={0}, out[4]={77,0,0,88};
  const uint64_t b=UINT64_C(0xfedcba9876543210),h=UINT64_C(0xf0123456789abcde);
  for(unsigned a=0;a<2;a++) {
    if(worker(state,out+1,a,b,3,4,5,6,7,h)!=0 || out[0]!=77 || out[3]!=88 ||
       out[1]!=(a?b:h) || out[2]!=(a?h:b)) return 1;
    if(caller(state,a,b,3,4,5,6,7,h)!=(a?h-b:b-h)) return 2;
  }
  puts("public pair and private nested stack-argument calls passed");
}
