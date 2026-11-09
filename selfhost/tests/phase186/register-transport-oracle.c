/* Independent ABI11102 transfer observer. The two runtime names below are
 * isolated semantic stubs, not production runtime/benchmark providers. All
 * probes satisfy count/arity/result contracts. Capability-off paths must
 * preserve the required clear; overlapping sources exercise memmove semantics. */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
typedef struct {
  uint64_t *mem,*alc,*sp;
  uint32_t seq,rn,next,reserved;
  uint64_t regs[256];
} State;
_Static_assert(offsetof(State,regs)==40 && offsetof(State,rn)==28 &&
  offsetof(State,next)==32 && offsetof(State,sp)==16 && sizeof(State)==2088,"ABI11102 state");
uint64_t p111_program[24];
typedef uint64_t (*Transfer)(State *,const uint64_t *);
#define DECLARE(N) extern uint64_t N(State *,const uint64_t *)
DECLARE(p186rt_j0); DECLARE(p186rt_j1); DECLARE(p186rt_j2); DECLARE(p186rt_j8);
DECLARE(p186rt_r0); DECLARE(p186rt_r1); DECLARE(p186rt_r2); DECLARE(p186rt_r8);
DECLARE(p186rt_jforeign); DECLARE(p186rt_rforeign);
static unsigned calls,seen_count,seen_fid;
static State *seen_state;
static const uint64_t *seen_source;
static void reference(State *s,const uint64_t *values,unsigned count,int jump) {
  memmove(s->regs,values,count*sizeof(uint64_t));
  if(!(p111_program[11]&4)) memset(s->regs+count,0,(8-count)*sizeof(uint64_t));
  s->rn=jump?0:count;
  if(jump) s->next=37;
  else s->next=(uint32_t)*--s->sp;
}
uint64_t p111_rt_jump(State *s,uint32_t fid,const uint64_t *values,uint32_t count) {
  ++calls;seen_state=s;seen_source=values;seen_count=count;seen_fid=fid;
  reference(s,values,count,1);return 0;
}
uint64_t p111_rt_return(State *s,const uint64_t *values,uint32_t count) {
  ++calls;seen_state=s;seen_source=values;seen_count=count;seen_fid=0;
  reference(s,values,count,0);return 0;
}
static unsigned checks,failures;
#define CHECK(X) do {++checks;if(!(X)){++failures;fprintf(stderr,"line %d: %s\n",__LINE__,#X);}}while(0)
int main(void) {
  Transfer funcs[10]={p186rt_j0,p186rt_j1,p186rt_j2,p186rt_j8,
    p186rt_r0,p186rt_r1,p186rt_r2,p186rt_r8,p186rt_jforeign,p186rt_rforeign};
  unsigned widths[10]={0,1,2,8,0,1,2,8,2,2};
  uint64_t caps[8]={1,3,5,7,9,11,13,15};
  for(unsigned f=0;f<10;++f)for(unsigned c=0;c<8;++c)for(unsigned mode=0;mode<5;++mode) {
    uint64_t stack[16],before_stack[16],values[8],before_values[8],snapshot[8];
    for(unsigned i=0;i<16;++i)stack[i]=UINT64_C(0x8abcdef0fedcba00)+i;
    for(unsigned i=0;i<8;++i)values[i]=UINT64_MAX-UINT64_C(0x123456789)*i;
    memcpy(before_stack,stack,sizeof(stack));memcpy(before_values,values,sizeof(values));
    State s;memset(&s,0x97,sizeof(s));s.sp=stack+8;
    for(unsigned i=0;i<256;++i)s.regs[i]=UINT64_C(0xc0ffee0000000000)+i;
    State want=s;
    const uint64_t *source=mode==0?values:mode==1?s.regs:mode==2?s.regs+1:
      mode==3?(const uint64_t *)((const char *)&s+32):stack+7;
    memcpy(snapshot,source,widths[f]*sizeof(uint64_t));
    memset(p111_program,0,sizeof(p111_program));p111_program[0]=11102;p111_program[1]=192;
    p111_program[6]=8;p111_program[7]=8;p111_program[11]=caps[c];
    int jump=f<4||f==8;reference(&want,snapshot,widths[f],jump);
    calls=0;seen_state=0;seen_source=0;seen_count=0;seen_fid=0;
    unsigned fallback=f>=8||!(caps[c]&4);
    CHECK(funcs[f](&s,source)==0);
    CHECK(memcmp(&s,&want,sizeof(s))==0);
    CHECK(memcmp(stack,before_stack,sizeof(stack))==0);
    CHECK(memcmp(values,before_values,sizeof(values))==0);
    CHECK(calls==fallback && (!calls || (seen_state==&s && seen_source==source &&
      seen_count==widths[f] && seen_fid==(jump?37:0))));
  }
  printf("register-transport-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
