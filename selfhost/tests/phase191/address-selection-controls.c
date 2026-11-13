/* Independent unsigned C oracle for manually selected typed instructions.
   Tests caller-register collisions and entirely stack-resident operands;
   every memory observation includes unchanged surrounding guard words. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*fn)(void *,uint64_t,uint64_t);
static unsigned checks,failures;
static void check(int good){++checks;if(!good)++failures;}
extern uint64_t p191sc_load_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_32_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_32_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_32_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_32_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_32_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_load_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_add_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_sub_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_mul_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_and_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_or_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_xor_64_4(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_64_0(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_64_1(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_64_2(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_64_3(void *,uint64_t,uint64_t);
extern uint64_t p191sc_store_64_4(void *,uint64_t,uint64_t);
static const fn functions32[8][5]={
  {p191sc_load_32_0,p191sc_load_32_1,p191sc_load_32_2,p191sc_load_32_3,p191sc_load_32_4},
  {p191sc_add_32_0,p191sc_add_32_1,p191sc_add_32_2,p191sc_add_32_3,p191sc_add_32_4},
  {p191sc_sub_32_0,p191sc_sub_32_1,p191sc_sub_32_2,p191sc_sub_32_3,p191sc_sub_32_4},
  {p191sc_mul_32_0,p191sc_mul_32_1,p191sc_mul_32_2,p191sc_mul_32_3,p191sc_mul_32_4},
  {p191sc_and_32_0,p191sc_and_32_1,p191sc_and_32_2,p191sc_and_32_3,p191sc_and_32_4},
  {p191sc_or_32_0,p191sc_or_32_1,p191sc_or_32_2,p191sc_or_32_3,p191sc_or_32_4},
  {p191sc_xor_32_0,p191sc_xor_32_1,p191sc_xor_32_2,p191sc_xor_32_3,p191sc_xor_32_4},
  {p191sc_store_32_0,p191sc_store_32_1,p191sc_store_32_2,p191sc_store_32_3,p191sc_store_32_4},
};
static const fn functions64[8][5]={
  {p191sc_load_64_0,p191sc_load_64_1,p191sc_load_64_2,p191sc_load_64_3,p191sc_load_64_4},
  {p191sc_add_64_0,p191sc_add_64_1,p191sc_add_64_2,p191sc_add_64_3,p191sc_add_64_4},
  {p191sc_sub_64_0,p191sc_sub_64_1,p191sc_sub_64_2,p191sc_sub_64_3,p191sc_sub_64_4},
  {p191sc_mul_64_0,p191sc_mul_64_1,p191sc_mul_64_2,p191sc_mul_64_3,p191sc_mul_64_4},
  {p191sc_and_64_0,p191sc_and_64_1,p191sc_and_64_2,p191sc_and_64_3,p191sc_and_64_4},
  {p191sc_or_64_0,p191sc_or_64_1,p191sc_or_64_2,p191sc_or_64_3,p191sc_or_64_4},
  {p191sc_xor_64_0,p191sc_xor_64_1,p191sc_xor_64_2,p191sc_xor_64_3,p191sc_xor_64_4},
  {p191sc_store_64_0,p191sc_store_64_1,p191sc_store_64_2,p191sc_store_64_3,p191sc_store_64_4},
};
static uint64_t reference(unsigned op,uint64_t a,uint64_t b){
  switch(op){case 0:return b;case 1:return a+b;case 2:return a-b;
    case 3:return a*b;case 4:return a&b;case 5:return a|b;default:return a^b;}
}
int main(void){
  static const uint64_t values[]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),
    UINT64_C(0xffffffff),UINT64_C(0x100000001),UINT64_C(0xdeadbeef01234567),UINT64_C(0xaaaaaaaa55555555)};
  for(unsigned width=0;width<2;width++)for(unsigned op=0;op<8;op++)for(unsigned mode=0;mode<5;mode++)for(unsigned n=0;n<8;n++){
    uint64_t a64[8],saved64[8];uint32_t a32[8],saved32[8];
    for(unsigned i=0;i<8;i++){a64[i]=values[(n+i)%8];a32[i]=(uint32_t)values[(n+i)%8];}
    memcpy(saved64,a64,sizeof a64);memcpy(saved32,a32,sizeof a32);
    uint64_t index=1+n%4,left=values[(n+3)%8],expected;
    unsigned target=(unsigned)index+1;
    void *base=width?(void*)a64:(void*)a32;
    uint64_t actual=(width?functions64: functions32)[op][mode](base,index,left);
    if(op<7){
      expected=reference(op,left,width?saved64[target]:saved32[target]);
      if(!width)expected=(uint32_t)expected;
      check(actual==expected);
      check(memcmp(a64,saved64,sizeof a64)==0&&memcmp(a32,saved32,sizeof a32)==0);
    }else{
      expected=mode==0?(uint64_t)(uintptr_t)base:mode==1?index:left;
      if(width)saved64[target]=expected;else saved32[target]=(uint32_t)expected;
      check(actual==0&&memcmp(a64,saved64,sizeof a64)==0&&memcmp(a32,saved32,sizeof a32)==0);
    }
  }
  printf("phase191 selection controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
