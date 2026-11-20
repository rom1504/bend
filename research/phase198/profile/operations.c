/* Link-time observers for the external generated-object/runtime ABI only. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
typedef struct P111State P111State;
static uint64_t ops[256], divisions[2][258], constructors[5], takes[5][4];
struct site_count { uintptr_t address; uint32_t op; uint64_t count; };
static struct site_count sites[4096];
static uint64_t site_overflow;
static void note_site(uintptr_t pc, uint32_t op) {
  unsigned i=(unsigned)((pc*UINT64_C(11400714819323198485))>>52);
  for(unsigned n=0;n<4096;++n) {
    struct site_count *s=&sites[(i+n)&4095];
    if(!s->address || (s->address==pc && s->op==op)) {
      s->address=pc;s->op=op;++s->count;return;
    }
  }
  ++site_overflow;
}
extern uint64_t __real_p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
uint64_t __wrap_p111_rt_op(P111State *s,uint32_t op,const uint64_t *args,uint32_t count) {
  if(op<256) {
    ++ops[op];
    note_site((uintptr_t)__builtin_return_address(0),op);
  }
  if((op==18 || op==19) && count==2 && args){
    uint32_t d=(uint32_t)args[1];
    ++divisions[op-18][d<=255 ? d : ((d & (d-1))==0 ? 256 : 257)];
  }
  return __real_p111_rt_op(s,op,args,count);
}
#define WRAP(N) \
extern uint64_t __real_p125_rt_ctor##N(P111State *,uint32_t,const uint64_t *); \
extern uint64_t __real_p125_rt_take##N(P111State *,uint64_t,uint64_t *); \
uint64_t __wrap_p125_rt_ctor##N(P111State *s,uint32_t cid,const uint64_t *f) { \
  ++constructors[N];return __real_p125_rt_ctor##N(s,cid,f); \
} \
uint64_t __wrap_p125_rt_take##N(P111State *s,uint64_t t,uint64_t *dst) { \
  unsigned h=t>>56; ++takes[N][h==2?0:(h==130?1:(h==1?2:3))]; \
  return __real_p125_rt_take##N(s,t,dst); \
}
WRAP(1)
WRAP(2)
WRAP(3)
WRAP(4)
__attribute__((destructor)) static void report(void) {
  if(site_overflow) fprintf(stderr,"P198 lost %"PRIu64"\n",site_overflow);
  for(unsigned i=0;i<4096;i++) if(sites[i].address)
    fprintf(stderr,"P198 site %u %"PRIxPTR" %"PRIu64"\n",sites[i].op,sites[i].address,sites[i].count);
  for(unsigned i=0;i<256;i++) if(ops[i]) fprintf(stderr,"P198 op %u %"PRIu64"\n",i,ops[i]);
  for(unsigned i=0;i<2;i++) for(unsigned j=0;j<258;j++) if(divisions[i][j])
    fprintf(stderr,"P198 divisor %u %u %"PRIu64"\n",i+18,j,divisions[i][j]);
  for(unsigned n=1;n<5;n++) {
    if(constructors[n]) fprintf(stderr,"P198 ctor %u %"PRIu64"\n",n,constructors[n]);
    for(unsigned h=0;h<4;h++) if(takes[n][h])fprintf(stderr,"P198 take %u %u %"PRIu64"\n",n,h,takes[n][h]);
  }
}
