#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <inttypes.h>
extern uint64_t row(uint64_t *,uint64_t *,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)
  __asm__("p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_");
static uint64_t handle(unsigned word_offset) {
  return UINT64_C(0x0400040000000000) | (UINT64_C(51413632) + word_offset);
}
static uint32_t minimum(uint32_t a,uint32_t b) { return a<b?a:b; }
int main(void) {
  const unsigned counts[]={0,1,2,7,16,33};
  const uint64_t indices[]={0,1,15,UINT64_C(0xffffffff),UINT64_C(0x100000000),UINT64_MAX};
  const uint64_t chars[]={0,1,UINT64_C(0xffffffff),UINT64_C(0x100000001)};
  unsigned checks=0,failures=0;
  for(unsigned layout=0;layout<4;layout++) for(unsigned n=0;n<6;n++)
    for(unsigned j=0;j<6;j++) for(unsigned c=0;c<4;c++) {
      uint32_t actual[64],expected[64];
      for(unsigned k=0;k<64;k++) actual[k]=(k*UINT32_C(0x9e3779b1))^(n*UINT32_C(0xffffffff))^(j*17);
      memcpy(expected,actual,sizeof actual);
      unsigned text=0,previous=16,current=32;
      if(layout==1) current=previous;
      if(layout==2) current=text;
      if(layout==3) previous=current=text;
      uint64_t cursor=indices[j];
      for(unsigned step=0;step<counts[n];step++) {
        uint32_t next=(uint32_t)cursor+1;
        uint32_t cost=(uint32_t)chars[c]!=expected[text+(cursor&15)];
        uint32_t diagonal=expected[previous+(cursor&15)];
        uint32_t above=expected[previous+(next&15)];
        uint32_t left=expected[current+(cursor&15)];
        expected[current+(next&15)]=minimum(minimum(above+1,left+1),diagonal+cost);
        cursor=next;
      }
      uint64_t state[1]={(uintptr_t)actual-UINT64_C(51413632)*8};
      uint64_t output[4]={0,0,0,0},token=UINT64_C(0x123456789abcdef0);
      uint64_t text_handle=handle(text/2),previous_handle=handle(previous/2),current_handle=handle(current/2);
      uint64_t result=row(state,output,counts[n],indices[j],chars[c],token,text_handle,previous_handle,current_handle);
      unsigned wrong=result!=0 || memcmp(actual,expected,sizeof actual)!=0 ||
        output[0]!=token || output[1]!=text_handle || output[2]!=current_handle || output[3]!=previous_handle;
      checks++; failures+=wrong;
      if(wrong && failures<=4) fprintf(stderr,"layout=%u n=%u j=%"PRIu64" char=%"PRIu64"\n",layout,counts[n],indices[j],chars[c]);
    }
  /* Entry with zero iterations must not touch any array cell. */
  long page_size=sysconf(_SC_PAGESIZE);
  if(page_size<=0) return 2;
  void *page=mmap(0,(size_t)page_size,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(page==MAP_FAILED) return 2;
  uint64_t state[1]={(uintptr_t)page-UINT64_C(51413632)*8},output[4]={0,0,0,0};
  uint64_t result=row(state,output,0,UINT64_MAX,0,17,handle(0),handle(0),handle(0));
  checks++;failures+=result!=0 || output[0]!=17 || output[1]!=handle(0) || output[2]!=handle(0) || output[3]!=handle(0);
  if(munmap(page,(size_t)page_size)) return 2;
  printf("phase195 loop carry observer: checks=%u failures=%u\n",checks,failures);
  return failures!=0;
}
