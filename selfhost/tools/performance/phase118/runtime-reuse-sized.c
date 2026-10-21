/* Append after runtime-reuse.c. Exact literal-count ABI projections retain all
 * checks and ownership effects of their generic counterpart. Removing count
 * gives take four arguments and extend six, avoiding the seventh stack arg.
 * Macro bodies deliberately match the frozen generic body; these are bounded
 * specializations, not a replacement ownership/runtime implementation. */
#define P118_REUSE_TAKE(N) \
uint64_t p118_rt_reuse_take##N(P111State *state, uint64_t term, uint64_t *out, uint64_t credit) { \
  p118_reuse_check(credit); \
  u32 cid = (u32)term_aux(term); \
  p111_require(cid < p111_program_active->constructor_count && N == cid_arity(cid), \
    "phase118: reuse take arity mismatch"); \
  if (!N) return credit; \
  p111_require(out != NULL, "phase118: missing reuse take outputs"); \
  if (N == 1 && term_tag(term) == TAG_PAK) { out[0] = term_loc(term); return credit; } \
  p111_require(term_tag(term) == TAG_CTR, "phase118: expected reuse constructor owner"); \
  Loc cell = ctr_take(state->e, term, N, out); \
  if (cell < HEAP_OFF) return credit; \
  p111_require(cell <= LOC_MASK, "phase118: reuse location exceeds private encoding"); \
  p118_reuse_drop(state->e, credit); \
  return cell | ((uint64_t)cls_fit(N) << 40); \
}
P118_REUSE_TAKE(1)
P118_REUSE_TAKE(2)
P118_REUSE_TAKE(3)
P118_REUSE_TAKE(4)
#undef P118_REUSE_TAKE

#define P118_REUSE_EXTEND(N) \
uint64_t p118_rt_reuse_extend##N(P111State *state, uint64_t parent, uint32_t cid, \
                                 const uint64_t *prefix, uint64_t credit, uint64_t *credit_out) { \
  p118_reuse_check(credit); \
  p111_require(cid < p111_program_active->constructor_count && N >= 1 && \
    N <= 7 && N + 1 == cid_arity(cid) && prefix && credit_out, \
    "phase118: invalid reuse constructor-tail prefix"); \
  Env e = state->e; Cls cls = cls_fit(N + 1); Loc at; \
  if (credit && p118_reuse_class(credit) == cls) { \
    at = p118_reuse_location(credit); credit = 0; \
  } else { \
    at = heap_alloc(e, cls); \
  } \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = prefix[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]); \
  } \
  e.mem[at + N] = TERM_HOLE; \
  Term node = term_ctr(cid, at); \
  if (parent) p118_destination_fill(state, parent, node); \
  *credit_out = credit; \
  return node; \
}
P118_REUSE_EXTEND(1)
P118_REUSE_EXTEND(2)
P118_REUSE_EXTEND(3)
P118_REUSE_EXTEND(4)
P118_REUSE_EXTEND(5)
P118_REUSE_EXTEND(6)
P118_REUSE_EXTEND(7)
#undef P118_REUSE_EXTEND
