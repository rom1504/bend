#include <stdint.h>

static uint32_t step(uint32_t s) {
    s ^= s<<13; s ^= s>>17; return s^(s<<5);
}

/* Each 32-row stripe consumes the horizontal distance differences left
   by the preceding stripe. hin/hout are encoded as distance change + 1. */
static uint32_t pair(uint32_t index) {
    uint32_t seed=(index+1)*2654435761u, text_seed=seed*340573321u;
    uint8_t delta[256];
    for (unsigned j=0; j<256; ++j) delta[j]=2;
    unsigned score=0;
    for (unsigned stripe=0; stripe<8; ++stripe) {
        uint32_t mask[4]={0};
        for (unsigned b=0; b<32; ++b) {
            seed=step(seed);
            mask[seed&3] |= 1u<<b;
        }
        uint32_t pv=UINT32_MAX, mv=0, s=text_seed;
        score=32*(stripe+1);
        for (unsigned j=0; j<256; ++j) {
            s=step(s);
            uint32_t eq=mask[s&3], xv=eq|mv, hin=delta[j];
            eq |= hin==0;
            uint32_t xh=(((eq&pv)+pv)^pv)|eq;
            uint32_t ph=mv|~(xh|pv), mh=pv&xh;
            unsigned plus=ph>>31, minus=mh>>31;
            delta[j]=(uint8_t)(1+plus-minus);
            score+=plus-minus;
            ph=(ph<<1)|(hin==2); mh=(mh<<1)|(hin==0);
            pv=mh|~(xv|ph); mv=ph&xv;
        }
    }
    return (score*2654435761u)^(index+1);
}

static uint32_t batch(uint32_t depth,uint32_t index) {
    if (!depth) return pair(index);
    uint32_t shift=depth-1;
    return batch(shift,index)+batch(shift,index+(shift<32 ? 1u<<shift : 0u));
}

uint32_t bench_u32(uint32_t depth,uint32_t seed) { return batch(depth,seed); }
