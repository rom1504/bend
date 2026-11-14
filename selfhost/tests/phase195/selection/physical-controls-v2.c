#include <stdint.h>
#include <stdio.h>
#define TEN(M,B) M(B##0) M(B##1) M(B##2) M(B##3) M(B##4) M(B##5) M(B##6) M(B##7) M(B##8) M(B##9)
#define DECL(n) extern uint64_t p195pm_##n(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9)
TEN(DECL,1) TEN(DECL,2) TEN(DECL,3)
#define ENTRY(n) p195pm_##n,
static uint64_t (*functions[])(uint64_t *)={
 ENTRY(0) ENTRY(1) ENTRY(2) ENTRY(3) ENTRY(4) ENTRY(5) ENTRY(6) ENTRY(7) ENTRY(8) ENTRY(9)
 TEN(ENTRY,1) TEN(ENTRY,2) TEN(ENTRY,3)
};
static int predicate(unsigned op,uint64_t a,uint64_t b,unsigned narrow) {
 if(narrow){a=(uint32_t)a;b=(uint32_t)b;}
 /* Biasing the sign bit defines signed ordering without implementation-defined casts. */
 uint64_t sign=narrow?(UINT64_C(1)<<31):(UINT64_C(1)<<63);
 switch(op) {
 case 0:return a==b; case 1:return a!=b;
 case 2:return a<b; case 3:return a<=b; case 4:return a>b; case 5:return a>=b;
 case 6:return (a^sign)<(b^sign); case 7:return (a^sign)<=(b^sign);
 case 8:return (a^sign)>(b^sign); default:return (a^sign)>=(b^sign);
 }
}
int main(void) {
 const uint64_t values[]={0,1,2,31,UINT32_MAX,UINT64_C(1)<<31,
  UINT64_C(1)<<32,(UINT64_C(1)<<32)+1,UINT64_C(1)<<63,(UINT64_C(1)<<63)+1,UINT64_MAX};
 unsigned checks=0,failures=0;
 for(unsigned m=0;m<40;m++)for(unsigned i=0;i<11;i++)for(unsigned j=0;j<11;j++){
  uint64_t a=values[i],b=values[j],p[]={a,b,UINT64_MAX,UINT64_MAX};
  unsigned narrow=((m/10)%2)==0;
  int choose=predicate(m%10,a,b,narrow)^(m>=20&&m<40);
  uint64_t expected=choose;
  uint64_t got=functions[m](p);checks++;
  if(got!=expected||p[2]!=expected||p[3]!=expected||p[0]!=a||p[1]!=b){
   if(failures++<8)fprintf(stderr,"mode=%u a=%llu b=%llu expected=%llu got=%llu\n",m,
    (unsigned long long)a,(unsigned long long)b,(unsigned long long)expected,(unsigned long long)got);
  }
 }
 printf("phase195 physical selection controls: checks=%u failures=%u\n",checks,failures);
 return failures!=0;
}
