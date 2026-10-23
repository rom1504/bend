/* Additive helper for a source-certified Nat.divmod product. Exact arithmetic
 * copied from P111_OP_NAT_DIVMOD; no Tuple allocation or ownership operation.
 * The checked import proves a writable local buffer of at least16 bytes.
 * Both operands are full uint64_t values. A zero divisor is valid Bend input. */
uint64_t p126_rt_nat_divmod(P111State *state, uint64_t a, uint64_t b,
                          uint64_t *out) {
  (void)state;
  p111_require(out != NULL, "phase126: missing Nat.divmod product output");
  out[0] = b == 0 ? 0 : a / b;
  out[1] = b == 0 ? a : a % b;
  return 0;
}
