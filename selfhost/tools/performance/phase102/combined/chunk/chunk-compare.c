/* Borrowed canonical String order. The caller keeps both roots alive.
 * Compare full U32 characters, never metadata or UTF-8 bytes. No retain/drop.
 * Only install at the scalar observer, not the owned pair-returning function.
 */
INLINE Term p101_compare(Env e, Term left, Term right) {
  u32 poll = 0;
  for (;;) {
    if (err_spun(e.mem, &poll)) return 0;
    if (left == right) return term_pak(CID_EQ, 0);
    u64 lk = term_aux(left), rk = term_aux(right);
    if ((lk != CID_SNIL && lk != CID_SCON) ||
        (rk != CID_SNIL && rk != CID_SCON)) {
      err_post(e.mem, ERR_FIDS); return 0;
    }
    if (lk == CID_SNIL || rk == CID_SNIL)
      return term_pak(lk == rk ? CID_EQ : lk == CID_SNIL ? CID_LT : CID_GT, 0);
    if (p101_string(left) && p101_string(right)) {
      Loc lp = term_loc(left), rp = term_loc(right);
      Loc lr = p101_root(e, left), rr = p101_root(e, right);
      Loc le = e.mem[lr + 1], re = e.mem[rr + 1];
      Loc n = le - lp < re - rp ? le - lp : re - rp;
      for (Loc i = 0; i < n; ++i) {
        u32 x = (u32)e.mem[lp + i], y = (u32)e.mem[rp + i];
        if (x != y) return term_pak(x < y ? CID_LT : CID_GT, 0);
      }
      lp += n; rp += n;
      left = lp == le ? e.mem[lr + 2] : term_make(TAG_STR, CID_SCON, lp);
      right = rp == re ? e.mem[rr + 2] : term_make(TAG_STR, CID_SCON, rp);
    } else {
      u32 x = (u32)p101_head(e, left), y = (u32)p101_head(e, right);
      if (x != y) return term_pak(x < y ? CID_LT : CID_GT, 0);
      left = p101_tail(e, left);
      right = p101_tail(e, right);
    }
  }
}
