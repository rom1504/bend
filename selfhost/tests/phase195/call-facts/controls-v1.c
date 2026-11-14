#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

/* Opaque to the generated caller; it changes memory but not caller locals. */
uint64_t p195cf_mutate(uint64_t *memory, uint64_t x, uint64_t y) {
  memory[0] = x ^ UINT64_C(0x13579bdf2468ace0);
  memory[1] = y ^ UINT64_C(0xfedcba9876543210);
  return x ^ y ^ UINT64_C(0x8000000100000001);
}
#define DECL(N) extern uint64_t p195cf_##N(uint64_t *);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7) DECL(8)
int main(void) {
  uint64_t (*functions[])(uint64_t *) = {p195cf_0,p195cf_1,p195cf_2,p195cf_3,
    p195cf_4,p195cf_5,p195cf_6,p195cf_7,p195cf_8};
  const uint64_t edges[] = {0,1,2,UINT64_C(0xffffffff),UINT64_C(0x100000000),
    UINT64_C(0x100000001),UINT64_C(0x8000000000000000),UINT64_MAX,UINT64_C(0x123456789abcdef0)};
  unsigned checks=0, failures=0;
  for (unsigned mode=0;mode<9;mode++) for (unsigned i=0;i<9;i++)
    for (unsigned j=0;j<9;j++) for (unsigned cond=0;cond<2;cond++) {
      uint64_t a=edges[i], b=edges[j], saved=mode==4 ? (uint32_t)a : a;
      uint64_t copy=saved, nar=(uint32_t)b, narcopy=nar, out=0, other=0;
      uint64_t memory0=a, memory1=b;
      if (mode!=5 || cond) {
        /* Literal arithmetic oracle, not a call to the tested helper. */
        uint64_t r=saved ^ nar ^ UINT64_C(0x8000000100000001);
        uint64_t r2=r ^ UINT64_C(0xfedcba9801020304);
        memory0=saved ^ UINT64_C(0x13579bdf2468ace0);
        memory1=nar ^ UINT64_C(0xfedcba9876543210);
        switch (mode) {
          case 1: a=r; break;
          case 2: saved=r; break;
          case 3: nar=r; break;
          case 6: a=r; nar=r2; break;
          case 7: saved=r; nar=r2; break;
          case 8: out=r; other=r2; break;
          default: out=r; break;
        }
      }
      uint64_t after=(uint32_t)nar, fresh=memory0;
      uint64_t result=after+saved+copy+a+narcopy+fresh+out+other;
      uint64_t state[10]={edges[i],b,cond,UINT64_MAX,UINT64_MAX,UINT64_MAX,
        UINT64_MAX,UINT64_MAX,UINT64_MAX,UINT64_MAX};
      uint64_t expected[10]={memory0,memory1,cond,saved,copy,a,nar,after,fresh,result};
      uint64_t actual=functions[mode](state);
      unsigned wrong=actual!=result;
      for (unsigned k=0;k<10;k++) wrong|=state[k]!=expected[k];
      checks++;
      if (wrong) {
        failures++;
        if (failures<=4) fprintf(stderr,"mode=%u a=%"PRIu64" b=%"PRIu64" cond=%u result=%"PRIu64" expected=%"PRIu64"\n",
          mode,edges[i],b,cond,actual,result);
      }
    }
  printf("phase195 call facts controls: checks=%u failures=%u\n",checks,failures);
  return failures!=0;
}
