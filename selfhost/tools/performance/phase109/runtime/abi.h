#ifndef PHASE109_RUNTIME_ABI_H
#define PHASE109_RUNTIME_ABI_H
#include <stdint.h>

/* Version 1: one live, single-threaded context; conservative boxed ADTs.
 * Term words are opaque owning values, not pointers or arithmetic integers.
 * All imports are ordered effects. id only borrows, but remains a barrier. */
#define NX_RT_ABI_VERSION 1u
#define NX_RT_NIL 0u
#define NX_RT_CON 1u
#define NX_RT_SNIL 2u
#define NX_RT_SCON 3u
typedef struct NxRt NxRt;
NxRt *nx_rt_open(void);
void nx_rt_close(NxRt *ctx);
uint32_t nx_rt_id(NxRt *ctx, uint64_t term);
uint64_t nx_rt_fail(NxRt *ctx, uint32_t reason);
uint64_t nx_rt_keep(NxRt *ctx, uint64_t term);
uint32_t nx_rt_sink(NxRt *ctx, uint64_t term);
uint64_t nx_rt_zero(NxRt *ctx, uint32_t cid);
uint64_t nx_rt_build2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail);
uint32_t nx_rt_take2(NxRt *ctx, uint64_t term);
uint64_t nx_rt_field(NxRt *ctx, uint32_t index);

/* Trusted worker ABI: only after checked graph admission plus verified Nxo.
 * The public checked constructors, context lifecycle and observers stay checked.
 * The same ownership contracts apply; malformed callers have no defined result. */
uint32_t nx_rt_fast_id(NxRt *ctx, uint64_t term);
uint64_t nx_rt_fast_keep(NxRt *ctx, uint64_t term);
uint32_t nx_rt_fast_sink(NxRt *ctx, uint64_t term);
uint64_t nx_rt_fast_zero(NxRt *ctx, uint32_t cid);
uint64_t nx_rt_fast_build2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail);
uint32_t nx_rt_fast_take2(NxRt *ctx, uint64_t term);
uint64_t nx_rt_fast_field(NxRt *ctx, uint32_t index);
/* Consume parent/other; preserve parent[keep_index] in result, transfer the
 * other old field to scratch0. The next field(ctx,0) consumes that old child. */
uint64_t nx_rt_rebuild2(NxRt *ctx, uint64_t parent, uint32_t cid,
                      uint32_t keep_index, uint64_t other);

/* Harness-only borrowed observers/static-image preparation; not IR imports. */
uint64_t nx_rt_borrow(NxRt *ctx, uint64_t term, uint32_t index);
uint64_t nx_rt_static2(NxRt *ctx, uint32_t cid, uint64_t head, uint64_t tail);
uint64_t nx_rt_live_words(NxRt *ctx);
uint64_t nx_rt_bump_words(NxRt *ctx);
uint32_t nx_rt_pending(NxRt *ctx);
#endif
