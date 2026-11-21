/* Only interposed edges from an already verified program object use this.
 * The shared runtime and its published guard retain their normal behavior. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
typedef struct P111State P111State;
extern uint64_t __real_p118_rt_borrow_scalar_safe(P111State *,uint64_t,uint64_t,uint32_t);
static uint64_t decisions[3][2];
uint64_t __wrap_p118_rt_borrow_scalar_safe(P111State *s,uint64_t first,uint64_t second,uint32_t n) {
    if(n!=1 && n!=2) return __real_p118_rt_borrow_scalar_safe(s,first,second,n);
#if MODE == 1
    return 1;
#elif MODE == 2
    return 0;
#else
    uint64_t accept=__real_p118_rt_borrow_scalar_safe(s,first,second,n);
#if MODE == 3
    ++decisions[n][!!accept];
#endif
    return accept;
#endif
}
#if MODE == 3
__attribute__((destructor)) static void report(void) {
    fprintf(stderr,"P198 guard %"PRIu64" %"PRIu64" %"PRIu64" %"PRIu64"\n",
        decisions[1][0],decisions[1][1],decisions[2][0],decisions[2][1]);
}
#endif
