#include <stdint.h>
#include <stdio.h>
extern uint64_t p199_snapshot(uint64_t n,uint64_t seed);
int main(void) {
  uint64_t seed = UINT64_C(0x6f43d923ab18421);
  for (unsigned count=0;count<256;count++) {
    seed=seed*UINT64_C(6364136223846793005)+1;
    uint64_t expected=seed;
    for(unsigned i=0;i<count;i++)expected=2*expected+i+1;
    if (p199_snapshot(count,seed)!=expected)return 1;
  }
  puts("256 wrapped complete loop results");
  return 0;
}
