/* A separate program interposes at the first genuine constructor so every test
 * has the real initialized runtime and H stack. Positive expectations are a
 * scalar pairwise reference; fallback is checked before the original runs. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
typedef uint64_t W;
#define FLAG(t,c) (((W)(t)<<56)|((W)(c)<<40))
#define MASK ((UINT64_C(1)<<40)-1)
#define RFC (UINT64_C(1)<<63)
extern W __real_p125_rt_ctor2(void*,unsigned,const W*),p125_rt_take2(void*,W,W*);
extern W p198_warp(void*,W,W,W,W,W,W),__real_p198_warp_original(void*,W,W,W,W,W,W);
extern W p111_rt_sink(void*,W),p111_rt_keep(void*,W);
static unsigned active,checks,seen_fallback,watch;
static W before_a,before_b;
static W leaf(unsigned x){return FLAG(1,164)|x;}
static W node(void*s,W l,W r){W t[2]={l,r};return __real_p125_rt_ctor2(s,165,t);}
static void check(int x){if(!x){fprintf(stderr,"failed %u\n",checks);abort();}checks++;}
static W hash(void*s,W t) {
    if ((t & ~MASK)==FLAG(1,164))return (t&MASK)+UINT64_C(0x966493849);
    W *heap=*(W**)s,k=t&MASK;if(t&RFC)k=heap[k]>>24;
    return UINT64_C(81)*hash(s,heap[k])+UINT64_C(913)*hash(s,heap[k+1])+101;
}
W __wrap_p198_warp_original(void*s,W a,W b,W dir,W mode,W depth,W prior){
    if(watch){check(hash(s,a)==before_a);check(hash(s,b)==before_b);seen_fallback++;}
    return __real_p198_warp_original(s,a,b,dir,mode,depth,prior);
}
static W build(void*s,const unsigned *xs,unsigned n) {
    if(n==1)return leaf(*xs);
    W l=build(s,xs,n/2),r=build(s,xs+n/2,n/2);return node(s,l,r);
}
static void inspect(void*s,W t,const unsigned*want,unsigned n) {
    if(n==1){check(t==leaf(*want));return;}
    W p[2];check(p125_rt_take2(s,t,p)==2);
    inspect(s,p[0],want,n/2);inspect(s,p[1],want+n/2,n/2);
}
static W probe(void*s,W a,W b,W dir,unsigned expect_fallback) {
    W sp=((W*)s)[2];before_a=hash(s,a);before_b=hash(s,b);seen_fallback=0;watch=1;
    W out=p198_warp(s,a,b,dir,0,0,0);watch=0;
    check(seen_fallback==expect_fallback);check(((W*)s)[2]==sp);return out;
}
static void tests(void*s) {
    unsigned a[1024],b[1024],lo[1024],hi[1024];
    for(unsigned d=0;d<=10;d++)for(unsigned dir=0;dir<=1;dir++)for(unsigned boxed=0;boxed<=1;boxed++) {
        unsigned n=1u<<d;
        for(unsigned j=0;j<n;j++){
            a[j]=j*1664525u+987654321u;b[j]=j*214013u+2531011u;
            if((j&7)==0)b[j]=a[j];
            if(d==10){a[j]=4000-j;b[j]=j;} // exactly 1024 planned ascending swaps
            unsigned swap=dir^(a[j]>b[j]);lo[j]=swap?b[j]:a[j];hi[j]=swap?a[j]:b[j];
        }
        W left=build(s,a,n),right=build(s,b,n);
        W result=probe(s,left,right,boxed?FLAG(1,dir?2:1):dir,d==10 && dir==0);
        W p[2];check(p125_rt_take2(s,result,p)==2);inspect(s,p[0],lo,n);inspect(s,p[1],hi,n);
    }
    W shared=node(s,leaf(6),leaf(2));shared=p111_rt_keep(s,shared);
    W l=node(s,node(s,leaf(10),leaf(9)),shared);
    W r=node(s,node(s,leaf(1),leaf(0)),node(s,leaf(5),leaf(5)));
    W xy[2];check(p125_rt_take2(s,probe(s,l,r,0,1),xy)==2);
    unsigned x[]={1,0,5,2},y[]={10,9,6,5},old[]={6,2};
    inspect(s,xy[0],x,4);inspect(s,xy[1],y,4);inspect(s,shared,old,2);
    /* A later mismatch occurs after two swaps were proposed in the first half. */
    l=node(s,node(s,leaf(9),leaf(8)),node(s,leaf(7),leaf(6)));
    r=node(s,node(s,leaf(0),leaf(1)),leaf(2));
    check(probe(s,l,r,0,1)==leaf(0));
    W *heap=*(W**)s,k=51413504+70;
    heap[k]=leaf(9);heap[k+1]=leaf(4);
    W stat=FLAG(2,165)|k;
    check(p125_rt_take2(s,probe(s,stat,node(s,leaf(1),leaf(2)),0,1),xy)==2);
    unsigned small[]={1,2},large[]={9,4};inspect(s,xy[0],small,2);inspect(s,xy[1],large,2);
    check(heap[k]==leaf(9));check(heap[k+1]==leaf(4));
    fprintf(stderr,"checks=%u\n",checks);
}
W __wrap_p125_rt_ctor2(void*s,unsigned c,const W*p) {
    if(!active){active=1;tests(s);}return __real_p125_rt_ctor2(s,c,p);
}
