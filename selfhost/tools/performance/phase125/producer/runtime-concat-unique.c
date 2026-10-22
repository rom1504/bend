/* Additive, sequential owned-append operation. Invoked only for the checked
 * structural append identity. Failure is observationally read-only; the caller
 * still owns both original operands and uses its original complete worker.
 * Success transfers both operands to out[0]. Heads are never copied or dropped.
 * V2 also accepts RFC cells with an acquired exact count of one, along an
 * already uniquely owned path. Wrappers and heads remain untouched. */
uint64_t p125_rt_concat(P111State *state, uint64_t left, uint64_t right,
                       uint32_t empty_cid, uint32_t link_cid, uint64_t *out) {
  p111_require(empty_cid < p111_program_active->constructor_count &&
    link_cid < p111_program_active->constructor_count && empty_cid != link_cid &&
    cid_arity(empty_cid) == 0 && cid_arity(link_cid) == 2 && out,
    "phase125: invalid checked append layout");
  Term nil = term_pak(empty_cid, 0), node = left;
  Loc last = 0;
  Env e = state->e;
  while (node != nil) {
    if (term_tag(node) != TAG_CTR || term_aux(node) != link_cid ||
        term_loc(node) < HEAP_OFF) return 0;
    if (term_rfc(node)) {
      u64 cell = rfc_view(e, term_loc(node));
      if ((cell & RFC_CNT) != 1) return 0;
      last = cell >> 24;
      /* A heap wrapper can refer to a static constructor. */
      if (last < HEAP_OFF) return 0;
    } else {
      last = term_loc(node);
    }
    node = e.mem[last + 1];
  }
  if (!last) {
    out[0] = right;
    return 1;
  }
  /* No mutation/ownership change before the entire spine was authenticated.
   * Match the ordinary constructor's publication/sealing rule exactly. */
  e.mem[last + 1] = ((p111_program_active->capabilities & UINT64_C(8)) &&
                    !cid_hot(link_cid)) ? right : rfc_seal(e, right);
  out[0] = left;
  return 1;
}
