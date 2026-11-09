/* Independent cache/field oracle for the ABI11102 late template. Slow helpers
 * below are isolated routing stubs. Invalid word/arity cases never enter the
 * production runtime. A sparse PROT_NONE corpus makes accidental address reads
 * fail without committing a runtime-sized heap. */
#define _GNU_SOURCE
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#define BASE UINT64_C(51413504)
#define LOC_MASK UINT64_C(0xffffffffff)
uint64_t p111_program[24];
typedef struct { uint64_t *mem,*alc,*sp; uint32_t seq,rn,next,reserved; uint64_t regs[256]; } State;
_Static_assert(sizeof(State)==2088 && offsetof(State,alc)==8,"ABI11102 state");
typedef uint64_t (*Take)(State *,uint64_t,uint64_t *);
extern uint64_t p186ut_one(State *,uint64_t,uint64_t *);
extern uint64_t p186ut_two(State *,uint64_t,uint64_t *);
extern uint64_t p186ut_three(State *,uint64_t,uint64_t *);
extern uint64_t p186ut_four(State *,uint64_t,uint64_t *);
extern uint64_t p186ut_foreign(State *,uint64_t,uint64_t *);
static unsigned calls,seen_count,checks,failures;
static State *seen_state;
static uint64_t seen_word,*seen_out;
static const uint64_t sentinel=UINT64_C(0xfedcba9876543210);
static uint64_t slow(State *s,uint64_t word,uint64_t *out,unsigned count) {
  ++calls;seen_state=s;seen_word=word;seen_out=out;seen_count=count;return sentinel;
}
#define SLOW(N) uint64_t p125_rt_take##N(State *s,uint64_t word,uint64_t *out){return slow(s,word,out,N);}
SLOW(1) SLOW(2) SLOW(3) SLOW(4)
uint64_t p111_rt_take(State *s,uint64_t word,uint64_t *out,uint32_t n){return slow(s,word,out,n);}
#define CHECK(X) do {++checks;if(!(X)){++failures;fprintf(stderr,"line %d: %s\n",__LINE__,#X);}}while(0)
static void test(Take fn,uint64_t *mem,unsigned n,unsigned stat,unsigned cid,uint64_t length,unsigned route,unsigned alias) {
  unsigned cls=n==1?0:n==2?1:2, size=1u<<cls;
  uint64_t heap_start=BASE+((stat+127u)&~127u), loc=heap_start+16;
  uint8_t arities[8]={201,202,203,204,205,206,207,208};
  if(route==7)loc=heap_start-1;
  uint64_t word=(UINT64_C(2)<<56)|((uint64_t)cid<<40)|loc;
  if(route==0){} else if(route==1)word|=UINT64_C(1)<<63;
  else if(route==2)word=(word&~(UINT64_C(255)<<56))|(UINT64_C(1)<<56);
  else if(route==3)word=(word&~(UINT64_C(255)<<56))|(UINT64_C(3)<<56);
  else if(route==4){cid=0;word=(word&~(UINT64_C(65535)<<40));}
  else if(route==5){cid=2;word=(word&~(UINT64_C(65535)<<40))|(UINT64_C(2)<<40);}
  else if(route==6){cid=8;word=(word&~(UINT64_C(65535)<<40))|(UINT64_C(8)<<40);}
  if(cid<8)arities[cid]=(route==8?n+1:n);
  memset(p111_program,0,sizeof(p111_program));p111_program[0]=11102;p111_program[1]=192;
  p111_program[3]=8;p111_program[8]=stat;p111_program[11]=15;p111_program[16]=(uintptr_t)arities;
  uint64_t alc[96],want_alc[96],external[8],want_external[8],want_heap[16];
  for(unsigned i=0;i<96;++i)alc[i]=UINT64_C(0xabababab00000000)+i;
  alc[cls]=heap_start+48;alc[32+cls]=length;
  for(unsigned i=0;i<8;++i)external[i]=UINT64_C(0xcafe000000000000)+i;
  uint64_t *window=mem+loc-4;
  for(unsigned i=0;i<16;++i)window[i]=UINT64_MAX-UINT64_C(0x100000001)*i;
  memcpy(want_heap,window,sizeof(want_heap));memcpy(want_alc,alc,sizeof(alc));memcpy(want_external,external,sizeof(external));
  State s;memset(&s,0x97,sizeof(s));s.mem=mem;s.alc=alc;State want=s;
  int delta=alias==1?0:alias==2?1:-1;
  uint64_t *out=alias?mem+loc+delta:external;
  unsigned fast=route==0 && fn!=p186ut_foreign && length+size<32768;
  if(fast) {
    for(unsigned i=0;i<n;++i) {
      if(alias)want_heap[4+delta+i]=want_heap[4+i];
      else want_external[i]=want_heap[4+i];
    }
    want_heap[4]=alc[cls];want_alc[cls]=loc;want_alc[32+cls]=length+size;
  }
  calls=0;seen_state=0;seen_word=0;seen_out=0;seen_count=0;
  CHECK(fn(&s,word,out)==(fast?n:sentinel));
  CHECK(calls==!fast && (!calls || (seen_state==&s && seen_word==word && seen_out==out && seen_count==n)));
  CHECK(memcmp(&s,&want,sizeof(s))==0);
  CHECK(memcmp(alc,want_alc,sizeof(alc))==0);
  CHECK(memcmp(window,want_heap,sizeof(want_heap))==0);
  CHECK(memcmp(external,want_external,sizeof(external))==0);
}
int main(void) {
  size_t bytes=(BASE+1024)*sizeof(uint64_t);
  uint64_t *mem=mmap(NULL,bytes,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(mem==MAP_FAILED || mprotect(mem+BASE-512,3*4096,PROT_READ|PROT_WRITE)){perror("sparse corpus");return 2;}
  Take funcs[4]={p186ut_one,p186ut_two,p186ut_three,p186ut_four};
  unsigned stats[5]={0,1,127,128,129},cids[2]={3,7};
  for(unsigned n=1;n<=4;++n) {
    unsigned size=n<=2?n:4;uint64_t lengths[4]={0,32768-2*size,32768-size,32768};
    for(unsigned st=0;st<5;++st)for(unsigned c=0;c<2;++c)for(unsigned l=0;l<4;++l)for(unsigned alias=0;alias<4;++alias)
      test(funcs[n-1],mem,n,stats[st],cids[c],lengths[l],0,alias);
    for(unsigned route=1;route<=8;++route)test(funcs[n-1],mem,n,129,7,0,route,0);
  }
  test(p186ut_foreign,mem,2,0,7,0,0,0);
  munmap(mem,bytes);
  printf("unique-take-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
