/* Isolated scratch-forwarding oracle. The p111_rt_op stub intentionally writes
 * through its argument pointer to test the call barrier; it does not implement
 * opcode 36 or replace any production runtime. All state words remain canaries.
 */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint64_t exact(void *,uint64_t,uint64_t) __asm__("p113d_FID_112_49_56_53_115_97_");
extern uint64_t mutate(void *,uint64_t *,uint64_t,uint64_t) __asm__("p113d_FID_112_49_56_53_115_98_");
extern uint64_t overlap(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_115_99_");
extern uint64_t disjoint(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_115_100_");
extern uint64_t branch(void *,uint64_t,uint64_t) __asm__("p113d_FID_112_49_56_53_115_101_");
extern uint64_t callbarrier(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_115_102_");
extern uint64_t loop(void *,uint64_t,uint64_t) __asm__("p113d_FID_112_49_56_53_115_103_");
extern uint64_t alias(void *) __asm__("p111_FID_112_49_56_53_115_104_");

static const uint64_t magic=UINT64_C(0x8877665544332211);
static unsigned calls,bad_call;
static void *expected_state;
static uint64_t expected_argument;
uint64_t p111_rt_op(void *state,uint32_t op,uint64_t *args,uint32_t count) {
  ++calls;
  if (state!=expected_state || op!=36 || count!=1 || !args || args[0]!=expected_argument) {
    ++bad_call;
    return 0;
  }
  args[0]=magic;
  return 0;
}

typedef struct { uint64_t before,words[4],after; } Output;
static const uint64_t sentinel=UINT64_C(0x3edcba9876543210);
static int check(const char *name,uint64_t actual,uint64_t expected) {
  if (actual==expected) return 1;
  fprintf(stderr,"%s: got %016" PRIx64 ", expected %016" PRIx64 "\n",name,actual,expected);
  return 0;
}

int main(void) {
  const uint64_t words[6]={0,1,17,UINT64_C(0xffffffff),UINT64_C(0xfedcba9876543210),UINT64_MAX};
  uint64_t state[261],before[261];
  for (unsigned i=0;i<261;++i) state[i]=UINT64_C(0xabcdaaaa00000000)+i;
  memcpy(before,state,sizeof(state)); expected_state=state;
  for (unsigned i=0;i<6;++i) for (unsigned j=0;j<6;++j) {
    const uint64_t a=words[i],b=words[j];
    if (!check("exact",exact(state,a,b),a+b)) return 1;
    Output out={sentinel,{sentinel,sentinel,sentinel,sentinel},sentinel};
    if (!check("mutate status",mutate(state,out.words,a,b),0) ||
        !check("old value",out.words[0],a) || !check("new value",out.words[1],b) ||
        out.before!=sentinel || out.after!=sentinel || out.words[2]!=sentinel || out.words[3]!=sentinel) return 2;
    if (!check("branch",branch(state,a,b),a==0?b:a)) return 3;
    if (memcmp(state,before,sizeof(state)) || calls || bad_call) return 4;
  }
  for (unsigned i=0;i<6;++i) {
    const uint64_t a=words[i];
    if (!check("overlap",overlap(state,a),(a&UINT64_C(0xffffffff))|UINT64_C(0xaabbccdd00000000))) return 5;
    if (!check("disjoint",disjoint(state,a),a)) return 6;
    calls=0; bad_call=0; expected_argument=a;
    if (!check("call barrier",callbarrier(state,a),magic) || calls!=1 || bad_call) return 7;
    calls=0;
    if (!check("loop",loop(state,100001,a),a+100001)) return 8;
    if (memcmp(state,before,sizeof(state)) || calls || bad_call) return 9;
  }
  if (!check("offset alias",alias(state),before[1]) || memcmp(state,before,sizeof(state))) return 10;
  puts("phase185 scratch forwarding controls pass");
  return 0;
}
