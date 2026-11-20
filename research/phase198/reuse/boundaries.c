/* Linked only into a separate correctness executable. Ordinary benchmark creates
 * the real bound runtime state. Tests call the modified worker on fresh values. */
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
typedef uint64_t W;
extern W p198_subject(void *,W,W);
extern W p198_transpose_counts[2];
extern W p125_rt_ctor2(void *,unsigned,const W *),p125_rt_take2(void *,W,W *);
extern W p111_rt_sink(void *,W),p111_rt_keep(void *,W);
static int exercised;
static unsigned checks;
static W leaf(unsigned v) { return (UINT64_C(1)<<56)|(UINT64_C(164)<<40)|v; }
static W node(void *s,W a,W b) { W p[2]={a,b}; return p125_rt_ctor2(s,165,p); }
static void check(int yes) { if (!yes) { fprintf(stderr,"check %u failed\n",checks); abort(); } checks++; }
static void consume_pair(void *s,W t,W a,W b) {
    W p[2]={0}; check(p125_rt_take2(s,t,p)==2); check(p[0]==a); check(p[1]==b);
}
enum shape { RAW, SHARED, RFC1, STATIC };
static W make(void *s,enum shape k,unsigned v,W *alias) {
    W p=leaf(v),q=leaf(v+1);
    if (k==STATIC) {
        /* Program declares 38 static words, page-rounded to 128. Two disjoint
         * words per test occupy the unused zero-filled padding, within the
         * valid static corpus. The original static image remains intact. */
        W loc=51413504+64+v;
        W *heap=*(W **)s; heap[loc]=p; heap[loc+1]=q;
        return (UINT64_C(2)<<56)|(UINT64_C(165)<<40)|loc;
    }
    W t=node(s,p,q);
    if (k==SHARED || k==RFC1) {
        t=p111_rt_keep(s,t);
        if (k==SHARED) *alias=t;
        else p111_rt_sink(s,t);
    }
    return t;
}
W p198_controls(void *s,W wa,W wb) {
    if (!exercised) {
        exercised=1;
        for (unsigned i=0;i<4;i++) for (unsigned j=0;j<4;j++) {
            W la=0,ra=0,l=make(s,i,1,&la),r=make(s,j,4,&ra),out[2];
            W before=p198_transpose_counts[1];
            W t=p198_subject(s,l,r);
            check(p198_transpose_counts[1]-before==(i==RAW && j==RAW));
            check(p125_rt_take2(s,t,out)==2);
            if (i==RAW && j==RAW) { check(out[0]==l); check(out[1]==r); }
            consume_pair(s,out[0],leaf(1),leaf(4));
            consume_pair(s,out[1],leaf(2),leaf(5));
            if (la) consume_pair(s,la,leaf(1),leaf(2));
            if (ra) consume_pair(s,ra,leaf(4),leaf(5));
            if (i==STATIC) consume_pair(s,l,leaf(1),leaf(2));
            if (j==STATIC) consume_pair(s,r,leaf(4),leaf(5));
        }
        W shared=node(s,leaf(5),leaf(6));
        shared=p111_rt_keep(s,shared);
        W out[2], t=p198_subject(s,shared,shared);
        check(p125_rt_take2(s,t,out)==2);
        consume_pair(s,out[0],leaf(5),leaf(5)); consume_pair(s,out[1],leaf(6),leaf(6));
        W mixed=p198_transpose_counts[1];
        check(p198_subject(s,leaf(1),node(s,leaf(2),leaf(3)))==leaf(0));
        check(p198_subject(s,node(s,leaf(1),leaf(2)),leaf(3))==leaf(0));
        check(p198_subject(s,leaf(1),leaf(2))==leaf(0));
        check(p198_transpose_counts[1]==mixed);
        /* Affine heap children move to different parents and remain valid
         * after consuming both newly oriented parents. */
        W child=node(s,leaf(7),leaf(8)), child2=node(s,leaf(9),leaf(10));
        W a=node(s,leaf(1),child),b=node(s,child2,leaf(4));
        t=p198_subject(s,a,b); check(p125_rt_take2(s,t,out)==2);
        consume_pair(s,out[0],leaf(1),child2); consume_pair(s,out[1],child,leaf(4));
        consume_pair(s,child,leaf(7),leaf(8)); consume_pair(s,child2,leaf(9),leaf(10));
        fprintf(stderr,"boundaries=%u\n",checks);
    }
    return p198_subject(s,wa,wb);
}
