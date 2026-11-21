#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <xmmintrin.h>
#include "../../../selfhost/src/runtime/qbe/runtime.h"
extern uint64_t p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
extern float p200_rt_f32_sqrt_keep(float);
extern uint32_t p200_test_registers(uint32_t,uint64_t *);
static uint32_t word(float f){uint32_t v;memcpy(&v,&f,4);return v;}
static float value(uint32_t v){float f;memcpy(&f,&v,4);return f;}
int main(void){
 const uint32_t edge[]={0,0x80000000,1,0x80000001,0x7fffff,0x807fffff,0x800000,0x80800000,0x3f800000,0xbf800000,0x40800000,0xc0800000,0x7f7fffff,0xff7fffff,0x7f800000,0xff800000,0x7fc00000,0xffc00000,0x7f800001,0xff800001,0x7fffffff,0xffffffff};
 uint64_t checks=0,register_checks=0;uint32_t random=200;
 P111State state={0};uint32_t saved=_mm_getcsr();
 for(unsigned mode=0;mode<16;mode++)for(unsigned j=0;j<4118;j++){
  random=random*1664525u+1013904223u;
  uint32_t bits=j<22?edge[j]:random;
  uint32_t csr=0x1f80u|((mode&3)<<13)|((mode&4)?0x8000:0)|((mode&8)?0x40:0)|(j&1?0x20:0);
  uint64_t input=UINT64_C(0xdeadbeef00000000)|bits;
  _mm_setcsr(csr);errno=1234;
  uint64_t expected=p111_rt_op(&state,36,&input,1);uint32_t expected_csr=_mm_getcsr();int expected_errno=errno;
  _mm_setcsr(csr);errno=1234;
  uint32_t got=word(p200_rt_f32_sqrt_keep(value(bits)));uint32_t got_csr=_mm_getcsr();int got_errno=errno;
  if(got!=expected || got_csr!=expected_csr || got_errno!=expected_errno){
   _mm_setcsr(saved);fprintf(stderr,"FAIL bits=%08x mode=%x result=%08x/%08x csr=%x/%x errno=%d/%d\n",bits,csr,got,(uint32_t)expected,got_csr,expected_csr,got_errno,expected_errno);return 1;
  }
  checks++;
  if(j<64){
   uint64_t out[45]={0};_mm_setcsr(csr);errno=1234;
   uint32_t r=p200_test_registers(bits,out);
   if(r!=expected || _mm_getcsr()!=expected_csr || errno!=expected_errno)return 2;
   for(unsigned k=0;k<13;k++)if(out[2+k]!=(k+1)*UINT64_C(0x0101010101010101))return 3;
   const uint32_t *x=(const uint32_t *)out;
   for(unsigned reg=2;reg<16;reg++)for(unsigned lane=0;lane<4;lane++)
    if(x[32+(reg-2)*4+lane]!=(uint32_t)(reg*UINT32_C(0x11111111)))return 4;
   register_checks++;
  }
 }
 _mm_setcsr(saved);
 printf("{\"complete\":true,\"runtimeDifferentials\":%llu,\"registerPreservationCases\":%llu,\"mxcsrModes\":16,\"errnoAndStickyFlags\":true}\n",(unsigned long long)checks,(unsigned long long)register_checks);
 return 0;
}
