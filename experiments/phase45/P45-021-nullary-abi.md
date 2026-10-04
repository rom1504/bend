# P45-021: nullary roots with preserved public code metadata

Status: implemented on frozen `source-worker19`, integrated after checked build,
eight maintained suites, independent controls and an eleven-point screen. Full
release qualification and installation remain pending. This is separate from
P45-019 primitive capability pruning: it preserves that baseline's exact fence
and full host/String guards. P45-020's profitability widening remains rejected.

`selfhost/tools/performance/phase45/nullary-abi-preserved21-v3.patch` applies to
the frozen19 source (static `git apply --check` passes). V1/V2 remain preserved;
V2 recognized demanded nullary source references in the graph prefilter. Review
found V2's raw no-argument getter exposure and unsafe legacy fallback; V3 fixes
both. No V2 qualification is claimed.
Earlier07 measurements do not qualify this implementation.

The existing ordinary nullary descriptor has `arity=0`, empty bound captures,
and normal `function(){...}` code: length0, empty name, own prototype and normal
constructibility. Old07's generic exact wrapper changed code.length to1. The
proposal extends `exactCode(inner,arrow=false,nullary=false)` with a distinct
normal anonymous zero-formal function branch. It reads `arguments[0]` only when
`arguments.length !== 0`, preventing raw no-argument calls from observing an
inherited numeric getter that the original wrapper never read.
Only nullary contextual roots request it; positive-arity and arrow wrappers keep
their existing code. Raw invocation receives no new permission. Exact saturated
public invocation retains its existing one-use token, environment evaluation
order and finally cleanup. Oversaturation still takes the original ungranted
path. New invocation preserves normal constructor return rules.

Admission reuses complete typed graph validation, bounded source instance facts,
source/native identity fences, worker lowering and current root profitability
selection. It admits zero source arity but does not admit arbitrary literal
roots. The existing non-Base/real-contextual Base-root requirement is unchanged.
Scalar/String results remain the only public result boundary. Computed nullary
source references are demanded calls: collect their complete bodies, rewrite
known references to private graph names, and lower an exact known private
zero-argument reference into the existing direct-call instruction. String literal
globals retain their existing guarded load. Unknown/malformed references fail
typed graph validation or worker lowering. If worker lowering refuses a graph
with any original zero-arity row, legacy private emission is conservatively
declined: its coverage pass does not rewrite private nullary references. Ordinary
source emission remains available; no unbound private registry load is emitted.

The runtime fragment and concatenated `src/runtime.mjs` change together. The
ordinary driver prepends `runtimePath` at `tools/typed-driver.mjs:565`; fresh
checked acquisition must bind that selected runtime, not an old saved module.

Independent fixture/controller work is delegated to the IR owner under explicit
root authorization: `nullary-demand21-catalog-v1.json`,
`fixtures/nullary-demand21-v1.bend`, `nullary-demand21-controls-v1.mjs`.
Qualification must check ordinary entry and complete values, descriptor/code
metadata, raw calls with arbitrary/no argument vectors, constructor calls,
oversaturation, mutated G/code/env/bound, Error hook reentry and proof cleanup.
Unsupported object/function/IO results must remain generic. The executed outcome
below supersedes this original protocol; root serializes all execution.

## Executed outcome

V3 builds as `checked-worker21` in 53.20 seconds; all eight maintained suites
pass. The original independent fixture failed baseline type checking because a
Nat literal lacked an annotation; `nullary21-baseline` preserves that failure.
Fixture/catalog v2 correct only that annotation. Controller v3 retains every
reviewed assertion and passes six oracles, 39 boundary observations, six private
activation observations and nine descriptor-metadata comparisons against fresh
worker19, worker21 and pinned TypeScript acquisitions. Raw direct, `.call` and
construction with no argument vector preserve inherited-index-getter behavior.

The 60-second-preset screen has eleven complete points (three serial runs,
actual combined wall 84.1 seconds). Relative to freshly sampled Phase44, RLE
improves 1.5315× and Map/Set 1.4317×; they still take 53.40× and 66.71× TypeScript
time. Morning/evening are effectively unchanged. The five maintained fast
canaries have no large regression; the row median regresses 3.65%. Map128 and
records256 retain the campaign gains: 16.31×/52.68× faster than Phase44 and
1.721×/1.551× TypeScript time. These latter figures measure the combined candidate,
not the isolated nullary change.

Evidence: `selfhost/build/phase45/checked-worker21/attempt.json`,
`qualify-worker21/report.json`, `nullary21-controls-v3/report.json`,
`runtime-worker21-{fast,nullary,map-record}/report.json`. The candidate API hash is
`73849dff4f47792ca134374d1a92d775da5efbc5bfdd6aa30f07b78fb5716fb8`; emitted runtime
is `23166fef7cc7434e1118bde889704b2d07e681f11d69d4e68e1acd4977dacd49`.
These raw campaign files will be bound by the final preserved evidence package.
