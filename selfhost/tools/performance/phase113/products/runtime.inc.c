/* Additive profile11301. Append to the exact runtime04 translation unit.
 * State ABI11101, array layout flags and all underlying operations are unchanged.
 * This replaces only the temporary Tuple carrier. Input and output fields each
 * retain their ordinary ownership credits; no borrowed array payload escapes.
 */
uint64_t p113_rt_array_pair(P111State *state, uint32_t op,
                         const uint64_t *args, uint32_t count,
                         uint64_t *out, uint32_t out_count) {
  uint32_t arity = 0;
  switch (op) {
    case P111_OP_ARRAY_GET: arity = 2; break;
    case P111_OP_ARRAY_SWAP: arity = 3; break;
    case P111_OP_ARRAY_SIZE:
    case P111_OP_ARRAY_CLONE: arity = 1; break;
    default: err_fail("phase113: unsupported array pair operation"); return 0;
  }
  p111_require(count == arity, "phase113: array pair argument count mismatch");
  p111_require(out_count == 2, "phase113: array pair output count mismatch");
  p111_require(state != NULL && args != NULL && out != NULL,
               "phase113: array pair missing state or buffer");
  /* Snapshot input words before output stores, including permitted buffer alias.
   * The authenticated compiler uses distinct local input/output buffers. */
  Env e = state->e;
  Term array = args[0];
  uint32_t index = arity > 1 ? (uint32_t)args[1] : 0;
  Term value = arity > 2 ? args[2] : 0;
  Term second = 0;
  switch (op) {
    case P111_OP_ARRAY_GET: second = native_array_get(e, array, index); break;
    case P111_OP_ARRAY_SWAP: second = native_array_swap(e, array, index, value); break;
    case P111_OP_ARRAY_SIZE: second = 1ull << blk_cls(array); break;
    case P111_OP_ARRAY_CLONE: second = blk_copy(e, array); break;
    default: err_fail("phase113: impossible array pair operation"); return 0;
  }
  out[0] = array;
  out[1] = second;
  return 0;
}
