#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
extern uint64_t p188tc_value(void),p188tc_branch(uint64_t),p188tc_loop(uint64_t),p188tc_read(void),p188tc_call(uint64_t),p188tc_stack(uint64_t),p188tc_float(uint64_t,uint64_t);
extern void p188tc_math(uint64_t,uint64_t,uint64_t*);
extern const unsigned char p188tc_data[16];
extern const unsigned char *p188tc_pointer;
extern const uint64_t p188tc_rodata;
static unsigned checks,failures,calls;
static void check(int good){checks++;if(!good)failures++;}
uint64_t p188tc_external(uint64_t value){calls++;return value^UINT64_C(0xa55aa55a11223344);}
int main(void){
  const uint64_t words[]={0,1,31,32,63,64,65,UINT64_C(0xffffffff),UINT64_C(0x8000000000000000),UINT64_MAX};
  check(p188tc_value()==UINT64_MAX);
  for(unsigned i=0;i<10;i++)for(unsigned j=0;j<10;j++){
    uint64_t out[5]={UINT64_C(0xdeadbeef12345678),0,0,0,UINT64_C(0x87654321deadbeef)};
    p188tc_math(words[i],words[j],out+1);
    check(out[0]==UINT64_C(0xdeadbeef12345678)&&out[4]==UINT64_C(0x87654321deadbeef)&&out[1]==words[i]+words[j]&&out[2]==(uint64_t)(uint32_t)(words[i]+words[j])&&out[3]==(uint64_t)(words[i]<words[j]));
  }
  for(unsigned i=0;i<10;i++){
    check(p188tc_branch(words[i])==(words[i]?23:17));
    check(p188tc_stack(words[i])==words[i]);
    check(p188tc_call(words[i])==(words[i]^UINT64_C(0xa55aa55a11223344)));
  }
  for(unsigned i=0;i<5;i++)check(p188tc_loop(i)==i*(i+1)/2);
  check(calls==10);
  uint64_t data=0;memcpy(&data,p188tc_data,8);check(data==UINT64_C(0x1122334455667788)&&p188tc_read()==data);
  const unsigned char tail[]={255,255,255,255,165,0,0,0};check(memcmp(p188tc_data+8,tail,8)==0);
  check(p188tc_pointer==p188tc_data+8);check(p188tc_rodata==UINT64_C(0x8000000000000000));
  check(p188tc_float(UINT64_C(0xffffffff3f800000),UINT64_C(0xdeadbeef40000000))==UINT64_C(0x40400000));
  check(p188tc_float(0,UINT64_C(0x80000000))==0);
  printf("phase188 typed controls: checks=%u failures=%u\n",checks,failures);
  return failures?1:0;
}
