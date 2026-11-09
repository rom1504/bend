#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define F "p113d_FID_112_49_56_54_109_"
extern uint64_t dead(void *,uint64_t,uint64_t) __asm__(F "97_");
extern uint64_t field(void *,uint64_t,uint64_t) __asm__(F "98_");
extern uint64_t barrier(void *,uint64_t,uint64_t) __asm__(F "99_");
extern uint64_t branch(void *,uint64_t,uint64_t) __asm__(F "100_");
extern uint64_t floating(void *,uint64_t,uint64_t) __asm__(F "101_");
extern uint64_t alias(void *) __asm__("p111_FID_112_49_56_54_109_102_");
static void *expected_state;
static uint64_t expected_arg;
static unsigned calls,bad;
uint64_t p111_rt_op(void *state,uint32_t op,uint64_t *args,uint32_t count) {
  if (state!=expected_state || op!=36 || count!=1 || args[0]!=expected_arg) bad=1;
  ++calls; args[0]=UINT64_C(0x8877665544332211); return 0;
}
int main(void) {
  uint64_t state[261],before[261];
  const uint64_t words[]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),UINT64_C(0xfedcba9876543210)};
  for(unsigned i=0;i<261;i++) state[i]=UINT64_C(0x9999000000000000)+i;
  expected_state=state;
  for(unsigned i=0;i<5;i++) for(unsigned j=0;j<5;j++) {
    uint64_t a=words[i],b=words[j]; memcpy(before,state,sizeof state);
    if(dead(state,a,b)!=a || field(state,a,b)!=(a>>32) || branch(state,a,b)!=(a?b:a)) return 1;
    expected_arg=a; if(barrier(state,a,b)!=UINT64_C(0x8877665544332211)) return 2;
    if(memcmp(before,state,sizeof state)) return 3;
    state[0]=a;state[1]=b;memcpy(before,state,sizeof state);
    if(alias(state)!=b || memcmp(before,state,sizeof state)) return 4;
  }
  if(floating(state,UINT64_C(0xaaaaaaaa3f800000),UINT64_C(0xbbbbbbbb3f000000))!=UINT64_C(0x3fc00000)) return 5;
  if(floating(state,UINT64_C(0x80000000),UINT64_C(0x80000000))!=UINT64_C(0x80000000)) return 6;
  if(bad || calls!=25) return 7;
  puts("phase186 private memory controls pass"); return 0;
}
