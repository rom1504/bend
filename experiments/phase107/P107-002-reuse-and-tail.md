# P107-002 — bounded call-graph analysis, tail recurrence and reusable units

2026-10-18. Closing status: bounded transformations and reusable-object controls
passed at their finite boundaries. Broader runtime migration remains open.

Initial hypotheses after the first32s paired screen:

- Separating depth-bounded purity admission from depth-bounded expansion can
  remove more helper boundaries without losing the global growth limit.
- Turning scalar self-tail recurrence into explicit loops removes stack/call
  cost independently of machine backend; exact argument snapshots and local
  reset are required. Unsupported patterns must remain unchanged.
- A small entry-function body emitted directly under the runner ABI removes
  an adapter call that Clang already removes. This primarily affects tiny
  functions; do not extrapolate it to long-running compiler workloads.
- Content-addressed function objects can cheaply replay a small edit. Keys must
  bind transformed IR, signatures, runtime ABI, producer/backend identity,
  target and flags; changed ABI or corrupt objects must invalidate reuse.

Keep first-pass artifacts and timings fixed. Add finite/negative controls before
paired screens. Measure reuse cold, unchanged, one function edited, changed ABI
and corrupted cache. Distinguish fully checked source loops from checked-graph
replay, object construction, link and repeated execution. No claim of recursive
acceleration or whole-compiler incremental correctness from this bounded seed.

## Closed evidence

- [Inlining audit02](../../selfhost/build/phase107/audit02/report.json): 108
  transformations/696 finite input pairs and three detected semantic mutants.
- [Tail audit02](../../selfhost/build/phase107/tail-audit02/report.json): eight
  structural comparisons and 69 native outputs, including six million-step
  observations. `tail_dead` is invalid IR; seven historical interpreter rows
  for it are excluded from semantic acceptance, as explained in the
  [inlining report](../../implementation/phase107/inlining.md).
- [QBE fusion controls](../../selfhost/build/phase107/qbe-fused-controls01/report.json)
  cover entry ABI, recursion/address-taking and bounded fusion. Later composed
  timings are not a fusion-only ablation.
- [Native real-cache02](../../selfhost/build/phase107/native-real-cache02/report.json):
  12 builds/120 outputs, same-path helper edit reuse, ABI invalidation and corrupt
  artifact recovery. Frontend checking and linking still run. Raw separate units
  and optimized whole-object mode are different policies, not an isolated
  unit-granularity comparison.

See the [phase report](../../implementation/phase107/README.md) and
[complete-path measurements](../../implementation/phase107/supervision.md).
Self-tail support is not mutual-tail support; machine-object reuse is not
incremental checking, full self-hosting or recursive research acceleration.
