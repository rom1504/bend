#include <stdio.h>
#include <string.h>
// Root-run ABI discriminator; not a compiler runtime or replacement artifact.
// Exact own-image WL_SIG/WL_ALL with runtime-style dead rp padding.
// Like WL_OPEN, an inner scope shadows rp with an uninitialized padding slot.
typedef unsigned long long u64;
typedef unsigned int u32;
typedef u64 Term;
typedef Term Reply;
typedef Term *Stk;
typedef struct { u64 *mem; u64 *alc; } Env;
#if __has_attribute(preserve_none) && __has_attribute(preserve_most) \
  && defined(__OPTIMIZE__)
#define PRESERVE(A) __attribute__((A))
#else
#define PRESERVE(A)
#endif
#define CC PRESERVE(preserve_none)
#define FAR static __attribute__((noinline))
#define DEVICE 0
typedef u32 Fid;
#define WL_DYN(F) __attribute__((musttail)) return wl_tab[F](WL_ALL)
#define FN CC __attribute__((noinline)) Reply
#define WL_SIG Env e, Stk sp, u32 seq, u32 rn, Term r0, Term r1, Term r2, Term r3, Term r4, Term r5, Term rp, Term r6, Term r7, Term r8, Term r9, Term r10, Term r11, Term r12, Term r13, Term r14, Term r15, Term r16, Term r17, Term r18, Term r19, Term r20
#define WL_ALL e, sp, seq, rn, r0, r1, r2, r3, r4, r5, rp, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20
typedef Reply (CC *WlFn)(WL_SIG);
FN sink(WL_SIG) {
  return e.mem[0]+e.alc[0]+sp[0]+seq+rn
    +r0+r1+r2+r3+r4+r5+r6+r7+r8+r9+r10
    +r11+r12+r13+r14+r15+r16+r17+r18+r19+r20;
}
#define WL_TABLE sink,sink
#if !DEVICE
static const WlFn wl_tab[] = { WL_TABLE };
#undef WL_X
#if FID_ENTER >= 4096
// Keep the shared dispatch table out of each segment's LLVM reference graph.
FAR PRESERVE(preserve_most) WlFn wl_target(Fid id) { return wl_tab[id]; }
#undef WL_DYN
#define WL_DYN(F) __attribute__((musttail)) return wl_target(F)(WL_ALL)
#endif
#endif
FN WL_FID_ENTER(WL_SIG) {
 { Term rp;
  WL_DYN((Fid)(r0 & 1));
 }
}
#define P90_STR_INNER(...) #__VA_ARGS__
#define P90_STR(...) P90_STR_INNER(__VA_ARGS__)
int main(void) {
  u64 mem=7,alc=11,stack=13;
  Env e={&mem,&alc};
  u64 got=WL_FID_ENTER(e,&stack,17,19,
    1,2,3,4,5,6,99,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21);
  int accessor=strstr(P90_STR(WL_DYN(0)),"wl_target")!=NULL;
  int preserve=strstr(P90_STR(PRESERVE(preserve_none)),"preserve_none")!=NULL;
#ifdef __OPTIMIZE__
  int expected_preserve=1;
#else
  int expected_preserve=0;
#endif
  if(got!=298 || accessor!=(FID_ENTER>=4096) || preserve!=expected_preserve) return 1;
  printf("%u %s %s %llu\n",(unsigned)FID_ENTER,accessor?"accessor":"direct",preserve?"preserve":"default",got);
  return 0;
}
