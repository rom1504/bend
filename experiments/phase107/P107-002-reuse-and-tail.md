# P107-002 — bounded call-graph analysis, tail recurrence and reusable units

2026-10-18. Hypotheses after the first32s paired screen:

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
