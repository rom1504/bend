# P131-004 — compose verified readers with scalar product consumers

Status: source06 passes independent review, native transfers and timing; final
composition is admitted but not yet native-qualified.

Hypothesis: reuse the existing traversal and borrowed product contract, expose
its scalar result virtually and retain the original owning fallback. The
actual callable bundle must contain the consumer; mere eligibility is useless.

Initial versions produced byte-identical whole QBE: they never installed the
consumer. The successful version closes already retained raw candidates and
retries against actual workers. It does not repeat frontend preparation.

Five clean paired rounds: short String/list queries take48.3%/44.8% less time
than parent. A closure-only control explains most of this. Projection itself
adds10.5%/11.2% improvement on short inputs; long-input incremental gain is
negligible/about2%. Instrumentation separately records89.2% fewer allocations
and29.9% fewer takes, with unchanged dispatch count versus closure-only.

Original product reader bodies are byte-identical. Each owning fallback matches
the closure-only ordinary body. Native oracles include retained aliases and
4096-element prefixes; no universal ownership or backend proof is claimed.

[Results and exact pins](../../selfhost/tools/performance/phase131/projection/RESULTS.md),
[independent audit](../../research/phase131/projection-review.md).
