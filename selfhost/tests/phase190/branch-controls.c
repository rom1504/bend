/* Independent finite oracle. Signed order flips the sign bit, avoiding
 * implementation-defined out-of-range unsigned-to-signed conversions. */
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

typedef uint64_t (*Branch)(uint64_t *);
#define DECL(W,O) extern uint64_t p190b_##W##_##O(uint64_t *)
#define DECL_WIDTH(W) DECL(W,eq); DECL(W,ne); DECL(W,ult); DECL(W,ule); \
  DECL(W,ugt); DECL(W,uge); DECL(W,slt); DECL(W,sle); DECL(W,sgt); DECL(W,sge)
DECL_WIDTH(32); DECL_WIDTH(64);
#define ROW(W) {p190b_##W##_eq,p190b_##W##_ne,p190b_##W##_ult,p190b_##W##_ule, \
  p190b_##W##_ugt,p190b_##W##_uge,p190b_##W##_slt,p190b_##W##_sle,p190b_##W##_sgt,p190b_##W##_sge}
extern uint64_t p190b_alias(uint64_t *),p190b_same(uint64_t *);
extern uint64_t p190b_reuse(uint64_t *),p190b_nested(uint64_t *);
extern uint64_t p190b_again(uint64_t *,uint64_t,uint64_t);

static int predicate(unsigned op,uint64_t a,uint64_t b,unsigned narrow) {
  uint64_t sign=narrow ? UINT64_C(0x80000000) : UINT64_C(0x8000000000000000);
  if(narrow){a=(uint32_t)a;b=(uint32_t)b;}
  switch(op) {
    case 0:return a==b; case 1:return a!=b;
    case 2:return a<b; case 3:return a<=b; case 4:return a>b; case 5:return a>=b;
    case 6:return (a^sign)<(b^sign); case 7:return (a^sign)<=(b^sign);
    case 8:return (a^sign)>(b^sign); default:return (a^sign)>=(b^sign);
  }
}

int main(void) {
  const Branch functions[2][10]={ROW(32),ROW(64)};
  const uint64_t words[]={0,1,2,UINT64_C(0x7fffffff),UINT64_C(0x80000000),
    UINT64_C(0xffffffff),UINT64_C(0x100000000),UINT64_C(0x7fffffffffffffff),
    UINT64_C(0x8000000000000000),UINT64_C(0xffffffff00000000),UINT64_MAX};
  const uint64_t canary=UINT64_C(0x69428ac3ba017cde);
  unsigned observations=0;
  for(unsigned i=0;i<sizeof(words)/sizeof(*words);++i)
    for(unsigned j=0;j<sizeof(words)/sizeof(*words);++j) {
      uint64_t state[4]={words[i],words[j],canary,canary},before[4];
      memcpy(before,state,sizeof state);
      for(unsigned width=0;width<2;++width)for(unsigned op=0;op<10;++op) {
        uint64_t want=predicate(op,words[i],words[j],width==0)?11:29;
        uint64_t got=functions[width][op](state);
        if(got!=want || memcmp(state,before,sizeof state)) {
          fprintf(stderr,"branch width=%u op=%u a=%016" PRIx64 " b=%016" PRIx64
            " got=%" PRIu64 " want=%" PRIu64 "\n",width?64:32,op,words[i],words[j],got,want);
          return 1;
        }
        ++observations;
      }
      uint64_t want=words[i]<words[j]?11:29;
      if(p190b_alias(state)!=want || p190b_same(state)!=11 || memcmp(state,before,sizeof state))return 2;
      observations+=2;
      want=words[i]<words[j]?(predicate(8,words[j],words[i],0)?11:29):47;
      if(p190b_nested(state)!=want || memcmp(state,before,sizeof state))return 3;
      ++observations;
      before[2]=(before[2]&UINT64_C(0xffffffff00000000))+(words[i]<words[j]);
      if(p190b_reuse(state)!=47 || memcmp(state,before,sizeof state))return 4;
      ++observations;
    }
  for(unsigned n=0;n<258;++n) {
    uint64_t state[4]={canary,canary,canary,canary},before[4];
    memcpy(before,state,sizeof state);
    if(p190b_again(state,n,19)!=19+(uint64_t)n*(n+1)/2 || memcmp(state,before,sizeof state))return 5;
    ++observations;
  }
  printf("phase190 branch controls pass: %u\n",observations);
  return 0;
}
