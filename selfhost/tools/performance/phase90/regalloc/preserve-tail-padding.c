// Root-run ABI discriminator; not a compiler runtime or replacement artifact.
// Exact own-image WL_SIG/WL_ALL with runtime-style dead rp padding.
// Like WL_OPEN, an inner scope shadows rp with an uninitialized padding slot.
typedef unsigned long long u64;
typedef unsigned int u32;
typedef u64 Term;
typedef Term Reply;
typedef Term *Stk;
typedef struct { u64 *mem; u64 *alc; } Env;
#ifndef REPRO_PRESERVE
#define REPRO_PRESERVE 1
#endif
#if REPRO_PRESERVE
#define CC __attribute__((preserve_none))
#else
#define CC
#endif
#define FN CC __attribute__((noinline)) Reply
#define WL_SIG Env e, Stk sp, u32 seq, u32 rn, Term r0, Term r1, Term r2, Term r3, Term r4, Term r5, Term rp, Term r6, Term r7, Term r8, Term r9, Term r10, Term r11, Term r12, Term r13, Term r14, Term r15, Term r16, Term r17, Term r18, Term r19, Term r20
#define WL_ALL e, sp, seq, rn, r0, r1, r2, r3, r4, r5, rp, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20
typedef Reply (CC *WlFn)(WL_SIG);
FN sink(WL_SIG) {
  return e.mem[0]+e.alc[0]+sp[0]+seq+rn
    +r0+r1+r2+r3+r4+r5+r6+r7+r8+r9+r10
    +r11+r12+r13+r14+r15+r16+r17+r18+r19+r20;
}
WlFn callbacks[2] = {sink,sink};
FN WL_FID_ENTER(WL_SIG) {
 { Term rp;
#ifdef REPRO_DIRECT
  __attribute__((musttail)) return sink(WL_ALL);
#else
  __attribute__((musttail)) return callbacks[r0 & 1](WL_ALL);
#endif
 }
}
int main(void) {
  u64 mem=7,alc=11,stack=13;
  Env e={&mem,&alc};
  return WL_FID_ENTER(e,&stack,17,19,
    1,2,3,4,5,6,99,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21)==298 ? 0 : 1;
}
