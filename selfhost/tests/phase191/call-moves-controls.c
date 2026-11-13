#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

typedef uint64_t (*entry)(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
#define DECLARE(n) extern uint64_t p191cm_##n(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)
DECLARE(identity); DECLARE(swap); DECLARE(cycle3); DECLARE(cycle5);
DECLARE(disjoint); DECLARE(duplicates); DECLARE(narrow_identity); DECLARE(narrow_cycle);
DECLARE(all_narrow); DECLARE(stack_source); DECLARE(constants); DECLARE(stack_duplicates);

static uint64_t observed[10];
uint64_t p191cm_observe(uint64_t a,uint64_t b,uint64_t c,uint64_t d,uint64_t e,
                       uint64_t f,uint64_t g,uint64_t h,uint64_t i,uint64_t j) {
  const uint64_t values[10]={a,b,c,d,e,f,g,h,i,j};
  for(unsigned k=0;k<10;++k) observed[k]=values[k];
  return UINT64_C(0x5a1ec7);
}

int main(void) {
  const entry entries[12]={p191cm_identity,p191cm_swap,p191cm_cycle3,p191cm_cycle5,
    p191cm_disjoint,p191cm_duplicates,p191cm_narrow_identity,p191cm_narrow_cycle,
    p191cm_all_narrow,p191cm_stack_source,p191cm_constants,p191cm_stack_duplicates};
  const unsigned sources[12][10]={
    {0,1,2,3,4,5,0,1,4,5},{1,0,2,3,4,5,0,1,4,5},
    {1,2,0,3,4,5,0,1,2,5},{1,2,4,3,5,0,0,1,4,5},
    {1,0,2,3,5,4,0,1,4,5},{1,1,1,0,0,0,1,0,4,5},
    {0,0,1,2,4,5,0,1,4,5},{1,2,4,3,5,0,0,1,4,5},
    {5,4,3,2,1,0,0,1,4,5},{3,3,0,1,2,3,3,0,4,5},
    {6,0,6,2,1,6,0,6,4,5},{1,0,5,3,2,4,0,0,0,0}};
  const unsigned masks[12]={0,0,0,0,0,0,1,341,1023,0,546,0};
  const uint64_t edges[8]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),
    UINT64_C(0x123456789abcdef0),UINT32_MAX,UINT64_C(0xffffffff00000000),
    UINT64_C(0x0102030405060708)};
  for(unsigned v=0;v<64;++v) {
    uint64_t input[7];
    for(unsigned k=0;k<6;++k) input[k]=edges[(v+k)%8] ^ ((uint64_t)(v/8) << (k*7));
    input[6]=UINT64_C(0xfedcba9812345678);
    for(unsigned c=0;c<12;++c) {
      if(entries[c](input[0],input[1],input[2],input[3],input[4],input[5])!=UINT64_C(0x5a1ec7)) return 2;
      for(unsigned k=0;k<10;++k) {
        uint64_t want=input[sources[c][k]];
        if(masks[c] & (1u<<k)) want=(uint32_t)want;
        if(observed[k]!=want) {
          fprintf(stderr,"call-moves case=%u vector=%u arg=%u got=%" PRIu64 " want=%" PRIu64 "\n",c,v,k,observed[k],want);
          return 1;
        }
      }
    }
  }
  puts("call-moves-runtime=1");
  return 0;
}
