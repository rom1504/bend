/* Isolated late-template oracle: all state bytes and every stack/capture word
 * are compared. Overlapping captures verify the runtime's ordered pairs.
 * p111_rt_frame below is a fallback observer, never a benchmark provider. */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
typedef struct {
  uint64_t *mem,*alc,*sp;
  uint32_t seq,rn,next,reserved;
  uint64_t regs[256];
} State;
_Static_assert(offsetof(State,sp)==16 && sizeof(State)==2088,"ABI11102 state");
typedef uint64_t (*Frame)(State *,const uint64_t *);
extern uint64_t p185fr_zero(State *,const uint64_t *);
extern uint64_t p185fr_one(State *,const uint64_t *);
extern uint64_t p185fr_eight(State *,const uint64_t *);
extern uint64_t p185fr_last(State *,const uint64_t *);
extern uint64_t p185fr_unscoped(State *,const uint64_t *);
extern uint64_t p185fr_foreign(State *,const uint64_t *);
extern uint64_t p185fr_outside(State *,const uint64_t *);
static unsigned calls,seen_count;
static uint32_t seen_fid;
static State *seen_state;
static const uint64_t *seen_captures;
static const uint64_t sentinel=UINT64_C(0xface1234fedcba98);
uint64_t p111_rt_frame(State *s,uint32_t fid,const uint64_t *captures,uint32_t count) {
  ++calls;seen_state=s;seen_fid=fid;seen_captures=captures;seen_count=count;
  return sentinel;
}
static unsigned checks,failures;
#define CHECK(X) do { ++checks;if(!(X)){++failures;fprintf(stderr,"line %d: %s\n",__LINE__,#X);} }while(0)
int main(void) {
  Frame funcs[7]={p185fr_zero,p185fr_one,p185fr_eight,p185fr_last,p185fr_unscoped,p185fr_foreign,p185fr_outside};
  unsigned widths[7]={0,1,8,3,1,1,1};
  for(unsigned f=0;f<7;++f)for(unsigned mode=0;mode<4;++mode) {
    uint64_t stack[32],want_stack[32],capture[8],want_capture[8];
    for(unsigned i=0;i<32;++i)stack[i]=UINT64_C(0x8abcdef000000000)+i;
    for(unsigned i=0;i<8;++i)capture[i]=UINT64_C(0xffffffffffffffff)-(UINT64_C(0x12345678)*i);
    memcpy(want_stack,stack,sizeof(stack));memcpy(want_capture,capture,sizeof(capture));
    State s;memset(&s,0x97,sizeof(s));s.sp=stack+8;State want=s;
    const uint64_t *source=mode==0?capture:stack+(mode==1?8:mode==2?9:7);
    if(f<4) {
      for(unsigned i=0;i<widths[f];++i)
        want_stack[8+i]=mode==0?want_capture[i]:want_stack[(mode==1?8:mode==2?9:7)+i];
      want_stack[8+widths[f]]=37;want.sp=stack+8+widths[f]+1;
    }
    calls=0;seen_state=0;seen_fid=0;seen_captures=0;seen_count=0;
    CHECK(funcs[f](&s,source)==(f<4?0:sentinel));
    CHECK(memcmp(&s,&want,sizeof(s))==0);
    CHECK(memcmp(stack,want_stack,sizeof(stack))==0);
    CHECK(memcmp(capture,want_capture,sizeof(capture))==0);
    CHECK(calls==(f<4?0:1) && (!calls || (seen_state==&s && seen_fid==37 && seen_captures==source && seen_count==widths[f])));
  }
  printf("frame-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
