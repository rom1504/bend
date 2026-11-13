#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
extern uint64_t p190lv_loop(void *,uint64_t,uint64_t,uint64_t);
extern uint64_t p190lv_dead(void *,uint64_t);
extern uint64_t p190lv_narrow(void *,uint64_t);
extern uint64_t p190lv_branch(void *,uint64_t,uint64_t);
extern uint64_t p190lv_incoming(void *,uint64_t,uint64_t);
extern uint64_t p190lv_call(void *,uint64_t);
extern uint64_t p190lv_cold(void *,uint64_t,uint64_t);
__attribute__((noinline)) uint64_t p190lv_clobber(uint64_t x) {
  uint64_t result=x*9+1;
  __asm__ volatile("mov $101, %%rdi; mov $102, %%rsi; mov $103, %%rdx; mov $104, %%r8; mov $105, %%r9"
    : : : "rdi", "rsi", "rdx", "r8", "r9");
  return result;
}
int main(void) {
  uint64_t seeds[]={0,1,17,UINT32_MAX,UINT64_C(0x123456789abcdef0),UINT64_MAX};
  for(unsigned i=0;i<6;i++) for(unsigned n=0;n<16;n++) {
    uint64_t s=seeds[i], a=UINT64_C(0xfedcba9876543210);
    uint64_t got=p190lv_loop(NULL,n,a,s), want=a+(n+1)*(s+3);
    if(got!=want) { fprintf(stderr,"loop %u %u: %llu != %llu\n",i,n,(unsigned long long)got,(unsigned long long)want); return 1; }
    if(p190lv_dead(NULL,s)!=s+8) return 2;
    if(p190lv_narrow(NULL,s)!=(s^(uint32_t)s)) return 3;
    if(p190lv_branch(NULL,n&1,s)!=s+((n&1)?s+11:(s^53))) return 4;
    if(p190lv_incoming(NULL,s,UINT64_MAX)!=s+1) return 5;
    if(p190lv_call(NULL,s)!=s*9+42) return 6;
    if(p190lv_cold(NULL,n&1,s)!=((n&1)?s*9+1:s+7)) return 7;
  }
  puts("liveness-runtime=1");
  return 0;
}
