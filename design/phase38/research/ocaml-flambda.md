# OCaml and Flambda: bounded facts, known calls and profitable specialization

Research date: 2026-10-01. Documentation and source inspection only; no compiler
or generated program was executed. Estimates below are speculative incremental
gains over installed Phase37, not transferred OCaml benchmark results.

## Sources and version boundary

OCaml's published Flambda manual describes the original optimizer; Flambda2 is
a different implementation in OxCaml. Do not attribute every Flambda2 behavior
to an ordinary OCaml release. The implementation pin inspected here is OxCaml
[`15584842f43dde95bd5ef9deb8956a447084c45e`](https://github.com/oxcaml/oxcaml/commit/15584842f43dde95bd5ef9deb8956a447084c45e),
retrieved from `main` on the research date, not a stable release claim.

Primary sources inspected:

- [OCaml 4.11 Flambda manual](https://ocaml.org/manual/4.11/flambda.html), especially
  simplification, recursive argument specialization and closure unboxing.
- [Flambda2 value approximations](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/docs/types.md).
- [Application simplifier](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/simplify/simplify_apply_expr.ml),
  notably `simplify_direct_full_application` and full/partial/overapplication dispatch.
- [Call-site inlining decision](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/simplify/inlining/call_site_inlining_decision.ml),
  notably speculative simplification and resulting cost accounting.

This extends the [Phase35 review](../../phase35/literature.md), whose limited
shape-fact recommendation is already partly implemented. The current evidence
is [Phase37 profiles](../../../implementation/phase37/profile-findings.md), not
the older profiles that originally motivated that review.

## Mechanism and concrete implementation lesson

The original Flambda manual separates discovering a known function from inlining
it. Propagating a function value can turn an indirect call into a direct call
without copying its body. An invariant functional argument in a recursive
iterator can specialize the recursive group; closure fields can become explicit
worker arguments. Public/indirect entry still needs its original convention.
That separation is useful even when aggressive inlining would increase size.
[Manual](https://ocaml.org/manual/4.11/flambda.html).

Flambda2 represents facts about kinds, constructor tags/fields, code identities,
closure slots and projections. Its design describes single-pass simplification
and explicitly rejects a widening-based general loop fixpoint in that setting.
Its must-alias relation does **not** prove two arbitrary objects cannot alias.
This is a warning against treating one successful projection fact as ownership.
[Value-domain design](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/docs/types.md).

The application simplifier has distinct saturated, partial and overapplied
routes. It checks argument/result arities and records conversion of an indirect
call to direct form separately from removal through inlining. Missing recursion
information can block inlining without discarding a known call. These are
specific implementation boundaries Bend can borrow without importing its IR.
[Application source](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/simplify/simplify_apply_expr.ml).

The inliner can simplify a speculative body before judging the result. It limits
the associated data-flow analysis to that body, and accounts for lifted constants
that could otherwise hide code growth. This suggests measuring the simplified
worker's benefit, not equating a small source helper with a profitable fast path.
[Decision source](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/simplify/inlining/call_site_inlining_decision.ml).

For Bend, consider conceptual `fold(add k, xs)`: a known closure body plus a
dynamic captured `k` can become a private `fold_add(xs, k, acc)` worker.
`k` remains a runtime argument; its value is not assumed constant.
Keeping the worker once avoids duplicating `fold` at every caller.
This example is an original proposal, not a claim that current Bend admits it.

## What Phase37 already has, and what it lacks

[`j_region_call`](../../../selfhost/src/back/js/region.bend) already recognizes
named saturated calls and selects existing `JCall`, `JGeneric` and `JNative`
plans. [`JPure`](../../../selfhost/src/back/js/jpure.bend) validates the whole
residual graph with explicit bounds. It currently excludes function-valued
arguments/fields from its closed data proof. Generic higher-order calls therefore
cannot be admitted merely by adding an emitter case.

The new native cast is an existence proof for removing one repeated dispatch:
numeric 1024 improved 5.165× in Phase37. That gain is already in the baseline.
The remaining targets differ: list 512 spends roughly 26% CPU self time in
`apply` and 16% in `force`, allocates about 2.78 MB per call, and is 44.42×
slower than TypeScript. Closures 256 remains 8.33× slower. These selected
profiles motivate a known-call experiment, not a forecast of closing those gaps.

## Proposed probes and incremental estimates

| Proposal | Scoped additional gain hypothesis | Complexity / risk | First falsifiable probe |
| --- | --- | --- | --- |
| F1: local callee/arity/environment fact | 1.05–1.5× on an affected closure case; zero elsewhere | Medium; 2–5 engineering days | One generated known-closure loop, worker versus current generic call |
| F2: specialize one pure higher-order component | 1.3–3× on selected list/closure work | High; 1–3 weeks | Fixed-body/dynamic-capture fold; no fusion or representation change |
| F3: profitable-root admission from actual work | Recover 0–5% on some unaffected workloads; may be neutral | Low–medium; 1–3 days | Suppress only proved unused/tiny fast paths in one saved module |

All ranges have low confidence and include failure to improve. They concern
whole selected program calls after Phase37, not generic-call microbenchmarks or
the entire compiler. F2 includes F1: multiplying their gains would double count.
Engineering time includes integration and relevant controls; the first saved
output discriminator should take hours, not require a bootstrap iteration.

F1's environment should start with a tiny finite fact set: unknown, known code
plus exact arity and captured scalar slots, and perhaps a known constructor.
Use existing term identities and plans; do not invent a second general type
checker. At a merge, discard a fact unless both paths justify it. Give the
fact walk, specialization count and worker size explicit small budgets.

F2 first needs one closed callback body, complete call saturation and a proof
that captured values remain private and unchanged throughout use. Reuse existing
primitive/signature checks. Do not generalize to arbitrary host callbacks or
recursive closure environments in the first experiment. A failed purity/lifetime
proof must leave the original generic path intact.

F3 is motivated by Phase37's rejected tiny ray scopes and final code-size costs.
The final list hot bodies are unchanged despite its +4.65% regression, so fewer
unused branches are a testable layout hypothesis, not an established cure.
Require paired timing before promoting any such heuristic.

## Semantic obligations and stopping rules

Known source name is insufficient: retain the public descriptor snapshot and
live `G`/code/environment/bound-argument checks. A closure's dynamic capture
must be evaluated exactly once at its original demand point. Partial application
must preserve observable staging; overapplication may force an intermediate
result and cannot be flattened indiscriminately. Getter, native-hook and
callback reentry controls must still force the generic route where required.

Do not borrow OCaml's eager-call assumptions to reorder Bend's `build`/`force`
work. Compare event traces and first errors as well as numeric results.
Shared subtrees and captured values require full alias-sensitive observations.
Recursive workers need the existing trampoline, a local loop, or an explicit
continuation stack; ordinary recursive JavaScript calls do not prove bounded
tail-stack behavior. Restore proof state on exceptions and reentry.

The first probe uses independent expected outputs at zero/small/large counts,
dynamic captures, partial calls, public mutations and 30,000-step tail cycles.
Run the future 20-second screen, then a 60-second paired confirmation only if
the mechanism is observed. Separate admission counters from clean timings.
Stop if the known-call path never runs, metadata checks dominate, code grows
without a reproducible gain, or any demand/alias/tail observation changes.
Before promotion, measure checked compilation and choose fresh held-out families;
the six Phase37 holdouts are now known evidence, not fresh validation data.

## Simplicity and overlap

The smallest useful transfer is a common fact/call interface that replaces
repeated special-case discovery. A complete Flambda2 domain would substantially
increase concepts and analysis cost. No line reduction is promised by adding F1.
The experiment should account for helpers deleted as well as helpers added.

Known-call specialization overlaps worker/wrapper, monomorphization and
defunctionalization; choose one representation of that knowledge. Fusion and
node reuse are separate transformations and must not be bundled into its first
ablation. This work can improve generated-program coverage within an existing
semantic subset; it adds no language-conformance feature and requires new
boundary controls before the current conformance result can be retained.
