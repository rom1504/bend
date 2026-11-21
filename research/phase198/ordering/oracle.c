#include <stdint.h>
#include <stdio.h>
extern uint64_t u32cmp(const uint64_t *);
extern uint64_t natcmp(const uint64_t *);

static uint64_t ord(uint64_t a, uint64_t b) {
    unsigned cid = a < b ? 65535 : a == b ? 0 : 32769;
    return (UINT64_C(1) << 56) | ((uint64_t)cid << 40);
}
static int check(uint64_t a, uint64_t b) {
    uint64_t buf[2] = {a,b};
    return u32cmp(buf)==ord((uint32_t)a,(uint32_t)b) && natcmp(buf)==ord(a,b);
}
int main(void) {
    const uint64_t e[] = {0,1,2,0xffffffff,UINT64_C(1)<<32,UINT64_C(1)<<63,UINT64_MAX};
    for (unsigned i=0; i<7; i++)
        for (unsigned j=0; j<7; j++)
            if (!check(e[i],e[j])) return 1;
    uint64_t state = 17;
    for (unsigned i=0; i<5000; i++) {
        uint64_t old=state;
        state=state*UINT64_C(6364136223846793005)+1;
        if (!check(state,old) || !check(state,state) || !check(old,state)) return 2;
    }
    puts("checked 30098");
    return 0;
}
