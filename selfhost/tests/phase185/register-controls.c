/* Independent full-word oracles for all nine forced physical register homes.
 * Unsigned arithmetic defines wrapping exactly; signed comparisons use a
 * sign-bit flip, avoiding implementation-defined unsigned-to-signed casts.
 * No runtime helpers or test stubs are linked.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define PREFIX "p113d_FID_112_49_56_53_114_98_"
#define DECL(N,D) \
  extern uint64_t a##N(void *,uint64_t *,uint64_t,uint64_t) __asm__(PREFIX "97_" D "_"); \
  extern uint64_t c##N(void *,uint64_t *,uint64_t,uint64_t) __asm__(PREFIX "99_" D "_"); \
  extern uint64_t w##N(void *,uint64_t *,uint64_t,uint64_t) __asm__(PREFIX "119_" D "_")
DECL(0,"48"); DECL(1,"49"); DECL(2,"50"); DECL(3,"51"); DECL(4,"52");
DECL(5,"53"); DECL(6,"54"); DECL(7,"55"); DECL(8,"56");
typedef uint64_t (*Function)(void *,uint64_t *,uint64_t,uint64_t);
static Function functions[3][9]={
  {a0,a1,a2,a3,a4,a5,a6,a7,a8},
  {c0,c1,c2,c3,c4,c5,c6,c7,c8},
  {w0,w1,w2,w3,w4,w5,w6,w7,w8}
};
typedef struct { uint64_t before,words[10],after; } Output;
static const uint64_t sentinel=UINT64_C(0x9b7d5f311357ace0);

static void oracle(unsigned group,uint64_t a,uint64_t b,uint64_t result[8]) {
  if (group==0) {
    result[0]=a-b; result[1]=a-b; result[2]=0;
    result[3]=a>>(b&63); result[4]=a<<(b&63);
    result[5]=a^UINT64_C(0x80000000); result[6]=a&UINT64_C(0xffffffff); result[7]=a*b;
  } else if (group==1) {
    const uint64_t sa=a^UINT64_C(0x8000000000000000),sb=b^UINT64_C(0x8000000000000000);
    result[0]=a==b; result[1]=a!=b; result[2]=a<b; result[3]=a<=b;
    result[4]=a>b; result[5]=a>=b; result[6]=sa<sb; result[7]=sa>=sb;
  } else {
    const uint32_t x=(uint32_t)a,y=(uint32_t)b;
    result[0]=(uint32_t)(x+y); result[1]=(uint32_t)(x-y); result[2]=(uint32_t)(x*y);
    result[3]=x>>(y&31); result[4]=(uint32_t)(x<<(y&31));
    result[5]=x==y; result[6]=x<y; result[7]=(x^UINT32_C(0x80000000))<(y^UINT32_C(0x80000000));
  }
}

int main(void) {
  const uint64_t inputs[11]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),UINT64_C(0xffffffff),
    UINT64_C(0xfedcba9876543210),31,32,63,64,255};
  uint64_t state[261],before[261];
  for (unsigned i=0;i<261;++i) state[i]=UINT64_C(0xabcdaaaa00000000)+i;
  memcpy(before,state,sizeof(state));
  for (unsigned group=0;group<3;++group) for (unsigned home=0;home<9;++home)
    for (unsigned i=0;i<11;++i) for (unsigned j=0;j<11;++j) {
      uint64_t expected[8]; oracle(group,inputs[i],inputs[j],expected);
      Output out; out.before=sentinel; out.after=sentinel;
      for (unsigned k=0;k<10;++k) out.words[k]=sentinel;
      const uint64_t status=functions[group][home](state,out.words,inputs[i],inputs[j]);
      if (status || out.before!=sentinel || out.after!=sentinel || out.words[8]!=sentinel || out.words[9]!=sentinel ||
          memcmp(state,before,sizeof(state))) {
        fprintf(stderr,"group=%u home=%u input=%u,%u: status/canary failure\n",group,home,i,j);
        return 1;
      }
      for (unsigned k=0;k<8;++k) if (out.words[k]!=expected[k]) {
        fprintf(stderr,"group=%u home=%u input=%u,%u result=%u: got %016" PRIx64 ", expected %016" PRIx64 "\n",
          group,home,i,j,k,out.words[k],expected[k]);
        return 2;
      }
    }
  puts("phase185 register binary controls pass");
  return 0;
}
