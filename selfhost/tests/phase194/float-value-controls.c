#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <xmmintrin.h>

typedef uint64_t (*worker)(uint64_t *,uint64_t,uint64_t,uint64_t);
#define DECL(n) extern uint64_t p194fvc_old_##n(uint64_t*,uint64_t,uint64_t,uint64_t); \
                extern uint64_t p194fvc_new_##n(uint64_t*,uint64_t,uint64_t,uint64_t);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9)
#define OLD(n) p194fvc_old_##n
#define NEW(n) p194fvc_new_##n
static worker old[10]={OLD(0),OLD(1),OLD(2),OLD(3),OLD(4),OLD(5),OLD(6),OLD(7),OLD(8),OLD(9)};
static worker newer[10]={NEW(0),NEW(1),NEW(2),NEW(3),NEW(4),NEW(5),NEW(6),NEW(7),NEW(8),NEW(9)};
uint64_t p194fvc_barrier(uint64_t *state,uint64_t value){state[2]=value;state[3]++;return value;}
static float real(uint64_t x){uint32_t w=(uint32_t)x;float f;memcpy(&f,&w,4);return f;}
static uint64_t bits(float f){uint32_t w;memcpy(&w,&f,4);return w;}
static float mul(float a,float b){return _mm_cvtss_f32(_mm_mul_ss(_mm_set_ss(a),_mm_set_ss(b)));}
static float sub(float a,float b){return _mm_cvtss_f32(_mm_sub_ss(_mm_set_ss(a),_mm_set_ss(b)));}
static float add(float a,float b){return _mm_cvtss_f32(_mm_add_ss(_mm_set_ss(a),_mm_set_ss(b)));}
static int result_equal(uint64_t a,uint64_t b,int float_result){
  if(a==b)return 1;
  return float_result && a<=UINT32_MAX && b<=UINT32_MAX && isnan(real(a)) && isnan(real(b));
}
int main(void){
  static const uint64_t inputs[]={0,0x80000000u,0x3f800000u,0xbf800000u,0x3f000000u,
    0x40700000u,0x00800000u,1,0x7f7fffffu,0x7f800000u,0xff800000u,
    0x7fc01234u,0x7f800001u,0xffc05678u,0x4effffffu,0x4f800000u,
    UINT64_C(0xffffffff3f800000),UINT64_C(0x1234567880000000),UINT64_MAX};
  unsigned checks=0,failures=0,initial=_mm_getcsr();
  for(unsigned rounding=0;rounding<4;rounding++)
  for(unsigned mode=0;mode<10;mode++)
  for(unsigned i=0;i<sizeof(inputs)/sizeof(*inputs);i++)
  for(unsigned j=0;j<sizeof(inputs)/sizeof(*inputs);j++)
  for(unsigned condition=0;condition<2;condition++){
    unsigned csr=(initial|0x1f80u)&~(0x603fu);csr|=rounding<<13;
    uint64_t a=inputs[i],b=inputs[j],s0[4]={0},s1[4]={0};
    _mm_setcsr(csr);float product=mul(real(a),real(b));uint64_t expected,saved=0;
    if(mode==2){expected=b;saved=bits(product);}
    else if(mode==3)expected=(product>=0.0f && product<4294967296.0f)?(uint64_t)product:0;
    else if(mode==4)expected=(uint32_t)b;
    else if(mode==9)expected=bits(product);
    else if(mode==7)expected=bits(sub(sub(product,real(a)),real(a)));
    else if(mode==1){expected=bits(add(sub(product,real(a)),product));saved=bits(product);}
    else expected=bits(sub(product,real(a)));
    _mm_setcsr(csr);uint64_t r0=old[mode](s0,a,b,condition);unsigned flags0=_mm_getcsr();
    _mm_setcsr(csr);uint64_t r1=newer[mode](s1,a,b,condition);unsigned flags1=_mm_getcsr();
    int ok=r0==r1 && memcmp(s0,s1,sizeof(s0))==0 && flags0==flags1 && r1==s1[0]
      && result_equal(r1,expected,mode!=2 && mode!=3 && mode!=4)
      && result_equal(s1[1],saved,mode==1 || mode==2)
      && (mode==5 || mode==6 ? result_equal(s1[2],bits(product),1) : s1[2]==0)
      && s1[3]==(mode==5?1u:0u);
    checks++;if(!ok){if(failures<5)fprintf(stderr,"mode=%u input=%u,%u condition=%u rounding=%u old=%llx new=%llx expected=%llx flags=%x/%x\n",mode,i,j,condition,rounding,(unsigned long long)r0,(unsigned long long)r1,(unsigned long long)expected,flags0,flags1);failures++;}
  }
  _mm_setcsr(initial);printf("phase194 float value controls: checks=%u failures=%u\n",checks,failures);return failures?1:0;
}
