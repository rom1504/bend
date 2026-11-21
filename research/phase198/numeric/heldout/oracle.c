/* Independent source oracle and C performance reference. No fixed-point shortcut. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#ifndef CYCLING
#define CYCLING 0
#endif
__attribute__((noinline)) static uint32_t work(uint32_t count,uint32_t seed) {
  uint32_t x=seed, sum=seed^UINT32_C(2654435769), step=seed|1;
  for (uint32_t i=0;i<count;++i) {
    sum += step+(x&7);
    if(CYCLING)x+=1;else x>>=1;
  }
  return sum;
}
static uint64_t ns(void){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return(uint64_t)t.tv_sec*1000000000+t.tv_nsec;}
int main(int argc,char **argv){
  if(argc!=5)return 2;
  uint64_t repetitions=strtoull(argv[1],0,10),warmups=strtoull(argv[2],0,10);
  volatile uint32_t size=(uint32_t)strtoul(argv[3],0,10),seed=(uint32_t)strtoul(argv[4],0,10);
  uint32_t result=work(size,seed);uint64_t count=0,warmed=0;
  for(uint64_t i=0;i<warmups;++i)warmed+=work(size,seed)==result;
  uint64_t begin=ns();for(uint64_t i=0;i<repetitions;++i)count+=work(size,seed)==result;
  uint64_t end=ns();printf("%u\n%llu\n%llu\n%llu\n",result,(unsigned long long)warmed,(unsigned long long)count,(unsigned long long)((end-begin)/1000000));return 0;
}
