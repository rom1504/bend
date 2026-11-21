#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
typedef struct { void *mem,*allocator,*sp; uint32_t seq,rn,next; uint64_t regs[256]; } State;
_Static_assert(offsetof(State,next)==32 && offsetof(State,regs)==40,"ABI11102");
uint64_t p111_program[24];
static unsigned failures, checks, calls, reached;
static uint64_t want0,want1;
extern uint64_t p111_FID_source(State *s);
uint64_t p111_rt_jump(State *s,uint32_t fid,const uint64_t *args,uint32_t count){
  ++calls;if(fid!=7||count!=2)abort();
  memmove(s->regs,args,count*8);
  if(!(p111_program[11]&4))memset(s->regs+count,0,(256-count)*8);
  s->rn=0;s->next=fid;return 0;
}
uint64_t p111_FID_116_97_114_103_101_116_(State *s){
  ++reached;
  ++checks;failures+=(s->next!=UINT32_MAX||s->rn!=0||s->regs[0]!=want0||s->regs[1]!=want1);
  ++checks;failures+=(s->regs[255]!=((p111_program[11]&4)?UINT64_C(0xa5a5a5a5a5a5a5a5):0));
  return s->regs[0]^(s->regs[1]+UINT64_C(0x123456789abcdef0));
}
int main(void){
  for(unsigned cap=0;cap<2;++cap)for(unsigned i=0;i<128;++i){
    State s;memset(&s,0xa5,sizeof s);s.rn=99;s.next=UINT32_MAX;
    s.regs[0]=UINT64_C(0x8000000000000001)*i;s.regs[1]=~(UINT64_C(0x1234567812345678)*i);
    want0=s.regs[1];want1=s.regs[0];p111_program[11]=cap?4:0;
    uint64_t reply=p111_FID_source(&s);
    ++checks;failures+=(reply!=(want0^(want1+UINT64_C(0x123456789abcdef0))));
  }
  ++checks;failures+=(calls!=128||reached!=256);
  printf("phase198 public tail machine controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
