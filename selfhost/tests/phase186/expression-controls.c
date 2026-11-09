/* Independent finite arithmetic/state oracle for the checked expression
 * fixtures. Unsigned C arithmetic supplies modulo-2^64/2^32 labels; signed
 * order is defined by sign-bit flipping, avoiding implementation-defined casts.
 * The isolated call stub tests ABI clobbers and exact arguments, not sqrt. */
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

typedef uint64_t (*Expression)(void *,uint64_t *,uint64_t,uint64_t);
#define DECLARE(L,N) extern uint64_t expr_##L(void *,uint64_t *,uint64_t,uint64_t) __asm__("p113d_FID_112_49_56_54_101_" #N "_")
DECLARE(a,97); DECLARE(b,98); DECLARE(c,99); DECLARE(d,100);
DECLARE(e,101); DECLARE(f,102); DECLARE(g,103); DECLARE(h,104);
DECLARE(i,105); DECLARE(j,106); DECLARE(k,107); DECLARE(l,108);
DECLARE(n,110); DECLARE(o,111);
extern uint64_t expr_m(void *) __asm__("p111_FID_112_49_56_54_101_109_");
#define MAGIC UINT64_C(0xfedcba9876543210)
#define SIGN UINT64_C(0x8000000000000000)
#define CANARY UINT64_C(0x6ab913f0d5278ce4)
static void *expected_state;
static uint64_t expected_arg;
static unsigned calls,bad_call;
uint64_t p111_rt_op(void *state,uint32_t op,const uint64_t *args,uint32_t count) {
  ++calls;
  if(state!=expected_state || op!=36 || count!=1 || !args || args[0]!=expected_arg)bad_call=1;
  __asm__ volatile("xorq %%rdi,%%rdi\n\txorq %%rsi,%%rsi\n\txorq %%rdx,%%rdx\n\t"
                   "xorq %%rcx,%%rcx\n\txorq %%r8,%%r8\n\txorq %%r9,%%r9\n\t"
                   "xorq %%r10,%%r10\n\txorq %%r11,%%r11"
                   : : : "rdi","rsi","rdx","rcx","r8","r9","r10","r11","cc","memory");
  return MAGIC;
}
static void expected(unsigned f,uint64_t a,uint64_t b,uint64_t out[4]) {
  uint64_t sum=a+b, low=(uint32_t)a;
  switch(f) {
    case 0: out[0]=sum;out[1]=sum;out[2]=a*b;out[3]=a*b;break;
    case 1: out[0]=sum;out[1]=sum+1;out[2]=a+1;out[3]=b;break;
    case 2: out[0]=b;out[1]=sum;out[2]=a;out[3]=b;break;
    case 3: out[0]=a;out[1]=b;out[2]=a+1;out[3]=b+1;break;
    case 4: out[0]=a+2;out[1]=a+1;out[2]=a+1;out[3]=a;break;
    case 5: out[0]=low;out[1]=low;out[2]=low*4;out[3]=low*4;break;
    case 6: out[0]=a==b;out[1]=a==b;out[2]=(a^SIGN)<(b^SIGN);out[3]=out[2];break;
    case 7: out[0]=a<<(b&63);out[1]=out[0];out[2]=a>>(b&63);out[3]=out[2];break;
    case 8: out[0]=sum;out[1]=sum;out[2]=sum;out[3]=a;break;
    case 9: out[0]=sum;out[1]=sum;out[2]=MAGIC;out[3]=a;break;
    case 10: out[0]=sum;out[1]=sum;out[2]=a;out[3]=b;break;
    case 11: out[0]=(uint32_t)((uint32_t)a+(uint32_t)b);out[1]=out[0];
      out[2]=(uint32_t)((uint32_t)a<<((uint32_t)b&31));out[3]=out[2];break;
    case 12: out[0]=sum;out[1]=sum;out[2]=b;out[3]=a;break;
    default: out[0]=sum;out[1]=sum;out[2]=a;out[3]=b;break;
  }
}
int main(void) {
  const Expression functions[14]={expr_a,expr_b,expr_c,expr_d,expr_e,expr_f,expr_g,expr_h,expr_i,expr_j,expr_k,expr_l,expr_n,expr_o};
  const char *names[14]={"a","b","c","d","e","f","g","h","i","j","k","l","n","o"};
  const uint64_t words[12]={0,1,31,32,63,64,65,UINT64_C(0xffffffff),UINT64_C(0x100000000),SIGN,UINT64_MAX,UINT64_C(0xdeadbeef01234567)};
  uint64_t state[261],before[261],out[8],want[4];unsigned observations=0;
  for(unsigned k=0;k<261;++k)state[k]=CANARY+k;
  expected_state=state;
  for(unsigned i=0;i<12;++i)for(unsigned j=0;j<12;++j) {
    uint64_t a=words[i],b=words[j];
    for(unsigned f=0;f<14;++f) {
      for(unsigned k=0;k<8;++k)out[k]=CANARY;
      memcpy(before,state,sizeof(state));expected(f,a,b,want);expected_arg=a;calls=0;bad_call=0;
      uint64_t status=functions[f](state,out+2,a,b);
      if(status || memcmp(out+2,want,sizeof(want)) || out[0]!=CANARY || out[1]!=CANARY || out[6]!=CANARY || out[7]!=CANARY ||
         memcmp(state,before,sizeof(state)) || bad_call || calls!=(f==9)) {
        fprintf(stderr,"expression%s a=%016" PRIx64 " b=%016" PRIx64 " status=%016" PRIx64 " calls=%u\n",names[f],a,b,status,calls);
        for(unsigned k=0;k<4;++k)fprintf(stderr,"word%u got=%016" PRIx64 " expected=%016" PRIx64 "\n",k,out[k+2],want[k]);
        return 1;
      }
      ++observations;
    }
    state[0]=a;state[1]=b;memcpy(before,state,sizeof(state));calls=0;bad_call=0;
    if(expr_m(state)!=a || memcmp(state,before,sizeof(state)) || calls || bad_call)return 2;
    ++observations;
  }
  printf("phase186 expression controls pass: %u\n",observations);
  return 0;
}
