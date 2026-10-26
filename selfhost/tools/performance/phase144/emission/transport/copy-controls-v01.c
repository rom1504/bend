/* Actual candidate helper, independent byte-snapshot oracle. All tests stay in
 * one thread. Byte-offset aliases extend beyond the admitted compiler's aligned
 * buffers to check the underlying x86-64 memmove contract conservatively. */
#include "runtime.c"
#include <sys/mman.h>

static P111Program control_program;
static unsigned observations;

static int check_copy(u32 width, u64 caps, u32 count, int source_kind, int offset) {
  P111State state;
  unsigned char expected[sizeof state], captured[P111_REG_CAP * 8];
  unsigned char external[P111_REG_CAP * 8 + 8];
  for (size_t i=0;i<sizeof state;i++) ((unsigned char *)&state)[i]=(unsigned char)(i*37+11);
  for (size_t i=0;i<sizeof external;i++) external[i]=(unsigned char)(i*19+91);
  memcpy(expected,&state,sizeof state);
  const unsigned char *values=source_kind==0?external+offset:
    source_kind==1?(const unsigned char *)&state+offsetof(P111State,regs)+offset:NULL;
  /* Snapshot precedes the actual call and every reference write. */
  if(count) memcpy(captured,values,count*8);
  for(u32 i=0;i<count*8;i++)expected[offsetof(P111State,regs)+i]=captured[i];
  if(!(caps&4))for(u32 i=count*8;i<width*8;i++)expected[offsetof(P111State,regs)+i]=0;
  control_program.capabilities=caps;p111_program_active=&control_program;p111_transport_words=width;
  p111_set_regs(&state,(const uint64_t *)(const void *)values,count);
  if(memcmp(&state,expected,sizeof state)!=0){
    fprintf(stderr,"copy mismatch width=%u caps=%llu count=%u kind=%d offset=%d\n",width,(unsigned long long)caps,count,source_kind,offset);return 2;
  }
  ++observations;return 0;
}

static int controls(void) {
  const u32 widths[]={2,26,256};const int offsets[]={-16,-8,-1,0,1,8,16};
  for(unsigned w=0;w<3;w++)for(u64 caps=1;caps<=5;caps+=4){
    if(check_copy(widths[w],caps,0,2,0))return 2;
    for(u32 count=0;count<=widths[w];count++){
      for(int b=0;b<8;b++)if(check_copy(widths[w],caps,count,0,b))return 2;
      for(unsigned k=0;k<7;k++){
        const int start=(int)offsetof(P111State,regs)+offsets[k];
        if(start>=0 && (size_t)start+count*8<=sizeof(P111State))
          if(check_copy(widths[w],caps,count,1,offsets[k]))return 2;
      }
    }
  }
  /* Exact read extent: source ends immediately before an inaccessible page. */
  long size=sysconf(_SC_PAGESIZE);if(size<4096)return 2;
  unsigned char *pages=mmap(NULL,(size_t)size*2,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(pages==MAP_FAILED || mprotect(pages+size,(size_t)size,PROT_NONE)!=0)return 2;
  for(u64 caps=1;caps<=5;caps+=4)for(u32 count=1;count<=3;count++){
    P111State state;memset(&state,0xa5,sizeof state);
    uint64_t expected[3]={13,17,19};unsigned char *src=pages+size-count*8;
    memcpy(src,expected,count*8);control_program.capabilities=caps;p111_program_active=&control_program;p111_transport_words=26;
    p111_set_regs(&state,(const uint64_t *)(const void *)src,count);
    if(memcmp(state.regs,expected,count*8)!=0)return 2;
    for(u32 i=count;i<26;i++)if(state.regs[i]!=(caps&4?UINT64_C(0xa5a5a5a5a5a5a5a5):0))return 2;
    ++observations;
  }
  if(munmap(pages,(size_t)size*2)!=0)return 2;
  printf("p144 small copies: %u PASS\n",observations);return 0;
}
int main(int argc,char **argv){
  if(argc!=2)return 2;
  if(strcmp(argv[1],"copy")==0)return controls();
  P111State state={0};uint64_t source[3]={11,22,33};
  control_program.capabilities=5;p111_program_active=&control_program;p111_transport_words=2;
  if(strcmp(argv[1],"null1")==0)p111_set_regs(&state,NULL,1);
  else if(strcmp(argv[1],"null2")==0)p111_set_regs(&state,NULL,2);
  else if(strcmp(argv[1],"wide")==0)p111_set_regs(&state,source,3);
  else if(strcmp(argv[1],"pool")==0)pool_open();
  else return 2;
  fputs("refusal unexpectedly returned\n",stderr);return 2;
}
