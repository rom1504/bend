#define _GNU_SOURCE
#include "scan.h"
#include "../../../selfhost/src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

extern uint64_t p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_(P111State *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t);
#define ORIGINAL p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_
#define HEAP_BOUND UINT64_C(0x3108280)
static uint32_t random_word(uint32_t *r) { *r=*r*1664525u+1013904223u;return *r; }
static uint64_t oracle(uint32_t *a,uint64_t mask,uint64_t n,uint64_t index,uint64_t acc) {
  if(!n) return acc;
  for(uint64_t step=0;step<n;++step) {
    uint32_t i=(uint32_t)(index+step);
    acc=(uint32_t)((uint32_t)acc+a[i&mask]);
    a[i&mask]=(uint32_t)acc^i;
  }
  return acc;
}
static void array_json(const uint32_t *a,unsigned len) {
  putchar('[');for(unsigned j=0;j<len;++j)printf("%s%" PRIu32,j?",":"",a[j]);putchar(']');
}
int main(void) {
  uint64_t empty=UINT64_C(0xfedcba9876543210);
  if(p199_rt_u32_scan4(NULL,UINT64_MAX,0,UINT64_MAX,empty)!=empty)return 1;
  size_t bytes=(HEAP_BOUND+2048)*8;
  uint64_t *mem=mmap(NULL,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(mem==MAP_FAILED)return 2;
  P111State state={0};state.e.mem=mem;
  const uint64_t starts[]={0,1,2,3,124,125,126,127,128,129,0xfffffffc,0xfffffffd,0xfffffffe,0xffffffff,UINT64_C(0x12345678fffffffd),UINT64_MAX};
  const uint64_t counts[]={0,1,2,3,4,5,7,15,31,63,64,65,126,127,128,129,130,255,256,257,4096};
  uint64_t tested=0,split=0;
  for(unsigned cls=0;cls<=10;++cls) for(unsigned seed=0;seed<16;++seed)
    for(unsigned si=0;si<sizeof(starts)/sizeof(*starts);++si)
      for(unsigned ni=0;ni<sizeof(counts)/sizeof(*counts);++ni) {
        unsigned len=1u<<cls;
        uint64_t mask=len-1,loc=HEAP_BOUND+8+(seed&1);
        uint64_t handle=UINT64_C(4)<<56 | (uint64_t)cls<<40 |loc;
        uint32_t original[1032],expected[1032],actual[1032],chunked[1032];
        uint32_t rng=seed^0x9e3779b9u;
        uint64_t carry=((uint64_t)random_word(&rng)<<32)|random_word(&rng);
        uint32_t *payload=(uint32_t *)(mem+loc);
        for(unsigned j=0;j<len+8;++j) original[j]=random_word(&rng);
        if(seed%3==0)for(unsigned j=0;j<len;++j)original[j+4]=seed?UINT32_MAX:0;
        memcpy(expected,original,(len+8)*4);memcpy(actual,original,(len+8)*4);
        memcpy(payload-4,original,(len+8)*4);
        uint64_t want=oracle(expected+4,mask,counts[ni],starts[si],carry);
        uint64_t got=p199_rt_u32_scan4(actual+4,mask,counts[ni],starts[si],carry);
        uint64_t out[4]={11,22,33,44};
        uint64_t ret=ORIGINAL(&state,out,counts[ni],starts[si],handle,carry);
        if(got!=want || out[1]!=want || out[0]!=handle || ret!=0 || out[2]!=33 || out[3]!=44 ||
           memcmp(actual,expected,(len+8)*4) || memcmp(payload-4,expected,(len+8)*4)) {
          fprintf(stderr,"FAIL cls=%u seed=%u i=%" PRIu64 " n=%" PRIu64 " got=%" PRIu64 " want=%" PRIu64 " original=%" PRIu64 "\n",cls,seed,starts[si],counts[ni],got,want,out[1]);return 3;
        }
        for(unsigned j=0;j<4;++j)if(actual[j]!=original[j] || actual[len+4+j]!=original[len+4+j])return 4;
        ++tested;
        if(ni==20) {
          memcpy(chunked,original,(len+8)*4);
          uint64_t c=p199_rt_u32_scan4(chunked+4,mask,3,starts[si],carry);
          c=p199_rt_u32_scan4(chunked+4,mask,counts[ni]-3,(uint32_t)(starts[si]+3),c);
          if(c!=want || memcmp(chunked,expected,(len+8)*4))return 5;
          ++split;
        }
        if(seed==7 && si==15 && (cls==0 || cls==1 || cls==7) && (ni==0 || ni==15 || ni==20)) {
          printf("{\"kind\":\"vector\",\"mask\":%" PRIu64 ",\"n\":%" PRIu64 ",\"index\":%" PRIu64 ",\"carry\":%" PRIu64 ",\"initial\":",mask,counts[ni],starts[si],carry);
          array_json(original+4,len);printf(",\"final\":");array_json(actual+4,len);printf(",\"result\":%" PRIu64 "}\n",got);
        }
      }
  /* Long wrap and irregular defensive-mask checks, independent of caller admission. */
  for(unsigned mask=0;mask<256;++mask) {
    uint32_t a[264],b[264];for(unsigned j=0;j<264;++j)a[j]=b[j]=j*UINT32_C(2654435761);
    uint64_t want=oracle(a+4,mask,65539,UINT64_C(0x12345678ffffff80),empty);
    uint64_t got=p199_rt_u32_scan4(b+4,mask,65539,UINT64_C(0x12345678ffffff80),empty);
    if(want!=got || memcmp(a,b,sizeof(a)))return 6;
  }
  /* Cross the 32-bit fuel boundary. The two subcalls each fit in 32 bits;
   * complete-state equality rejects silently narrowing the single full call.
   */
  uint32_t wide[128],parts[128],truncated[128];
  for(unsigned j=0;j<128;++j)wide[j]=parts[j]=truncated[j]=17+j;
  uint64_t wc=p199_rt_u32_scan4(wide,127,UINT64_C(0x100000005),0,empty);
  uint64_t pc=p199_rt_u32_scan4(parts,127,UINT64_C(0x80000000),0,empty);
  pc=p199_rt_u32_scan4(parts,127,UINT64_C(0x80000005),UINT64_C(0x80000000),pc);
  uint64_t tc=p199_rt_u32_scan4(truncated,127,5,0,empty);
  if(wc!=pc || memcmp(wide,parts,sizeof(wide)))return 8;
  if(wc==tc && !memcmp(wide,truncated,sizeof(wide)))return 9;
  if(munmap(mem,bytes))return 7;
  printf("{\"kind\":\"summary\",\"originalWorkerFullStateCases\":%" PRIu64 ",\"splitCases\":%" PRIu64 ",\"longMaskCases\":256,\"wideFuel\":4294967301,\"emptyNullHighBits\":true}\n",tested,split);
  return 0;
}
