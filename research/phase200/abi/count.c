#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
typedef struct State State;
static uint64_t calls[2][256];
extern uint64_t __real_p111_rt_keep(State*,uint64_t);
extern uint64_t __real_p111_rt_sink(State*,uint64_t);
uint64_t __wrap_p111_rt_keep(State *s,uint64_t t) {
  ++calls[0][t>>56];
  return __real_p111_rt_keep(s,t);
}
uint64_t __wrap_p111_rt_sink(State *s,uint64_t t) {
  ++calls[1][t>>56];
  return __real_p111_rt_sink(s,t);
}
__attribute__((destructor)) static void report(void) {
  for (unsigned k=0;k<2;k++) for (unsigned tag=0;tag<256;tag++)
    if (calls[k][tag]) fprintf(stderr,"P200 %s %u %"PRIu64"\n",k==0?"keep":"sink",tag,calls[k][tag]);
}
