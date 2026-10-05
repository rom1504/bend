# Prioritized unvalidated follow-ups

Updated 2026-10-05. Final selection and release evidence belong to the
[phase report](README.md), not this list. The proposals below are not promoted
optimizations, forecasts of parity, or substitutes for qualification.

The complete array04 run passes45 points/669 samples. Its equal-point slowdown
is3.00678× pinned TypeScript versus3.08744× for freshly paired worker23, a1.02683×
gain. The modest aggregate contains a real scale tradeoff: the128-step fold
regresses7.705→16.362µs, while8192 steps improve173.065→110.662µs. The closed Bend
batch's much larger backing-view gain has a different entry/work schedule; it
cannot replace or be multiplied into the public-call score.
[Array04 results](evidence/corpus-array04.json), [guard study](evidence/array-guard-cost.json).

1. **Compose complete private proofs across existing lowering paths.**
   Array04's positive-depth edit-distance tree called a separate handle-based
   private helper, bypassing the optimized public root. Array05's shared tree
   adapter fixes that route; five-round screens improve the two positive-depth
   points1.840×/1.853× against worker23, remaining1.144×/1.135× TypeScript.
   Its159 independent recursive scalar oracles and11 boundaries are separate
   from final representative qualification. This is evidence for composing one
   representation contract through known private callers, rather than adding
   another public wrapper or a source-name selector. Next investigate finite
   function-target/capture facts before first-order admission: renamed lexical
   lambdas transported through helpers/records, then demanded factory results.
   Preserve curried prefix/argument order, shared captures and public escape.
   Morning remains a coverage problem; immediate beta reduction alone does not
   handle its returned functions passed through finishing helpers.
   [Tree evidence](../../selfhost/build/phase47/array05-tree-timing/report.json),
   [scope and controls](nested-array-entry.md), [outlier inventory](outlier-inventory.md).

2. **Model public entry cost and profitability as a general boundary problem.**
   Short calls repeatedly pay fresh host/input/source guards; longer private
   graphs amortize them. The integer-only array capability is a narrow reduction,
   not an unguarded default: canonical root/helper signatures and complete
   source/planned-term scans must exclude F32, including unused aliased inputs.
   `U32.div` emits `Math.floor`, so the existing integer hook subset needs that
   captured method in addition to retained `Math.imul`, Number/BigInt/Array,
   reflection, allocation and protocol checks. Fill/isSafeInteger, numeric and
   marker prototypes, Error suspension and nested-proof refusal remain required.
   The full guard has40 numeric checks; this subtype retains16 and omits five
   float-view checks. The saved integer-only screen reduces the short guard
   case15.879→14.075µs, far less than unsafe bypass; it does not qualify a later
   source guard or promise the same gain with the required floor check.
   Future work should measure a source-derived profitability rule or explicit
   caller/callee proof composition that checks a complete contract once at a
   real boundary. Do not infer a loop-count shortcut, cache permission across
   public calls, inherit stale proof, or erase mutation observations to recover
   the closed-batch speed. A sealed/immutable opt-in ABI would be a separately
   specified feature with escape analysis, not a replacement default metric.
   Candidate06 qualification/performance belongs to its own fresh receipts.

3. **Add public result adapters only with alias and demand proofs.**
   Generic row returns a composite result and remains refused. A future closed
   region could retain raw storage internally and reconstruct handles once at
   return. Prove result layout, tags, storage shape and repeated-reference
   sharing; preserve demanded fields and failures. Start with saved ablations
   and independently renamed results containing shared/distinct arrays, including
   mutation after return. No speed estimate follows from the scalar-root gain.

4. **Reduce duplicated private emission before broadening an inliner.**
   Raw and original helper closures currently coexist to preserve fallback.
   A representation-aware private call graph may share helpers without global
   emission state, mixed handle/raw calls or weakened fallback. Measure emitted
   size, import/startup and compiler work as well as runtime. The405-line worker
   cleanup passed its scoped controls but did not eliminate the intended shells
   on actual Map/record graphs;4.0%/1.9% drift-affected screens did not justify
   shipping it. First demonstrate one producer/projection chain left by existing
   passes and V8, then test a bounded value/use consumer there.
   [Deferred worker outcome](worker-outcome.md).

5. **Keep compiler query reuse on its separate cost track.**
   The request-local exact book/type Boolean memo screen reduces one lexer
   request6.64%, despite roughly51% repeated queries. No production cache is
   installed. Replicate on an independent request, then measure Bend key/table,
   miss, lifetime and retention costs before implementation. Source-only Base
   prefixes cannot restore chronological checker memo/output state; skipping
   rechecking is a different state-checkpoint project. Preserve first diagnostics,
   recursive budget refusals and changed source/import/API boundaries.
   [Compiler memo outcome](compiler-memo-outcome.md).

Historical Phase45 frontend/backend inventories and earlier owner controls keep
only their original scope; this phase's eight maintained suites and focused array,
tree and host tests do not relabel those inventories as freshly rerun. Preserve
all failed fixtures, admission refusals, parser errors, adverse timings and unsafe
diagnostic derivatives. The native IO.args mismatch remains unresolved. Final
release receipts must identify the exact selected API/runtime and renewed checks;
no subset result establishes universal speed, full host equivalence or parity.

## Defer moving array snapshots into root closures

Moving fill/isSafeInteger captures from the prelude into each root closure could bless an earlier foreign initializer's replacement hooks.
[foreign.bend:77](../../selfhost/src/back/js/foreign.bend#L77) executes foreign JS in a top-level IIFE; [typed-driver.mjs:565](../../selfhost/tools/typed-driver.mjs#L565) places it after the runtime but before generated definitions.
This is an unexecuted semantic counterexample, not evidence that capture placement caused the measured ~4% tree regression; its JIT cause remains unresolved.
Keep capture timing unchanged for this release. A future optional guard fragment could use explicit selected-feature metadata and execute at the same early prelude boundary before foreign modules.
That requires emission-order/driver work and independent initializer controls; a root-local textual move alone is insufficient.
