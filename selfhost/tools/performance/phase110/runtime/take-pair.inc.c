/* Generic atomic transfer: consume one binary parent, shallow-free its shell
 * through the unchanged production operation, return its two owned children.
 * No context scratch is read/written and no constructor is rebuilt. */
NxRtPair nx_rt_pair_take2(NxRt *ctx, uint64_t parent) {
  Env e = ctx->env;
  Term old[2];
  Loc spare = ctr_take(e, parent, 2, old);
  spare_free(e, cls_fit(2), spare);
  NxRtPair result = {old[0], old[1]};
  return result;
}
