#include <stdint.h>
#include <stdio.h>
extern uint64_t p197d_machine_0(uint64_t,uint64_t);
extern uint64_t p197d_machine_1(uint64_t,uint64_t);
extern uint64_t p197d_machine_2(uint64_t,uint64_t);
extern uint64_t p197d_machine_3(uint64_t,uint64_t);
extern uint64_t p197d_machine_4(uint64_t,uint64_t);
extern uint64_t p197d_machine_5(uint64_t,uint64_t);
extern uint64_t p197d_machine_6(uint64_t,uint64_t);
extern uint64_t p197d_machine_7(uint64_t,uint64_t);
int main(void) {
  uint64_t (*fn[])(uint64_t,uint64_t) = {p197d_machine_0,p197d_machine_1,p197d_machine_2,p197d_machine_3,
    p197d_machine_4,p197d_machine_5,p197d_machine_6,p197d_machine_7};
  const uint64_t edge[] = {0,1,2,UINT64_MAX,UINT64_MAX-1,UINT64_C(0x8000000000000000),
    UINT64_C(0x7fffffffffffffff),UINT64_C(0xffffffff),UINT64_C(0x100000000)};
  unsigned checks=0,failures=0; uint64_t seed=0x197;
  for(unsigned i=0;i<265;i++) {
    seed=seed*UINT64_C(6364136223846793005)+1;
    uint64_t x=i<9?edge[i]:seed;
    uint64_t y=i<9?edge[8-i]:(seed^(seed>>17));
    uint64_t expected[] = {x-1,x+1,x-UINT64_C(2147483648),x+1,x==0,x==1,
      (x^UINT64_C(0x8000000000000000))<UINT64_C(0x8000000000000001),x<y};
    for(unsigned k=0;k<8;k++) {checks++; if(fn[k](x,y)!=expected[k])failures++;}
  }
  printf("phase197 decrement machine controls: checks=%u failures=%u\n",checks,failures);
  return failures!=0;
}
