/* Only the uncommon class1 free-list handoff is added. Generated Take2 uses
 * the same production hot-list state and the same production heap_hand. */
uint32_t nx_rt_ir_hand1(NxRt *ctx) {
  heap_hand(ctx->env, 1);
  return 0;
}
