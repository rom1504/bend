/* Independent oracle retained from phase186 stacked-frame-controls.c.
 * No source planner or candidate-generated result supplies expected values. */
#include "../../src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint64_t (*worker)(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p192h_control_0(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p192h_control_1(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
static worker workers[]={p192h_control_0,p192h_control_1};

static uint64_t expected(unsigned mode,uint64_t n,uint64_t seed) {
  uint64_t value=seed+3*n;
  for(uint64_t k=1;k<=n;++k) {
    uint64_t captured=seed+3*(n-k);
    if(mode==0) value=(value+17*k)^captured;
    else value=(k&1)?(value^captured)+17*k:value^captured;
  }
  return value;
}

int main(void) {
  static const uint64_t counts[]={0,1,2,3,17,128,100001};
  static const uint64_t seeds[]={0,1,UINT32_MAX,UINT64_C(0x100000000),UINT64_C(0x8000000000000000),UINT64_MAX};
  const uint64_t guard=UINT64_C(0x8d4a391bcf726e05);
  unsigned observations=0,failures=0;
  for(unsigned mode=0;mode<2;++mode)
    for(unsigned n=0;n<sizeof(counts)/sizeof(*counts);++n) {
      size_t capacity=4*(size_t)counts[n]+16;
      uint64_t *stack=malloc(capacity*sizeof(*stack));
      if(!stack)return 2;
      for(unsigned s=0;s<sizeof(seeds)/sizeof(*seeds);++s) {
        for(size_t i=0;i<capacity;++i)stack[i]=guard;
        P111State state={0};
        state.sp=stack+4;state.seq=1;state.rn=73;state.next=97;state.reserved=UINT32_C(0xabcddcba);
        for(unsigned i=0;i<P111_REG_CAP;++i)state.regs[i]=guard;
        uint64_t actual=workers[mode](&state,counts[n],seeds[s],0,0,0);
        uint64_t want=expected(mode,counts[n],seeds[s]);
        int good=actual==want&&state.sp==stack+4&&state.rn==73&&state.next==97&&state.seq==1
          &&state.reserved==UINT32_C(0xabcddcba)&&state.e.mem==NULL&&state.e.alc==NULL;
        for(unsigned i=0;i<P111_REG_CAP;++i)good=good&&state.regs[i]==guard;
        for(unsigned i=0;i<4;++i)good=good&&stack[i]==guard&&stack[capacity-1-i]==guard;
        if(!good){
          ++failures;
          fprintf(stderr,"mode=%u n=%" PRIu64 " seed=%016" PRIx64 " got=%016" PRIx64 " expected=%016" PRIx64 " state-preserved=%d\n",
            mode,counts[n],seeds[s],actual,want,good);
        }
        ++observations;
      }
      free(stack);
    }
  printf("phase192 recursive worker controls: observations=%u failures=%u\n",observations,failures);
  return failures?1:0;
}
