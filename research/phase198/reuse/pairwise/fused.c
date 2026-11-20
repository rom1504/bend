#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
typedef uint64_t W;
#define FLAG(t,c) (((W)(t)<<56)|((W)(c)<<40))
#define NODE FLAG(2,165)
#define LEAF FLAG(1,164)
#define MASK ((UINT64_C(1)<<40)-1)
#define DYNAMIC UINT64_C(51413632)
#define MAX_STACK 64
#define MAX_CHANGES 512
#define MAX_LEAVES 1024
extern W p198_warp_original(void *,W,W,W,W,W,W);
extern W p125_rt_ctor2(void *,unsigned,const W *);
struct pair { W *a,*b; };
#ifdef P198_EVENTS
static W event[5];
#define HIT(i,n) (event[i]+=(n))
__attribute__((destructor)) static void report(void){
    fprintf(stderr,"counts %" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 "\n",event[0],event[1],event[2],event[3],event[4]);
}
#else
#define HIT(i,n) ((void)0)
#endif
W p198_warp(void *state,W left,W right,W dir,W mode,W depth,W prior){
    HIT(0,1);
    if(mode||depth||prior) goto miss;
    unsigned desc;
    if(dir==0 || dir==FLAG(1,1)) desc=0;
    else if(dir==1 || dir==FLAG(1,2)) desc=1;
    else goto miss;
    W roots[2]={left,right};
    W *heap=*(W **)state;
    struct pair todo[MAX_STACK],changed[MAX_CHANGES];
    unsigned sp=1,work=0,swaps=0;
    todo[0]=(struct pair){roots,roots+1};
    while(sp){
        struct pair p=todo[--sp];
        W a=*p.a,b=*p.b;
        if((a&~MASK)==LEAF && (b&~MASK)==LEAF){
            if ((a&MASK)>UINT32_MAX || (b&MASK)>UINT32_MAX || ++work>MAX_LEAVES) goto miss;
            if (a!=b && (desc ^ ((uint32_t)a>(uint32_t)b))){
                if(swaps==MAX_CHANGES)goto miss;
                changed[swaps++]=p;
            }
        }else{
            W x=a&MASK,y=b&MASK;
            if((a&~MASK)!=NODE || (b&~MASK)!=NODE || x<DYNAMIC || y<DYNAMIC || x==y || sp+2>MAX_STACK)goto miss;
            todo[sp++]=(struct pair){heap+x+1,heap+y+1};
            todo[sp++]=(struct pair){heap+x,heap+y};
        }
    }
    for(unsigned j=0;j<swaps;j++){
        W a=*changed[j].a;*changed[j].a=*changed[j].b;*changed[j].b=a;
    }
    HIT(1,1);HIT(2,work);HIT(3,swaps);
    return p125_rt_ctor2(state,165,roots);
miss:
    HIT(4,1);return p198_warp_original(state,left,right,dir,mode,depth,prior);
}
