# Shared facts and a bounded worker consumer

2026-10-04. Source investigation against selected Phase 45 worker23; repository
HEAD during implementation was `7193c71de4fdf49ce9cf86b4490672c7eb15af3d`.
**Final status: deferred and removed from maintained compiler source.** The
checked worker02 experiment passed its focused controls, but the short screen
showed only small helper-call gains, with no demonstrated aggregate elimination
in the timed corpus programs. The [outcome report](worker-outcome.md) records the measurements,
scope and decision. The design below is retained as the experiment's proposal;
it is not a description of an installed optimization.

The first build (`source-worker01`) failed at the parser before type checking:
the initial implementation used computed `match` scrutinees, which Bend does
not accept. That exact snapshot remains preserved. The successor replaces all
nine computed matches with helper functions matching named parameters; it does
not alter the transformation or its bounds. This setup failure receives no
correctness or measurement credit.

## Original implementation decision

Start inside the existing first-order worker IR: expand small known direct
helpers, propagate private constructor fields, and remove unused aggregate
shells. This supplies one useful consumer of shared value/use facts without
adding a competing emitter or broadening graph admission. A whole-program
closure-analysis framework is a larger second step.

The 405-line experimental `worker-optimize.bend` module and its two integration
edits are preserved in [worker-cleanup.patch](../../experiments/phase47/patches/worker-cleanup.patch),
SHA256 `6107b3ac3642dad134c29126b594ffe2395bb04e66755f7ee96defdf9dcde1fe`.
The full checked raw source remains in
`selfhost/build/phase47/source-worker02/`. Its only integration entry was:

```text
jw_optimize_functions(List<JWFunction>) -> List<JWFunction>
```

It preserves function count, names, arities, validity flags and index order.
The experimental integration position was after existing tuple/Char case
simplification and before Number-Nat selection, SCC analysis and emission.
Original source dependencies, successful
JPure proofs and runtime guards remain inputs to the existing wrapper;
optimized use information must never prune them.

## What source inspection establishes

[`worker-model.bend`](../../selfhost/src/back/js/ir/worker-model.bend) already
separates `JWDirectCall`, `JWCase`, assignments and returns. Constructor and
projection nodes retain layout names. This is sufficient for a local consumer;
there is no need to recover meaning from generated JavaScript.

[`worker-lower.bend`](../../selfhost/src/back/js/ir/worker-lower.bend) stores
nontrivial expression results in slots (`jw_store`, `jw_fields`, `jw_args`).
Parameters occupy slots `0 .. arity-1`. The two arms of `jw_match_fields` can
reuse numerical destination slots; `jw_match_done` takes their maximum bound.
Consequently slot facts have lexical branch scope, not global SSA identity.

The previous [`worker-simplify.bend`](../../selfhost/src/back/js/ir/worker-simplify.bend)
only removes terminal cases whose tuple/Char condition is already literal true.
It does not propagate private constructor fields or expand general worker calls.

Higher-order coverage has an earlier barrier. In
[`jpure.bend`](../../selfhost/src/back/js/jpure.bend), `j_instances_call` and
`j_erased_instance_step` require a first-order `j_pure_signature` before the
worker view exists. `j_pure_type_head` does not admit function types;
`jw_expr` has no value-lambda case, and `jw_call` requires a known source target.
Adding a function-target field to JW alone cannot admit a returned closure.

Existing narrow capabilities must not be described as absent: ordinary
`JIRCopy` facts handle local/null aliases; `j_region_inline_defs` performs
bounded private-region inlining; `JInline`/virtual nodes forward some private
projections; `j_l_mark`/`j_l_walk` lift deep closures into flat factories;
`j_plan_context` caches exact source proof plans. None supplies general local
worker aggregate elimination or known-function transport through arbitrary
helpers.

## Small fact contract

| Fact | Representation and producer | Consumer / conservative refusal |
| --- | --- | --- |
| Known target | Existing `JWDirectCall.target`, exact graph index | Look up an original function and check exact arity. Missing/invalid targets are left unchanged. |
| Immutable alias | `JWOptFact{slot, JWSlot{source}}` | Replace a read with an already bound slot. Overwriting either key or referenced source invalidates the fact. |
| Fresh private aggregate | `JWOptFact{slot, JWConstruct{layout,name,fields}}` | Only tagged objects or canonical two-field Tuple; every field must already be Slot/Nat. Forward a projection only on the same layout and an in-range field index. |
| Remaining uses | `JWOptUses{slots,complete}` | A backwards structured walk sees value children, calls, case inputs and both arms. Above 64 distinct live slots, `complete=false` means all slots are live. |
| Discard permission | `jw_opt_discardable` | Only Slot/Nat reads and fresh aggregate shells with stable fields. Opaque literals, globals, calls, checked/native operations and native projections have no permission. |
| Escape | No separate speculative escape bit yet | A shell can disappear only when the complete use walk proves no remaining use. Passing or returning it keeps it live. This is local nonescape evidence, not interprocedural ownership analysis. |

Value facts are bounded to 64 entries. They are immutable compile-time facts,
not runtime entry capabilities. Each branch starts with the incoming fact map;
neither arm exports facts to its sibling or continuation. Constructors are
never substituted as expressions, so an alias cannot duplicate allocation.

The effect contract deliberately answers only “may this unused evaluation be
discarded?” It does not infer `noThrow`, speculate computations, perform CSE,
move loads across calls, or equate source purity with unobservable JavaScript.
Future consumers should add independent permissions only when needed.

## First transformation and limits

1. Inspect original callees, never already-expanded templates. Admit only
   `JWAssign*; JWReturn` bodies with at most 12 instructions and no call or case.
   Supported values are slots, Nat literals, opaque literals whose evaluation
   remains, tuple/tagged projections and construction, and a narrow set of
   plain U32 operators. Native/global operations refuse expansion.
2. At the original call position, assign every actual argument left-to-right
   to fresh parameter slots, including unused arguments. Rename the entire
   callee slot range using `jw_register_bound`, and replace its return with
   an assignment to the original call's result slot.
3. Charge every introduced instruction—including argument bindings and the
   result assignment—to a 32-instruction budget shared across the caller's
   branches. Overflow or a refused candidate retains the original call.
4. Walk forward with immutable slot facts. A field read of a known fresh
   aggregate becomes its already-evaluated field value. String, Char, Nat
   and Number-Nat projections receive no new rewrite.
5. Walk backwards once with bounded live-slot sets. Remove unused stable
   copies and aggregate shells; retain all field computations and all other
   evaluations, even when their values are unused.

The pass inherits the successful graph/lowering bounds (including the 96-worker
graph limit). It adds no unbounded rewrite fixed point. The direct-call lookup
is bounded by the graph, candidates by 12 instructions, facts by 64 entries and
expansion by 32 introduced instructions per function. A later compile-cost
measurement must still determine whether these extra traversals pay for their
construction and allocation costs.

Example in schematic JW:

```text
pack(a,b): q = Tuple(a,b); return q
caller:    x = compute_a(); y = compute_b()
           p = direct pack(x,y)
           z = project tuple p 0
           return z
```

After expansion and cleanup, `compute_a()` and `compute_b()` remain in their
original order; the call and tuple shell can disappear, and the result is the
already computed `x`. If `compute_b()` fails, it must still fail. If `p` is
returned or passed to another surviving operation, its shell remains.

No inlining of branchy helpers is attempted. Generalizing that requires either
a shared continuation/join representation or a strict code-growth argument;
copying the caller suffix into every branch is specifically avoided.

## Proof obligations and smallest falsifiers

- **Demand and order:** an unused actual containing a genuine checked Nat
  overflow still fails; opaque/global actuals are evaluated once and in order.
  Private projection forwarding must not duplicate a field initializer.
- **Scope:** sibling cases assigning the same slot numbers do not share
  constructor/copy facts. Reassignment invalidates dependent facts. Parameter
  permutations and a recursive caller retain their original values.
- **Representation:** only matching tuple/tagged layout and valid field indices
  forward. Native String/Char/Succ observations remain unchanged. Malformed
  tuple names/arity do not gain dead-shell permission.
- **Use completeness:** nested call arguments, native arguments, returned
  aggregates and both branches keep values live. More than 64 live slots must
  lose precision safely. The pass does not delete effectful instructions.
- **Call identity:** invalid target/arity/validity refuses expansion; source
  `G`, descriptor, `.code`, `.env`, `.bound` and `.call` mutations still take
  the inherited public fallback. Dependency lists are not recomputed from
  optimized instructions.
- **Budget and stack behavior:** preserve function indices and recompute SCCs
  from the transformed graph using the existing analysis. Inline candidates
  contain no recursive or suspended calls. Deep recursive controls still
  exercise native-budget exhaustion and the continuation fallback.

The independent synthetic test should interpret original and transformed JW
with an implementation separate from this pass, then validate emitted programs
through the checked compiler. A mechanism counter or structural reduction is
needed before runtime timing; equal outputs alone do not establish activation.

## Corpus expectations, including likely misses

Map and record graphs contain short tuple-returning helpers and projection
leaves; these are the best first inspection targets. `Map.del.fin` is a useful
projection-leaf candidate. Helpers that also call a native operation, such as
`Char.cmp`, are intentionally excluded from this first inliner.

The [Map source](../../selfhost/tools/performance/phase37/fixtures-new/map-churn.bend)
and [record source](../../selfhost/tools/performance/phase37/fixtures-new/record-aggregation.bend)
are independent measured consumers to screen after focused correctness. But
many aggregate results cross recursive calls or returns, and a local pass
cannot erase those allocations automatically. V8 may already remove some
short-lived shells; static opportunity counts are not execution gains.

The bitonic program has useful aggregate structure, but stronger earlier
selection can bypass JW. RLE helpers contain cases and may be refused by this
linear slice. Already-fast closure-chain and RLE points are preservation
canaries, not promised wins. A zero-activation or flat clean screen is a valid
reason to stop this version without enlarging it around workload names.

## Later producer: known function values

Retain the existing
[known-local-function design](../../design/phase45/known-local-functions.md)
as the larger coverage plan. Its natural producer is a bounded analysis before
the current first-order signature gate, with exact lambda-site IDs, typed
capture slots, original-definition provenance and contextual helper keys.
It must specialize known helper parameters and private aggregate fields, then
emit first-order definitions with explicit capture arguments that can reuse
this worker consumer.

The smallest meaningful higher-order test is a renamed lexical lambda carried
through a helper and a private single-constructor wrapper, then invoked. A
returned factory with a demanded prefix is a distinct next case: preserve
`factory(a)` evaluation before evaluating the later argument of its returned
function. Do not flatten both stages merely because a target is known.

Morning's `Str.split` and `Str.join.go` return functions transported through
`Str.split.fin`/`Str.join.fin`; immediate beta reduction alone cannot close that
graph. Unknown target sets, public closures, function-containing public results,
foreign callbacks and unsummarized helpers remain refusal boundaries. This
implementation does not yet change those facts or claim Morning admission.

## Reuse and consolidation

Reuse the worker's typed layout nodes, stable registers, `jw_register_bound`,
complete graph proof, native boundary fence, SCC implementation and unchanged
public wrapper. Keep original proof-cache identity rules from
[Phase 42](../../design/phase42/facts.md).

Do not retire existing region inlining, finite selectors or callback paths in
this first patch: their domains differ and current selection intentionally
preserves strong plans. After a demonstrated replacement, move an overlapping
consumer onto shared facts and remove its duplicate walk in a separate measured
change. `JIRCopy` remains an ordinary-runtime analysis with a different demand
boundary; it is not silently interchangeable with proved private worker facts.

The seven-compiler survey supports this narrow direction: [Lean](../../research/compilers_architecture_and_techniques/lean.md)
connects specialization, captures and bounded cleanup;
[Go](../../research/compilers_architecture_and_techniques/go.md) separates target
discovery from escape and effect legality;
[LLVM](../../research/compilers_architecture_and_techniques/llvm.md) and
[Rust](../../research/compilers_architecture_and_techniques/rust.md) emphasize
uses, dominance, budgets and invalidation;
[Zig](../../research/compilers_architecture_and_techniques/zig.md) motivates
shared immutable summaries;
[V8](../../research/compilers_architecture_and_techniques/v8.md) warns that
allocation syntax alone does not establish remaining JIT cost; and
[pinned Bend TypeScript](../../research/compilers_architecture_and_techniques/bend-typescript.md)
shows the value of direct calls and uncomplicated representations. Their
reported gains are not transferred as a forecast for this implementation.
