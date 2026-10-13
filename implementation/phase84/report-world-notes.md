# Phase84 report-world prototype

Agent handoff notes; see the [final Phase84 report](README.md) for root-run
measurements, completed controls and rejection/deferral decisions.

Prepared against `7352a0048c84a4eb48d8197169858b5fb262c229`. This is a
**prototype handoff, not a measured or qualified improvement**. The agent made
temporary source copies, a patch and this note; it ran no compiler targets.
Root owns application, checking, measurements and promotion.

Patch: [report-world.patch](../../experiments/phase84/prototypes/report-world.patch).
It adds 17 Bend lines in the existing report module, one optional bootstrap API
export, and one ordinary-driver dispatch alternative. No module, compiler IR,
prepared artifact, public result field or cache format is added.

## Selected smallest variant

The current report query canonicalizes all source declarations with
`book_final_fast`, then builds a new complete name index. The loader already
has an exact prepared Base index (`FReadyPrefixState.names`) and an exact fresh
source suffix (`FPrefixLoad.suffix`). The new private entry overlays that suffix
onto the existing Base index using `f_prefix_names_extend`, places the result
in the existing `BookCache` representation with bound zero, and calls the
unchanged `dr_cached_names` traversal.

The old `driver_report_data`, `driver_report`, `driver_bad_names`, verdict
formatting, root order and safe-closure traversal remain unchanged. This first
variant isolates eliminating whole-Base final selection/index construction.
It does not claim to implement the reverse-dependency algorithm.

The host passes **loaded source**, not the checked or specialized book. It
selects the new API only for its actual owned compiler, actual completed load,
and admitted cached frontend state. Both Bend readiness flags must be true;
otherwise the original query runs. Older images, injected/raw API objects,
custom/non-admitted loads and missing optional exports retain their old path.
The existing Base index was already constructed and decoded before this
experiment; no new work moves outside the timed request.

## A semantic trap caught during review

Do **not** simply retain `FReadyPrefixGraph.names` from before graph freshening.
Freshening is more than binder-number changes: `ffw_walk_existing` rewrites
`FGlobal` to `Ref`, and `ffw_walk` resolves `FName`. In particular, the parser
produces `FGlobal("Empty")` for negative equality. A pre-fresh report index
could therefore lose proof dependencies.

The patch avoids that issue by using the certified already-fresh Base index
and overlaying the **actual freshened suffix**. `FPrefixLoad.ready` is true
only on the admitted leading-Base path after actual suffix freshening. The
existing host admission binds the Base state to the exact API, Base bytes,
path, source interval and producer. No caller-provided source metadata is
newly trusted.

The name-index equivalence follows source event order: the Base index retains
its latest event for each name; `f_prefix_names_extend` updates each fresh
suffix event in chronological order. This is the same latest-definition
selection as `book_final_fast` followed by `book_cached`. Law/fill pairs must
therefore be included in controls.

`kr_parent` still sees the chronological source list after the synthetic cache
head, rather than the canonical final list. Successfully checked loader input
has unique ADT and constructor declarations, so its constructor-owner result
is unchanged. The original arbitrary-book APIs keep their original behavior.
Constructor collisions/duplicate ADTs are required rejection controls, not a
permission to change their error order.

## Required fast controls

Run one instrumented **correctness-only** request derivative. Wrap the owned
API's new export after `loadApi()`; for every real host invocation compare the
new result against `driver_report_data(book)` and also verify that the actual
load's `trace.result.book` equals the supplied source book. Return the new
result unchanged. These doubled report queries must not supply speed numbers.

```js
const selected = api.driver_report_prefix_data;
api.driver_report_prefix_data = (book, load, state) => {
  assert.strictEqual(book, load.trace.result.book);
  const actual = selected(book, load, state);
  assert.deepStrictEqual(actual, api.driver_report_data(book));
  return actual;
};
```

Compare complete report objects, including name order and all verdict bytes.
Also compare full ordinary request observations—`proofTrust`,
`unsafeDefinitions`, `kernelChecked`, status, exit code and emitted C—against
the preceding candidate. Suggested focused inputs:

1. All eight Phase83 sources, particularly `functions65` and `small`.
2. `tests/import/unsafe_used.bend`, `unsafe_unused.bend`,
   `unsafe_law_derived.bend`, `unsafe_law_fill.bend`,
   `unsafe_law_own.bend`, and `unsafe_law_unused.bend`. Preserve the expected
   distinction between type acceptance and proof trust.
3. `tests/halt/sugar_self_call.bend`: negative equality exercises the
   freshening trap; it also has ordinary law/fill pairs.
4. `tests/import/alias_twice.bend`, `alias_shadow.bend`, `alias_decl.bend`
   and `tests/parse/law_fill_arrow.bend`, retaining both successful reports
   and existing rejection behavior.
5. `tests/parse/duplicate_ctor_name.bend`, `tests/page/ambiguous_ctor_error.bend`
   and foreign-name/constructor collisions: failures must occur before the
   new report query, just as before.
6. A successful typed source whose unsafe reference occurs only in a type or
   constructor field; an unsafe root with shared/cyclic dependencies. Because
   the traversal is unchanged, these chiefly check index selection.
7. Legacy/raw report APIs on existing arbitrary-book controls, unchanged.
   Confirm an injected API does not acquire the owned-only dispatch.
8. Capture a real load/state, set either readiness flag false in a **separate
   direct control**, and compare the new entry with the old report function.

For any control rejected by the checker, compare its complete ordinary error
observation rather than forcing the report query to run. Existing tests may
have mode-specific expectations; do not relabel a known rejection as a new
optimization failure without comparing the baseline.

## Measurement and build notes

- New bootstrap export: `driver_report_prefix_data`. The patch adds its
  feature-detected export in `selfhost/tools/typed-driver.mjs`; no static
  `compiler.json` module change is needed. Root must use the normal checked
  API build so the optional function is exported in B1/B2.
- Add `driver_report_prefix_data` to the diagnostic worker's public-stage
  list when profiling. Existing `driver_report_data` timing disappears on
  selected owned requests; that alone is not evidence that reporting vanished.
- After report-product controls, use the ordinary paired whole-request clock,
  including reports and source suffix overlay. Do not time only the helper.
- Expected gain is bounded by the removed work. Phase82 sampled report final
  selection/index work was roughly 18–20 ms Numeric and 18 ms Functions65.
  Overlay and altered JIT/allocation behavior consume part of that budget.
  A **1–3% whole-request improvement** is a hypothesis; a larger small-case
  percentage is plausible. It is not a mechanism for the full 25% objective.
- The earlier reverse-graph idea is deliberately deferred. Safe closures are
  already shared, so functions65 does not repeatedly rediscover all earlier
  safe functions. Building reverse edges and a second node product could cost
  more than the existing DFS. Measure the small reuse variant first.

Static checks performed: `git apply --check` against the current source and
Node `--check` on the temporary driver copy pass. The 17 Bend lines still need
the checked bootstrap; no source typechecking, correctness or speed claim is
made here. Production files remain untouched by this agent.

Root's first checked bootstrap (compiler02) rejected inference of the locally
constructed `Con` report context. The preserved patch now explicitly types it
`List<&2,KDef>`; compiler03 is the subsequent root-owned build. The first
rejection is retained as evidence, not a successful source validation.

Actual differential controls: `selfhost/tools/performance/phase84/report-controls.mjs`
accepts `FROZEN_PLAN OUT [ROLE=candidate]`. It checks the complete old/new report
product on ordinary owned requests, false-readiness direct fallbacks, explicit
raw-API behavior, trust/name ordering and pre-report refusals. Generated sources
and all literal imported fixture dependencies are hashed before any request.
This is an untimed correctness method; root runs it with ExecutionGuard.

## First differential-control run and corrected fixture

Root's `selfhost/build/phase84/report-controls01/report.json` records twelve
successful owned-path complete report comparisons, three direct readiness
fallbacks and two explicit/raw API comparisons. It then correctly rejects the
generated `unsafe-type-field` source during checking: a field of a `Data` ADT
requires a `Data` type, while the fixture declared `field_type() -> Type`. This
is a malformed fixture, not evidence of report equivalence or a report bug.

The frozen v1 method and run remain untouched.
`selfhost/tools/performance/phase84/report-controls-v2.mjs` changes the alias
result kind to `Data`, preserving every verdict/name/status assertion. The body
returns `Nat`, which has kind `Data`; upstream examples
`tests/check/kind_terms.bend` (`F(n: Nat) -> Data`) and
`tests/check/data_alias_whnf_001.bend` (a Data alias used as a constructor field)
exercise these same kind constraints. The no-Base source remains the linear
`identity(x: Type) -> Type: x`: `Type` is builtin and `x` is consumed once, so no
constructor Data-kind restriction applies. V2 itself has only been syntax
checked here; root owns its actual compiler run.
