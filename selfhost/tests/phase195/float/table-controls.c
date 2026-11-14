#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <xmmintrin.h>
typedef uint64_t (*worker)(uint64_t *,uint64_t,uint64_t);
#define DECL(n) extern uint64_t p195tc_old_##n(uint64_t*,uint64_t,uint64_t); extern uint64_t p195tc_new_##n(uint64_t*,uint64_t,uint64_t);
DECL(0) DECL(1) DECL(2) DECL(3)
static worker old[4]={p195tc_old_0,p195tc_old_1,p195tc_old_2,p195tc_old_3};
static worker newer[4]={p195tc_new_0,p195tc_new_1,p195tc_new_2,p195tc_new_3};
uint64_t p195tc_barrier(uint64_t *state,uint64_t value){state[0]++;state[1]=value;return ~value;}
static uint64_t lookup(uint64_t index){
  static const uint32_t table[]={0,UINT32_C(0x80000000),UINT32_C(0x7f800000),UINT32_C(0xff800000),UINT32_C(0x7fc12345),UINT32_C(0x7f800001),UINT32_MAX,UINT32_C(0xdeadbeef)};
  return table[index<7?index:7];
}
int main(void){
  const uint64_t extras[]={UINT64_MAX,UINT64_C(0x100000000),UINT64_C(0x100000001),UINT64_C(0x8000000000000000),UINT64_C(0x7fffffffffffffff),UINT64_C(0xffffffff00000000),UINT32_MAX,UINT64_C(0x100000007)};
  const uint64_t conditions[]={0,1,2,UINT64_C(0x100000000),UINT64_MAX};
  unsigned checks=0,failures=0,initial=_mm_getcsr();
  for(unsigned mode=0;mode<4;mode++)for(unsigned i=0;i<104;i++)for(unsigned c=0;c<5;c++){
    uint64_t index=i<96?i:extras[i-96],condition=conditions[c],s0[2]={0},s1[2]={0},expected=lookup(index);
    uint64_t state[2]={0};
    if(mode==1){state[0]=index;state[1]=expected;}
    if(mode==2)expected=(uint32_t)condition?expected:lookup(0);
    if(mode==3){state[0]=1;state[1]=expected;expected+=lookup(index+1);}
    uint64_t a=old[mode](s0,index,condition);unsigned flags0=_mm_getcsr();
    uint64_t b=newer[mode](s1,index,condition);unsigned flags1=_mm_getcsr();
    int ok=a==expected && b==expected && memcmp(s0,state,sizeof(state))==0 && memcmp(s1,state,sizeof(state))==0 && flags0==initial && flags1==initial;
    checks++;if(!ok){if(failures<5)fprintf(stderr,"mode=%u index=%llx condition=%llx old=%llx new=%llx expected=%llx\n",mode,(unsigned long long)index,(unsigned long long)condition,(unsigned long long)a,(unsigned long long)b,(unsigned long long)expected);failures++;}
  }
  printf("phase195 table controls: checks=%u failures=%u\n",checks,failures);return failures?1:0;
}
