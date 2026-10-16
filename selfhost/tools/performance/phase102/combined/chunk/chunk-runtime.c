/* Experimental host-only String ABI. General C intervention, not a release.
 * Every live slice owns one atomic chunk reference. Borrowed projections own
 * none and cannot outlive their held root. Each chunk owns its sealed suffix.
 * Header: refs, exclusive end, suffix. Cells: distance-to-header | full U32.
 * Immutable visible cells; cons may fill unused prefix only under exclusivity.
 */
#define TAG_STR 7ull
#ifndef P101_CHUNK_CLASS
#define P101_CHUNK_CLASS 6
#endif
#define P101_CHUNK_WORDS (1u << P101_CHUNK_CLASS)
#define p101_string(t) (term_tag(t) == TAG_STR)

INLINE Loc p101_root(Env e, Term t) {
  Loc p = term_loc(t);
  return p - (e.mem[p] >> 32);
}

INLINE void p101_retain(Env e, Term t, u32 count) {
  u32 old = a32_add(a32_at(e.mem, p101_root(e, t)), count);
  if (old == 0 || old > UINT32_MAX - count) err_post(e.mem, ERR_RFCS);
}

INLINE Term p101_head(Env e, Term t) {
  return p101_string(t) ? (u32)e.mem[term_loc(t)] : e.mem[term_peek(e, t)];
}

INLINE Term p101_tail(Env e, Term t) {
  if (!p101_string(t)) return e.mem[term_peek(e, t) + 1];
  Loc p = term_loc(t), r = p101_root(e, t);
  return p + 1 < e.mem[r + 1] ? term_make(TAG_STR, CID_SCON, p + 1) : e.mem[r + 2];
}

INLINE Term p101_field(Env e, Term t, u32 i) {
  return p101_string(t) ? (i == 0 ? p101_head(e, t) : p101_tail(e, t))
                       : e.mem[term_peek(e, t) + i];
}

INLINE bool p101_shared(Env e, Term t) {
  return p101_string(t) ? a32_load(a32_at(e.mem, p101_root(e, t))) > 1
    : term_rfc(t) && (rfc_view(e, term_loc(t)) & RFC_CNT) > 1;
}

/* Returns the owned suffix only on the final release; caller consumes it. */
INLINE Term p101_release(Env e, Term t) {
  Loc r = p101_root(e, t);
  DEV u32* refs = a32_at(e.mem, r);
  if (a32_sub_rel(refs, 1) != 1) return 0;
  a32_acq(refs);
  Term tail = e.mem[r + 2];
  heap_free(e, P101_CHUNK_CLASS, r);
  return tail;
}

INLINE Term p101_cons(Env e, Term head, Term tail) {
  if (p101_string(tail)) {
    Loc p = term_loc(tail), r = p101_root(e, tail);
    DEV u32* refs = a32_at(e.mem, r);
    if (p > r + 3 && a32_load(refs) == 1) {
      a32_acq(refs);
      --p;
      e.mem[p] = ((p - r) << 32) | (u32)head;
      return term_make(TAG_STR, CID_SCON, p);
    }
  }
  Loc r = heap_alloc(e, P101_CHUNK_CLASS);
  Loc p = r + P101_CHUNK_WORDS - 1;
  e.mem[r] = 1;
  e.mem[r + 1] = p + 1;
  e.mem[r + 2] = rfc_seal(e, tail);
  e.mem[p] = ((p - r) << 32) | (u32)head;
  return term_make(TAG_STR, CID_SCON, p);
}
