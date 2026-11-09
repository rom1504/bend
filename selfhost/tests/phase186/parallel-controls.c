#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define F "p113d_FID_112_49_56_54_118_"
extern uint64_t chain(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "97_");
extern uint64_t swap(void*,uint64_t*,uint64_t,uint64_t,uint64_t) __asm__(F "98_");
extern uint64_t rotate(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "99_");
extern uint64_t fanout(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "100_");
extern uint64_t constants(void*,uint64_t*,uint64_t,uint64_t,uint64_t) __asm__(F "101_");
extern uint64_t transient(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "102_");
extern uint64_t setup(void*,uint64_t*,uint64_t,uint64_t) __asm__(F "103_");
static const uint64_t sentinel=UINT64_C(0x9b7d5f311357ace0), k=UINT64_C(0xfedcba9889abcdef);
static int same(uint64_t *out,const uint64_t *want,unsigned n) {
  for(unsigned i=0;i<n;i++) if(out[i]!=want[i]) return 0;
  for(unsigned i=n;i<8;i++) if(out[i]!=sentinel) return 0;
  return 1;
}
static void reset(uint64_t *out) { for(unsigned i=0;i<8;i++) out[i]=sentinel; }
int main(void) {
  uint64_t state[261],before[261],out[8];
  for(unsigned i=0;i<261;i++) state[i]=UINT64_C(0x9999000000000000)+i;
  memcpy(before,state,sizeof state);
  const uint64_t a=UINT64_C(0x8000000000000001),b=UINT64_MAX,c=UINT64_C(0xfedcba9876543210);
  reset(out); if(chain(state,out,1,a,b,c) || !same(out,(uint64_t[]){b,c,k},3)) return 1;
  reset(out); if(chain(state,out,100001,a,b,c) || !same(out,(uint64_t[]){k,k,k},3)) return 2;
  reset(out); if(swap(state,out,100001,a,b) || !same(out,(uint64_t[]){b,a},2)) return 3;
  reset(out); if(rotate(state,out,100001,a,b,c) || !same(out,(uint64_t[]){c,a,b},3)) return 4;
  reset(out); if(fanout(state,out,1,a,b,c) || !same(out,(uint64_t[]){b,b,a},3)) return 5;
  reset(out); if(fanout(state,out,2,a,b,c) || !same(out,(uint64_t[]){b,b,b},3)) return 6;
  reset(out); if(constants(state,out,3,a,b) || !same(out,(uint64_t[]){k,UINT64_MAX},2)) return 7;
  reset(out); if(transient(state,out,100001,a,b,c,5,6) ||
    !same(out,(uint64_t[]){a+100001,b+200002,c+300003,400009,500011},5)) return 8;
  reset(out); if(setup(state,out,100001,UINT64_MAX) || !same(out,(uint64_t[]){100000,UINT64_MAX},2)) return 9;
  reset(out); if(chain(state,out,0,a,b,c) || !same(out,(uint64_t[]){a,b,c},3)) return 10;
  if(memcmp(state,before,sizeof state)) return 11;
  puts("phase186 parallel move controls pass"); return 0;
}
