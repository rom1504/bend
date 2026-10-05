# Phase52 remaining work

This separates checked observations from prospective changes. Candidate06 is
usable for its exercised scope, with explicit opt-in direct output; release
installation and full45 measurements are still separate pending decisions.

## Observed limits to preserve

- The candidate06 semantic controller completes96 scenarios with95 passing
  (candidate05 previously completed90 with89 passing). Its
  aggregate report is failed. `f32_table_nan_bits` has source oracle40, pinned TS
  value1 and direct value39 under the selected Node host. Both fail the oracle;
  matching one erroneous value is not source correctness.
- Upstream constant F32 table folding serializes Number NaNs as bare `NaN`,
  losing payloads. Direct currently emits dynamic conversions instead. Runtime
  helpers are byte-identical; this difference occurs in generated code. The saved host diagnostic confirms bare NaN bits2143289344 versus dynamic
  quieted payload bits2143289345/6/7 for source signaling bits2139095041/2/3.
  Its repeated host oracle also returns1 after those row observations; this
  demonstrates that a one-off row trace does not establish invariant payload
  transport. Direct's single failed comparison remains unlocalized. A cold then
  repeated per-index trace of both source expression paths is the next diagnostic,
  not a claimed fix.
- Numeric match-table lowering is absent from direct. Upstream table reads use
  Math.min; direct branches use different comparisons/coercions. Post-import
  Math.min/coercion hooks and native conversion observations can differ.
  Earlier Word matcher conversion/order fixes address their tested cases, not
  every global-hook/table combination. Preserve those contract limits explicitly.
- Direct reachability/tail analysis admits at most512 selected definitions, with
  additional node/edge budgets. Larger graphs fail explicitly; no legacy or
  TypeScript fallback is hidden behind a successful direct artifact. Raise these
  limits only with bounded compile-cost and refusal tests.
- Pure/selected IO/FFI observations do not establish all Node system effects.
  Pinned syscall/polling paths still require Bun FFI or a suitable BEND_SYS
  provider; non-tail recursion and branching host marshalling retain native
  stack limits.

## Plausible next changes, unvalidated

1. Define payload-correct F32 constant/table lowering from exact source U32 bits,
   rather than serializing a JavaScript Number NaN. A table of raw bits with
   demanded conversion is a candidate, but must preserve conversion/hook order
   and be tested at cold, warmed and host-mutated boundaries. Do not canonicalize
   every NaN merely to force one reference value. A pinned-upstream bug needs an
   explicit contract decision and regression control.
2. Candidate06's small intrinsic-lowering change has a modest observed gain;
   attribution and full45 conclusions remain in the root's measurement report.
   The parameter-IIFE successor07 was rejected. A future ordered statement
   emitter must preserve once-only argument evaluation, partial-call staging,
   lazy demand and host/throw order without creating a function per expansion.
   No further gain is established; see the bounded next step below.
3. Measure direct compilation throughput and budget scaling before introducing
   query caches or larger graph limits. Generated-program execution timings do
   not measure compiler request latency. No new compiler-throughput result or
   self-emitted fixed point is established by this phase's checked B1 builds.

Full45 performance, default-JS compatibility, installation/relocation and direct
runtime inventory integrity must be reported independently of the semantic
controller. Keep the NaN failure, earlier failed attempts and actual checked
identities linked in the phase report; never relabel89/90 as a complete PASS.

[User guide](../../selfhost/docs/direct-javascript.md),
[parity contract](parity-contract.md),
[comparison method](../../selfhost/tools/performance/phase52/README.md).

## Candidate06 NaN decision

A general fix is not established within the short investigation. Upstream's
`js_expr` serializes a constant F32 NaN through `String(v)` and therefore loses
its payload before execution. Direct's dynamic `f32_from_bits`/`f32_bits` path
retains distinct quieted payloads in the saved host rows but still returns39
for the full source test. Both use JavaScript Number transport and the same
Float32Array helpers; changing only a constant spelling cannot repair all
observations. Canonicalizing NaNs globally could make both source paths equal,
but would change observed raw bits and conversion hooks and does not satisfy
the current TS differential result. Exact raw-bit representation/transport or
a narrowly proved cancellation pass needs a new explicit semantic experiment.
No oracle weakening, cold-call warmup workaround or benchmark-specific rewrite
is recommended for the frozen release candidate.

## What the rejected IIFE experiment changes

[P52-003](../../experiments/phase52/P52-003-ordered-intrinsics.md) passed all72
screen output checks but was1.25746× slower than06 geometrically; Mandelbrot was
3.568× slower. Generated `mit` replaced nested intrinsic calls with nested arrow
IIFEs. This rejects that lowering under the measured conditions; it does not
identify a V8 inlining, allocation or deoptimization cause without profiles.
Candidate06 source was restored, and the07 artifacts remain retained.

The next bounded compiler change would return **ordered statement prefixes plus
one value** from expression lowering, as pinned `js_call`/`emit_hold` do. Before
emitting a later operand's prefix, materialize any earlier operand whose pending
evaluation can observe effects. Keep prefixes inside their original branch,
closure and demanded expression; preserve erased/partial application boundaries
and usage/reference metadata. Start with admitted intrinsic applications and
verify the emitted straight-line code before timing. The existing
[Go ordering survey](../../research/compilers_architecture_and_techniques/go.md)
and [LLVM invariants](../../research/compilers_architecture_and_techniques/llvm.md)
support explicit evaluation order, not a promise that this change will be faster.

Numeric tables are a separate opportunity: raytrace's five scalar lookup
functions use reference tables while direct output still executes selected
branches/conversions. They do not explain the whole Mandelbrot gap. Any table
experiment needs its own bounded folding policy, import-time versus demand-time
hook controls and the unresolved NaN/raw-bit contract above; do not combine it
with statement lowering in the first causal measurement.
