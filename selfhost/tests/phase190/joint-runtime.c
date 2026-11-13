/* Reuse all seven independent liveness oracles, then exercise all nine homes
 * together with eight-result output, stack ABI arguments and cyclic Again. */
#define main p190j_previous_main
#include "liveness-runtime.c"
#undef main

extern uint64_t p190j_nine(void *,uint64_t *,uint64_t,
  uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);

int main(void) {
  if(p190j_previous_main()) return 1;
  const uint64_t input[8]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),
    UINT64_C(0x123456789abcdef0),UINT32_MAX,17,UINT64_C(0xfedcba9876543210)};
  const uint64_t sentinel=UINT64_C(0xacce5510deadcafe);
  for(unsigned n=0;n<130;n++) {
    uint64_t out[10];
    for(unsigned i=0;i<10;i++) out[i]=sentinel;
    if(p190j_nine(NULL,out+1,n,input[0],input[1],input[2],input[3],input[4],input[5],input[6],input[7])) return 2;
    if(out[0]!=sentinel || out[9]!=sentinel) return 3;
    for(unsigned i=0;i<8;i++) if(out[i+1]!=input[(i+n)%8]) {
      fprintf(stderr,"joint rotation n=%u lane=%u\n",n,i); return 4;
    }
  }
  puts("joint-runtime=1");
  return 0;
}
