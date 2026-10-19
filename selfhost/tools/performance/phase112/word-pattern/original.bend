# Exact renamed frozen generic fallback.
@unsafe
def p112m_original_match_apply(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word : N111Value = N111Local{nc_word(ix(arg), env)}
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = p111_lower(book, nd_reapply(nc_field_apps(kid(mat, 0), count, 0, n), nd_match_rest(t)), nt_append(NC_Binding, nc_remove_env(env, ix(arg)), p111_field_env(count, 0, n)), U32.add(n, count))
  +miss = p111_lower(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, p111_fresh(hit))
  +branch = nt_append(N111Stmt, p111_test(nm(mat), word), [N111If{N111Local{"match_condition"}, nt_append(N111Stmt, p111_take(nm(mat), word, count, n), p111_body(hit)), p111_body(miss)}])
  P111Code{p111_guard_io(nm(mat), word, branch), nt_append(N111Segment, p111_segments(hit), p111_segments(miss)), p111_fresh(miss), p111_first(p111_error(hit), p111_error(miss))}
