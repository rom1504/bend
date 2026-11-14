#include <stdint.h>
#include <stdio.h>
#define DECL(n) extern uint64_t p194st_##n(uint64_t *,uint64_t);
DECL(0) DECL(1) DECL(2) DECL(3) DECL(4) DECL(5) DECL(6) DECL(7)
extern uint64_t p194str_0(uint64_t *,uint64_t);
extern uint64_t p194str_6(uint64_t *,uint64_t);
int main(void) {
 uint64_t (*f[])(uint64_t *,uint64_t)={p194st_0,p194st_1,p194st_2,p194st_3,p194st_4,p194st_5,p194st_6,p194st_7,p194str_0,p194str_6};
 const uint64_t values[]={0,1,2,31,UINT32_MAX,UINT64_C(1)<<31,UINT64_C(1)<<32,
  (UINT64_C(1)<<32)+1,UINT64_C(1)<<63,(UINT64_C(1)<<63)+1,UINT64_MAX};
 const uint64_t guard=UINT64_C(0x9abc7654fedc3210);
 unsigned checks=0,failures=0;
 for(unsigned worker=0;worker<10;worker++)for(unsigned i=0;i<11;i++)for(unsigned j=0;j<11;j++) {
  unsigned m=worker<8?worker:(worker==8?0:6);
  uint64_t a=values[i],b=values[j],p[]={a,b,guard,guard,guard,guard,guard};
  uint64_t first=m==1?(a<b?b:a):(a<b?a:b);
  uint64_t second=m==0?(a>b?a:b):first;
  uint64_t copy=m==2?(a<b):guard,wide=m==3?(a<b):guard;
  uint64_t result=f[worker](p,a^b);checks++;
  if(result!=(first^second)||p[0]!=a||p[1]!=b||p[2]!=first||p[3]!=second||p[4]!=copy||p[5]!=wide||p[6]!=guard) {
   if(failures++<8)fprintf(stderr,"worker=%u a=%llu b=%llu expected=%llu/%llu got=%llu/%llu\n",worker,
    (unsigned long long)a,(unsigned long long)b,(unsigned long long)first,(unsigned long long)second,
    (unsigned long long)p[2],(unsigned long long)p[3]);
  }
 }
 printf("phase194 predicate stress: checks=%u failures=%u\n",checks,failures);
 return failures!=0;
}
