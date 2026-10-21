/* Exact constant-prefix copies of allocation-only p118_rt_extend. Count is
 * encoded in the helper symbol. No ownership/sealing/parent protocol changes. */
#define P118_EXTEND(N) \
uint64_t p118_rt_extend##N(P111State *state, uint64_t parent, uint32_t cid, const uint64_t *prefix) { \
  p111_require(cid < p111_program_active->constructor_count && N >= 1 && \
    N <= 7 && N + 1 == cid_arity(cid) && prefix, \
    "phase118: invalid constructor-tail prefix"); \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N + 1)); \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = prefix[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]); \
  } \
  e.mem[at + N] = TERM_HOLE; \
  Term node = term_ctr(cid, at); \
  if (parent) p118_destination_fill(state, parent, node); \
  return node; \
}
P118_EXTEND(1)
P118_EXTEND(2)
P118_EXTEND(3)
P118_EXTEND(4)
P118_EXTEND(5)
P118_EXTEND(6)
P118_EXTEND(7)
#undef P118_EXTEND
