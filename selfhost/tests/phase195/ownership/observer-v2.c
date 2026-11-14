/* Independent finite semantic/lifetime oracle over the actual pinned runtime.
 * Both compared algorithms are emitted by checked Bend; C builds valid inputs,
 * computes expected values and observes results, aliases and post-root lifetime. */
#define _POSIX_C_SOURCE 200809L
#include "../../../src/runtime/qbe/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifndef P195_COLD
#define P195_COLD 0
#endif
extern uint64_t p118_rt_borrow_fields(P111State*,uint64_t,uint64_t*,uint32_t,uint32_t);
typedef uint64_t (*reader)(P111State*,uint64_t*,uint64_t,uint64_t);
extern uint64_t p195o_base_0(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_48_");
extern uint64_t p195o_base_1(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_49_");
extern uint64_t p195o_base_2(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_50_");
extern uint64_t p195o_base_3(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_51_");
extern uint64_t p195o_base_4(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_52_");
extern uint64_t p195o_base_5(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_53_");
extern uint64_t p195o_base_6(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_54_");
extern uint64_t p195o_base_7(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_55_");
extern uint64_t p195o_base_8(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_98_97_115_101_95_56_");
static reader base[9]={p195o_base_0,p195o_base_1,p195o_base_2,p195o_base_3,p195o_base_4,p195o_base_5,p195o_base_6,p195o_base_7,p195o_base_8};
extern uint64_t p195o_fast_0(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_48_");
extern uint64_t p195o_fast_1(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_49_");
extern uint64_t p195o_fast_2(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_50_");
extern uint64_t p195o_fast_3(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_51_");
extern uint64_t p195o_fast_4(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_52_");
extern uint64_t p195o_fast_5(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_53_");
extern uint64_t p195o_fast_6(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_54_");
extern uint64_t p195o_fast_7(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_55_");
extern uint64_t p195o_fast_8(P111State*,uint64_t*,uint64_t,uint64_t) __asm__("p113d_FID_112_49_57_53_111_95_102_97_115_116_95_56_");
static reader fast[9]={p195o_fast_0,p195o_fast_1,p195o_fast_2,p195o_fast_3,p195o_fast_4,p195o_fast_5,p195o_fast_6,p195o_fast_7,p195o_fast_8};
static unsigned failures,checks;static int bench_role=-1,bench_shared;static unsigned bench_depth=8,bench_reps;
enum{EMPTY=18,LEAF=19,NODE=20,PAYLOAD=21,END=22};
static uint64_t construct(P111State*s,unsigned cid,uint64_t a,uint64_t b,uint64_t c,unsigned n){
 uint64_t words[3]={a,b,c};return p111_rt_ctor(s,cid,words,n);
}
static uint64_t mix(uint64_t a,uint64_t b){return (a^b)*UINT64_C(1099511628211);}
static uint64_t payload_expected(uint64_t key){return mix(mix(7,key*17+11),key*31+13);}
static uint64_t make_payload(P111State*s,uint64_t key){
 uint64_t end=construct(s,END,0,0,0,0);
 uint64_t tail=construct(s,PAYLOAD,key*31+13,end,0,2);
 return construct(s,PAYLOAD,key*17+11,tail,0,2);
}
/* A cold constructor may contain raw owned children while unique. Before a
 * parent is shared, publish each nontrivial child as an RFC owner. keep creates
 * two references; sink releases the temporary second reference, leaving one
 * owned RFC word that replaces the consumed raw word in the parent's field. */
static uint64_t publish_owned(P111State*s,uint64_t owned){
 uint64_t published=p111_rt_keep(s,owned);p111_rt_sink(s,published);return published;
}
static uint64_t make_tree(P111State*s,unsigned depth,uint64_t first,unsigned published){
 if(!depth){uint64_t payload=make_payload(s,first);if(published)payload=publish_owned(s,payload);
  return construct(s,LEAF,first,payload,0,2);}
 uint64_t middle=first+(UINT64_C(1)<<(depth-1));
 uint64_t left=make_tree(s,depth-1,first,published),right=make_tree(s,depth-1,middle,published);
 if(published){left=publish_owned(s,left);right=publish_owned(s,right);}
 return construct(s,NODE,middle,left,right,3);
}
static uint64_t payload_digest(P111State*s,uint64_t word){
 uint64_t f[2],answer=7;
 for(unsigned i=0;i<2;i++){
  if(p111_rt_tag(s,word)!=PAYLOAD){failures++;return UINT64_MAX;}
  p118_rt_borrow_fields(s,word,f,PAYLOAD,2);answer=mix(answer,f[0]);word=f[1];
 }
 if(p111_rt_tag(s,word)!=END)failures++;
 return answer;
}
static uint64_t tree_digest(P111State*s,uint64_t root,unsigned fuel){
 uint64_t f[3];unsigned cid=(unsigned)p111_rt_tag(s,root);
 if(cid==EMPTY)return 37;
 if(cid==LEAF){p118_rt_borrow_fields(s,root,f,LEAF,2);return mix(f[0],payload_digest(s,f[1]));}
 if(cid!=NODE||!fuel){failures++;return UINT64_MAX;}
 p118_rt_borrow_fields(s,root,f,NODE,3);
 return mix(mix(f[0],tree_digest(s,f[1],fuel-1)),tree_digest(s,f[2],fuel-1));
}
/* Independent representation precondition for all genuinely shared roots.
 * This observer refuses to feed an unsealed raw child to shared ctr_take. */
static int published_word(uint64_t word){return (word>>63)||(((word>>56)&127)<=1);}
static int shareable_tree(P111State*s,uint64_t root,unsigned fuel){
 uint64_t f[3];unsigned cid=(unsigned)p111_rt_tag(s,root);
 if(cid==EMPTY)return 1;
 if(cid==LEAF){p118_rt_borrow_fields(s,root,f,LEAF,2);return published_word(f[0])&&published_word(f[1]);}
 if(cid!=NODE||!fuel)return 0;
 p118_rt_borrow_fields(s,root,f,NODE,3);
 return published_word(f[0])&&published_word(f[1])&&published_word(f[2])
  &&shareable_tree(s,f[1],fuel-1)&&shareable_tree(s,f[2],fuel-1);
}
static void churn(P111State*s){
 for(unsigned i=0;i<64;i++){uint64_t t=make_payload(s,10000+i);p111_rt_sink(s,t);}
}
static void one(P111State*s,unsigned role,unsigned depth,unsigned shared,unsigned empty,uint64_t query){
 uint64_t root=empty?construct(s,EMPTY,0,0,0,0):make_tree(s,depth,0,P195_COLD&&shared),alias=0;
 if(shared){if(!shareable_tree(s,root,8)){failures++;p111_rt_sink(s,root);return;}root=p111_rt_keep(s,root);alias=root;}
 uint64_t before=tree_digest(s,root,8),out[4]={0};
 uint64_t status=(role?fast[depth]:base[depth])(s,out,root,query);
 unsigned hit=!empty&&query<(UINT64_C(1)<<depth);
 unsigned route=role&&(!hit||!P195_COLD||shared);
 int ok=status==0&&out[1]==hit&&out[3]==route&&tree_digest(s,out[0],8)==before;
 if(shared)ok=ok&&tree_digest(s,alias,8)==before;
 if(route)ok=ok&&out[0]==root;
 if(!hit)ok=ok&&out[2]==0;
 p111_rt_sink(s,out[0]);if(shared)p111_rt_sink(s,alias);
 churn(s); /* Result must remain owned after both original root aliases die. */
 if(hit){ok=ok&&payload_digest(s,out[2])==payload_expected(query);p111_rt_sink(s,out[2]);}
 checks++;if(!ok){if(failures<5)fprintf(stderr,"role=%u depth=%u shared=%u empty=%u query=%"PRIu64" hit=%"PRIu64" route=%"PRIu64"\n",role,depth,shared,empty,query,out[1],out[3]);failures++;}
}
static uint64_t nanos(void){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return (uint64_t)t.tv_sec*1000000000+(uint64_t)t.tv_nsec;}
static void run_bench(P111State*s){
 uint64_t root=make_tree(s,bench_depth,0,P195_COLD&&bench_shared),alias=0,checksum=0,expected=0,fast_count=0;
 if(bench_shared){if(!shareable_tree(s,root,8)){failures++;p111_rt_sink(s,root);return;}root=p111_rt_keep(s,root);alias=root;}
 uint64_t before=tree_digest(s,root,8),start=nanos();
 for(unsigned i=0;i<bench_reps;i++){
  uint64_t query=((uint64_t)i*17)&((UINT64_C(1)<<bench_depth)-1),out[4];
  uint64_t status=(bench_role?fast[bench_depth]:base[bench_depth])(s,out,root,query);root=out[0];
  uint64_t value=payload_digest(s,out[2]);
  if(status||out[1]!=1||value!=payload_expected(query))failures++;
  checksum=mix(checksum,value);expected=mix(expected,payload_expected(query));fast_count+=out[3];p111_rt_sink(s,out[2]);
 }
 uint64_t elapsed=nanos()-start;
 if(checksum!=expected||tree_digest(s,root,8)!=before||(bench_shared&&tree_digest(s,alias,8)!=before))failures++;
 p111_rt_sink(s,root);if(bench_shared)p111_rt_sink(s,alias);
 printf("phase195 ownership bench: role=%d cold=%d shared=%d depth=%u repetitions=%u checksum=%"PRIu64" fast=%"PRIu64" elapsed_ns=%"PRIu64" failures=%u\n",bench_role,P195_COLD,bench_shared,bench_depth,bench_reps,checksum,fast_count,elapsed,failures);
}
static uint64_t activation_main(P111State*s){uint64_t action=p111_rt_closure(s,1,NULL,0);return p111_rt_return(s,&action,1);}
static uint64_t activation_action(P111State*s){
 uint64_t continuation=p111_rt_reg_get(s,0);
 if(bench_role>=0)run_bench(s);
 else{
  for(unsigned role=0;role<2;role++)for(unsigned d=0;d<=8;d++)for(unsigned shared=0;shared<2;shared++)for(unsigned empty=0;empty<2;empty++){
   uint64_t n=UINT64_C(1)<<d,queries[5]={0,n/2,n-1,n,UINT64_MAX};
   for(unsigned q=0;q<5;q++)one(s,role,d,shared,empty,queries[q]);
  }
  printf("phase195 ownership controls: cold=%d checks=%u failures=%u\n",P195_COLD,checks,failures);
 }
 uint64_t unit=p111_rt_ctor(s,7,NULL,0);return p111_rt_apply(s,continuation,unit);
}
static const P111Segment segments[]={activation_main,activation_action};
static const uint8_t arities[]={0,1},flags[]={0,0},results[]={0,0};
static const char*const names[]={"SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit","None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT","OEmpty","OLeaf","ONode","OPayload","OEnd"};
static const uint8_t cid_arity[]={0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0,0,2,3,2,0};
static const uint8_t cid_hot[]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1};
const P111Program p111_program={.abi_version=P111_ABI_VERSION,.descriptor_bytes=sizeof(P111Program),
 .segment_count=2,.constructor_count=23,.main_fid=0,.main_pure=0,.register_width=4,.result_width=1,
 .capabilities=P111_SEQUENTIAL|(P195_COLD?UINT64_C(8):0),.segments=segments,.fid_arity=arities,.fid_flags=flags,.fid_results=results,
 .cid_arity=cid_arity,.cid_hot=cid_hot,.cid_names=names};
int main(int argc,char**argv){
 if(argc>1){
  if(argc!=6||strcmp(argv[1],"bench")){fprintf(stderr,"usage: program [bench role repetitions depth shared]\n");return 2;}
  bench_role=atoi(argv[2]);bench_reps=(unsigned)strtoul(argv[3],NULL,10);bench_depth=(unsigned)strtoul(argv[4],NULL,10);bench_shared=atoi(argv[5]);
  if(bench_role<0||bench_role>1||bench_reps<1||bench_reps>10000000||bench_depth>8||bench_shared<0||bench_shared>1)return 2;
 }
 int status=p111_rt_main(1,argv,&p111_program);return status?status:(failures?1:0);
}
