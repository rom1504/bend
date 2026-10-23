/* Additive diagnostic prototype. Not linked or selected automatically.
 * Contract: the checked worker's exact successful equation is
 * C(C(a,b), C(c,d)) input pair -> C(C(a,c), C(b,d)) result.
 * Inputs are two independently owned C Terms; each C has exactly two fields.
 * Return zero consumes/mutates nothing; nonzero transfers both inputs.
 * Only raw dynamic distinct shells are reused. RFC/shared/static paths decline.
 */
uint64_t p126_rt_transpose2(P111State *state, uint64_t left, uint64_t right,
                           uint32_t cid) {
  p111_require(cid < p111_program_active->constructor_count && cid_arity(cid) == 2,
    "phase126: invalid checked local-reshape layout");
  if (term_tag(left) != TAG_CTR || term_tag(right) != TAG_CTR ||
      term_aux(left) != cid || term_aux(right) != cid ||
      term_rfc(left) || term_rfc(right)) return 0;
  Loc a = term_loc(left), b = term_loc(right);
  if (a < HEAP_OFF || b < HEAP_OFF || a == b) return 0;
  Env e = state->e;
  /* Snapshot every old field before any mutation, allocation or publication. */
  Term a0 = e.mem[a], a1 = e.mem[a + 1];
  Term b0 = e.mem[b], b1 = e.mem[b + 1];
  bool cold = (p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid);
  /* Follow the ordinary constructor's field order and sealing policy. No field
   * is duplicated/dropped, and neither consumed shell enters a freelist. */
  e.mem[a]     = cold ? a0 : rfc_seal(e, a0);
  e.mem[a + 1] = cold ? b0 : rfc_seal(e, b0);
  e.mem[b]     = cold ? a1 : rfc_seal(e, a1);
  e.mem[b + 1] = cold ? b1 : rfc_seal(e, b1);
  Term outer[2] = {left, right};
  return p125_rt_ctor2(state, cid, outer);
}
