/* Independent unsigned recurrence and complete stack/state oracle.
 * Scope-off and scope-on workers share one independently verified H fixture.
 * The first continuation pushes FID2 with its result capture before reentry. */
#include "../../src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef uint64_t (*Worker)(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p192hcf_plain(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p192hcf_scoped(P111State *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t);

/* This models the documented original control flow, not candidate-generated IR.
 * First frames hold seed+3*j and FID1. Their resumed first continuations replace
 * those words with the returned result and FID2, then calculate the recurrence.
 * The entire popped storage remains observable in want_stack after completion. */
static uint64_t oracle(uint64_t n,uint64_t seed,uint64_t *want_stack) {
  const uint64_t mask=UINT64_C(0x5a5a5a5aa5a5a5a5);
  for(uint64_t j=0;j<n;++j) {
    want_stack[4+2*j]=seed+3*j;
    want_stack[5+2*j]=1;
  }
  uint64_t value=seed+3*n;
  for(uint64_t k=1;k<=n;++k) {
    uint64_t j=n-k,captured=seed+3*j;
    want_stack[4+2*j]=value;
    want_stack[5+2*j]=2;
    value=(value*33)^(captured^mask);
  }
  return value;
}

int main(void) {
  static const uint64_t counts[]={0,1,2,3,17,128,100001};
  static const uint64_t seeds[]={0,1,UINT32_MAX,UINT64_C(0x100000000),UINT64_C(0x8000000000000000),UINT64_MAX};
  const uint64_t guard=UINT64_C(0x8d4a391bcf726e05);
  Worker workers[]={p192hcf_plain,p192hcf_scoped};
  unsigned observations=0,failures=0;
  for(unsigned role=0;role<2;++role)for(unsigned ni=0;ni<sizeof(counts)/sizeof(*counts);++ni) {
    size_t capacity=2*(size_t)counts[ni]+16;
    uint64_t *stack=malloc(capacity*sizeof(*stack));
    uint64_t *want_stack=malloc(capacity*sizeof(*want_stack));
    if(!stack||!want_stack){free(stack);free(want_stack);return 2;}
    for(unsigned si=0;si<sizeof(seeds)/sizeof(*seeds);++si) {
      for(size_t i=0;i<capacity;++i)stack[i]=want_stack[i]=guard;
      P111State state;memset(&state,0,sizeof(state));
      state.sp=stack+4;state.seq=1;state.rn=73;state.next=97;state.reserved=UINT32_C(0xabcddcba);
      for(unsigned i=0;i<P111_REG_CAP;++i)state.regs[i]=guard;
      P111State want_state;memcpy(&want_state,&state,sizeof(state));
      uint64_t want=oracle(counts[ni],seeds[si],want_stack);
      uint64_t actual=workers[role](&state,counts[ni],seeds[si],0,0,0);
      int good=actual==want&&memcmp(&state,&want_state,sizeof(state))==0
        &&memcmp(stack,want_stack,capacity*sizeof(*stack))==0;
      if(!good) {
        ++failures;
        if(failures<=8)fprintf(stderr,"role=%u n=%" PRIu64 " seed=%016" PRIx64
          " got=%016" PRIx64 " expected=%016" PRIx64 " state=%d stack=%d\n",
          role,counts[ni],seeds[si],actual,want,
          memcmp(&state,&want_state,sizeof(state))==0,memcmp(stack,want_stack,capacity*sizeof(*stack))==0);
      }
      ++observations;
    }
    free(stack);free(want_stack);
  }
  printf("phase192 scoped reentry controls: observations=%u failures=%u\n",observations,failures);
  return failures?1:0;
}
