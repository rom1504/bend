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

static int observe_workers(void) {
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

/* Activate the unchanged runtime through its public program entry. The IO
 * main returns a no-capture CPS action; that action calls its continuation
 * with Unit, so the ordinary IO dispatcher completes without printing.
 * Slots 0..2 preserve the fixture's FIDs and original segment metadata.
 * Those segments must never dispatch: both machine workers run privately. */
static uint64_t unexpected_dispatch(P111State *state) {
  (void)state;
  fputs("unexpected reentry observer segment dispatch\n",stderr);
  abort();
}
static uint64_t activation_main(P111State *state) {
  uint64_t action=p111_rt_closure(state,4,NULL,0);
  return p111_rt_return(state,&action,1);
}
static uint64_t activation_action(P111State *state) {
  uint64_t continuation=p111_rt_reg_get(state,0);
  uint64_t unit=p111_rt_ctor(state,7,NULL,0);
  return p111_rt_apply(state,continuation,unit);
}
static const P111Segment segments[]={
  unexpected_dispatch,unexpected_dispatch,unexpected_dispatch,
  activation_main,activation_action
};
static const uint8_t arities[]={2,2,2,0,1};
static const uint8_t flags[]={0,1,1,0,0};
static const uint8_t results[]={0,1,1,0,0};
static const char *const constructor_names[]={
  "SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit",
  "None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"
};
static const uint8_t constructor_arities[]={0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0};
static const uint8_t constructor_hot[]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
static const P111Program activation_program={
  .abi_version=P111_ABI_VERSION,.descriptor_bytes=sizeof(P111Program),
  .segment_count=5,.constructor_count=18,.main_fid=3,.main_pure=0,
  .register_width=2,.result_width=1,.capabilities=P111_SEQUENTIAL,
  .segments=segments,.fid_arity=arities,.fid_flags=flags,.fid_results=results,
  .cid_arity=constructor_arities,.cid_hot=constructor_hot,.cid_names=constructor_names
};
int main(int argc,char **argv) {
  int status=p111_rt_main(argc,argv,&activation_program);
  if(status)return status;
  return observe_workers();
}
