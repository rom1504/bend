/* Post-verification ABIs. p111v_counted_call proves ctor metadata and buffer
 * capacity; take input shape remains dynamic and retains its original checks.
 * Allocations, fields, publication, reference counts and reclamation are exact
 * copies of the selected Phase118 runtime, not its earlier unconditional seal. */
#define P125_VERIFIED(N) \
uint64_t p125_rt_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields) { \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \
  } \
  return term_ctr(cid, at); \
} \
uint64_t p125_rt_take##N(P111State *state, uint64_t term, uint64_t *out) { \
  u32 cid = (u32)term_aux(term); \
  p111_require(cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \
  else { \
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \
  } \
  return N; \
}
P125_VERIFIED(1)
P125_VERIFIED(2)
P125_VERIFIED(3)
P125_VERIFIED(4)
#undef P125_VERIFIED
