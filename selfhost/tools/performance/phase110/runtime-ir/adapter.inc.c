/* Private entry/slow-path ABI for the exact Bend-generated runtime templates.
 * No source worker, ownership fast path or new allocator is implemented here. */
_Static_assert(sizeof(Term) == 8 && sizeof(Loc) == 8 && sizeof(void*) == 8,
  "private runtime IR requires 64-bit host words");
_Static_assert(DEVICE == 0 && LANE_STEP == 1 && ALC_WORDS == 32,
  "private runtime IR requires CPU allocator layout");
_Static_assert(HEAP_OFF == 51413376 && CAP_WORDS == 32768,
  "private runtime IR layout constants differ");
_Static_assert(LOC_MASK == 1099511627775ull && RFC_BIT == (1ull << 63)
  && RFC_CNT == 16777215 && TAG_CTR == 2,
  "private runtime IR Term constants differ");

uintptr_t nx_rt_ir_heap(NxRt *ctx) {
  Env e = nx_env(ctx);
  nx_require(!io_gpu && KEEP_WORDS == CAP_WORDS && e.alc == ALC[0]
    && ctx->pending == 0, "private runtime IR requires clean single-thread CPU context");
  return (uintptr_t)e.mem;
}
uintptr_t nx_rt_ir_alc(NxRt *ctx) {
  Env e = nx_env(ctx);
  nx_require(!io_gpu && KEEP_WORDS == CAP_WORDS && e.alc == ALC[0]
    && ctx->pending == 0, "private runtime IR requires clean single-thread CPU context");
  return (uintptr_t)e.alc;
}
uint64_t nx_rt_ir_alloc0(NxRt *ctx) {
  return heap_alloc_miss(ctx->env, 0);
}
uint32_t nx_rt_ir_hand0(NxRt *ctx) {
  heap_hand(ctx->env, 0);
  return 0;
}
uint64_t nx_rt_ir_view(NxRt *ctx, uint64_t loc) {
  return rfc_view(ctx->env, loc);
}
