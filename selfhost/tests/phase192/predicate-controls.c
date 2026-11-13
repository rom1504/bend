#include <stdint.h>
#include <stdio.h>
#define DECL(n) extern uint64_t p192pc_##n(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9) DECL(10)
uint64_t p192pc_barrier(uint64_t *p) { return p[0] ^ p[1]; }
int main(void) {
  uint64_t (*f[])(uint64_t *)={p192pc_0,p192pc_1,p192pc_2,p192pc_3,p192pc_4,p192pc_5,p192pc_6,p192pc_7,p192pc_8,p192pc_9,p192pc_10};
  const uint64_t values[]={0,1,2,3,31,32,UINT32_MAX,UINT64_C(1)<<32,(UINT64_C(1)<<32)+1,UINT64_C(1)<<63,UINT64_MAX};
  unsigned checks=0,failures=0;
  for(unsigned m=0;m<11;m++) for(unsigned i=0;i<11;i++) for(unsigned j=0;j<11;j++) {
    uint64_t a=values[i],b=values[j],p[]={a,b,UINT64_MAX,UINT64_MAX};
    uint64_t expected=a<b;
    if(m==1||m==9||m==10) expected=!expected;
    if(m==2||m==3||m==5) expected=(uint32_t)a!=0;
    if(m==6) expected=(uint32_t)(a<b?a:b)!=0;
    if(m==7) expected=a;
    uint64_t got=f[m](p);checks++;
    if(got!=expected||p[2]!=expected||p[3]!=expected||p[0]!=a||p[1]!=b) {
      if(failures++<8) fprintf(stderr,"mode=%u a=%llu b=%llu expected=%llu got=%llu c=%llu d=%llu\n",m,(unsigned long long)a,(unsigned long long)b,(unsigned long long)expected,(unsigned long long)got,(unsigned long long)p[2],(unsigned long long)p[3]);
    }
  }
  printf("phase192 predicate controls: checks=%u failures=%u\n",checks,failures);
  return failures!=0;
}
