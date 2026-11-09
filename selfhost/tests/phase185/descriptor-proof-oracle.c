/* Paired descriptor proof plus unchanged raw-IDs fallback. Only paired
 * fixtures satisfying the bound final descriptor are invoked as paired. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
uint64_t p111_program[24];
uint8_t p111_cid_arity[1]={2},p111_cid_hot[1]={0};
typedef struct { uint64_t *mem,*alc; } State;
extern uint64_t p185bd_paired(State *,const uint64_t *);
extern uint64_t p185bd_raw(State *,const uint64_t *);
static unsigned calls;
static State *seen_state;
static const uint64_t *seen_fields;
static uint32_t seen_cid;
static const uint64_t sentinel=UINT64_C(0xdeadbeef12345678);
uint64_t p125_rt_ctor2(State *s,uint32_t cid,const uint64_t *fields) {
  ++calls;seen_state=s;seen_fields=fields;seen_cid=cid;return sentinel;
}
static unsigned checks,failures;
#define CHECK(X) do { ++checks;if(!(X)){++failures;fprintf(stderr,"line %d: %s\n",__LINE__,#X);} }while(0)
int main(void) {
  uint64_t fields[2]={UINT64_MAX,UINT64_C(0x80000123456789ab)};
  p111_program[3]=1;
  p111_program[16]=(uintptr_t)p111_cid_arity;
  p111_program[17]=(uintptr_t)p111_cid_hot;
  for(unsigned f=0;f<2;++f)for(unsigned empty=0;empty<2;++empty) {
    uint64_t heap[32],alc[96],want_heap[32],want_alc[96];
    for(unsigned i=0;i<32;++i)heap[i]=UINT64_C(0x1212121200000000)+i;
    for(unsigned i=0;i<96;++i)alc[i]=UINT64_C(0x3434343400000000)+i;
    heap[8]=16;alc[1]=empty?0:8;alc[33]=8;
    memcpy(want_heap,heap,sizeof(heap));memcpy(want_alc,alc,sizeof(alc));
    if(!empty){want_heap[8]=fields[0];want_heap[9]=fields[1];want_alc[1]=16;want_alc[33]=6;}
    State s={heap,alc};p111_program[0]=11102;p111_program[1]=192;p111_program[11]=15;calls=0;
    CHECK((f?p185bd_raw(&s,fields):p185bd_paired(&s,fields))==(empty?sentinel:((UINT64_C(2)<<56)|8)));
    CHECK(calls==empty && (!calls || (seen_state==&s && seen_fields==fields && seen_cid==0)));
    CHECK(memcmp(heap,want_heap,sizeof(heap))==0 && memcmp(alc,want_alc,sizeof(alc))==0);
  }
  const uint64_t caps[5]={0,1,3,5,7};
  for(unsigned i=0;i<5;++i){p111_program[11]=caps[i];calls=0;CHECK(p185bd_raw(0,fields)==sentinel && calls==1 && seen_state==0);}
  p111_program[11]=15;p111_program[0]=11101;calls=0;CHECK(p185bd_raw(0,fields)==sentinel && calls==1);
  p111_program[0]=11102;p111_program[1]=184;calls=0;CHECK(p185bd_raw(0,fields)==sentinel && calls==1);
  printf("descriptor-proof-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
