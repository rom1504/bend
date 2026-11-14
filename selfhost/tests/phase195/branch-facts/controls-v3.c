#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

uint64_t p195bf_external(uint64_t x) { return x ^ UINT64_C(0x8000000100000001); }
#define DECL(N) extern uint64_t p195bf_##N(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8) DECL(9) DECL(10) DECL(11) DECL(12)
int main(void) {
  uint64_t (*functions[])(uint64_t *) = {p195bf_0,p195bf_1,p195bf_2,p195bf_3,p195bf_4,
    p195bf_5,p195bf_6,p195bf_7,p195bf_8,p195bf_9,p195bf_10,p195bf_11,p195bf_12};
  const uint64_t edges[] = {0,1,2,UINT64_C(0xffffffff),UINT64_C(0x100000000),
    UINT64_C(0x100000001),UINT64_C(0x8000000000000000),UINT64_MAX,UINT64_C(0x123456789abcdef0)};
  unsigned checks=0, failures=0;
  for (unsigned mode=0;mode<13;mode++) for (unsigned i=0;i<9;i++)
    for (unsigned j=0;j<9;j++) for (unsigned cond=0;cond<2;cond++) {
      uint64_t old=edges[i], b=edges[j], a=old, saved=old, result=0;
      if (mode==4 || mode==5 || mode==10) saved=(uint32_t)old;
      uint64_t copy=saved;
      if ((mode==1 || mode==4 || mode==6 || mode==9 || mode==12) && cond) a=b;
      if (mode==2 && !cond) a=b;
      if ((mode==3 || mode==5 || mode==11) && cond) saved=b;
      if (mode==8 && cond) a=old ^ UINT64_C(0x8000000100000001);
      switch (mode) {
        case 0: a=b; result=old; break;
        case 10: a=b; result=(uint32_t)old; break;
        case 5: case 6: case 11: result=copy+saved; break;
        case 7: result=(cond ? (uint64_t)(uint32_t)b : old)+saved; break;
        default: result=saved+a; break;
      }
      uint64_t state[6]={old,b,cond,UINT64_MAX,UINT64_MAX,UINT64_MAX};
      uint64_t actual=functions[mode](state); checks++;
      if (actual!=result || state[3]!=saved || state[4]!=a || state[5]!=result) {
        failures++;
        if (failures<=4) fprintf(stderr,"mode=%u a=%"PRIu64" b=%"PRIu64" cond=%u result=%"PRIu64" expected=%"PRIu64"\n",mode,old,b,cond,actual,result);
      }
    }
  printf("phase195 branch facts controls: checks=%u failures=%u\n",checks,failures);
  return failures!=0;
}
