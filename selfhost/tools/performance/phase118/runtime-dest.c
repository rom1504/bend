/* Private destination contract. Only the checked constructor-tail producer may
 * call these operations. A raw root and its current raw parent remain private;
 * no partial node is observable by source code. Links use ordinary rfc_seal.
 * This does not infer unique input ownership or reuse input storage. */
static void p118_destination_fill(P111State *state, Term parent, Term value) {
  u32 cid = (u32)term_aux(parent);
  p111_require(term_tag(parent) == TAG_CTR && !term_rfc(parent) &&
    cid < p111_program_active->constructor_count && cid_arity(cid) >= 2 &&
    cid_arity(cid) <= 8 && term_loc(parent) >= HEAP_OFF,
    "phase118: invalid private destination");
  Loc slot = term_loc(parent) + cid_arity(cid) - 1;
  p111_require(state->e.mem[slot] == TERM_HOLE, "phase118: destination already initialized");
  state->e.mem[slot] = rfc_seal(state->e, value);
}

uint64_t p118_rt_extend(P111State *state, uint64_t parent, uint32_t cid,
                        const uint64_t *prefix, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count >= 1 &&
    count <= 7 && count + 1 == cid_arity(cid) && prefix,
    "phase118: invalid constructor-tail prefix");
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(count + 1));
  for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);
  e.mem[at + count] = TERM_HOLE;
  Term node = term_ctr(cid, at);
  if (parent) p118_destination_fill(state, parent, node);
  return node;
}

uint64_t p118_rt_finish(P111State *state, uint64_t root, uint64_t parent, uint64_t result) {
  if (!parent) {
    p111_require(!root, "phase118: empty destination root mismatch");
    return result;
  }
  p111_require(root && term_tag(root) == TAG_CTR && !term_rfc(root), "phase118: missing destination root");
  p118_destination_fill(state, parent, result);
  return root;
}
