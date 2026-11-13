#include <stdint.h>
#include <stdio.h>
typedef void (*select_fn)(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_0_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_0_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_1_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_1_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_2_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_2_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_3_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_32_3_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_0_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_0_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_1_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_1_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_2_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_2_4(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_3_1(uint64_t,uint64_t,uint64_t,uint64_t*);
extern void p191cc_64_3_4(uint64_t,uint64_t,uint64_t,uint64_t*);
static const select_fn functions[2][4][2]={
{{p191cc_32_0_1,p191cc_32_0_4},{p191cc_32_1_1,p191cc_32_1_4},{p191cc_32_2_1,p191cc_32_2_4},{p191cc_32_3_1,p191cc_32_3_4}},
{{p191cc_64_0_1,p191cc_64_0_4},{p191cc_64_1_1,p191cc_64_1_4},{p191cc_64_2_1,p191cc_64_2_4},{p191cc_64_3_1,p191cc_64_3_4}},
};
int main(void){
  static const uint64_t values[]={0,1,UINT64_MAX,UINT64_C(0x8000000000000000),UINT64_C(0xffffffff),UINT64_C(0x100000001),UINT64_C(0xdeadbeef01234567),UINT64_C(0xaaaaaaaa55555555)};
  static const uint64_t conditions[]={0,1,2,UINT64_C(0xffffffff),UINT64_C(0x100000000),UINT64_C(0x8000000000000000),UINT64_MAX};
  const uint64_t guard=UINT64_C(0x37e9b4d1205acf86);
  unsigned checks=0,failures=0;
  for(unsigned w=0;w<2;w++)for(unsigned m=0;m<4;m++)for(unsigned len=0;len<2;len++)for(unsigned v=0;v<8;v++)for(unsigned c=0;c<7;c++){
    uint64_t out[6]={guard,guard,guard,guard,guard,guard};
    uint64_t yes=values[v],no=values[(v+3)%8];
    uint64_t expected=(uint32_t)conditions[c]?yes:no;
    if(m==3)expected=(uint32_t)conditions[c]?UINT64_C(0xdeadbeefffffffff):UINT64_C(0x1234567880000000);
    if(w==0)expected=(uint32_t)expected;
    functions[w][m][len](conditions[c],yes,no,out+1);
    unsigned count=len?4:1;
    for(unsigned k=0;k<6;k++){
      uint64_t want=k>=1&&k<=count?expected:guard;
      checks++;if(out[k]!=want)failures++;
    }
  }
  printf("phase191 conditional controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
