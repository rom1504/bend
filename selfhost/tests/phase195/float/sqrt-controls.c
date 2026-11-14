#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <xmmintrin.h>
#include "../../../src/runtime/qbe/runtime.h"
extern uint64_t p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
__attribute__((noinline)) uint64_t p195sc_runtime(P111State *s,uint32_t op,const uint64_t *a,uint32_t n){return p111_rt_op(s,op,a,n);}
typedef uint64_t (*worker)(P111State *,uint64_t *,uint64_t);
#define DECL(n) extern uint64_t p195sc_old_##n(P111State*,uint64_t*,uint64_t); extern uint64_t p195sc_new_##n(P111State*,uint64_t*,uint64_t);
DECL(0) DECL(1) DECL(2) DECL(3)
static worker old[4]={p195sc_old_0,p195sc_old_1,p195sc_old_2,p195sc_old_3};
static worker newer[4]={p195sc_new_0,p195sc_new_1,p195sc_new_2,p195sc_new_3};
int main(void){
  static const uint32_t edge[32]={
    0,0x80000000,0x3f800000,0x40800000,0x41100000,0x41800000,0x3e800000,0x3d800000,
    1,0x007fffff,0x00800000,0x7f7fffff,0x7f800000,0xff800000,0xbf800000,0xc0800000,
    0x7fc00000,0x7fc12345,0xffc12345,0x7f800001,0xff800001,0x7fffffff,0xffffffff,0x80000001,
    0x80800000,0xff7fffff,0x3f7fffff,0x3f800001,0x40000000,0x40400000,0x80000100,0x00800001};
  static const uint32_t exact[8]={0,0x80000000,0x3f800000,0x40000000,0x40400000,0x40800000,0x3f000000,0x3e800000};
  unsigned original=_mm_getcsr(),checks=0,failures=0;
  uint32_t random=0x1955a731;
  for(unsigned i=0;i<128;i++){
    random=random*1664525u+1013904223u;
    uint32_t bits=i<32?edge[i]:random;
    uint64_t raw=(UINT64_C(0xa5c31957)<<32)|bits;
    for(unsigned rounding=0;rounding<4;rounding++)for(unsigned denormal=0;denormal<4;denormal++)for(unsigned mode=0;mode<4;mode++){
      unsigned control=0x1f80u|(rounding<<13)|((denormal&1)<<6)|((denormal>>1)<<15);
      /* Include preexisting sticky flags: neither path may silently clear them. */
      control|=(i&1)?0x20:0;
      uint64_t a=raw,b=raw,salt=UINT64_C(0xf123456789abcdef);
      P111State sa={0},sb={0},expected={0};
      _mm_setcsr(control);errno=E2BIG;
      uint64_t ra=old[mode](&sa,&a,salt);unsigned fa=_mm_getcsr();int ea=errno;
      _mm_setcsr(control);errno=E2BIG;
      uint64_t rb=newer[mode](&sb,&b,salt);unsigned fb=_mm_getcsr();int eb=errno;
      int ok=ra==rb&&fa==fb&&ea==eb&&a==raw&&b==raw&&memcmp(&sa,&sb,sizeof(sa))==0;
      if(mode!=2)ok=ok&&(ra>>32)==0&&memcmp(&sa,&expected,sizeof(sa))==0;
      else {expected.regs[0]=sa.regs[0];expected.regs[1]=sa.regs[1];ok=ok&&sa.regs[0]==sa.regs[1]&&(sa.regs[0]>>32)==0&&ra==sa.regs[0]*2+salt&&memcmp(&sa,&expected,sizeof(sa))==0;}
      /* Independent exact arithmetic / errno facts; no host sqrt oracle. */
      if(i<8){uint64_t wanted=exact[i];if(mode==2)wanted=wanted*2+salt;ok=ok&&ra==wanted&&ea==E2BIG&&fa==control;}
      if(i==14||i==15||i==13)ok=ok&&ea==EDOM&&(fa&1)!=0;
      if(i==12)ok=ok&&ea==E2BIG;
      checks++;
      if(!ok){if(failures<5)fprintf(stderr,"i=%u bits=%08x mode=%u mxcsr=%x old=%llx/%x/%d new=%llx/%x/%d\n",i,bits,mode,control,(unsigned long long)ra,fa,ea,(unsigned long long)rb,fb,eb);failures++;}
    }
  }
  _mm_setcsr(original);
  printf("phase195 sqrt controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
