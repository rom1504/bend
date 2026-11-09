/* Reuse all635 frozen scalar/operand observations through the XMM emitter.
 * The wrapper additionally destroys every candidate XMM home at an unknown
 * call. New labels below are exact elementary IEEE results, except NaN class. */
#define main p186_x_prior_main
#define p111_rt_op p186_x_prior_rt_op
#include "float-values-controls.c"
#undef p111_rt_op
#undef main

uint64_t p111_rt_op(void *state,uint32_t op,const uint64_t *args,uint32_t count) {
  uint64_t result=p186_x_prior_rt_op(state,op,args,count);
  __asm__ volatile("pxor %%xmm2,%%xmm2\n\tpxor %%xmm3,%%xmm3\n\tpxor %%xmm4,%%xmm4\n\t"
    "pxor %%xmm5,%%xmm5\n\tpxor %%xmm6,%%xmm6\n\tpxor %%xmm7,%%xmm7\n\t"
    "pxor %%xmm8,%%xmm8\n\tpxor %%xmm9,%%xmm9\n\tpxor %%xmm10,%%xmm10\n\t"
    "pxor %%xmm11,%%xmm11\n\tpxor %%xmm12,%%xmm12\n\tpxor %%xmm13,%%xmm13\n\t"
    "pxor %%xmm14,%%xmm14\n\tpxor %%xmm15,%%xmm15"
    : : : "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11","xmm12","xmm13","xmm14","xmm15","memory");
  return result;
}
#define X "p113d_FID_112_49_56_54_120_"
extern uint64_t x_rhs(void *,uint64_t) __asm__(X "97_");
extern uint64_t x_copy(void *,uint64_t) __asm__(X "98_");
extern uint64_t x_raw(void *,uint64_t *,uint64_t,uint64_t) __asm__(X "99_");
extern uint64_t x_pressure(void *,uint64_t) __asm__(X "100_");
extern uint64_t x_call(void *,uint64_t *,uint64_t,uint64_t) __asm__(X "101_");
extern uint64_t x_branch(void *,uint64_t,uint64_t) __asm__(X "102_");
extern uint64_t x_divide(void *,uint64_t) __asm__(X "103_");

extern uint64_t x_cmp0(void *,uint64_t,uint64_t) __asm__(X "104_");
extern uint64_t x_cmp1(void *,uint64_t,uint64_t) __asm__(X "105_");
extern uint64_t x_cmp2(void *,uint64_t,uint64_t) __asm__(X "106_");
extern uint64_t x_cmp3(void *,uint64_t,uint64_t) __asm__(X "107_");
extern uint64_t x_cmp4(void *,uint64_t,uint64_t) __asm__(X "108_");
extern uint64_t x_cmp5(void *,uint64_t,uint64_t) __asm__(X "109_");
typedef uint64_t (*XCompare)(void *,uint64_t,uint64_t);
static XCompare x_comparisons[]={x_cmp0,x_cmp1,x_cmp2,x_cmp3,x_cmp4,x_cmp5};

typedef struct {uint32_t input,subtract,divide;unsigned nan;} XCase;
static const XCase xcases[]={
  {0x00000000,0x40000000,0x7f800000,0},
  {0x80000000,0x40000000,0xff800000,0},
  {0x3f800000,0x3f800000,0x40000000,0},
  {0x40000000,0x00000000,0x3f800000,0},
  {0xbf800000,0x40400000,0xc0000000,0},
  {0x00000001,0x40000000,0x7f800000,0},
  {0x7f800000,0xff800000,0x00000000,0},
  {0xff800000,0x7f800000,0x80000000,0},
  {0x7fc00001,0,0,1},
  {0x7f800001,0,0,1}
};
static int x_match(uint64_t word,uint32_t exact,unsigned nan) {
  if(!nan)return word==exact;
  return !(word>>32) && (word&UINT64_C(0x7f800000))==UINT64_C(0x7f800000) && (word&UINT64_C(0x007fffff));
}
int main(void) {
  if(p186_x_prior_main())return 30;
  uint64_t state[261],before[261],out[8];
  const uint64_t markers[]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),UINT64_C(0xfedcba9876543210)};
  for(unsigned k=0;k<261;k++)state[k]=CANARY+k;
  expected_state=state;calls=bad_call=0;mutate_buffer=0;
  unsigned checks=0;
  for(unsigned i=0;i<sizeof(xcases)/sizeof(xcases[0]);i++)for(unsigned j=0;j<5;j++) {
    const XCase *c=&xcases[i];uint64_t marker=markers[j],a=(marker&UINT64_C(0xffffffff00000000))|c->input;
    memcpy(before,state,sizeof(state));
    if(!x_match(x_rhs(state,a),c->subtract,c->nan))return 31;++checks;
    if(!x_match(x_divide(state,a),c->divide,c->nan))return 32;++checks;
    if(!x_match(x_copy(state,a),c->input,c->nan))return 33;++checks;
    clear(out);
    if(x_raw(state,out+1,a,marker)||!x_match(out[1],c->input,c->nan)||out[2]!=marker||!canaries(out,2))return 34;++checks;
    expected_arg=marker;calls=bad_call=0;clear(out);
    if(x_call(state,out+1,a,marker)||!x_match(out[1],c->input,c->nan)||out[2]!=STUB_RESULT||!canaries(out,2)||calls!=1||bad_call)return 35;++checks;
    if(!x_match(x_branch(state,a,0),c->input,c->nan))return 36;++checks;
    if(!x_match(x_branch(state,a,1),c->input,c->nan))return 37;++checks;
    if(memcmp(state,before,sizeof(state)))return 38;
  }
  const uint32_t input[]={0x3f800000,0x3f000000,0xbf800000,0x00000001};
  const uint32_t sum[]={0x41800000,0x41000000,0xc1800000,0x00000010};
  for(unsigned i=0;i<4;i++)for(unsigned j=0;j<5;j++) {
    uint64_t a=(markers[j]&UINT64_C(0xffffffff00000000))|input[i];memcpy(before,state,sizeof(state));
    if(x_pressure(state,a)!=sum[i]||memcmp(state,before,sizeof(state)))return 39;++checks;
  }
  /* A true comparison publishes integer bits1 into an XMM home. As an F32
   * operand these are minimum subnormal, so multiplication by2 yields bits2. */
  for(unsigned i=0;i<93;i++)if(cases[i].op>=30)for(unsigned j=0;j<5;j++) {
    const Case *c=&cases[i];uint64_t a=(markers[j]&UINT64_C(0xffffffff00000000))|(uint32_t)c->a;
    uint64_t b=(~markers[j]&UINT64_C(0xffffffff00000000))|(uint32_t)c->b;
    memcpy(before,state,sizeof(state));
    if(x_comparisons[c->op-30](state,a,b)!=c->expected*2 || memcmp(state,before,sizeof(state)))return 40;
    ++checks;
  }
  printf("phase186 XMM controls pass: %u\n",checks);return 0;
}
