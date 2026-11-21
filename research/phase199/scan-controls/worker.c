#include "runtime.h"
#include "primitives.h"
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern const P111Program p111_program;
extern uint64_t worker(P111State *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t) __asm__(TEST_WORKER);
extern uint64_t __real_p199_rt_u32_scan4(uint32_t *,uint64_t,uint64_t,uint64_t,uint64_t) __attribute__((weak));
static P111Program descriptor;
static unsigned calls,positive_calls,trials,cells;
static int want_helper,uniform;
static uint64_t expected_mask,expected_n,expected_i,expected_carry;
static uint32_t *expected_data;

static void fail(const char *label,unsigned line) {
  fprintf(stderr,"failed %s at %u, trial %u, fuel %" PRIu64 ", mask %" PRIu64 "\n",label,line,trials,expected_n,expected_mask);
  exit(98);
}
#define CHECK(x) do { if (!(x)) fail(#x,__LINE__); } while(0)

uint64_t __wrap_p199_rt_u32_scan4(uint32_t *data,uint64_t mask,uint64_t n,uint64_t i,uint64_t carry) {
  CHECK(__real_p199_rt_u32_scan4!=NULL);
  CHECK(data==expected_data && mask==expected_mask && n==expected_n);
  CHECK((uint32_t)i==(uint32_t)expected_i && (uint32_t)carry==(uint32_t)expected_carry);
  ++calls;
  return __real_p199_rt_u32_scan4(data,mask,n,i,carry);
}

enum owner { RAW,SHARED,STATIC };
static void one(P111State *state,unsigned cls,enum owner mode,uint64_t fuel,uint64_t start,uint64_t carry) {
  ++trials;
  unsigned cap=1u<<cls;
  const uint64_t mask=UINT64_C(0xffffffffff);
  uint64_t handle;
  if(mode==STATIC) {
    CHECK(!uniform && descriptor.static_words>=(cap+1)/2);
    uint64_t loc=UINT64_C(51413504)+descriptor.static_words-(cap+1)/2;
    handle=(UINT64_C(4)<<56)|((uint64_t)cls<<40)|loc;
  } else {
    uint64_t args[]={cls,0};
    handle=p111_rt_op(state,P111_OP_ARRAY_NEW,args,2);
    CHECK((handle>>56)==(uniform?6u:4u));
  }
  uint32_t expected[256];
  uint64_t loc=handle&mask;
  uint64_t static_backup[128];
  if(mode==STATIC)memcpy(static_backup,state->e.mem+loc,((cap+1)/2)*sizeof(uint64_t));
  expected_data=(uint32_t *)(state->e.mem+loc);
  expected_mask=cap-1;
  expected_n=fuel;expected_i=start;expected_carry=carry;
  for(unsigned j=0;j<cap;j++) {
    expected[j]=UINT32_C(0x9e3779b9)*(j+3) ^ (uint32_t)(j*173+trials);
    uint64_t args[]={handle,j,expected[j]};
    CHECK(p111_rt_op(state,P111_OP_ARRAY_SET,args,3)==handle);
  }
  if(mode==SHARED) {
    handle=p111_rt_keep(state,handle);
    CHECK(handle>>63);
  }
  uint64_t answer=carry;
  uint32_t i=(uint32_t)start;
  for(uint64_t left=fuel;left;left--,i++) {
    unsigned j=i&(cap-1);
    answer=(uint32_t)((uint32_t)answer+expected[j]);
    expected[j]=(uint32_t)answer^i;
  }
  uint64_t out[]={UINT64_C(0x24b09cf320de0011),0,0,UINT64_C(0x7dedee8122334455)};
  unsigned before=calls;
  CHECK(worker(state,out+1,fuel,start,handle,carry)==0);
  CHECK(out[0]==UINT64_C(0x24b09cf320de0011) && out[3]==UINT64_C(0x7dedee8122334455));
  CHECK(out[1]==handle && out[2]==answer);
  if(uniform || mode!=RAW || !want_helper)CHECK(calls==before);
  if(!uniform && mode==RAW && want_helper && cap>=4 && fuel>=8) {
    CHECK(calls==before+1);
    ++positive_calls;
  }
  for(unsigned j=0;j<cap;j++) {
    uint64_t args[]={handle,j},pair[2];
    CHECK(p113_rt_array_pair(state,P111_OP_ARRAY_GET,args,2,pair,2)==0);
    CHECK(pair[0]==handle && pair[1]==expected[j]);
    ++cells;
  }
  if(mode!=STATIC)p111_rt_sink(state,handle);
  if(mode==SHARED)p111_rt_sink(state,handle);
  if(mode==STATIC)memcpy(state->e.mem+loc,static_backup,((cap+1)/2)*sizeof(uint64_t));
}

static uint64_t test_segment(P111State *s) {
  const unsigned cls[]={0,1,2,3,5,7,8};
  const uint64_t starts[]={0,1,3,UINT32_MAX-2,UINT64_C(0xabcdef00ffffffff)};
  for(unsigned c=0;c<sizeof(cls)/sizeof(*cls);c++) {
    uint64_t cap=UINT64_C(1)<<cls[c];
    const uint64_t counts[]={0,1,3,4,5,cap-1,cap,cap+1,cap*3+7};
    for(unsigned i=0;i<sizeof(starts)/sizeof(*starts);i++) {
      for(unsigned j=0;j<sizeof(counts)/sizeof(*counts);j++) {
        one(s,cls[c],RAW,counts[j],starts[i],UINT64_C(0xabcd00fffffffef1)+j);
      }
    }
    one(s,cls[c],SHARED,cap+3,UINT32_MAX-1,UINT32_MAX-5);
    if(!uniform && descriptor.static_words>=(cap+1)/2) {
      one(s,cls[c],STATIC,cap+3,3,UINT32_MAX-5);
    }
  }
  if(want_helper && !uniform)CHECK(positive_calls>0);
  printf("trials %u cells %u helper %u long-raw %u uniform %d\n",trials,cells,calls,positive_calls,uniform);
  exit(0);
}

int __wrap_main(int argc,char **argv) {
  if(argc!=3)return 97;
  want_helper=atoi(argv[1]);uniform=atoi(argv[2]);
  descriptor=p111_program;
  P111Segment *segments=calloc(descriptor.segment_count,sizeof *segments);
  CHECK(segments!=NULL);
  memcpy(segments,descriptor.segments,descriptor.segment_count*sizeof *segments);
  segments[descriptor.main_fid]=test_segment;
  descriptor.segments=segments;descriptor.main_pure=0;
  if(uniform)descriptor.capabilities&=~UINT64_C(2);
  char *runtime[]={"worker-test","+RTS","--threads","1","--gpu","off","-RTS",NULL};
  return p111_rt_main(7,runtime,&descriptor);
}
