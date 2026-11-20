#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../../../selfhost/src/runtime/qbe/runtime.h"
extern uint64_t p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
__attribute__((noinline)) uint64_t p195rc_runtime(P111State*s,uint32_t op,const uint64_t*a,uint32_t n){return p111_rt_op(s,op,a,n);}
typedef uint64_t(*worker)(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_0(P111State*,uint64_t,uint64_t),p195rc_new_0(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_1(P111State*,uint64_t,uint64_t),p195rc_new_1(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_2(P111State*,uint64_t,uint64_t),p195rc_new_2(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_3(P111State*,uint64_t,uint64_t),p195rc_new_3(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_4(P111State*,uint64_t,uint64_t),p195rc_new_4(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_5(P111State*,uint64_t,uint64_t),p195rc_new_5(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_6(P111State*,uint64_t,uint64_t),p195rc_new_6(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_7(P111State*,uint64_t,uint64_t),p195rc_new_7(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_8(P111State*,uint64_t,uint64_t),p195rc_new_8(P111State*,uint64_t,uint64_t);
extern uint64_t p195rc_old_9(P111State*,uint64_t,uint64_t),p195rc_new_9(P111State*,uint64_t,uint64_t);
static worker old[10]={p195rc_old_0,p195rc_old_1,p195rc_old_2,p195rc_old_3,p195rc_old_4,p195rc_old_5,p195rc_old_6,p195rc_old_7,p195rc_old_8,p195rc_old_9};
static worker newer[10]={p195rc_new_0,p195rc_new_1,p195rc_new_2,p195rc_new_3,p195rc_new_4,p195rc_new_5,p195rc_new_6,p195rc_new_7,p195rc_new_8,p195rc_new_9};
static uint32_t divisor[10]={6u,10u,26u,7u,0u,1u,97u,80u,4294967295u,26u};
int main(void){
 uint32_t rng=19526u,edge[8]={0,1,25,26,27,0x7fffffffu,0x80000000u,0xffffffffu};unsigned checks=0,failures=0;
 for(unsigned i=0;i<264;i++){rng=rng*1664525u+1013904223u;uint32_t n=i<8?edge[i]:rng;
  uint64_t raw=((i&1)?UINT64_C(0xfedcba98)<<32:0)|n,salt=UINT64_C(0xf123456789abcdef);
  for(unsigned m=0;m<10;m++){P111State a={0},b={0},zero={0};uint32_t d=divisor[m];
   uint64_t want=(d?(uint64_t)(n%d):raw)+salt;
   uint64_t x=old[m](&a,raw,salt),y=newer[m](&b,raw,salt);
   int ok=x==want&&y==want&&!memcmp(&a,&zero,sizeof a)&&!memcmp(&b,&zero,sizeof b);
   checks++;if(!ok){if(failures<5)fprintf(stderr,"mode=%u n=%llu expected=%llu old=%llu new=%llu\n",m,(unsigned long long)raw,(unsigned long long)want,(unsigned long long)x,(unsigned long long)y);failures++;}
  }
 }
 printf("phase195 remainder controls: checks=%u failures=%u\n",checks,failures);return failures?1:0;
}
