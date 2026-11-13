#include <stdint.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*function)(void *,uint32_t *,uint64_t,uint64_t,uint32_t *);
#define DECL(K,M) extern uint64_t p192sm_##K##_##M(void *,uint32_t *,uint64_t,uint64_t,uint32_t *);
#define DECL_KIND(K) DECL(K,0) DECL(K,1) DECL(K,2) DECL(K,3)
DECL_KIND(0) DECL_KIND(1) DECL_KIND(2) DECL_KIND(3) DECL_KIND(4)
#define ROW(K) {p192sm_##K##_0,p192sm_##K##_1,p192sm_##K##_2,p192sm_##K##_3}
static function functions[5][4]={ROW(0),ROW(1),ROW(2),ROW(3),ROW(4)};
static unsigned checks,failures;
static void check(int good) { ++checks; if (!good) ++failures; }
int main(void) {
  const uint32_t words[]={0,1,UINT32_C(0x7fffffff),UINT32_C(0x80000000),UINT32_MAX};
  for (unsigned kind=0;kind<5;++kind)
    for (unsigned mode=0;mode<4;++mode)
      for (unsigned alias=0;alias<2;++alias)
        for (unsigned input=0;input<5;++input)
          for (unsigned index=0;index<4;++index) {
            uint32_t source[8],target[8],want_source[8],want_target[8];
            for(unsigned i=0;i<8;++i) {
              source[i]=UINT32_C(0x82e4ba11)*(i+1)+words[input];
              target[i]=UINT32_C(0xf1234567)^(i*UINT32_C(0x13579bdf));
            }
            memcpy(want_source,source,sizeof source);
            memcpy(want_target,target,sizeof target);
            uint64_t accumulator=UINT64_C(0xfeedface00000000)|words[(input+2)%5];
            uint64_t actual_index=kind==4?UINT64_C(0x40000000)+index:index;
            uint32_t result=kind==2?(uint32_t)accumulator:source[index]+(uint32_t)accumulator;
            if(kind==1 && !alias) want_target[index]=result;
            else want_source[index]=result;
            uint64_t actual=functions[kind][mode](0,source,actual_index,accumulator,alias?source:target);
            check(actual==result);
            check(!memcmp(source,want_source,sizeof source));
            check(!memcmp(target,want_target,sizeof target));
          }
  printf("phase192 shared machine controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
