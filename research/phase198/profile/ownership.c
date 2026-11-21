/* Observe external ABI edges from compiler-produced objects. Categories use the
 * complete high byte; unknown heap layout is deliberately not inferred. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
typedef struct P111State P111State;
static uint64_t word[2][256], fields[17][256], guard[3][2];
extern uint64_t __real_p111_rt_keep(P111State *,uint64_t);
extern uint64_t __real_p111_rt_sink(P111State *,uint64_t);
extern uint64_t __real_p118_rt_borrow_scalar_safe(P111State *,uint64_t,uint64_t,uint32_t);
extern uint64_t __real_p118_rt_borrow_fields(P111State *,uint64_t,uint64_t *,uint32_t,uint32_t);
uint64_t __wrap_p111_rt_keep(P111State *s,uint64_t t) {
  word[0][t>>56]++;return __real_p111_rt_keep(s,t);
}
uint64_t __wrap_p111_rt_sink(P111State *s,uint64_t t) {
  word[1][t>>56]++;return __real_p111_rt_sink(s,t);
}
uint64_t __wrap_p118_rt_borrow_scalar_safe(P111State *s,uint64_t a,uint64_t b,uint32_t count) {
  uint64_t result=__real_p118_rt_borrow_scalar_safe(s,a,b,count);
  if(count<=2)guard[count][result!=0]++;
  return result;
}
uint64_t __wrap_p118_rt_borrow_fields(P111State *s,uint64_t t,uint64_t *out,uint32_t cid,uint32_t count) {
  fields[count<16?count:16][t>>56]++;
  return __real_p118_rt_borrow_fields(s,t,out,cid,count);
}
__attribute__((destructor)) static void report(void) {
  for(unsigned k=0;k<2;k++)for(unsigned t=0;t<256;t++)if(word[k][t])
    fprintf(stderr,"P198 %s %u %"PRIu64"\n",k?"sink":"keep",t,word[k][t]);
  for(unsigned k=0;k<=16;k++)for(unsigned t=0;t<256;t++)if(fields[k][t])
    fprintf(stderr,"P198 fields %u %u %"PRIu64"\n",k,t,fields[k][t]);
  for(unsigned k=0;k<3;k++)for(unsigned i=0;i<2;i++)if(guard[k][i])
    fprintf(stderr,"P198 guard %u %u %"PRIu64"\n",k,i,guard[k][i]);
}
