#include <stdint.h>
#include <stdio.h>
#define TEN(M,B) M(B##0) M(B##1) M(B##2) M(B##3) M(B##4) M(B##5) M(B##6) M(B##7) M(B##8) M(B##9)
#define DECL(n) extern uint64_t p194cr_##n(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9)
TEN(DECL,1) TEN(DECL,2) TEN(DECL,3) TEN(DECL,4)
#define ENTRY(n) p194cr_##n,
static uint64_t (*functions[])(uint64_t *)={
 ENTRY(0) ENTRY(1) ENTRY(2) ENTRY(3) ENTRY(4) ENTRY(5) ENTRY(6) ENTRY(7) ENTRY(8) ENTRY(9)
 TEN(ENTRY,1) TEN(ENTRY,2) TEN(ENTRY,3) TEN(ENTRY,4)
};
static uint64_t expected(unsigned mode,uint64_t a,uint64_t b) {
 if(mode/10==1)a=b;
 if(mode/10==4)a=7;
 uint64_t result;
 switch(mode%5) {
 case 0:result=a+b;break; case 1:result=a*b;break;
 case 2:result=a&b;break;case 3:result=a|b;break;default:result=a^b;break;
 }
 return mode%10<5?(uint32_t)result:result;
}
int main(void) {
 const uint64_t values[]={0,1,2,31,UINT32_MAX,UINT64_C(1)<<31,
  UINT64_C(1)<<32,(UINT64_C(1)<<32)+1,UINT64_C(1)<<63,(UINT64_C(1)<<63)+1,UINT64_MAX};
 unsigned checks=0,failures=0;
 for(unsigned m=0;m<50;m++)for(unsigned i=0;i<11;i++)for(unsigned j=0;j<11;j++){
  uint64_t a=values[i],b=values[j],p[]={a,b};
  uint64_t want=expected(m,a,b),got=functions[m](p);checks++;
  if(got!=want||p[0]!=a||p[1]!=b){
   if(failures++<8)fprintf(stderr,"mode=%u a=%llu b=%llu expected=%llu got=%llu\n",m,
    (unsigned long long)a,(unsigned long long)b,(unsigned long long)want,(unsigned long long)got);
  }
 }
 printf("phase194 commutative controls: checks=%u failures=%u\n",checks,failures);
 return failures!=0;
}
