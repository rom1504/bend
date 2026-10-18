/* Appended after the exact Phase109 adapter. Descriptor constants reach the
 * production ctr_take/heap_alloc/rfc_seal bodies in this translation unit.
 * These are generic binary reconstruction operations, never source workers. */
#include "abi-extension.h"

#define NX_RT_DEFINE_REBUILD(C,K) \
uint64_t nx_rt_rebuild2_c##C##_k##K(NxRt *ctx, uint64_t parent, uint64_t other) { \
  Env e = ctx->env; \
  Term old[2]; \
  Loc spare = ctr_take(e, parent, 2, old); \
  Loc loc = spare >= HEAP_OFF ? spare : heap_alloc(e, cls_fit(2)); \
  ctx->fields[0] = old[1u - K]; \
  ctx->fields[1] = TERM_HOLE; \
  ctx->pending = 1; \
  return nx_construct2(e, C, old[K], other, loc); \
} \
NxRtPair nx_rt_pair_rebuild2_c##C##_k##K(NxRt *ctx, uint64_t parent, uint64_t other) { \
  Env e = ctx->env; \
  Term old[2]; \
  Loc spare = ctr_take(e, parent, 2, old); \
  Loc loc = spare >= HEAP_OFF ? spare : heap_alloc(e, cls_fit(2)); \
  NxRtPair result = {nx_construct2(e, C, old[K], other, loc), old[1u - K]}; \
  return result; \
}
NX_RT_DEFINE_REBUILD(1,0)
NX_RT_DEFINE_REBUILD(1,1)
NX_RT_DEFINE_REBUILD(3,0)
NX_RT_DEFINE_REBUILD(3,1)
#undef NX_RT_DEFINE_REBUILD
