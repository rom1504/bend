#include <stdint.h>
#include <stdio.h>
#define DECL(n) extern uint64_t p192pf_##n(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9) DECL(10)
DECL(11) DECL(12) DECL(13) DECL(14) DECL(15) DECL(16)
uint64_t p192pf_barrier(uint64_t *p) { return p[0] ^ p[1]; }
static unsigned tag(uint64_t x) { return (x>>40)&65535; }
int main(void) {
 uint64_t (*f[])(uint64_t *)={p192pf_0,p192pf_1,p192pf_2,p192pf_3,p192pf_4,p192pf_5,p192pf_6,p192pf_7,p192pf_8,p192pf_9,p192pf_10,p192pf_11,p192pf_12,p192pf_13,p192pf_14,p192pf_15,p192pf_16};
 uint64_t vals[]={0,1,2,UINT32_MAX,UINT64_C(1)<<32,(UINT64_C(1)<<32)+1,UINT64_C(25)<<40,(UINT64_C(25)<<40)+1,(UINT64_C(24)<<40)+1,(UINT64_C(65538)<<40)+1,(UINT64_C(65538)<<40)+123,UINT64_C(1)<<63,UINT64_MAX};
 unsigned checks=0,failures=0;
 for(unsigned m=0;m<17;m++) for(unsigned i=0;i<13;i++) for(unsigned j=0;j<13;j++) {
  uint64_t a=vals[i],b=vals[j],p[]={a,b};
  uint64_t expected=tag(a)==25 ? ((m==1||m==2||m==5) && tag(b)!=25?2:1):3;
  if(m==6) expected=(uint32_t)a==1?(a==1?1:2):3;
  if(m==7) expected=(a==1||((a>>40)&8388607)==65538)?1:3;
  if(m==8) expected=2;
  if(m==11) expected=a==UINT64_C(4294967297)?2:3;
  if(m==12) expected=a<b&&a==1?1:3;
  if(m==13) expected=a<b||a==1?3:2;
  if(m==14) expected=(uint32_t)a?(a==1?1:2):3;
  if(m==15) expected=(a<b&&a==1)?3:(a<b?1:2);
  if(m==16) expected=(a<b||a==1)?(a<b?1:2):3;
  uint64_t written=(m==4||m==5)&&tag(a)==25?b:a;
  uint64_t got=f[m](p);checks++;
  if(got!=expected||p[0]!=written||p[1]!=b) {
   if(failures++<8) fprintf(stderr,"mode=%u a=%llu b=%llu expected=%llu got=%llu memory=%llu\n",m,(unsigned long long)a,(unsigned long long)b,(unsigned long long)expected,(unsigned long long)got,(unsigned long long)p[0]);
  }
 }
 printf("phase192 path controls: checks=%u failures=%u\n",checks,failures);
 return failures!=0;
}
