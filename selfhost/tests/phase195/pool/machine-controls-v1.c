#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint64_t p195pm_0(uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_1(uint64_t *,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_2(uint64_t *,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_3(uint64_t *,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_4(uint64_t *,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_5(uint64_t *,uint64_t,uint64_t,uint64_t);
extern uint64_t p195pm_6(uint64_t *,uint64_t,uint64_t,uint64_t);
typedef uint64_t (*worker4)(uint64_t *,uint64_t,uint64_t,uint64_t);
static const uint64_t sentinel=UINT64_C(0xa359c7e28db146f0);

/* An ordinary independent C callee checks the implicit-state transport through
   its effects. The wrapper's fixed-register asm reads the actual caller R12
   before and after a generated call, preventing a constant-folded ABI check. */
uint64_t p195pm_effect(uint64_t *state,uint64_t carry,uint64_t fourth) {
  state[0]^=carry+UINT64_C(0x9e3779b97f4a7c15);
  state[1]+=fourth+3;
  state[3]++;
  return carry^fourth^state[0];
}
static uint64_t invoke4(worker4 fn,uint64_t *state,uint64_t a,uint64_t b,uint64_t c,int *kept) {
  register uint64_t marker __asm__("r12")=sentinel;
  __asm__ volatile("" : "+r"(marker));
  uint64_t result=fn(state,a,b,c);
  __asm__ volatile("" : "+r"(marker));
  *kept=marker==sentinel;
  return result;
}
static uint64_t invoke_call(uint64_t *state,uint64_t a,uint64_t b,uint64_t c,uint64_t n,int *kept) {
  register uint64_t marker __asm__("r12")=sentinel;
  __asm__ volatile("" : "+r"(marker));
  uint64_t result=p195pm_0(state,a,b,c,n);
  __asm__ volatile("" : "+r"(marker));
  *kept=marker==sentinel;
  return result;
}
static unsigned checks,failures;
static void observe(unsigned mode,unsigned i,unsigned j,int pass) {
  checks++;
  if(!pass) {
    if(failures<12)fprintf(stderr,"pool mismatch: mode=%u i=%u j=%u\n",mode,i,j);
    failures++;
  }
}
int main(void) {
  static const uint64_t values[]={0,1,UINT64_C(0xffffffff),UINT64_C(0x100000000),
    UINT64_C(0x8000000000000000),UINT64_MAX,UINT64_C(0x123456789abcdef0),UINT64_C(0x80000001)};
  static const uint64_t counts[]={0,1,7,31,32,63,64,65,UINT64_C(0x100000001),UINT64_MAX};
  for(unsigned i=0;i<8;i++)for(unsigned j=0;j<10;j++) {
    uint64_t a=values[i],b=values[(i+3)%8]^counts[j],c=counts[j];
    uint64_t initial[4]={UINT64_C(0x7293abcd9ef01023)^a,UINT64_C(0xfedcba9876543210)+b,0,0};
    uint64_t state[4],wanted[4];int kept=0;uint64_t actual;
    memcpy(state,initial,sizeof state);memcpy(wanted,initial,sizeof wanted);
    uint64_t carry=a+c;
    wanted[0]^=carry+UINT64_C(0x9e3779b97f4a7c15);
    wanted[1]+=c+3;
    wanted[3]++;
    uint64_t answer=carry^c^wanted[0];
    uint64_t expected=carry+answer+wanted[1];wanted[2]=expected;
    actual=invoke_call(state,a,b,c,j,&kept);
    observe(0,i,j,actual==expected&&kept&&!memcmp(state,wanted,sizeof state));
    worker4 workers[]={p195pm_2,p195pm_3,p195pm_4,p195pm_5,p195pm_6};
    for(unsigned k=0;k<5;k++) {
      memcpy(state,initial,sizeof state);
      unsigned mode=k+2;
      if(mode==4) {
        actual=invoke4(workers[k],state,c,b,a,&kept);expected=a>>(c&63);
      } else if(mode==6) {
        actual=invoke4(workers[k],state,a,c,b,&kept);expected=(a<<(c&63))^b;
      } else {
        actual=invoke4(workers[k],state,a,b,c,&kept);
        expected=mode==3?(uint64_t)((uint32_t)a<<((uint32_t)c&31)):(a<<(c&63));
      }
      observe(mode,i,j,actual==expected&&kept&&!memcmp(state,initial,sizeof state));
    }
    for(unsigned n=0;n<9;n++) {
      memcpy(state,initial,sizeof state);
      uint64_t left=(n&1)?b:a,right=(n&1)?a:b;
      expected=left+3*right+initial[0];
      actual=invoke4(p195pm_1,state,n,a,b,&kept);
      observe(1,i,j,actual==expected&&kept&&!memcmp(state,initial,sizeof state));
    }
  }
  printf("phase195 pool machine controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
