# P115-004: remove an unnecessary baseline wrapper lookup

Final source review found that the experimental legacy evaluator looked up the
direct-worker signature before checking whether policy0 should call the unchanged
Phase114 hook, which then performs its own lookup. This does not change QBE but
adds baseline work and can bias the reusable-plan timing.

Source04 moves the policy0 branch before that lookup. Its false branch calls a
new helper containing the unchanged non-default behavior. No planner, policy,
case, oracle, warmup or repetition count changes. API04/manifest03/replay-v3
rerun the full six-case matrix; every emitted product must also equal its exact
prior matrix02 product. The native execution campaign can then be reused by
product identity, with explicit lineage rather than another identical build.

Matrix02 remains historical evidence, not the final timing denominator. The
independent 17-line negative-decision experiment calls full original/candidate
emitters directly and never uses this wrapper, so that result is unaffected.
