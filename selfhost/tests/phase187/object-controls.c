/* Independent integer, byte, relocation and frozen F32 observations.
 * No floating host arithmetic or compiler implementation is an oracle.
 * Phase112 labels: bde39b2e416263ae82219c601ea409afc0e14be42ddb877a4d8aa4c545ce9753. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern uint64_t p187_widths(uint64_t *,uint64_t,uint64_t);
extern uint64_t p187_compare(uint64_t *,uint64_t,uint64_t);
extern uint64_t p187_shift64(uint64_t,uint64_t),p187_shift32(uint64_t,uint64_t);
extern uint64_t p187_branch(uint64_t),p187_memory(uint64_t *),p187_call(uint64_t),p187_data(void),p187_convert(uint64_t);
extern uint64_t p187_words[2],*p187_external_pointer;
extern uint64_t (*p187_function_pointer)(uint64_t);
extern unsigned char p187_bytes[16];
uint64_t p187_external[2]={UINT64_C(0x8765432101234567),UINT64_C(0x1122334455667788)};
static unsigned helper_calls;
uint64_t p187_helper(uint64_t x){++helper_calls;return x^UINT64_C(0xfedcba9876543210);}
extern uint64_t p187_fp26(uint64_t,uint64_t);
extern uint64_t p187_fp27(uint64_t,uint64_t);
extern uint64_t p187_fp28(uint64_t,uint64_t);
extern uint64_t p187_fp29(uint64_t,uint64_t);
extern uint64_t p187_fp30(uint64_t,uint64_t);
extern uint64_t p187_fp31(uint64_t,uint64_t);
extern uint64_t p187_fp32(uint64_t,uint64_t);
extern uint64_t p187_fp33(uint64_t,uint64_t);
extern uint64_t p187_fp34(uint64_t,uint64_t);
extern uint64_t p187_fp35(uint64_t,uint64_t);
typedef uint64_t (*Binary)(uint64_t,uint64_t);
static Binary fp[10]={p187_fp26,p187_fp27,p187_fp28,p187_fp29,p187_fp30,p187_fp31,p187_fp32,p187_fp33,p187_fp34,p187_fp35};
typedef struct {unsigned op;uint64_t a,b,expected;unsigned nan;const char *name;} Case;
static const Case cases[93]={
  {26, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x000000003fc00000), 0, "add"},
  {27, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "sub-cancel"},
  {27, UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), 0, "sub-negative-zero"},
  {28, UINT64_C(0x0000000040000000), UINT64_C(0x000000003f000000), UINT64_C(0x000000003f800000), 0, "mul"},
  {28, UINT64_C(0x000000007f7fffff), UINT64_C(0x0000000040000000), UINT64_C(0x000000007f800000), 0, "mul-overflow"},
  {28, UINT64_C(0x0000000000800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000400000), 0, "mul-normal-to-subnormal"},
  {28, UINT64_C(0x0000000000000001), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000002), 0, "mul-min-subnormal"},
  {29, UINT64_C(0x0000000000000001), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000000), 0, "div-subnormal-tie-zero"},
  {29, UINT64_C(0x0000000000000003), UINT64_C(0x0000000040000000), UINT64_C(0x0000000000000002), 0, "div-subnormal-tie-even"},
  {29, UINT64_C(0x0000000080000000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000080000000), 0, "div-negative-zero"},
  {29, UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), UINT64_C(0x000000007f800000), 0, "div-positive-infinity"},
  {29, UINT64_C(0x00000000bf800000), UINT64_C(0x0000000000000000), UINT64_C(0x00000000ff800000), 0, "div-negative-infinity"},
  {29, UINT64_C(0x000000003f800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000080000000), 0, "div-negative-zero-from-infinity"},
  {26, UINT64_C(0x000000003f800000), UINT64_C(0x0000000033800000), UINT64_C(0x000000003f800000), 0, "add-tie-even-down"},
  {26, UINT64_C(0x000000003f800001), UINT64_C(0x0000000033800000), UINT64_C(0x000000003f800002), 0, "add-tie-even-up"},
  {26, UINT64_C(0xdeadbeef3f800000), UINT64_C(0xffffffff3f000000), UINT64_C(0x000000003fc00000), 0, "upper-words-discarded"},
  {29, UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), UINT64_C(0x000000007fc00000), 1, "zero-div-zero"},
  {26, UINT64_C(0x000000007f800000), UINT64_C(0x00000000ff800000), UINT64_C(0x000000007fc00000), 1, "infinity-cancel"},
  {28, UINT64_C(0x0000000000000000), UINT64_C(0x000000007f800000), UINT64_C(0x000000007fc00000), 1, "zero-times-infinity"},
  {26, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc00000), 1, "quiet-nan-add"},
  {28, UINT64_C(0x000000007f801234), UINT64_C(0x0000000040000000), UINT64_C(0x000000007fc00000), 1, "signaling-nan-mul"},
  {30, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-30"},
  {31, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-31"},
  {32, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-32"},
  {33, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-33"},
  {34, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000000), 0, "compare-signed-zeros-34"},
  {35, UINT64_C(0x0000000000000000), UINT64_C(0x0000000080000000), UINT64_C(0x0000000000000001), 0, "compare-signed-zeros-35"},
  {30, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-30"},
  {31, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-31"},
  {32, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-32"},
  {33, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000000), 0, "compare-greater-33"},
  {34, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-34"},
  {35, UINT64_C(0x000000003f800000), UINT64_C(0x000000003f000000), UINT64_C(0x0000000000000001), 0, "compare-greater-35"},
  {30, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-30"},
  {31, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-31"},
  {32, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-32"},
  {33, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-negative-positive-33"},
  {34, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-34"},
  {35, UINT64_C(0x00000000bf800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-negative-positive-35"},
  {30, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-30"},
  {31, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-left-nan-31"},
  {32, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-32"},
  {33, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-33"},
  {34, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-34"},
  {35, UINT64_C(0x000000007fc01234), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-left-nan-35"},
  {30, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-30"},
  {31, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000001), 0, "compare-right-nan-31"},
  {32, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-32"},
  {33, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-33"},
  {34, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-34"},
  {35, UINT64_C(0x000000003f800000), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-right-nan-35"},
  {30, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-30"},
  {31, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000001), 0, "compare-two-nans-31"},
  {32, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-32"},
  {33, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-33"},
  {34, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-34"},
  {35, UINT64_C(0x000000007fc01234), UINT64_C(0x000000007fc01234), UINT64_C(0x0000000000000000), 0, "compare-two-nans-35"},
  {30, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-30"},
  {31, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-31"},
  {32, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-32"},
  {33, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-signed-infinities-33"},
  {34, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-34"},
  {35, UINT64_C(0x00000000ff800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-signed-infinities-35"},
  {30, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-30"},
  {31, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-31"},
  {32, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-32"},
  {33, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-positive-subnormal-33"},
  {34, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-34"},
  {35, UINT64_C(0x0000000000000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-positive-subnormal-35"},
  {30, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-30"},
  {31, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-31"},
  {32, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-32"},
  {33, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000001), 0, "compare-negative-subnormal-33"},
  {34, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-34"},
  {35, UINT64_C(0x0000000080000001), UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000), 0, "compare-negative-subnormal-35"},
  {30, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-30"},
  {31, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-31"},
  {32, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-32"},
  {33, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-33"},
  {34, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000000), 0, "compare-positive-infinities-34"},
  {35, UINT64_C(0x000000007f800000), UINT64_C(0x000000007f800000), UINT64_C(0x0000000000000001), 0, "compare-positive-infinities-35"},
  {30, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-30"},
  {31, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-31"},
  {32, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-32"},
  {33, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-33"},
  {34, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000000), 0, "compare-negative-infinities-34"},
  {35, UINT64_C(0x00000000ff800000), UINT64_C(0x00000000ff800000), UINT64_C(0x0000000000000001), 0, "compare-negative-infinities-35"},
  {30, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-30"},
  {31, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-31"},
  {32, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-32"},
  {33, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-33"},
  {34, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000000), 0, "compare-upper-word-34"},
  {35, UINT64_C(0xdeadbeef3f800000), UINT64_C(0x000000003f800000), UINT64_C(0x0000000000000001), 0, "compare-upper-word-35"},
};
typedef struct {uint64_t a,expected;} Unary;
static const Unary unary[7]={
  {UINT64_C(0x0000000000000000), UINT64_C(0x0000000000000000)},
  {UINT64_C(0x0000000000000001), UINT64_C(0x000000003f800000)},
  {UINT64_C(0x0000000001000001), UINT64_C(0x000000004b800000)},
  {UINT64_C(0x0000000001000003), UINT64_C(0x000000004b800002)},
  {UINT64_C(0x00000000ffffffff), UINT64_C(0x000000004f800000)},
  {UINT64_C(0x0000000080000000), UINT64_C(0x000000004f000000)},
  {UINT64_C(0xffffffff00000001), UINT64_C(0x000000003f800000)},
};
static unsigned checks,failures;
#define CHECK(X) do{++checks;if(!(X)){++failures;fprintf(stderr,"failed line %u\n",(unsigned)__LINE__);}}while(0)
static int words(const uint64_t *got,const uint64_t *want,unsigned count){return memcmp(got,want,count*8)==0;}
static int fp_match(uint64_t got,const Case *c){return c->nan ? !(got>>32) && (got&UINT64_C(0x7f800000))==UINT64_C(0x7f800000) && (got&UINT64_C(0x007fffff)) : got==c->expected;}
int main(void){
  const uint64_t canary=UINT64_C(0xa5b6c7d8e9fa0123),sign=UINT64_C(1)<<63;
  const uint64_t grid[]={0,1,31,32,63,64,65,UINT64_C(0xffffffff),UINT64_C(0x100000000),UINT64_C(0x8000000000000000),UINT64_MAX,UINT64_C(0xdeadbeef01234567)};
  for(unsigned i=0;i<12;i++)for(unsigned j=0;j<12;j++){
    uint64_t a=grid[i],b=grid[j],out[8],want[6]={a+b,a-b,a*b,(uint32_t)((uint32_t)a+(uint32_t)b),a^b,a&b};
    for(unsigned k=0;k<8;k++)out[k]=canary;
    CHECK(p187_widths(out+1,a,b)==0&&words(out+1,want,6)&&out[0]==canary&&out[7]==canary);
    uint32_t aa=(uint32_t)a,bb=(uint32_t)b;
    uint64_t cmp[6]={a<b,(a^sign)<(b^sign),a==b,aa<bb,(aa^UINT32_C(0x80000000))<(bb^UINT32_C(0x80000000)),aa==bb};
    for(unsigned k=0;k<8;k++)out[k]=canary;
    CHECK(p187_compare(out+1,a,b)==0&&words(out+1,cmp,6)&&out[0]==canary&&out[7]==canary);
    CHECK(p187_shift64(a,b)==(a<<(b&63)));
    CHECK(p187_shift32(a,b)==((uint32_t)a>>(b&31)));
  }
  for(uint64_t i=0;i<=32;i++)CHECK(p187_branch(i)==i*(i+1)/2);
  uint64_t memory[40],want_memory[40];for(unsigned i=0;i<40;i++)memory[i]=canary;
  memcpy(want_memory,memory,sizeof(memory));want_memory[7]=UINT64_C(0xfedcba9876543210);
  want_memory[24]=(canary&UINT64_C(0xffffffff00000000))|UINT64_C(0xaabbccdd);want_memory[10]=UINT64_C(0xaabbccdd);
  CHECK(p187_memory(memory+8)==UINT64_C(0xaabbccdd)&&words(memory,want_memory,40));
  helper_calls=0;for(unsigned i=0;i<12;i++)CHECK(p187_call(grid[i])==(grid[i]^UINT64_C(0xfedcba9876543210))+grid[i]&&helper_calls==i+1);
  CHECK(p187_data()==sign&&p187_words[0]==UINT64_C(0x100000001)&&p187_words[1]==sign);
  CHECK(p187_external_pointer==p187_external+1&&*p187_external_pointer==UINT64_C(0x1122334455667788));
  CHECK(p187_function_pointer(1)==(UINT64_C(1)^UINT64_C(0xfedcba9876543210))+1&&helper_calls==13);
  const unsigned char expected_bytes[16]={17,34,221,204,187,170,0,0,0,0,0,0,0,0,0,0};
  CHECK(memcmp(p187_bytes,expected_bytes,16)==0);
  const uint64_t high[]={0,UINT64_C(0xffffffff00000000),UINT64_C(0xdeadbeef00000000)};
  for(unsigned i=0;i<93;i++)for(unsigned h=0;h<3;h++)CHECK(fp_match(fp[cases[i].op-26]((uint32_t)cases[i].a|high[h],(uint32_t)cases[i].b|high[2-h]),cases+i));
  for(unsigned i=0;i<7;i++)for(unsigned h=0;h<3;h++)CHECK(p187_convert((uint32_t)unary[i].a|high[h])==unary[i].expected);
  printf("phase187 object controls: checks=%u failures=%u\n",checks,failures);
  return failures||checks!=926;
}
