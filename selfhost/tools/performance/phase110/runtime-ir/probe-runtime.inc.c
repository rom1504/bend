/* Test-only adapter for returning the second owner from an exact generated
 * operation probe. Timed/source-generated workers never import this function. */
uint32_t nx_rt_ir_probe_transfer(NxRt *ctx, uint64_t remaining) {
  (void)nx_env(ctx);
  nx_require(ctx->pending == 0, "runtime IR probe has pending child");
  ctx->fields[0] = remaining;
  ctx->fields[1] = TERM_HOLE;
  ctx->pending = 1;
  return 0;
}
