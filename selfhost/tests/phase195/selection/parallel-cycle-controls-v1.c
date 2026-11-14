#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define DECL(n) extern uint64_t p195cy_##n(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7)
static uint64_t (*functions[])(void*,uint64_t*,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)={p195cy_0,p195cy_1,p195cy_2,p195cy_3,p195cy_4,p195cy_5,p195cy_6,p195cy_7};
int main(void){
 const uint64_t vals[]={0,1,UINT32_MAX,UINT64_C(1)<<32,UINT64_C(1)<<63,UINT64_MAX,UINT64_C(0x123456789abcdef0),UINT64_C(0xfedcba9876543210),UINT64_C(0x8000000000000001),31,65537};
 const unsigned iterations[]={0,1,2,3,4,7,31,257};
 unsigned checks=0,failures=0;
 for(unsigned m=0;m<8;m++)for(unsigned i=0;i<11;i++)for(unsigned k=0;k<8;k++){
  uint64_t initial[6],want[6],out[8],state[8],before[8];
  for(unsigned t=0;t<6;t++)want[t]=initial[t]=vals[(i+t)%11];
  for(unsigned t=0;t<8;t++){out[t]=UINT64_C(0xa55a5aa5f00f0ff0);state[t]=before[t]=UINT64_MAX-t;}
  for(unsigned n=0;n<iterations[k];n++){
   uint64_t old[6];memcpy(old,want,sizeof old);
   if(m==5)old[0]=(uint32_t)old[0];if(m==7)old[3]=(uint32_t)old[3];
   memcpy(want,old,sizeof old);
   switch(m){
    case 0:case 6:want[0]=old[1];want[1]=old[0];break;
    case 1:want[0]=old[1];want[1]=old[2];want[2]=old[0];break;
    case 2:want[0]=old[1];want[1]=old[0];want[2]=old[3];want[3]=old[2];break;
    case 3:want[0]=old[1];want[1]=old[0];want[2]=old[0];want[3]=old[2];want[4]=UINT64_C(0xfedcba9889abcdef);break;
    case 4:want[0]=old[2];want[2]=old[0];want[4]=old[5];want[5]=old[4];break;
    case 7:want[0]=old[1];want[1]=old[0];want[4]=old[5];want[5]=old[4];break;
   }
  }
  uint64_t result=functions[m](state,out,iterations[k],initial[0],initial[1],initial[2],initial[3],initial[4],initial[5]);checks++;
  if(result||memcmp(out,want,sizeof want)||memcmp(state,before,sizeof state)||out[6]!=UINT64_C(0xa55a5aa5f00f0ff0)||out[7]!=UINT64_C(0xa55a5aa5f00f0ff0)){
   if(failures++<8)fprintf(stderr,"mode=%u index=%u iterations=%u\n",m,i,iterations[k]);
  }
 }
 printf("phase195 residual cycle controls: checks=%u failures=%u\n",checks,failures);return failures!=0;
}
