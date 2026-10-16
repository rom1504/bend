/* Consuming append at the representation boundary. Reuse complete exclusive
 * chunks; copy shared views and legacy cells into a forward chunk builder.
 * The language's original String.append recursion is pure and strictly
 * saturated here. Its closure/continuation machinery remains in the original C
 * for all other functions. This is a prototype intrinsic, not a trusted proof.
 */
OUTLINE Term p101_append(Env e, Term left, Term right) {
  /* Short prefixes dominate formatting. Pack them backwards into the right
   * builder instead of retaining a mostly empty chunk for every tiny append. */
  Term probe = left;
  u32 chars[P101_CHUNK_WORDS - 3];
  u32 count = 0;
  while (count < P101_CHUNK_WORDS - 3 && term_aux(probe) == CID_SCON) {
    chars[count++] = (u32)p101_head(e, probe);
    probe = p101_tail(e, probe);
  }
  if (term_aux(probe) == CID_SNIL) {
    term_sink(e, left);
    while (count) right = p101_cons(e, chars[--count], right);
    return right;
  }
  Term result = term_pak(CID_SNIL, 0);
  Loc last = 0, writable = 0;
  u32 poll = 0;
  while (term_aux(left) == CID_SCON) {
    if (err_spun(e.mem, &poll)) return 0;
    if (p101_string(left)) {
      Loc root = p101_root(e, left);
      DEV u32* refs = a32_at(e.mem, root);
      if (a32_load(refs) == 1) {
        a32_acq(refs);
        Term rest = e.mem[root + 2];
        e.mem[root + 2] = term_pak(CID_SNIL, 0);
        if (last) e.mem[last + 2] = left; else result = left;
        last = root;
        writable = 0;
        left = rest;
        continue;
      }
    }
    Term pair[2];
    spare_free(e, cls_fit(2), ctr_take(e, left, 2, pair));
    left = pair[1];
    if (!writable || e.mem[writable + 1] == writable + P101_CHUNK_WORDS) {
      Loc root = heap_alloc(e, P101_CHUNK_CLASS);
      e.mem[root] = 1;
      e.mem[root + 1] = root + 3;
      e.mem[root + 2] = term_pak(CID_SNIL, 0);
      Term start = term_make(TAG_STR, CID_SCON, root + 3);
      if (last) e.mem[last + 2] = start; else result = start;
      writable = last = root;
    }
    Loc at = e.mem[writable + 1]++;
    e.mem[at] = ((at - writable) << 32) | (u32)pair[0];
  }
  if (term_aux(left) != CID_SNIL) {
    fprintf(stderr, "p101 invalid append tail: %llx\n", (unsigned long long)left);
    term_sink(e, left); term_sink(e, right); term_sink(e, result);
    err_post(e.mem, ERR_FIDS); return 0;
  }
  if (!last) return right;
  e.mem[last + 2] = rfc_seal(e, right);
  return result;
}
