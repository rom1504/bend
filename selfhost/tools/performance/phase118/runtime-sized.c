/* Constant-count counterparts preserve every original public contract. */
#define P118_SIZED(N) \
uint64_t p118_p111_rt_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) { \
  p111_require(count == N && cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: constructor arity mismatch"); \
  p111_require(fields != NULL, "phase118: missing constructor fields"); \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \
  for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \
  return term_ctr(cid, at); \
} \
uint64_t p118_p111_rt_take##N(P111State *state, uint64_t term, uint64_t *out, uint32_t count) { \
  u32 cid = (u32)term_aux(term); \
  p111_require(count == N && cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \
  p111_require(out != NULL, "phase118: missing take outputs"); \
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \
  else { \
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \
  } \
  return N; \
}
P118_SIZED(1)
P118_SIZED(2)
P118_SIZED(3)
P118_SIZED(4)
#undef P118_SIZED
