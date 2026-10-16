/* Experimental consuming append on the ORIGINAL linked String ABI.
 * Each ctr_take transfers head/tail ownership. Its reusable heap cell belongs
 * exclusively to us; shared/static cells are copied. The result stays private
 * while its forward links are filled. No task, character or String ABI changes.
 */
#ifndef P102_APPEND_REUSE
#define P102_APPEND_REUSE 1
#endif

INLINE Term p102_string_seal(Env e, Term value) {
#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON
  return value;
#else
  return rfc_seal(e, value);
#endif
}

OUTLINE Term p102_linked_append(Env e, Term left, Term right) {
  Term result = term_pak(CID_SNIL, 0);
  Loc last = 0;
  u32 poll = 0;
  while (term_aux(left) == CID_SCON) {
    if (err_spun(e.mem, &poll)) return 0;
    Term fields[2];
    Loc cell = ctr_take(e, left, 2, fields);
    left = fields[1];
#if !P102_APPEND_REUSE
    spare_free(e, cls_fit(2), cell);
    cell = 0;
#endif
    if (cell < HEAP_OFF) cell = heap_alloc(e, cls_fit(2));
    e.mem[cell] = fields[0];
    e.mem[cell + 1] = term_pak(CID_SNIL, 0);
    Term node = term_ctr(CID_SCON, cell);
    if (last) e.mem[last + 1] = p102_string_seal(e, node);
    else result = node;
    last = cell;
  }
  if (term_aux(left) != CID_SNIL) {
    term_sink(e, left); term_sink(e, right); term_sink(e, result);
    err_post(e.mem, ERR_FIDS); return 0;
  }
  if (!last) return right;
  e.mem[last + 1] = p102_string_seal(e, right);
  return result;
}
