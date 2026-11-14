#include <stdint.h>
#include <stdio.h>
#define DECL(n) extern uint64_t p195sp_##n(uint64_t*);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7)
static uint64_t (*functions[])(uint64_t*)={p195sp_0,p195sp_1,p195sp_2,p195sp_3,p195sp_4,p195sp_5,p195sp_6,p195sp_7};
int main(void){
 const uint64_t values[]={0,1,2,31,UINT32_MAX,UINT64_C(1)<<31,UINT64_C(1)<<32,(UINT64_C(1)<<32)+1,UINT64_C(1)<<63,(UINT64_C(1)<<63)+1,UINT64_MAX};
 unsigned checks=0,failures=0;
 for(unsigned m=0;m<8;m++)for(unsigned i=0;i<11;i++)for(unsigned j=0;j<11;j++){
  uint64_t a=values[i],b=values[j],ca=(m%2)?a:(uint32_t)a,cb=(m%2)?b:(uint32_t)b;
  unsigned pick=(ca<cb)^(m>=4);uint64_t wanted=pick?a:b;
  if((m/2)%2==0)wanted=(uint32_t)wanted;
  uint64_t sum=0;for(unsigned n=0;n<12;n++)sum^=((n%2)?b:a)+(n+1);
  uint64_t p[]={a,b,UINT64_MAX,UINT64_MAX,0,0,UINT64_MAX};
  uint64_t got=functions[m](p);checks++;
  if(got!=(sum^wanted)||p[0]!=a||p[1]!=b||p[2]!=wanted||p[3]!=wanted||p[4]!=a||p[5]!=b||p[6]!=sum){
   if(failures++<8)fprintf(stderr,"mode=%u i=%u j=%u got=%llu expected=%llu\n",m,i,j,(unsigned long long)got,(unsigned long long)(sum^wanted));
  }
 }
 printf("phase195 selection controls: checks=%u failures=%u\n",checks,failures);return failures!=0;
}
