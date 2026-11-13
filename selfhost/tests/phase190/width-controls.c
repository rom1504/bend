#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*Copy)(uint64_t *);
#define DECL(W) extern uint64_t p190w_##W##_0(uint64_t *),p190w_##W##_1(uint64_t *), \
  p190w_##W##_2(uint64_t *),p190w_##W##_3(uint64_t *)
DECL(32); DECL(64);
#define ROW(W) {p190w_##W##_0,p190w_##W##_1,p190w_##W##_2,p190w_##W##_3}
extern uint64_t p190w_const_0(uint64_t *),p190w_const_1(uint64_t *),p190w_const_2(uint64_t *),
  p190w_const_3(uint64_t *),p190w_const_4(uint64_t *),p190w_symbol(uint64_t *);
uint64_t p190w_global=UINT64_C(0xe1f2a3b4c5d60718);
int main(void) {
  const Copy copies[2][4]={ROW(32),ROW(64)};
  const Copy constants[]={p190w_const_0,p190w_const_1,p190w_const_2,p190w_const_3,p190w_const_4};
  const uint64_t lows[]={0,1,UINT64_C(0x7fffffff),UINT64_C(0x80000000),UINT32_MAX};
  const uint64_t highs[]={0,1,UINT64_C(0x80000000),UINT32_MAX};
  const uint64_t canary=UINT64_C(0xa73f419b8c02e56d);
  unsigned observations=0;
  for(unsigned h=0;h<4;++h)for(unsigned l=0;l<5;++l) {
    uint64_t word=(highs[h]<<32)|lows[l],state[]={word,canary,canary},before[3];
    memcpy(before,state,sizeof state);
    for(unsigned w=0;w<2;++w)for(unsigned mode=0;mode<4;++mode) {
      uint64_t got=copies[w][mode](state),want=w?word:lows[l];
      if(got!=want || memcmp(state,before,sizeof state)) {
        fprintf(stderr,"width=%u mode=%u input=%016" PRIx64 " got=%016" PRIx64
          " want=%016" PRIx64 "\n",w?64:32,mode,word,got,want);return 1;
      }
      ++observations;
    }
    for(unsigned c=0;c<5;++c) {
      if(constants[c](state)!=lows[c] || memcmp(state,before,sizeof state))return 2;
      ++observations;
    }
    if(p190w_symbol(state)!=(uint32_t)(uintptr_t)&p190w_global ||
       p190w_global!=UINT64_C(0xe1f2a3b4c5d60718) || memcmp(state,before,sizeof state))return 3;
    ++observations;
  }
  printf("phase190 width controls pass: %u\n",observations);
  return 0;
}
