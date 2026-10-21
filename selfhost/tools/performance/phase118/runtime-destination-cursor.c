/* Private TRMC cursor, independent of source Term encoding: low40=heap slot;
 * bit63=that slot's parent's seal policy. Zero means no pending destination.
 * Root remains an ordinary owned Term. No cell reuse/global scratch is added. */
#define P118_CURSOR_SEAL (UINT64_C(1) << 63)

static void p118_cursor_fill(P111State *state, uint64_t cursor, Term value) {
  Loc slot = cursor & LOC_MASK;
  uint64_t end = HEAP_OFF + ((uint64_t)a32_load_acq(a32_at(state->e.mem, H_CAP)) << PAGE_BITS);
  p111_require(!(cursor & ~(LOC_MASK | P118_CURSOR_SEAL)) && slot >= HEAP_OFF && slot < end,
    "phase118: invalid private destination cursor");
  p111_require(state->e.mem[slot] == TERM_HOLE, "phase118: destination already initialized");
  state->e.mem[slot] = (cursor & P118_CURSOR_SEAL) ? rfc_seal(state->e, value) : value;
}

uint64_t p118_rt_extend_cursor(P111State *state, uint64_t cursor, uint32_t cid,
                               uint64_t *prefix, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count >= 1 &&
    count <= 7 && count + 1 == cid_arity(cid) && prefix,
    "phase118: invalid constructor-tail prefix");
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(count + 1));
  bool seal = !(p111_program_active->capabilities & UINT64_C(8)) || cid_hot(cid);
  if (!seal) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = prefix[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);
  }
  e.mem[at + count] = TERM_HOLE;
  Term node = term_ctr(cid, at);
  if (cursor) p118_cursor_fill(state, cursor, node);
  p111_require(at <= LOC_MASK - count, "phase118: destination cursor exceeds location encoding");
  /* All prefix reads finish before writing the fresh output word. The caller's
   * verified local buffer is writable and separate from heap/source owners. */
  prefix[0] = (at + count) | (seal ? P118_CURSOR_SEAL : 0);
  return node;
}

uint64_t p118_rt_finish_cursor(P111State *state, uint64_t root, uint64_t cursor, uint64_t result) {
  if (!cursor) {
    p111_require(!root, "phase118: empty destination root mismatch");
    return result;
  }
  p111_require(root && term_tag(root) == TAG_CTR && !term_rfc(root), "phase118: missing destination root");
  p118_cursor_fill(state, cursor, result);
  return root;
}
