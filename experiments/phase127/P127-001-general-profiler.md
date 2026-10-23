# P127-001: can reusable attribution explain native compiler cost?

Status: reusable profiler and causal diagnosis demonstrated; final consolidation
in progress. Parent `6fe4f29`; start2026-10-23 09:44 UTC.

Hypothesis: unchanged-binary samples plus a small generic context/counter layer
can distinguish repeated compiler work from runtime representation costs, making
the next optimization decision more precise without another broad rebuild.

Design: [general native profiler](../../design/phase127/general-native-profiler.md).
Qualified Phase125/126 N1 images and each image's own complete emitted-QBE oracle
are the initial fixed inputs. Independently specified ordinary programs test
generality. Clean timings and diagnostic captures are separate artifacts.

Falsifier: attribution stays in undifferentiated runtime helpers, changes program
output, materially distorts the computation without a useful clean counterpart,
or requires more machinery than its first measurable insight justifies.

At the start, disk had147MiB free. The already-extracted official Lean archive
was removed as a recoverable download cache; its hash/URL and recovered bytes
are recorded. Later exact-oracle output hardlinks retain every evidence path
while recovering duplicate output space.

The profiler now distinguishes physical leaves, authenticated one-frame callers,
active dispatch context, conditional lowered owners, direct-entry dispatches,
and16 runtime event channels. It has found both the lost whole-program
transport admission ([P127-002](P127-002-live-bank-admission.md)) and fixture-
specific duplicated lowering ([P127-003](P127-003-repeated-lowering.md)).

Ordinary Mandelbrot and tree-bitonic batches pass50 output-checked observations.
Their profiles differ materially: numeric generated code versus ownership,
allocation and continuations. Counter files repeat byte-for-byte across three
runs each; leaf sampling adds about1% CPU, context-only links5–12%, and detailed
counters25–90%. Instrumented timings are therefore never performance claims.

The independent three-segment runtime fixture passes all16 expected channels.
A stronger nested-Tuple test initially exposed a mistaken hand model: the
runtime seals the nested constructor with one additional RC cell. The original
failed expectation is retained; source tracing explains the extra allocation,
refill and free, and the corrected expectation passes. This is a corrected
source-audited control, not a blind first-run prediction.

Other retained failures: a2GiB checked-API acquisition was stopped by the RSS
guard and passed with a4GiB bound; a stale tooling pin rejected a prepared
ordinary-program plan after the runner changed; a full-request launch was
refused for insufficient disk before execution. Fresh plans and exact-byte
deduplication resolved these without weakening gates. An early section-inspection
script read NOBITS as file data; the durable machine comparison correctly treats
it as a zero-initialized extent.

The same-source causal image improves repeated small N1 requests11.37%
geometrically and the single full-source request9.95%. Full-source deep
profiling now includes55,761 uninstrumented physical samples,36,220 diagnostic
context samples and an ordered CPU timeline. Full-scale ownership/name-search
costs differ materially from fixed short-request preparation. Evidence,
limitations, cost and next steps belong in
the [report](../../implementation/phase127/README.md).
