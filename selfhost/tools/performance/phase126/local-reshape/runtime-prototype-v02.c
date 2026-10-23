/* Sequential owning transpose, runtime variant2. The compiler/import/source
 * certificate is unchanged. Return zero changes neither operand nor ownership.
 * Accept raw dynamic roots or dynamic RFC roots with acquired exact count1.
 * Keep the original owning Terms, including their wrappers, for the new outer
 * node. No wrapper is consumed, freed, duplicated or resealed here.
 */
uint64_t p126_rt_transpose2(P111State *state, uint64_t left, uint64_t right,
                           uint32_t cid) {
  p111_require(cid < p111_program_active->constructor_count && cid_arity(cid) == 2,
    "phase126: invalid checked local-reshape layout");
  if (term_tag(left) != TAG_CTR || term_tag(right) != TAG_CTR ||
      term_aux(left) != cid || term_aux(right) != cid) return 0;
  Env e = state->e;
  Loc a = term_loc(left), b = term_loc(right);
  /* A static raw node or static wrapper is never a mutation candidate. */
  if (a < HEAP_OFF || b < HEAP_OFF) return 0;
  if (term_rfc(left)) {
    u64 cell = rfc_view(e, a);
    if ((cell & RFC_CNT) != 1) return 0;
    a = cell >> 24;
  }
  if (term_rfc(right)) {
    u64 cell = rfc_view(e, b);
    if ((cell & RFC_CNT) != 1) return 0;
    b = cell >> 24;
  }
  /* Dynamic wrappers can refer to static data. Distinct wrappers are not
   * sufficient: the resolved constructor locations must also be distinct. */
  if (a < HEAP_OFF || b < HEAP_OFF || a == b) return 0;
  /* All validation above is read-only. Snapshot all old fields before writes,
   * sealing, allocation or publication. Every field moves exactly once. */
  Term a0 = e.mem[a], a1 = e.mem[a + 1];
  Term b0 = e.mem[b], b1 = e.mem[b + 1];
  bool cold = (p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid);
  e.mem[a]     = cold ? a0 : rfc_seal(e, a0);
  e.mem[a + 1] = cold ? b0 : rfc_seal(e, b0);
  e.mem[b]     = cold ? a1 : rfc_seal(e, a1);
  e.mem[b + 1] = cold ? b1 : rfc_seal(e, b1);
  /* Existing count1 wrappers remain count1 and are transferred, unchanged,
   * into the result. Ordinary constructor publication seals raw roots only. */
  Term outer[2] = {left, right};
  return p111_rt_ctor(state, cid, outer, 2);
}
