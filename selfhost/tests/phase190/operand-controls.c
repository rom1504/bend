/* Independent modular arithmetic/bit-pattern oracle; no signed overflow or
 * implementation-defined arithmetic right shifts. High U32 input halves are
 * deliberately nonzero to test each result's zero extension. */
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
typedef uint64_t (*Operation)(uint64_t *);
#define OPS(M,W) M(W,add) M(W,sub) M(W,mul) M(W,and) M(W,or) M(W,xor) \
  M(W,shl) M(W,shr) M(W,sar) M(W,eq) M(W,ne) M(W,ult) M(W,ule) \
  M(W,ugt) M(W,uge) M(W,slt) M(W,sle) M(W,sgt) M(W,sge)
#define DECL(W,O) extern uint64_t p190o_##W##_##O##_0(uint64_t *), \
  p190o_##W##_##O##_1(uint64_t *),p190o_##W##_##O##_2(uint64_t *),p190o_##W##_##O##_3(uint64_t *);
OPS(DECL,32) OPS(DECL,64)
#define ROW(W,O) {p190o_##W##_##O##_0,p190o_##W##_##O##_1,p190o_##W##_##O##_2,p190o_##W##_##O##_3},
extern uint64_t p190o_load_32(uint64_t *),p190o_load_64(uint64_t *);
extern uint64_t p190o_store_32(uint64_t *),p190o_store_64(uint64_t *);
extern uint64_t p190o_store_same_32(uint64_t *),p190o_store_same_64(uint64_t *);

static uint64_t reference(unsigned op,uint64_t a,uint64_t b,unsigned width) {
  uint64_t mask=width==32?UINT32_MAX:UINT64_MAX;
  uint64_t sign=UINT64_C(1)<<(width-1),result;
  a&=mask;b&=mask;
  unsigned shift=(unsigned)(b&(width-1));
  switch(op) {
    case 0:result=a+b;break; case 1:result=a-b;break;
    case 2:result=a*b;break; case 3:result=a&b;break;
    case 4:result=a|b;break; case 5:result=a^b;break;
    case 6:result=a<<shift;break; case 7:result=a>>shift;break;
    case 8:result=a>>shift;if(shift && (a&sign))result|=mask^(mask>>shift);break;
    case 9:return a==b;case 10:return a!=b;case 11:return a<b;
    case 12:return a<=b;case 13:return a>b;case 14:return a>=b;
    case 15:return (a^sign)<(b^sign);case 16:return (a^sign)<=(b^sign);
    case 17:return (a^sign)>(b^sign);default:return (a^sign)>=(b^sign);
  }
  return result&mask;
}

int main(void) {
  const Operation ops[2][19][4]={{OPS(ROW,32)},{OPS(ROW,64)}};
  const uint64_t words[]={0,1,31,32,63,64,65,UINT32_MAX,UINT64_C(0x80000000),
    UINT64_C(0x100000000),UINT64_C(0x8000000000000000),UINT64_C(0xffffffff00000001),UINT64_MAX};
  const uint64_t canary=UINT64_C(0x61a578f2bc39d04e);
  unsigned observations=0;
  for(unsigned i=0;i<sizeof words/sizeof *words;++i)
    for(unsigned j=0;j<sizeof words/sizeof *words;++j)
      for(unsigned w=0;w<2;++w)for(unsigned op=0;op<19;++op)for(unsigned mode=0;mode<4;++mode) {
        uint64_t state[]={words[i],words[j],canary,canary},before[4];
        memcpy(before,state,sizeof state);
        uint64_t want=reference(op,words[i],mode==3?words[i]:words[j],w?64:32);
        uint64_t got=ops[w][op][mode](state);
        if(got!=want || memcmp(state,before,sizeof state)) {
          fprintf(stderr,"operand w=%u op=%u mode=%u a=%016" PRIx64 " b=%016" PRIx64
            " got=%016" PRIx64 " want=%016" PRIx64 "\n",w?64:32,op,mode,words[i],words[j],got,want);
          return 1;
        }
        ++observations;
      }
  const Operation loads[]={p190o_load_32,p190o_load_64};
  const Operation stores[]={p190o_store_32,p190o_store_64};
  const Operation same[]={p190o_store_same_32,p190o_store_same_64};
  for(unsigned i=0;i<sizeof words/sizeof *words;++i)for(unsigned w=0;w<2;++w) {
    uint64_t target[]={canary,words[i],canary},state[]={(uintptr_t)target,canary,canary,canary},before[4];
    uint64_t mask=w?UINT64_MAX:UINT32_MAX;
    memcpy(before,state,sizeof state);
    if(loads[w](state)!=(words[i]&mask) || memcmp(state,before,sizeof state) ||
       target[0]!=canary || target[1]!=words[i] || target[2]!=canary)return 2;
    state[0]=words[i];memcpy(before,state,sizeof state);
    before[2]=(canary&~mask)|(words[i]&mask);
    if(stores[w](state)!=words[i] || memcmp(state,before,sizeof state))return 3;
    state[2]=canary;memcpy(before,state,sizeof state);
    before[2]=(canary&~mask)|((uintptr_t)state&mask);
    if(same[w](state)!=(uintptr_t)state || memcmp(state,before,sizeof state))return 4;
    observations+=3;
  }
  printf("phase190 operand controls pass: %u\n",observations);
  return 0;
}
