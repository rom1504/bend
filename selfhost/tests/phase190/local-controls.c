#include <stdint.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*Fn)(uint64_t *);
#define DECL(O) extern uint64_t p190lc_##O(uint64_t *)
DECL(add); DECL(sub); DECL(mul); DECL(and); DECL(or); DECL(xor);
DECL(shr); DECL(shl); DECL(sar); DECL(mutable); DECL(branch); DECL(call); DECL(memory); DECL(width);
__attribute__((noinline)) uint64_t p190lc_external(uint64_t x){return x*3+7;}
static uint64_t sar(uint64_t a,unsigned n){
  if(!n)return a;
  return (a>>n)|((a>>63)?(~UINT64_C(0)<<(64-n)):0);
}
int main(void){
  const Fn ops[]={p190lc_add,p190lc_sub,p190lc_mul,p190lc_and,p190lc_or,p190lc_xor,p190lc_shr,p190lc_shl,p190lc_sar};
  const uint64_t words[]={0,1,31,32,63,64,UINT32_MAX,UINT64_C(0x100000000),UINT64_C(0x80000000ffffffff),UINT64_MAX};
  unsigned observations=0;
  for(unsigned i=0;i<10;i++)for(unsigned j=0;j<10;j++){
    uint64_t a=words[i],b=words[j],state[4]={a,b,UINT64_C(0xfedcba9876543210),17},before[4];
    memcpy(before,state,sizeof state);
    uint64_t want[]={a+b,a-b,a*b,a&b,a|b,a^b,a>>(b&63),a<<(b&63),sar(a,b&63)};
    for(unsigned k=0;k<9;k++){
      uint64_t got=ops[k](state);
      if(got!=(uint32_t)want[k]||memcmp(state,before,sizeof state)){fprintf(stderr,"operation %u inputs %u %u\n",k,i,j);return 1;}
      observations++;
    }
    if(p190lc_mutable(state)!=(a^(a+1))||memcmp(state,before,sizeof state))return 2;
    if(p190lc_branch(state)!=a+(b?10:20)||memcmp(state,before,sizeof state))return 3;
    if(p190lc_call(state)!=(a^(a*3+7))||memcmp(state,before,sizeof state))return 4;
    if(p190lc_width(state)!=((uint64_t)(uint32_t)a<<32)||memcmp(state,before,sizeof state))return 5;
    before[0]=b;
    if(p190lc_memory(state)!=(a^b)||memcmp(state,before,sizeof state))return 6;
    observations+=5;
  }
  printf("local-values controls pass: %u\n",observations);
  return 0;
}
