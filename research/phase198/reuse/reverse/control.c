#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
typedef uint64_t W;
enum { NIL=17,CON=18 };
#define EMPTY ((UINT64_C(1)<<56)|((W)NIL<<40))
#define RAW ((UINT64_C(2)<<56)|((W)CON<<40))
#define LOC ((UINT64_C(1)<<40)-1)
#define RFC (UINT64_C(1)<<63)
static unsigned active, checks;
extern W p198_reverse(void *,W,W),p111_rt_keep(void *,W),p111_rt_sink(void *,W),p125_rt_take2(void *,W,W *);
extern W __real_p125_rt_ctor2(void *,unsigned,const W *);
static W cell(void *s,W a,W b){W pair[2]={a,b};return __real_p125_rt_ctor2(s,CON,pair);}
static void check(unsigned v){if(!v){fprintf(stderr,"failure=%u\n",checks);abort();}++checks;}
static void sequence(void *s,W v,const W *want,unsigned n){
    for(unsigned i=0;i<n;i++){W p[2];check(p125_rt_take2(s,v,p)==2);check(p[0]==want[i]);v=p[1];}
    check(v==EMPTY);
}
static W list(void *s,unsigned n){W t=EMPTY;while(n)t=cell(s,(W)n--,t);return t;}
static void verify(void *s){
    W want[32],original[32];
    for(unsigned n=0;n<=20;n++){
        for(unsigned i=0;i<n;i++){want[i]=n-i;original[i]=i+1;}
        W src=list(s,n);
        sequence(s,p198_reverse(s,src,EMPTY),want,n);
        if(n){
            src=p111_rt_keep(s,list(s,n));
            W result=p198_reverse(s,src,EMPTY);
            sequence(s,result,want,n);
            sequence(s,src,original,n);
            src=p111_rt_keep(s,list(s,n));p111_rt_sink(s,src);
            sequence(s,p198_reverse(s,src,EMPTY),want,n);
        }
        W acc=cell(s,99,EMPTY);
        want[n]=99;
        sequence(s,p198_reverse(s,list(s,n),acc),want,n+1);
    }
    /* Check the same count-one wrapper now protects the previous input root. */
    W *words=*(W**)s;
    W two=cell(s,42,cell(s,24,EMPTY)),first=two&LOC;
    W old_link=words[first+1],credit=old_link&LOC;
    check((old_link&~LOC)==(RAW|RFC));check((words[credit]&0xffffff)==1);
    W second=words[credit]>>24;
    W rotated=p198_reverse(s,two,EMPTY);
    check(rotated==(RAW|second));check(words[first]==42);check(words[first+1]==EMPTY);
    check(words[second]==24);check(words[second+1]==old_link);check(words[credit]==(first<<24|1));
    W reverse_pair[]={24,42};sequence(s,rotated,reverse_pair,2);
    /* A live alias of the last two nodes forces a mid-spine fallback after
     * two candidate prefix operations. Consuming the result leaves it valid. */
    W tail=cell(s,3,cell(s,4,EMPTY));tail=p111_rt_keep(s,tail);
    W root=cell(s,1,cell(s,2,tail));W result=p198_reverse(s,root,EMPTY);
    W a[]={4,3,2,1},b[]={3,4};sequence(s,result,a,4);sequence(s,tail,b,2);
    /* A source static cell resides in padding past the original 52 words. */
    W *heap=*(W **)s;const W st=51413504+72;
    heap[st]=7;heap[st+1]=EMPTY;
    W static_node=RAW|st;
    W c[]={7};sequence(s,p198_reverse(s,static_node,EMPTY),c,1);
    check(heap[st]==7);check(heap[st+1]==EMPTY);
    /* The first dynamic cell references a static tail through an RFC. */
    W d[]={7,9};sequence(s,p198_reverse(s,cell(s,9,static_node),EMPTY),d,2);
    check(heap[st]==7);check(heap[st+1]==EMPTY);
    /* Heads themselves can be shared aggregate owners. Both the moved head
     * and a held original alias survive destruction of the containing list. */
    W h=cell(s,17,cell(s,19,EMPTY));h=p111_rt_keep(s,h);
    W z=cell(s,2,cell(s,h,EMPTY));W cells[2];
    check(p125_rt_take2(s,p198_reverse(s,z,EMPTY),cells)==2);
    W heads[]={17,19};sequence(s,cells[0],heads,2);W last[]={2};sequence(s,cells[1],last,1);
    sequence(s,h,heads,2);
    /* Exercise the RLE fixture's concrete pair head KType as well. */
    W pa[2]={3,7},pb[2]={1,2};
    W ca=p111_rt_keep(s,__real_p125_rt_ctor2(s,8,pa)),cb=__real_p125_rt_ctor2(s,8,pb);
    W packed=cell(s,ca,cell(s,cb,EMPTY));W typed=p198_reverse(s,packed,EMPTY),e[2],v[2];
    check(p125_rt_take2(s,typed,e)==2);check(p125_rt_take2(s,e[0],v)==2);check(v[0]==1&&v[1]==2);
    check(p125_rt_take2(s,e[1],e)==2);check(p125_rt_take2(s,e[0],v)==2);check(v[0]==3&&v[1]==7);check(e[1]==EMPTY);
    check(p125_rt_take2(s,ca,v)==2);check(v[0]==3&&v[1]==7);
    fprintf(stderr,"checks=%u\n",checks);
}
W __wrap_p125_rt_ctor2(void *s,unsigned cid,const W *fields){
    if(!active){active=1;verify(s);}return __real_p125_rt_ctor2(s,cid,fields);
}
