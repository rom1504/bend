# P134-001 — Bounded native emission

Started 2026-10-24 03:00 UTC at `ed0a842`. Status: in progress.
[Plan](../../design/phase134/README.md).

Hypothesis: the existing verified pipeline can return a sealed rendering plan;
the native IO consumer can render/write/release each function and bounded data
piece rather than retain all textual QBE. Complete emitted bytes and existing
optimization decisions must remain identical. The whole structured program is
retained initially; this is not a bounded-total-IR claim.

The selected runtime lacks IO.write but already supports File.open/write/close.
Test an owned `/dev/stdout` descriptor in append mode, retaining the exact native
IO.print LF at each historical chunk boundary. It must support long data lines,
pipe and file output and explicit write failures without a runtime modification.

Independent work: emission cursor and all successful route inventory; conservative
early lowering reuse; metric adapters. Root owns source integration and one heavy
execution lane. Preserve Phase131 and all unrelated workspace modifications.

First falsifiers: independent source checking, finite cursor/byte equivalence,
small real requests, then native image acquisition and one required full request
with exact output and memory observation. No gain or qualification yet claimed.

03:45 checkpoint: source02 has passed independent source checking,15 finite
controls, exact native self-reproduction, focused19 on both generations and
ordinary45 on N2. All45 hosted repetition-wrapper products also match the frozen
native reference. The native wrapper bridge remains a separate pending gate.

Same-source full-request observations reduce peak sampled RSS2.909→1.006GB,
but increase elapsed378.760→392.994s. The controlled three-request screen is
2.49% slower than Phase131 N2. This is a qualified memory improvement, not a
speed-default promotion. A separately checked packet writer is being acquired.
See [report](../../implementation/phase134/README.md) and the immutable
[checkpoint archive](../../implementation/phase134/stream/receipt.json).
