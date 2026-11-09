/* Link with p185ct_oracle_module's generated machine code. This independent
 * cache oracle checks every mutated word and exact fallback arguments. It
 * deliberately stubs the slow helper: real-runtime source controls remain
 * a separate gate. No runtime replacement is used in benchmark products. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

uint64_t p111_program[24];
typedef struct { uint64_t *mem, *alc; } State;
typedef uint64_t (*Ctor)(State *, const uint64_t *);
extern uint64_t p185ct_width1(State *, const uint64_t *);
extern uint64_t p185ct_width2(State *, const uint64_t *);
extern uint64_t p185ct_width3(State *, const uint64_t *);
extern uint64_t p185ct_width4(State *, const uint64_t *);
extern uint64_t p185ct_hot(State *, const uint64_t *);
extern uint64_t p185ct_twice(State *, const uint64_t *);
static unsigned calls, got_count;
static uint32_t got_cid;
static State *got_state;
static const uint64_t *got_fields;
static const uint64_t sentinel = UINT64_C(0xdeadbeef12345678);
static uint64_t slow(State *s, uint32_t cid, const uint64_t *f, unsigned n) {
  ++calls; got_state = s; got_cid = cid; got_fields = f; got_count = n;
  return sentinel;
}
#define SLOW(N) uint64_t p125_rt_ctor##N(State *s, uint32_t c, const uint64_t *f) { return slow(s,c,f,N); }
SLOW(1) SLOW(2) SLOW(3) SLOW(4)
static unsigned failures, checks;
#define CHECK(X) do { ++checks; if (!(X)) { ++failures; fprintf(stderr,"line %d: %s\n",__LINE__,#X); } } while (0)

static void descriptor(uint64_t caps) {
  memset(p111_program,0,sizeof(p111_program));
  p111_program[0]=11102; p111_program[1]=192; p111_program[11]=caps;
  calls=0; got_state=0; got_fields=0; got_cid=0; got_count=0;
}
static void fallback(Ctor fn, unsigned n, uint32_t cid, State *s, uint64_t *fields) {
  calls=0;
  CHECK(fn(s,fields)==sentinel);
  CHECK(calls==1 && got_state==s && got_fields==fields && got_cid==cid && got_count==n);
}
int main(void) {
  Ctor funcs[4]={p185ct_width1,p185ct_width2,p185ct_width3,p185ct_width4};
  uint64_t fields[4]={UINT64_C(0xffffffffffffffff),UINT64_C(0x8000012300000042),UINT64_C(0x03000000deadbeef),UINT64_C(0x00000100abcdef01)};
  const uint64_t caps[4]={9,11,13,15};
  for(unsigned n=1;n<=4;++n) {
    unsigned cls=n==1?0:n==2?1:2;
    for(unsigned c=0;c<4;++c) {
      uint64_t heap[64], alc[96], want_heap[64], want_alc[96];
      for(unsigned i=0;i<64;++i) heap[i]=UINT64_C(0x7070707000000000)+i;
      for(unsigned i=0;i<96;++i) alc[i]=UINT64_C(0x6060606000000000)+i;
      heap[16]=32; alc[cls]=16; alc[32+cls]=32;
      memcpy(want_heap,heap,sizeof(heap)); memcpy(want_alc,alc,sizeof(alc));
      for(unsigned i=0;i<n;++i) want_heap[16+i]=fields[i];
      want_alc[cls]=32; want_alc[32+cls]=32-(1u<<cls);
      State s={heap,alc}; descriptor(caps[c]);
      uint32_t cid=65536-n;
      CHECK(funcs[n-1](&s,fields)==((UINT64_C(2)<<56)|((uint64_t)cid<<40)|16));
      CHECK(calls==0);
      CHECK(memcmp(heap,want_heap,sizeof(heap))==0);
      CHECK(memcmp(alc,want_alc,sizeof(alc))==0);
      CHECK(s.mem==heap && s.alc==alc);

      /* Empty bins fall back without touching heap, length, or scratch. */
      alc[cls]=0; memcpy(want_heap,heap,sizeof(heap)); memcpy(want_alc,alc,sizeof(alc));
      fallback(funcs[n-1],n,cid,&s,fields);
      CHECK(memcmp(heap,want_heap,sizeof(heap))==0 && memcmp(alc,want_alc,sizeof(alc))==0);
    }
    /* Failed descriptor guards must precede even the state-pointer load. */
    for(unsigned c=0;c<9;++c) {
      descriptor(c); if((c&9)==9) continue;
      fallback(funcs[n-1],n,65536-n,0,fields);
    }
    descriptor(15); p111_program[0]=11101; fallback(funcs[n-1],n,65536-n,0,fields);
    descriptor(15); p111_program[1]=184; fallback(funcs[n-1],n,65536-n,0,fields);
  }
  descriptor(15); fallback(p185ct_hot,2,41,0,fields);
  uint64_t heap[64]={0}, alc[96]={0}; State s={heap,alc};
  heap[16]=24; heap[24]=0; alc[1]=16; alc[33]=4; descriptor(15);
  CHECK(p185ct_twice(&s,fields)==((UINT64_C(2)<<56)|(UINT64_C(42)<<40)|24));
  CHECK(calls==0 && alc[1]==0 && alc[33]==0);
  CHECK(heap[16]==fields[0] && heap[17]==fields[1] && heap[24]==fields[0] && heap[25]==fields[1]);
  printf("cold-ctor-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
