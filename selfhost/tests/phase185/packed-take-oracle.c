/* Compile to assembly and combine with emitted p185pc_functions, as with the
 * existing private-function controls. Isolated slow stubs observe original
 * arguments and return a deliberately full-width field; no real heap is
 * modelled here. Real-runtime coverage uses packed-take-inputs.bend. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern uint64_t f0(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_97_");
extern uint64_t f1(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_98_");
extern uint64_t f2(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_99_");
extern uint64_t f3(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_100_");
extern uint64_t f4(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_101_");
extern uint64_t f5(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_102_");
extern uint64_t f6(void *,uint64_t) __asm__("p113d_FID_112_49_56_53_116_103_");
static unsigned calls;
static void *seen_state;
static uint64_t seen_word;
static unsigned seen_count;
static uint64_t *seen_out;
static const uint64_t salt=UINT64_C(0x9e3779b97f4a7c15);
static uint64_t slow(void *state,uint64_t word,uint64_t *out,unsigned count) {
  ++calls; seen_state=state; seen_word=word; seen_out=out; seen_count=count;
  *out=word^salt; return 1;
}
uint64_t p125_rt_take1(void *state,uint64_t word,uint64_t *out) { return slow(state,word,out,1); }
uint64_t p111_rt_take(void *state,uint64_t word,uint64_t *out,uint32_t count) { return slow(state,word,out,count); }
static unsigned checks,failures;
#define CHECK(X) do { ++checks; if(!(X)){ ++failures; fprintf(stderr,"line %d: %s\n",__LINE__,#X); } } while(0)
int main(void) {
  uint64_t (*fn[7])(void *,uint64_t)={f0,f1,f2,f3,f4,f5,f6};
  const uint64_t words[20]={0,1,UINT64_C(0xffffffff),
    UINT64_C(0x01002a0000000000),UINT64_C(0x01002a0000000001),UINT64_C(0x01002affffffffff),
    UINT64_C(0x81002a0000000000),UINT64_C(0x81002affffffffff),
    UINT64_C(0x0100290000000001),UINT64_C(0x01002b0000000001),
    UINT64_C(0x02002a0000000001),UINT64_C(0x82002a0000000001),
    UINT64_C(0x03002a0000000001),UINT64_C(0x00002a0000000001),
    UINT64_C(0x80002a0000000001),UINT64_C(0x7f002a0000000001),UINT64_MAX,
    UINT64_C(0x01002a0100000001),UINT64_C(0x01002a8000000000),UINT64_C(0x81002a8000000000)};
  /* Independent labels: expected PAK/CID42, including the ignored RFC bit. */
  const unsigned packed[20]={0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1};
  uint64_t state[261],before[261];
  for(unsigned i=0;i<261;++i) state[i]=UINT64_C(0xabcdaaaa00000000)+i;
  memcpy(before,state,sizeof(state));
  for(unsigned f=0;f<7;++f) for(unsigned w=0;w<20;++w) {
    unsigned fast=packed[w] && f!=3 && f!=4;
    uint64_t expected=f==6?1:fast?(words[w]&UINT64_C(0xffffffffff)):(words[w]^salt);
    calls=0; seen_state=0; seen_word=0; seen_out=0; seen_count=0;
    CHECK(fn[f](state,words[w])==expected);
    CHECK(calls==(fast?0:1));
    CHECK(memcmp(state,before,sizeof(state))==0 &&
      (!calls || (seen_state==state && seen_word==words[w] && seen_out!=0 && seen_count==1)));
  }
  printf("packed-take-oracle: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
