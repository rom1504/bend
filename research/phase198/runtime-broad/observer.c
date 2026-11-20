/* Link directly to each production runtime object. All successful cases boot
 * the production scheduler and run this ordinary closed segment with its state. */
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DECL(N) extern uint64_t p125_rt_ctor##N(P111State *,uint32_t,const uint64_t *); \
                extern uint64_t p125_rt_take##N(P111State *,uint64_t,uint64_t *);
DECL(1) DECL(2) DECL(3) DECL(4)
typedef uint64_t (*Ctor)(P111State *,uint32_t,const uint64_t *);
typedef uint64_t (*Take)(P111State *,uint64_t,uint64_t *);
static Ctor constructors[] = {NULL,p125_rt_ctor1,p125_rt_ctor2,p125_rt_ctor3,p125_rt_ctor4};
static Take take[] = {NULL,p125_rt_take1,p125_rt_take2,p125_rt_take3,p125_rt_take4};
static const char *core[] = {"SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit","None",
                            "Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"};
static const char *names[65536], *mode;
static uint8_t arity[65536],hot[65536];
static uint64_t image[260];
static uint8_t fid[1];
static P111Program descriptor;
static unsigned checks;
#define CHECK(e) do { if (!(e)) { fprintf(stderr,"line %d: %s\n",__LINE__,#e);exit(99); } ++checks; } while(0)
#define TERM(tag,cid,loc) (((uint64_t)(tag)<<56)|((uint64_t)(cid)<<40)|(uint64_t)(loc))
#define LOC_MASK UINT64_C(0xffffffffff)
static uint64_t segment(P111State *s) {
  uint64_t fields[4]={13,21,34,55},out[4]={0};
  uint32_t top=(uint32_t)descriptor.constructor_count-1;
  if (!strcmp(mode,"owner-hot") || !strcmp(mode,"owner-cap")) {
    uint64_t child=constructors[1](s,18,fields);
    if (!strcmp(mode,"owner-hot")) hot[22]=1;
    else descriptor.capabilities=1;
    uint64_t parent=constructors[1](s,22,&child);
    CHECK(take[1](s,parent,out)==1);
    unsigned sealed=(unsigned)(out[0]>>63);
    CHECK(take[1](s,out[0],out)==1 && out[0]==13);
    printf("sealed %u field 13\n",sealed);
    exit(0);
  }
  if (!strcmp(mode,"rebind")) {
    char *argv[]={"again",NULL};
    return p111_rt_main(1,argv,&descriptor);
  }
  if (!strcmp(mode,"bad-take-id")) return take[1](s,TERM(2,65535,0),out);
  if (!strcmp(mode,"bad-arity")) return take[1](s,TERM(2,19,0),out);
  if (!strcmp(mode,"max-arity")) return take[1](s,TERM(2,top,0),out);
  if (!strcmp(mode,"bad-owner")) return take[1](s,TERM(3,18,0),out);
  if (!strcmp(mode,"bad-checked-ctor")) return p111_rt_ctor(s,top+1,fields,1);
  for(unsigned n=1;n<=4;n++) {
    unsigned cid=17+n;
    uint64_t first=constructors[n](s,cid,fields);
    CHECK((first>>56)==2 && ((first>>40)&65535)==cid);
    CHECK(take[n](s,first,out)==n && !memcmp(out,fields,n*sizeof(*out)));
    uint64_t next=constructors[n](s,cid,fields);
    CHECK(first==next);
    uint64_t shared=p111_rt_keep(s,next);
    CHECK(shared>>63);
    CHECK(take[n](s,shared,out)==n && !memcmp(out,fields,n*sizeof(*out)));
    CHECK(take[n](s,shared,out)==n && !memcmp(out,fields,n*sizeof(*out)));
  }
  for (unsigned is_hot=0;is_hot<2;is_hot++) {
    uint64_t kid=constructors[1](s,18,fields);
    unsigned parent=22+is_hot;
    uint64_t box=constructors[1](s,parent,&kid);
    CHECK(take[1](s,box,out)==1);
    CHECK((out[0]>>63)==(is_hot || !(descriptor.capabilities&8)));
    CHECK(take[1](s,out[0],out)==1 && out[0]==13);
  }
  CHECK(take[1](s,TERM(1,top,LOC_MASK),out)==1 && out[0]==LOC_MASK);
  CHECK(take[1](s,TERM(129,top,17),out)==1 && out[0]==17);
  uint64_t highest=constructors[1](s,top,fields);
  CHECK(take[1](s,highest,out)==1 && out[0]==13);
  if(descriptor.static_words>=4) {
    uint64_t at=UINT64_C(51413504)+descriptor.static_words-4;
    uint64_t static_term=TERM(2,21,at);
    CHECK(take[4](s,static_term,out)==4 && !memcmp(out,image+descriptor.static_words-4,4*sizeof(*out)));
    CHECK(take[4](s,static_term,out)==4 && !memcmp(out,image+descriptor.static_words-4,4*sizeof(*out)));
  }
  printf("checks %u\n", checks);
  exit(0);
}
int main(int argc,char **argv) {
  if(argc!=5) return 98;
  mode=argv[1];
  static P111Segment segments[]={segment};
  for(unsigned i=0;i<65536;i++) names[i]= i<18 ? core[i] : "TestConstructor";
  for(unsigned i=0;i<260;i++) image[i]=100+i;
  for(unsigned i=18;i<=21;i++) arity[i]=i-17;
  arity[22]=arity[23]=1;hot[23]=1;
  unsigned count=atoi(argv[3]); if(count>65536 || count<25)return 98;
  arity[count-1]=!strcmp(mode,"max-arity")?255:1;
  descriptor=(P111Program){.abi_version=P111_ABI_VERSION,.descriptor_bytes=sizeof(P111Program),.segment_count=1,
    .constructor_count=count,.register_width=2,.result_width=1,.capabilities=strtoul(argv[2],NULL,10),
    .static_words=strtoul(argv[4],NULL,10),.static_image=image,.segments=segments,.fid_arity=fid,
    .fid_flags=fid,.fid_results=fid,.cid_arity=arity,.cid_hot=hot,.cid_names=names};
  if(!strcmp(mode,"zero-count"))descriptor.constructor_count=0;
  if(!strcmp(mode,"over-count"))descriptor.constructor_count=65537;
  if(!strcmp(mode,"bad-hot"))hot[count-1]=2;
  if(!strcmp(mode,"bad-name"))names[count-1]="";
  if(!strcmp(mode,"no-arity"))descriptor.cid_arity=NULL;
  if(!strcmp(mode,"no-static"))descriptor.static_image=NULL;
  if(!strcmp(mode,"bad-abi"))descriptor.abi_version++;
  if(!strcmp(mode,"bad-size"))descriptor.descriptor_bytes--;
  if(!strcmp(mode,"bad-core"))names[0]="Absent";
  char *rts[]={"probe","+RTS","--threads","1","--gpu","off","-RTS",NULL};
  if(!strcmp(mode,"two-threads"))rts[3]="2";
  if(!strcmp(mode,"gpu-on"))rts[5]="on";
  return p111_rt_main(7,rts,&descriptor);
}
