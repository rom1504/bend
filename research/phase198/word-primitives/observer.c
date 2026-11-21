#include <stdint.h>
#include <stdio.h>
extern uint64_t word24(const uint64_t *);
extern uint64_t word25(const uint64_t *);
extern uint64_t word63(const uint64_t *);
extern uint64_t word67(const uint64_t *);
static unsigned total;
static int check(uint64_t a, uint64_t b) {
    uint64_t words[] = {a,b};
    total += 4;
    return word24(words)==a && word25(words)==(uint32_t)a
        && word63(words)==(a<b?0:a-b) && word67(words)==(a<b);
}
int main(void) {
    const uint64_t edge[]={0,UINT32_MAX,(uint64_t)UINT32_MAX+1};
    for(unsigned i=0;i<3;i++)for(unsigned j=0;j<3;j++) if(!check(edge[i],edge[j]))return 1;
    uint64_t z=UINT64_MAX;
    for(unsigned i=0;i<4096;i++){
        const uint64_t x=z;z=z*UINT64_C(6364136223846793005)+UINT64_C(1442695040888963407);
        if(!check(x,z))return 1;
    }
    printf("checked %u\n",total);
    return 0;
}
