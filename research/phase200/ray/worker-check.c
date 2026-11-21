#include <stdint.h>
#include <stdio.h>
#include <errno.h>
#include <xmmintrin.h>
#include "../../../selfhost/src/runtime/qbe/runtime.h"
extern uint64_t worker(P111State *,uint64_t,uint64_t,uint64_t) __asm__(TEST_WORKER);
extern uint64_t p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
static uint64_t op(P111State *s,unsigned id,uint64_t a,uint64_t b){uint64_t v[]={a,b};return p111_rt_op(s,id,v,id==36?1:2);}
static uint64_t oracle(P111State *s,uint64_t x,uint64_t y,uint64_t z){
 uint64_t a=op(s,26,x,y),b=op(s,28,y,z),c=op(s,27,x,z),d=op(s,36,a,0);
 uint64_t e=op(s,28,d,b),f=op(s,26,e,c),g=op(s,28,a,z);
 return op(s,26,f,g);
}
int main(void){
 P111State s={0};uint32_t seed=200,saved=_mm_getcsr();unsigned count=0,negative=0;
 const uint32_t edges[]={0,0x80000000,0x3f800000,0xbf800000,0x40800000,0xc0800000,1,0x80000001};
 for(unsigned mode=0;mode<4;++mode)for(unsigned k=0;k<4096;++k){
  uint32_t v[3];for(unsigned j=0;j<3;++j){seed=seed*1664525u+1013904223u;v[j]=k<512?edges[(k>>(j*3))&7]:(seed&0x807fffff)|(((seed>>24&127)+64)<<23);}
  uint32_t csr=0x1f80|(mode<<13);_mm_setcsr(csr);errno=1234;
  uint64_t expected=oracle(&s,v[0],v[1],v[2]);int ee=errno;uint32_t ef=_mm_getcsr();
  _mm_setcsr(csr);errno=1234;
  uint64_t got=worker(&s,v[0],v[1],v[2]);int ge=errno;uint32_t gf=_mm_getcsr();
  if(got!=expected||ge!=ee||gf!=ef){_mm_setcsr(saved);fprintf(stderr,"FAIL k=%u mode=%u bits=%08x,%08x,%08x got=%llx expected=%llx errno=%d/%d csr=%x/%x\n",k,mode,v[0],v[1],v[2],(unsigned long long)got,(unsigned long long)expected,ge,ee,gf,ef);return 1;}
  count++;negative+=ee!=1234;
 }
 _mm_setcsr(saved);printf("{\"complete\":true,\"cases\":%u,\"negativeSqrtCases\":%u,\"roundingModes\":4}\n",count,negative);return 0;
}
