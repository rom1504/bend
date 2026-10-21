/* Additive sequential-runtime helper. No ownership transition occurs here.
 * Decline aliased nontrivial RFC roots: count>1 independently is insufficient
 * when two adapter-owned aliases could consume the final two references. */
uint64_t p118_rt_borrow_scalar_safe(P111State *state, Term first, Term second,
                                  uint32_t count) {
  p111_require(count == 1 || count == 2, "phase118: scalar root count");
  Env e = state->e;
  if (count == 2 && !term_triv(first) && !term_triv(second) &&
      term_rfc(first) && term_rfc(second) &&
      term_loc(first) == term_loc(second)) return 0;
  if (!term_triv(first) &&
      (!term_rfc(first) || (rfc_view(e, term_loc(first)) & RFC_CNT) <= 1)) return 0;
  if (count == 2 && !term_triv(second) &&
      (!term_rfc(second) || (rfc_view(e, term_loc(second)) & RFC_CNT) <= 1)) return 0;
  return 1;
}
