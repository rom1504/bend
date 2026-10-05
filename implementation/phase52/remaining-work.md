# Phase52 remaining work

This separates checked observations from prospective changes. Candidate05 is
usable for its exercised scope, with explicit opt-in direct output; release
installation and full45 measurements are still separate pending decisions.

## Observed limits to preserve

- The candidate05 semantic controller completes90 scenarios with89 passing. Its
  aggregate report is failed. `f32_table_nan_bits` has source oracle40, pinned TS
  value1 and direct value39 under the selected Node host. Both fail the oracle;
  matching one erroneous value is not source correctness.
- Upstream constant F32 table folding serializes Number NaNs as bare `NaN`,
  losing payloads. Direct currently emits dynamic conversions instead. Runtime
  helpers are byte-identical; this difference occurs in generated code. The
  direct single mismatch is not localized by aggregate outputs. A bounded cold
  then repeated per-index bit trace is the next diagnostic, not a claimed fix.
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
2. Assess eliminating tiny named native wrappers when templates receive already
   evaluated operands. Repeating template operands, discarded arguments,
   curried stages, effects and thrown conversions still require left-to-right
   once-only evaluation. A possible roughly10% opportunity is speculation, not
   a measured isolated gain or a promised corpus improvement.
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
