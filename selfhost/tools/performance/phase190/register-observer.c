/* Independent unsigned-word oracles for ordinary active register placement.
 * No runtime helpers or stubs are needed. Output and state sentinels detect
 * writes outside each function's four-result ABI. */
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define F "p113d_FID_112_49_57_48_114_"
extern uint64_t rotate(void *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "97_");
extern uint64_t helper(void *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "98_");
extern uint64_t calls(void *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(F "99_");
extern uint64_t setup(void *,uint64_t *,uint64_t,uint64_t,uint64_t) __asm__(F "100_");
extern uint64_t buffers(void *,uint64_t *,uint64_t,uint64_t) __asm__(F "101_");
static const uint64_t sentinel=UINT64_C(0x9b7d5f311357ace0);
typedef struct { uint64_t before,words[8],after; } Output;
static void reset(Output *out) {
  out->before=out->after=sentinel;
  for(unsigned i=0;i<8;i++) out->words[i]=sentinel;
}
static int check(const char *name,unsigned input,uint64_t status,const Output *out,const uint64_t want[4]) {
  if(status || out->before!=sentinel || out->after!=sentinel) return 0;
  for(unsigned i=4;i<8;i++) if(out->words[i]!=sentinel) return 0;
  for(unsigned i=0;i<4;i++) if(out->words[i]!=want[i]) {
    fprintf(stderr,"%s input=%u result=%u: got %016" PRIx64 ", expected %016" PRIx64 "\n",
      name,input,i,out->words[i],want[i]);
    return 0;
  }
  return 1;
}
static void transform(uint64_t a,uint64_t b,uint64_t c,uint64_t d,uint64_t out[4]) {
  out[0]=a+b; out[1]=b^c; out[2]=c+d; out[3]=d-a;
}
static void recurrence(uint64_t n,uint64_t out[4]) {
  while(n) {
    uint64_t v[4]; const uint64_t a=out[0];
    transform(out[0],out[1],out[2],out[3],v);
    if(n&1) {
      const unsigned shift=(a&1)?0:1;
      for(unsigned i=0;i<4;i++) out[i]=v[(i+shift)%4];
    } else {
      for(unsigned i=0;i<4;i++) out[i]=v[3-i];
    }
    n--;
  }
}
int main(void) {
  const uint64_t inputs[]={0,1,2,UINT64_MAX,UINT64_C(0x8000000000000000),
    UINT64_C(0xfedcba9876543210),UINT64_C(0x00000000ffffffff)};
  const uint64_t counts[]={0,1,2,3,4,7,64,1001};
  uint64_t state[261],before[261]; Output out;
  for(unsigned i=0;i<261;i++) state[i]=UINT64_C(0xabcdaaaa00000000)+i;
  memcpy(before,state,sizeof(state));
  unsigned observations=0;
  for(unsigned i=0;i<sizeof(inputs)/sizeof(inputs[0]);i++) {
    const uint64_t a=inputs[i],b=inputs[(i+1)%7],c=inputs[(i+3)%7],d=inputs[(i+5)%7];
    uint64_t want[4];
    transform(a,b,c,d,want); reset(&out);
    if(!check("helper",i,helper(state,out.words,a,b,c,d),&out,want)) return 1;
    observations++;
    want[0]=a; want[1]=b; want[2]=a+b; want[3]=a^b; reset(&out);
    if(!check("buffers",i,buffers(state,out.words,a,b),&out,want)) return 2;
    observations++;
    for(unsigned j=0;j<sizeof(counts)/sizeof(counts[0]);j++) {
      const uint64_t n=counts[j],initial[4]={a,b,c,d};
      for(unsigned k=0;k<4;k++) want[k]=initial[(k+n)%4];
      reset(&out);
      if(!check("rotate",i*8+j,rotate(state,out.words,n,a,b,c,d),&out,want)) return 3;
      observations++;
      memcpy(want,initial,sizeof want); recurrence(n,want); reset(&out);
      if(!check("calls",i*8+j,calls(state,out.words,n,a,b,c,d),&out,want)) return 4;
      observations++;
      want[0]=a; want[1]=b; want[2]=a; want[3]=b;
      for(uint64_t k=0;k<n;k++) { want[1]^=want[0]; want[0]++; }
      reset(&out);
      if(!check("setup",i*8+j,setup(state,out.words,n,a,b),&out,want)) return 5;
      observations++;
    }
  }
  if(memcmp(state,before,sizeof(state))) return 6;
  printf("phase190 register controls pass: %u observations\n",observations);
  return 0;
}
