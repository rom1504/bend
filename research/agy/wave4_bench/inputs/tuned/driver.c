#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>

uint32_t bench_u32(uint32_t n, uint32_t seed);

static uint32_t batch(uint32_t count,uint32_t n,uint32_t seed) {
    uint32_t h=0;
    for (uint32_t i=0;i<count;++i)
        h=h*16777619u+bench_u32(n,seed+(i&31u)*2654435761u);
    return h;
}

static uint64_t millis(void) {
    struct timespec t;
    if(clock_gettime(CLOCK_MONOTONIC,&t)) exit(2);
    return (uint64_t)t.tv_sec*1000u+(unsigned)t.tv_nsec/1000000u;
}

int main(int argc,char **argv) {
    if(argc!=5) return 2;
    uint32_t reps=(uint32_t)strtoul(argv[1],0,10), warm=(uint32_t)strtoul(argv[2],0,10);
    uint32_t n=(uint32_t)strtoul(argv[3],0,10), seed=(uint32_t)strtoul(argv[4],0,10);
    printf("%" PRIu32 "\n",bench_u32(n,seed));
    printf("%" PRIu32 "\n",batch(warm,n,seed));
    uint64_t before=millis();
    printf("%" PRIu32 "\n",batch(reps,n,seed));
    printf("%" PRIu64 "\n",millis()-before);
    return 0;
}
