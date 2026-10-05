# Phase48 independent review contract

This is an adversarial review plan, not a claim that the proposed transformations
are implemented or qualified. The starting compiler/runtime is installed Phase47
array06. Root owns every checked build, generated-program execution, benchmark
and release action. Review agents inspect source and receipts; existing Phase6
files and closed experimental evidence remain unchanged.

The objective is useful composition of known-function, aggregate, array and
boundary optimizations. A smaller emitted expression is not enough: show which
executed calls, transport objects or checks disappear, and retain all required
evaluation. The deferred Phase47 worker pass is a concrete warning: it removed
helper calls while leaving the important return shells allocated.

## Shared invariants

- **Proof domain is explicit.** State the supported source types, operation
  shapes, representations, effects, entry conditions and bounds. Exhausted fuel,
  unknown syntax, unsupported callees and malformed IR refuse the optimization.
  A successfully emitted fragment is not proof of its source semantics.
- **Source provenance survives transformation.** Original functions, factories,
  constructors and primitives remain dependencies even when a rewrite removes
  their calls. Preserve checked owner/type/erasure facts; a matching name alone
  never establishes native layout or arity.
- **Demand stays ordered.** Evaluate a callee before its arguments, live arguments
  left-to-right and parallel Let RHSs in the old scope. Finish an intermediate
  demanded call before evaluating the next application chunk. Preserve erased
  non-evaluation and delayed constructor/matcher fields.
- **Evaluation and value use are separate.** An unused result, projection or
  argument may still throw, read a host hook or mutate storage. Facts must state
  whether evaluation is discardable, movable or duplicable; source purity and
  private ownership alone do not grant all three permissions.
- **Identity is a graph property.** Internal aliases remain aliases; distinct
  allocations remain distinct wherever observable. Scalar replacement may erase
  an unobservable shell, but not a shared persistent child or an escaped handle.
- **Permission is fresh and correctly ordered.** Establish the necessary host
  capability before input validation or dependency checks can invoke mutable
  hooks. Do not inherit an unrelated `regionProof`, cache success across calls,
  or resume halfway through a generic fallback after speculative source work.
- **Public ABI is retained.** Public descriptor arity, leading matcher demand,
  `.code` function metadata, `.call`/`.env` lookup order, bound arguments,
  nullary recomputation, raw `.code` calls, partial application and oversaturation
  remain on their established paths unless separately proved equivalent.
- **Stack and temporary ownership remain bounded.** Changed private call edges
  feed the existing SCC policy. Tail transfers capture all arguments before
  assigning destinations. Non-tail callers retain their own live state. No
  global reusable output vector may be overwritten by recursion or reentry.
- **Composition preserves facts.** A pass declares what it invalidates. Recompute
  call components after changing targets; invalidate value/alias facts at slot
  writes and joins. A private representation must have consistent producers,
  consumers and boundary adapters throughout the admitted graph.

The existing host domain assumes standard intrinsics at module initialization
and supports the documented post-import mutations. Do not quietly narrow that
domain to rescue a gain, or describe unexecuted hostile-import hypotheses as
current failures. Captured intrinsic identities are allowed; a captured admission
result across mutable public calls is a different, currently unsupported claim.

## Known functions, factory prefixes and captures

The proposed first slice normalizes bounded, typed known calls before private
first-order proof. That does not grant general function-type admission. A source
helper may be expanded only over its proved leading lambda prefix. A matcher or
computed factory stage is a demand boundary, not extra arity inferred from an
`All` telescope. Unsupported factory alternatives or dynamic targets retain the
ordinary path. If the first slice refuses match-selected factories, report that
limit explicitly: it does not yet establish full higher-order library coverage.

Administrative bindings must be hygienic. Captures refer to values evaluated at
closure creation, not to later rebinding or newly evaluated source expressions.
Factory/helper dependencies must still describe the original graph, including
untaken branches and lambda bodies removed by specialization.

| Counterexample | Required observation |
| --- | --- |
| `closure-prefix-before-argument` | In `factory(a)(b)`, a failing factory prefix wins over a failing or logging `b`; moving `b` before the prefix fails. |
| `closure-capture-once` | A capture-producing computation runs once when the closure is created, even when two aliases apply it. |
| `closure-parallel-shadow` | A new Let binder with a reused ID cannot change what a simultaneously evaluated RHS or older capture sees. |
| `closure-matcher-gap` | A matcher between argument groups keeps partial arity and delayed branch selection; refuse if the slice cannot represent it. |
| `closure-alternative-order` | A finite branch-dependent target preserves selected captures and argument order, or refuses without evaluating the other branch. |
| `closure-unknown-escape` | Passing a closure to an unknown callback or returning it publicly does not accidentally authorize a private direct call. |
| `closure-mutated-origin` | Mutating factory/helper G, code, env, bound or `.call` restores the ordinary observation sequence. |

## Aggregate transport and private results

Prefer a bounded producer/consumer contract over an unqualified inliner. State
whether each returned field is already demanded and materialized, immutable,
private, and used once or repeatedly. Preserve the original public result path.
If a new private call returns several fields into caller-owned destinations,
define destination lifetime and parallel assignment explicitly. Carry values
through the existing continuation machine without introducing native recursion.

| Counterexample | Required observation |
| --- | --- |
| `transport-unused-throw` | Constructing `(good, failing)` then keeping the first component still performs the second computation at its original demand point. |
| `transport-two-failures` | Two failing fields retain left-to-right winner and error identity; a discarded branch remains unevaluated. |
| `transport-permuted-inputs` | A transfer exchanging argument/result slots reads all old operands before any destination overwrite. |
| `transport-shared-child` | Eliminating a pair around two references does not duplicate, mutate or rebuild their shared persistent child. |
| `transport-recursive-return` | Non-tail recursion keeps each caller's result slots and pending arithmetic, including beyond native budget exhaustion. |
| `transport-reentry-unwind` | Error construction with same-root reentry cannot overwrite suspended temporaries or leave native budget/proof state changed. |
| `transport-branch-facts` | Differing branch assignments invalidate stale constructor/alias facts; invalid target/arity/callee IR retains refusal. |

Synthetic IR controls need independent interpretation and structural refusal
checks. An interpreter that ignores an invalid-callee flag cannot by itself
validate that refusal. On generated programs, count actual transport creation
or consumption separately from static constructor sites and total module bytes.
Inlining a site while retaining the callee can increase static sites without
changing dynamic allocation; neither count alone establishes a speed gain.

## Array effects, F32 and swap

The selected private-array proof is closed and scalar-boundary. Broadening it
requires exact element and operation facts, not merely adding native names.
Canonical Array/F32 owners, dimensions, index behavior and runtime errors remain
part of the proof. A fresh local array can have aliases; ownership does not mean
unique access. Reads, writes and allocation are effects with ordering constraints.

The current public `Array.swap` performs `arrayget` followed by `arrayset`. Its
ordinary behavior can read backing storage and convert the index twice. A
mutation can therefore change the second destination or length. A private proof
may justify simplifying inert operations; the public fallback must preserve the
full behavior, and the proof must cover every hook being skipped.

F32 arithmetic rounds at the existing operations. An F32 type is not permission
to insert rounding at every array write, erase signed zero, rewrite NaN behavior
or fuse arithmetic into a differently rounded expression. An unused F32 argument
still requires floating input-validation hooks; aliases must normalize likewise.

| Counterexample | Required observation |
| --- | --- |
| `array-swap-split-index` | A Number hook returning different indices on successive conversions distinguishes read location from write location on fallback. |
| `array-swap-replaced-backing` | A backing getter or index hook replacing storage between get and set preserves the returned old value and actual new destination. |
| `array-late-fill-hook` | A fill hook that exposes storage or installs Number/Math mutation refuses private entry and preserves the later trace. |
| `array-zero-demand` | Zero iterations do not read an unused malformed handle or convert an unused index. |
| `array-alias-rotation` | Two/four arrays transported through records and swapped roles preserve the independent recurrence for shared and distinct handles. |
| `array-f32-round-sites` | Cancellation/overflow/subnormal examples, NaN and negative zero match the original sequence of F32 operations and stored values. |
| `array-unused-f32-alias` | A root with an unused aliased F32 parameter never takes an integer-only guard that omits its validation hooks. |
| `array-native-replacement` | Mutating Array.new/get/set/swap or reachable scalar/native dependencies refuses the optimized path before body evaluation. |

## Public composite results

The first composite proposal preserves original Array handles throughout an
unflagged private region, then constructs one flat public user-record shell.
This deliberately avoids a general raw-backing wrapper registry: repeated fields
can carry the identical existing handle. Limit its claim to the admitted flat,
nonnative, single-constructor result shape and scalar public inputs.

The final shell must be constructed after fields complete in their original
order, with ordinary `$`/`a` layout and prototypes. Verify that no private vector
or raw backing is mistaken for a public handle. Nested results, functions,
dependent fields, public array inputs and unsupported native constructors refuse
this slice. Any later general materializer must map one private object to one
public object per invocation, preserve distinct objects, and handle cycles
explicitly or refuse them; recursively copying each occurrence is insufficient.

| Counterexample | Required observation |
| --- | --- |
| `result-repeated-handle` | Two fields containing one handle compare identical; mutation through either changes the other. |
| `result-distinct-equal-handles` | Equal contents from two allocations retain distinct identities. |
| `result-public-replay` | Returned handles work with an ordinary exported helper and remain shared after host mutation. |
| `result-fresh-invocation` | Separate root invocations do not share a scratch vector, wrapper or handle. |
| `result-field-failure` | A later failing field is demanded at the same point even if the host subsequently reads only the first field. |
| `result-prototype-hook` | Numeric/protocol/prototype mutations before entry select ordinary behavior; no added setter/getter event comes from reconstruction. |
| `result-unsupported-nesting` | Nested/public-input/closure-bearing shapes refuse instead of leaking a private representation. |

## Entry profitability and observation timing

A cost decision is subordinate to legality. Prefer measured general work facts
such as a proved loop count and operation cost; exclude source names, benchmark
IDs and constants copied from fixture inputs. Reading those facts must not itself
coerce, force or dereference a value earlier than the original program.

| Counterexample | Required observation |
| --- | --- |
| `entry-zero-before-read` | A zero-work call does not acquire storage or demand an otherwise unused value merely to estimate work. |
| `entry-invalid-scalar` | A coercible object or malformed scalar cannot trigger a new comparison/coercion before ordinary validation. |
| `entry-restoring-hook` | A reflection hook mutating an already inspected dependency and then restoring itself cannot create stale permission. |
| `entry-between-calls` | Mutation between two successful calls invalidates the next admission; no prior success is reused. |
| `entry-nested-proof` | An unrelated active region permission does not skip the required host/source checks. |
| `entry-raw-code` | Ungranted raw `.code`, partial and oversaturated paths keep their established ABI and observation order. |

## Cheap qualification sequence

1. Inspect the smallest source/IR delta and state one falsifier before building.
   Reuse existing controllers and receipt formats rather than another framework.
2. Root acquires checked outputs from the exact baseline/candidate/runtime pair.
   Run small renamed value/error/identity witnesses plus separate activation and
   refusal counters. Keep derivatives untimed and distinct from production code.
3. Use the maintained fast canaries, including short work and generic public
   boundaries. A target-shaped speedup does not excuse an unexplained regression.
4. For a surviving mechanism, take a short rotated affected-family screen and
   separate profiles/counters. Hold source/API/runtime/tool identities fixed.
5. Integrate compatible survivors, rerun relevant composition controls, then one
   final broader qualification. Do not credit another candidate's results merely
   because its compiler API hash matches while its runtime or source differs.

Record refusals and failed hypotheses. Claims about 1× or 0.5× TypeScript require
the controlled corpus and stated weighting; independent witnesses establish
semantic mechanisms, not the distribution of ordinary Bend programs.

References: [current IR contracts](../../selfhost/docs/JAVASCRIPT_IR.md),
[selected private arrays](../../docs/self_hosted/private-array-regions.md),
[known-function design](../phase45/known-local-functions.md),
[Phase47 aggregate outcome](../../implementation/phase47/worker-outcome.md),
[pinned compiler research](../../research/compilers_architecture_and_techniques/README.md).

## Initial static review checkpoints

These are source-review verdicts only. Root-owned checked compilation, actual
entry witnesses and differential controls remain separate requirements.

- `selfhost/src/back/js/array-result.bend`: SHA256 `1eb531ca87139383c976699d43166b1aa736d2e8cb83a87ea177ce55c7bb3582`.
- `selfhost/src/back/js/array-effects.bend`: SHA256 `bbae40d6a1929b83189d5ad8942a66857a967a305aa1f5d87bcbfe16e6d3b04d`.
- `selfhost/src/back/js/ir/function-flow.bend`: SHA256 `60e3010191f64242a6496ab6cab3aa09ac8d9bd5b81ec8403bee8eacda01a0ad`.
- `selfhost/tools/performance/phase48/entry-profitability/array-local-guard-v1.js.frag`: SHA256 `f363b77e1e3e0f60ebb0697df1069135e33588631d458c682b8fc2109abe9470`.

The composite adapter passes the narrow flat-owner, original-handle and fresh-guard review. Its final vector evaluates live fields left-to-right with the existing non-tail emitter, then receives one ordinary `ctor` shell. Mutated native allocation can validate shared-handle fallback; it is not evidence of selected-path duplicate-handle production.

The typed array effect proof and printer pass static review provided the old local/native delegates are replaced consistently. Swap retains two read/write index conversions; F32 cells gain no store rounding. Source/helper/input float facts must keep the full host guard.

Known-function normalization preserves prefix demand and materializes scalar actuals once in this first slice. Integration must independently supply a fresh ID above the complete request, original removed-reference dependencies and complete first-order admission. This is not approval to replace public higher-order ABI or matcher factories.

The specialized raw-entry dependency guard retains the original checks under a preceding fresh array host proof. It may remove only inert temporary-container protocols at those entry sites; no general scalarGuard replacement or admission cache is approved.

The aggregate draft initially accepted an inline tuple expression at return, then split it into two projections; that could duplicate field effects. Review required a dominated, already materialized tuple slot instead. The successor makes that refusal explicit. Its multiple-result emitter evaluates every leaf into lexical temporaries, restores continuation frames before committing extra return registers, and captures them before destination stores. Budget-finally bookkeeping between return and capture is lexical and inert. Exact entry exclusion and graph/Nat visitors still need the root integration and independent execution controls.

Reviewed aggregate successor files:

- `selfhost/src/back/js/ir/worker-values.bend`: SHA256 `0be8aab7a1bb48d456dd9898d010aec11fdc72c2a16f65ac87b9e064553debeb`.
- `selfhost/src/back/js/ir/worker-emit.bend`: SHA256 `36d4ee9bea05daef1cac26e427898d4a43a9492298469b08cd4e64a4a77487f0`.
- `selfhost/src/back/js/ir/worker-model.bend`: SHA256 `e6208ebdfc3a003d41169b1ed9f4ce61a106f42822d7938c517a8c477d245542`.

The function-flow successor additionally restricts alpha-renaming to Var/Lam/All/Bind identity fields, preserving incidental metadata indices. This is a conservative tightening of the earlier reviewed draft.

## Follow-on source and controller review

The literal-array successor uses an explicit handle mode in the shared closed-graph audit. Raw callers remain in the rejecting mode. Canonical ALeaf/ANode construction keeps ordinary ctor/arraydata and the unflagged helper ABI; the root retains full fresh host and source guards. Nullary entry reuses the existing zero-formal exactCode form, including omitted-vector behavior. F32 literal realization retains ordered shared-view writes. The source and nullary/lazy-materialization controller pass static review; actual Evening entry remains an execution gate.

The function-flow root integration passes static review: it scans the original complete book for fresh IDs, builds a separate private root, checks complete JPure/worker admission, and retains exact original aliases for removed dependencies and source/native/primitive guards. Substitution allocation is bounded before copying. Whole-book scans and normalization remain compiler-cost risks; matched recursive factories remain outside the first slice.

Independent synthetic tuple controls and generated aggregate controls pass static review. The former tests logical JW interpretation, not JavaScript machine emission; its nonterminal Case witness is deliberately noncanonical and only tests conservative analysis. Generated controls separately cover non-tail returns beyond the native budget, unused-field overflow, Error reentry, public aliases, and actual array-literal allocation deltas.

Reviewed follow-on files:

- `selfhost/src/back/js/array-literals.bend`: SHA256 `52492cb219cd72eed21b9a892d0cb1563b48fb4670c31c2a704e793ebd25ec22`.
- `selfhost/src/back/js/ir/function-flow-root.bend`: SHA256 `a1190d2d67d7c8ae20b1530260cc5f353d409a102cc9d59009d38cca900e8045`.
- `selfhost/src/back/js/ir/function-flow.bend`: SHA256 `2cdc7cf28b88e5567f836c4f1c60263e476a5acccc7f793827c873ce3adbf854`.
- `selfhost/tools/performance/phase48/controls/jw-values-controls-v1.mjs`: SHA256 `a3ed57037376baea771f729bfa0374a7368db39dcc926aa1636877159575c552`.
- `selfhost/tools/performance/phase48/controls/aggregate-transport-controls-v1.mjs`: SHA256 `b97cead60d22e9812d4e7e3c19830d12fe458f83e030a78e85e8f62cbe54f05c`.
- `selfhost/tools/performance/phase48/controls/array-literals-controls-v1.mjs`: SHA256 `5a4e1e69fabcd69f977d5e2b0abc3f6c4c8427fcff6ecddeef04c71ea69399dc`.
