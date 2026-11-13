#include <stdint.h>
#include <stdio.h>
#include <string.h>
static unsigned checks,failures;
static void check(int good){checks++;if(!good)failures++;}
extern const unsigned char p191mc_bytes_0[];
extern const unsigned char p191mc_bytes_1[];
extern const unsigned char p191mc_bytes_2[];
extern const unsigned char p191mc_bytes_3[];
extern const unsigned char p191mc_bytes_4[];
extern const unsigned char p191mc_bytes_5[];
extern const unsigned char p191mc_bytes_6[];
extern const unsigned char p191mc_bytes_7[];
extern const unsigned char p191mc_bytes_8[];
extern const unsigned char p191mc_bytes_9[];
extern const unsigned char p191mc_bytes_10[];
extern const unsigned char p191mc_bytes_11[];
extern const unsigned char p191mc_bytes_12[];
extern const unsigned char p191mc_bytes_13[];
extern const unsigned char p191mc_bytes_14[];
extern const unsigned char p191mc_bytes_15[];
extern const unsigned char p191mc_bytes_16[];
extern const unsigned char p191mc_bytes_17[];
extern const unsigned char p191mc_bytes_18[];
extern const unsigned char p191mc_bytes_19[];
extern const unsigned char p191mc_bytes_20[];
extern const unsigned char p191mc_bytes_21[];
extern const unsigned char p191mc_bytes_22[];
extern const unsigned char p191mc_bytes_23[];
extern uint64_t p191mc_e_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ne_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_b_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_be_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_a_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ae_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_l_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_le_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_g_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ge_32(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_e_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ne_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_b_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_be_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_a_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ae_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_l_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_le_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_g_64(uint64_t,uint64_t,uint64_t,uint64_t);
extern uint64_t p191mc_ge_64(uint64_t,uint64_t,uint64_t,uint64_t);
typedef uint64_t (*select_fn)(uint64_t,uint64_t,uint64_t,uint64_t);
static const select_fn selectors[2][10]={
  {p191mc_e_32,p191mc_ne_32,p191mc_b_32,p191mc_be_32,p191mc_a_32,p191mc_ae_32,p191mc_l_32,p191mc_le_32,p191mc_g_32,p191mc_ge_32},
  {p191mc_e_64,p191mc_ne_64,p191mc_b_64,p191mc_be_64,p191mc_a_64,p191mc_ae_64,p191mc_l_64,p191mc_le_64,p191mc_g_64,p191mc_ge_64},
};
int main(void){
  {const unsigned char bytes[]={69,15,68,202};check(memcmp(p191mc_bytes_0,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,69,202};check(memcmp(p191mc_bytes_1,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,66,202};check(memcmp(p191mc_bytes_2,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,70,202};check(memcmp(p191mc_bytes_3,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,71,202};check(memcmp(p191mc_bytes_4,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,67,202};check(memcmp(p191mc_bytes_5,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,76,202};check(memcmp(p191mc_bytes_6,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,78,202};check(memcmp(p191mc_bytes_7,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,79,202};check(memcmp(p191mc_bytes_8,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,77,202};check(memcmp(p191mc_bytes_9,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,68,202};check(memcmp(p191mc_bytes_10,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,69,202};check(memcmp(p191mc_bytes_11,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,66,202};check(memcmp(p191mc_bytes_12,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,70,202};check(memcmp(p191mc_bytes_13,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,71,202};check(memcmp(p191mc_bytes_14,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,67,202};check(memcmp(p191mc_bytes_15,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,76,202};check(memcmp(p191mc_bytes_16,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,78,202};check(memcmp(p191mc_bytes_17,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,79,202};check(memcmp(p191mc_bytes_18,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={77,15,77,202};check(memcmp(p191mc_bytes_19,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={15,68,193};check(memcmp(p191mc_bytes_20,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={72,15,68,69,0};check(memcmp(p191mc_bytes_21,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={79,15,69,84,229,0};check(memcmp(p191mc_bytes_22,bytes,sizeof bytes)==0);}
  {const unsigned char bytes[]={69,15,77,132,36,127,255,255,255};check(memcmp(p191mc_bytes_23,bytes,sizeof bytes)==0);}
  const uint64_t values[]={0,1,UINT32_MAX,UINT64_C(0x80000000),UINT64_C(0x7fffffff),UINT64_C(0x100000000),UINT64_C(0x7fffffffffffffff),UINT64_C(0x8000000000000000),UINT64_MAX};
  const uint64_t yes=UINT64_C(0xfedcba9887654321),no=UINT64_C(0x1234567887654320);
  for(unsigned w=0;w<2;w++)for(unsigned i=0;i<9;i++)for(unsigned j=0;j<9;j++){
    uint64_t a=w?values[i]:(uint32_t)values[i],b=w?values[j]:(uint32_t)values[j];
    uint64_t sign=w?UINT64_C(0x8000000000000000):UINT64_C(0x80000000);
    int less=(a^sign)<(b^sign),greater=(a^sign)>(b^sign);
    const int truth[]={a==b,a!=b,a<b,a<=b,a>b,a>=b,less,!greater,greater,!less};
    for(unsigned k=0;k<10;k++){uint64_t expected=truth[k]?yes:no;if(!w)expected=(uint32_t)expected;
      check(selectors[w][k](values[i],values[j],yes,no)==expected);}
  }
  printf("phase191 cmov controls: checks=%u failures=%u\n",checks,failures);return failures?1:0;
}
