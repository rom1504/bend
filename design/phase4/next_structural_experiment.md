# Next experiment: inline exact list-matcher arms in the private compiler

Decision: **propose one bounded falsifier; do not implement a general matcher rewrite yet**. Read against the [current strategy](../../experiments/STEERING.md) and [ledger](../../experiments/ledger.md), after the Boolean/stability combination has a frozen result. This targets compilation throughput inside the existing private inspect boundary. Public libraries and generated programs retain their ABI and runtime.

## Hypothesis and evidence

An exact, saturated list arm can execute inside its existing matcher worker instead of allocating a fresh arm function record and sending it through another trampoline/application step on every visited list cell. This may remove a residual allocation/dispatch cost that positional calls cannot reach.

The actual completed H (`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`) contains **133** literal sites shaped as `matcher1("Con",()=>fn(2,function(a){...}))`. A read-only textual inventory also finds 632 literal `matcher1`/`fn` sites overall; 137 Con arms have arity 3 and are deliberately excluded because they return a partial application. These counts describe the original H, before duplicate private worker bodies, and are not dynamic work or a speed estimate. They can be reproduced by searching the frozen `combined-fixedpoint/stage2.mjs` for `matcher1\("Con",\(\)=>fn\(2,function\(a\)`.

Concrete examples include generated `dr_count`, `dr_lines` and `driver_holes_terms`. The Bend emitter produces the shape in [`j_match`](../../selfhost/src/back/js/emit.bend); [`matcher1`](../../selfhost/src/runtime.mjs) currently projects fields, evaluates the selected arm thunk, and returns `jump(arm(),fields)`. [`PrivateFunction`/exact apply](../../selfhost/tools/private-compiler/runtime.mjs) already skips argument copying for that exact internal call, but still constructs the arm's JavaScript closure, private function record, empty bound array and bounce record, then dispatches the arm through `apply`.

**Do not count a removed field-array copy:** Con projection returns its existing immutable field array, and private exact apply already borrows it. The proposed savings are the intermediate arm closure/record/bound array/bounce and one application transition; the list, outer matcher worker, caller argument array and projection remain.

A warmed private list profile previously attributed 26.3% of exclusive samples to `apply`, 11.5% to `force` and 8.4% to GC ([report](../../implementation/phase4/private-image.md)). Those shares include unrelated work, predate the current combination, and supply no defensible speedup ceiling. Measure the qualifying path before committing implementation time.

## What is different from earlier attempts

[Phase 1 matcher fusion](../../implementation/phase1/rapid_performance_experiments.md#matcher-allocation-and-fallback-chains) already removed temporary wrappers from 901 arms and optionally fused 463 fallback chains. It passed 59 ABI/effect checks and saved 7.3% on tree; complexity prevented promotion. Its helper still constructs the selected code closure, preserves defensive copies and handles general arity/ABI cases. This proposal is a narrower successor with a stronger private invariant, not a new claim for that old result.

[Ordinary uncurrying](../../experiments/phase4/P4-011-ordinary-uncurry.md) found zero sites and remains rejected. [Boolean specialization](../../implementation/phase4/private-booleans.md) reuses partial handlers and must preserve the first argument's demand before the second argument. Neither is replaced here. Do not revisit tag comparison, nullary sharing or normalization caches in this experiment.

## Smallest transformation

Only accept a tokenizer-proven literal `matcher1("Con",()=>fn(2,function(a){BODY}))` with reviewed constructor metadata and the unchanged private runtime fingerprints. Conceptually replace its outer matcher with:

```js
fn(1, function(privateArgs) {
  const a = project("Con", privateArgs[0]);
  if (a.length !== 2) {
    const arm = fn(2, function(a) { /* original BODY */ });
    return a.length ? jump(arm, a) : arm;
  }
  // Original BODY, in the original arm's argument scope.
});
```

The transform must splice the original body structurally, not call a newly allocated helper closure. Preserve lexical captures, nested argument scopes and return/tail forms. Refuse bodies using `this`, `arguments`, unsupported syntax or observable environments. Keep the original path for an unexpected field count. Retain `project` rather than introduce a different tag check: `matcher1` is intentionally a projection, including its existing error/fallback behavior.

Start with Con/arity2 only. Exclude computed arms, zero-field constructors, erased/short/overapplied arms and all other constructors. No global result cache, closure cache, new term representation, source algorithm or public export is needed.

## Quickest falsifier and stop rule

1. **Inventory and counts, at most 10 minutes.** On a disposable copy of the final winning private image, count entries into the exact eligible arms during tree, list and the existing 312-declaration compiler-core workload. Keep counters separate from timing. If few eligible arms execute, stop. Count prevented allocations/application transitions, not allocated bytes or GC time.
2. **Prototype and semantic gate, at most 25 minutes.** Implement only the shape above in a new experimental transform, then run the boundary cases below. A mismatch stops timing. Preserve any failed case and original image.
3. **One alternating pilot, approximately two minutes of CPU.** Freeze the current Boolean/stability winner as control; compare control/candidate then candidate/control on list and the real core. Use fresh processes, independently validated Base caches, identical Node flags/host/runtime, exact emitted bytes and process wall, and record peak RSS. If the core gain is absent or below roughly 3% with opposite-order disagreement, stop and retain the negative result. Do not rescue the idea with a favorable list microbenchmark.
4. **Confirm only a survivor.** Three alternating repetitions across tree, list, exact rejection and core. Require a consistent useful core/process gain without a material small-request or memory regression. A roughly 5% core gain is a practical reason to spend the remaining full-source budget, not a statistical confidence claim.

The owner must obtain an idle physical core before counters or timings; no CPU runs were performed for this proposal. Total initial investigation is capped around 45 minutes, excluding an explicitly approved full-source gate.

## Required correctness argument and gates

The existing data-only private boundary prevents callers from supplying function records, getters, proxies or mutable compiler graphs. That restriction is essential: eliminating an observable public `.code` access, function identity or argument copy is invalid. Keep public runtime tests unchanged and require the ordinary public getter counterexample to continue demonstrating that boundary.

For the selected arm, show that projection and its failure happen before body effects, the arm body executes exactly once, and no computed branch is evaluated early. A successful projection yields the same ordered fields. Nested lambdas retain their own `a`; external lexical captures remain in the same declaration environment. Moving the body across one private trampoline step must not eagerly force its returned bounce/build or enter any unselected constructor field thunk. Tail recursion must remain bounded. No memo survives a request, and constructor provenance is fixed by the reviewed image.

Cheap tests must cover: nonempty and empty lists; captured variables and nested lambdas; returned higher-order functions; caller partial and overapplication; a wrong field count taking the original path; projection exceptions before body effects; selected-arm exceptions and unselected-branch sentinels; build-field demand order; and at least 100,000 tail-recursive visits. Include malformed internal shapes as differential controls even though the public transport cannot inject them. Run existing private-boundary and exact application tests.

Before support, require unchanged exact diagnostics and outputs on the selected import/foreign/Unicode cases, the complete 2,756-observation frontend sweep, and a successful full frozen-source library emission matching H `b33b38e3…`. Compare against the unchanged winning private control on the same source; do not substitute historical public-H times. This private image emits the same public program bytes, so it cannot establish faster generated-user-program execution. Production generalization into the Bend emitter is separate work with a broader ABI proof.

## Completed bounded decision

The proposed falsifier was run as [P4-015](../../experiments/phase4/P4-015-exact-con-arms.md). The narrow transformation passed selected semantic controls but was **rejected for insufficient repeatable benefit**: compiler-core pairs improved 3.49% and 0.061%, so no combination or full-source escalation followed. See the [complete result](../../implementation/phase4/private-con-arms.md), including the independent canonical-control full-source limitation. This proposal remains historical; implementation is no longer pending.
