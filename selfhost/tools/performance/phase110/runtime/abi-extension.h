#ifndef PHASE110_RUNTIME_ABI_EXTENSION_H
#define PHASE110_RUNTIME_ABI_EXTENSION_H
/* Additive ABI v2. All worker imports require the same checked typed graph,
 * live single-thread context and verified ownership program as Phase109.
 * Constructor identity is now a pure borrowed operation with the authenticated
 * representation below. These constants do not authorize raw Term pointers. */
#define NX_RT_TERM_AUX_SHIFT 40u
#define NX_RT_TERM_AUX_MASK 65535u
#define NX_RT_ABI_EXTENSION_VERSION 2u
typedef struct NxRtPair { uint64_t first; uint64_t second; } NxRtPair;

/* Each descriptor specialization consumes parent and other, transfers the
 * selected old field into built, and transfers the other old field separately.
 * The scratch ABI requires fast_field(ctx,0) immediately afterward. The pair
 * ABI returns both owners atomically and neither reads nor writes scratch. */
#define NX_RT_DECLARE_REBUILD(C,K) \
  uint64_t nx_rt_rebuild2_c##C##_k##K(NxRt*, uint64_t, uint64_t); \
  NxRtPair nx_rt_pair_rebuild2_c##C##_k##K(NxRt*, uint64_t, uint64_t);
NX_RT_DECLARE_REBUILD(1,0)
NX_RT_DECLARE_REBUILD(1,1)
NX_RT_DECLARE_REBUILD(3,0)
NX_RT_DECLARE_REBUILD(3,1)
#undef NX_RT_DECLARE_REBUILD
#endif
