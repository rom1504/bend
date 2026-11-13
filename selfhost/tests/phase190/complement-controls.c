#include <stdint.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*Fn)(uint64_t *);
#define DECL(P,W,O) extern uint64_t P##_##W##_##O(uint64_t *)
#define ALL(P,W) DECL(P,W,eq);DECL(P,W,ne);DECL(P,W,ult);DECL(P,W,ule);DECL(P,W,ugt);DECL(P,W,uge);DECL(P,W,slt);DECL(P,W,sle);DECL(P,W,sgt);DECL(P,W,sge)
ALL(p190cc,32);ALL(p190cc,64);ALL(p190cs,32);ALL(p190cs,64);
#define ROW(P,W) {P##_##W##_eq,P##_##W##_ne,P##_##W##_ult,P##_##W##_ule,P##_##W##_ugt,P##_##W##_uge,P##_##W##_slt,P##_##W##_sle,P##_##W##_sgt,P##_##W##_sge}
static int pred(unsigned op,uint64_t a,uint64_t b,unsigned narrow){
  uint64_t sign=narrow?UINT64_C(0x80000000):UINT64_C(0x8000000000000000);
  if(narrow){a=(uint32_t)a;b=(uint32_t)b;}
  switch(op){case 0:return a==b;case 1:return a!=b;case 2:return a<b;case 3:return a<=b;case 4:return a>b;case 5:return a>=b;case 6:return (a^sign)<(b^sign);case 7:return (a^sign)<=(b^sign);case 8:return (a^sign)>(b^sign);default:return (a^sign)>=(b^sign);}
}
int main(void){
  const Fn opposite[2][10]={ROW(p190cc,32),ROW(p190cc,64)},same[2][10]={ROW(p190cs,32),ROW(p190cs,64)};
  const uint64_t v[]={0,1,2,UINT64_C(0x7fffffff),UINT64_C(0x80000000),UINT32_MAX,UINT64_C(0x100000000),UINT64_C(0x7fffffffffffffff),UINT64_C(0x8000000000000000),UINT64_C(0xffffffff00000000),UINT64_MAX};
  unsigned observations=0;
  for(unsigned i=0;i<11;i++)for(unsigned j=0;j<11;j++)for(unsigned w=0;w<2;w++)for(unsigned op=0;op<10;op++){
    uint64_t state[4]={v[i],v[j],17,99},before[4];memcpy(before,state,sizeof state);
    int yes=pred(op,v[i],v[j],w==0);
    if(opposite[w][op](state)!=(yes?13:17)||memcmp(state,before,sizeof state))return 1;
    if(same[w][op](state)!=(yes?11:19)||memcmp(state,before,sizeof state))return 2;
    observations+=2;
  }
  printf("complement controls pass: %u\n",observations);return 0;
}
