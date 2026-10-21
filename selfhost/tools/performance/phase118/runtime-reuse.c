/* Append after the selected Phase118 destination helpers. This is an isolated
 * private-worker ABI, not a P111State/global cache. Credit is an opaque scalar:
 * low40 bits = an exclusively transferred dynamic cell; high bits = its Cls.
 * Its former children have moved into ordinary local Terms before capture. */
static Loc p118_reuse_location(uint64_t credit) { return credit & LOC_MASK; }
static Cls p118_reuse_class(uint64_t credit) { return (Cls)(credit >> 40); }

static void p118_reuse_check(uint64_t credit) {
  p111_require(!credit || (p118_reuse_location(credit) >= HEAP_OFF &&
    p118_reuse_class(credit) <= cls_fit(255)), "phase118: invalid private reuse credit");
}

static void p118_reuse_drop(Env e, uint64_t credit) {
  if (credit) spare_free(e, p118_reuse_class(credit), p118_reuse_location(credit));
}

uint64_t p118_rt_reuse_take(P111State *state, uint64_t term, uint64_t *out,
                            uint32_t count, uint64_t credit) {
  p118_reuse_check(credit);
  u32 cid = (u32)term_aux(term);
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase118: reuse take arity mismatch");
  if (!count) return credit;
  p111_require(out != NULL, "phase118: missing reuse take outputs");
  if (count == 1 && term_tag(term) == TAG_PAK) { out[0] = term_loc(term); return credit; }
  p111_require(term_tag(term) == TAG_CTR, "phase118: expected reuse constructor owner");
  Loc cell = ctr_take(state->e, term, count, out);
  /* Shared inputs contribute zero; static inputs must never become writable.
   * Preserve an older credit when this consumption supplies no dynamic cell. */
  if (cell < HEAP_OFF) return credit;
  p111_require(cell <= LOC_MASK, "phase118: reuse location exceeds private encoding");
  p118_reuse_drop(state->e, credit);
  return cell | ((uint64_t)cls_fit(count) << 40);
}

uint64_t p118_rt_reuse_extend(P111State *state, uint64_t parent, uint32_t cid,
                              const uint64_t *prefix, uint32_t count,
                              uint64_t credit, uint64_t *credit_out) {
  p118_reuse_check(credit);
  p111_require(cid < p111_program_active->constructor_count && count >= 1 &&
    count <= 7 && count + 1 == cid_arity(cid) && prefix && credit_out,
    "phase118: invalid reuse constructor-tail prefix");
  Env e = state->e; Cls cls = cls_fit(count + 1); Loc at;
  if (credit && p118_reuse_class(credit) == cls) {
    at = p118_reuse_location(credit); credit = 0;
  } else {
    at = heap_alloc(e, cls);
  }
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = prefix[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);
  }
  e.mem[at + count] = TERM_HOLE;
  Term node = term_ctr(cid, at);
  if (parent) p118_destination_fill(state, parent, node);
  *credit_out = credit;
  return node;
}

uint64_t p118_rt_reuse_finish(P111State *state, uint64_t root, uint64_t parent,
                              uint64_t result, uint64_t credit) {
  p118_reuse_check(credit);
  Term complete = p118_rt_finish(state, root, parent, result);
  p118_reuse_drop(state->e, credit);
  return complete;
}
