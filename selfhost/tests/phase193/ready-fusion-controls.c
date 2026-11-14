/* Independent public scheduler, capture timing, and full caller-state oracle.
 * Four separately linked roles use the same original verified source fixture.
 * No candidate's transformed IR is used to calculate expected values. */
#include "../../src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef P193RF_FUSION
#define P193RF_FUSION 0
#endif
#ifndef P193RF_TAIL
#define P193RF_TAIL 0
#endif
extern uint64_t p193rf_owner(P111State *);
extern uint64_t p193rf_cont(P111State *);
extern uint64_t p193rf_helper(P111State *);
extern uint64_t p193rf_tail(P111State *);

static int observe(void) {
  static const uint64_t values[]={0,1,11,UINT32_MAX,UINT64_C(0x100000000),
    UINT64_C(0x8000000000000000),UINT64_MAX,UINT64_C(0x123456789abcdef)};
  const uint64_t guard=UINT64_C(0x8d4a391bcf726e05);
  unsigned observations=0,failures=0;
  for(unsigned which=0;which<2;++which)for(unsigned xi=0;xi<8;++xi)for(unsigned yi=0;yi<8;++yi) {
    uint64_t stack[16],expected_stack[16];
    for(unsigned i=0;i<16;++i)stack[i]=expected_stack[i]=guard;
    stack[3]=expected_stack[3]=4; /* Valid preexisting caller continuation FID. */
    P111State state;memset(&state,0,sizeof(state));
    state.sp=stack+4;state.seq=1;state.rn=73;state.next=4;
    state.reserved=UINT32_C(0xabcddcba);
    for(unsigned i=0;i<P111_REG_CAP;++i)state.regs[i]=guard;
    uint64_t x=values[xi],y=values[yi];state.regs[0]=x;state.regs[1]=y;
    P111State expected;memcpy(&expected,&state,sizeof(state));
    expected.regs[0]=which?2*y+x:3*x+12+y;
    expected.regs[1]=0;expected.rn=1;expected.next=4;expected.sp=stack+3;
    /* Eliminated frame writes are intentionally absent in fused output.
     * No live caller stack word may change in any role. */
    if(!which&&!P193RF_FUSION){expected_stack[4]=x;expected_stack[5]=1;}
    uint64_t status=which?p193rf_tail(&state):p193rf_owner(&state);
    unsigned dispatches=1;
    while(status==0&&state.next!=4&&dispatches<8) {
      if(state.next==1)status=p193rf_cont(&state);
      else if(state.next==2)status=p193rf_helper(&state);
      else break;
      ++dispatches;
    }
    unsigned expected_dispatches=which?(P193RF_TAIL?1:2):
      (P193RF_FUSION?1:(P193RF_TAIL?2:3));
    int good=status==0&&dispatches==expected_dispatches&&
      memcmp(&state,&expected,sizeof(state))==0&&memcmp(stack,expected_stack,sizeof(stack))==0;
    if(!good){
      ++failures;
      if(failures<=8)fprintf(stderr,"which=%u x=%016" PRIx64 " y=%016" PRIx64
        " result=%016" PRIx64 " expected=%016" PRIx64 " next=%u rn=%u sp=%td dispatch=%u/%u state=%d stack=%d\n",
        which,x,y,state.regs[0],expected.regs[0],state.next,state.rn,state.sp-stack,
        dispatches,expected_dispatches,memcmp(&state,&expected,sizeof(state))==0,
        memcmp(stack,expected_stack,sizeof(stack))==0);
    }
    ++observations;
  }
  printf("phase193 ready fusion controls: observations=%u failures=%u\n",observations,failures);
  return failures?1:0;
}

/* Public runtime activation copied from the established Phase192 observer.
 * FIDs0..3 match the original fixture order; IO activation occupies4..5. */
static uint64_t activation_main(P111State *state) {
  uint64_t action=p111_rt_closure(state,5,NULL,0);
  return p111_rt_return(state,&action,1);
}
static uint64_t activation_action(P111State *state) {
  uint64_t continuation=p111_rt_reg_get(state,0);
  uint64_t unit=p111_rt_ctor(state,7,NULL,0);
  return p111_rt_apply(state,continuation,unit);
}
static const P111Segment segments[]={p193rf_owner,p193rf_cont,p193rf_helper,p193rf_tail,
  activation_main,activation_action};
static const uint8_t arities[]={2,2,2,2,0,1};
static const uint8_t flags[]={0,1,0,0,0,0};
static const uint8_t results[]={0,1,0,0,0,0};
static const char *const constructor_names[]={
  "SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit",
  "None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"};
static const uint8_t constructor_arities[]={0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0};
static const uint8_t constructor_hot[]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
static const P111Program activation_program={
  .abi_version=P111_ABI_VERSION,.descriptor_bytes=sizeof(P111Program),
  .segment_count=6,.constructor_count=18,.main_fid=4,.main_pure=0,
  .register_width=2,.result_width=1,.capabilities=P111_SEQUENTIAL,
  .segments=segments,.fid_arity=arities,.fid_flags=flags,.fid_results=results,
  .cid_arity=constructor_arities,.cid_hot=constructor_hot,.cid_names=constructor_names
};
int main(int argc,char **argv) {
  int status=p111_rt_main(argc,argv,&activation_program);
  return status?status:observe();
}
