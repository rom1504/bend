/* Copy borrowed field views without transferring ownership. The original owned
 * root stays live until the certified observer returns it to its caller. */
uint64_t p118_rt_borrow_fields(P111State *state, uint64_t term, uint64_t *out,
                               uint32_t cid, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count &&
    term_aux(term) == cid && count == cid_arity(cid) && (!count || out),
    "phase118: borrowed constructor mismatch");
  if (!count) return 0;
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected borrowed constructor");
    Loc at = term_peek(state->e, term);
    for (u32 i = 0; i < count; ++i) out[i] = state->e.mem[at + i];
  }
  return count;
}
