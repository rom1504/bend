# P39 unary producer extension

Prospective source design, 2026-10-01. Root owns execution. This narrows the
remaining expression-construction opportunity after the saved-output component
experiment; it introduces no representation change or new public entry.

The warmed five-round prototype retained the tagged `Expr` and existing iterative
`eval`. Producer-only descent/rebuild improved numeric expression points by
1.398×/1.388×; direct producer **and existing private-compatible Nat chooser**
improved them by 5.40×/8.83×. The chooser matters. These are saved-output results
against installed Phase37, not gains already demonstrated by a source compiler.

## Admission

Reuse the existing scalar-input, sum-output `JProducer` context and bounded
whole-graph JPure proof. Preserve the current two-child producer path first.
When that shape declines, recognize a successor whose complete body is one
known saturated combiner call with at most eight arguments. Exactly one argument
must be a saturated self call whose first argument is the immediate Nat
predecessor. The complete definition must contain exactly that one self reference;
zero branches, other arguments and nested expressions must contain none.

The proposal uses the already introduced structural-component reference counter
and graph backedge refusal. Any other graph member referring back to the producer
declines; direct lowering must not hide mutual recursion behind native JS frames.
The candidate is bounded to 512 term nodes and 1,024 reference-scan visits, then
uses the existing region fuel and helper limits. Partial/erased combiner arguments,
an unavailable private helper, a residual generic combiner, more than one child,
or recursion nested deeper inside an argument remains generic.

## Planning and execution

The existing `JProducer` gets a unary flag and records the child argument index.
Its original typed lambda prefix remains intact. The combiner is planned through
the existing helper machinery (including Nat selectors and tagged constructors),
and its arguments through the existing expression planner. Only the known child
receives the producer's self-tail exemption. No fresh source binders or general
ANF extraction are needed; no new IR tag, KDef registry or mutable runtime table
is introduced.

At runtime each descent performs these operations in order:

1. Bind parent scalar arguments and the BigInt predecessor.
2. Evaluate combiner arguments preceding the child, left to right.
3. Evaluate recursive child arguments, left to right.
4. Save the parent scalar values and already evaluated prefix arguments in one
   invocation-local frame; transfer to the child in a loop.

The zero branch builds the same tagged value. Unwinding restores immutable parent
aliases, passes saved prefix arguments followed by the child value, evaluates
the remaining combiner arguments left to right, and invokes the private combiner.
Nat countdowns and operation conversion stay BigInt; countdown narrowing is a
separate proven rule and is not opportunistically added here.

This matters when an earlier argument overflows, the child overflows, or a later
argument overflows. Evaluating all combiner arguments eagerly during descent
would change the first error. Purity does not justify that movement. Likewise,
prefix values must not be recomputed after the child, because errors or callbacks
could change observations. Existing complete private prefix admission permits
only inert canonical matches before later arguments; the source fixture must
verify this obligation rather than infer it from a function's result type.

## Boundary and ownership obligations

Only existing guarded scalar roots call these private producers. Their original
public matcher/functions, raw calls, partial application, getters, mutation and
fallback remain untouched. The complete dependency/host guard covers every helper
before any direct work. A source-pure callee does not authorize an arbitrary
foreign tagged tree. Constructors keep ordinary tags and field arrays; surviving
subtree aliases and full shape must be observed. Frames are local to one call,
and recursive depth uses explicit stack storage rather than JS recursion.

## Proposal and acceptance

`selfhost/tools/performance/phase39/proposals/unary-producer-v1.patch` is proposal
only: **142 added physical lines and 16 definitions**, confined to `producer.bend`.
The original file is 114 lines, so this is a meaningful complexity increase even
though it reuses the existing pipeline. Its metadata pins the original source and
patch identities; no canonical source was changed while preparing it.

Root should first review/check it as a separate candidate and require visible
actual unary-producer entry in the expression workload. A small independent source
fixture must place the child first/middle/last, preserve shared subtree references,
and independently vary errors before the child, in the child and after it. Add
refusals for duplicate/non-predecessor/mutual recursion and staged unknown calls.
Run complete output controls at small sizes and an iterative 30,000-depth witness;
host mutation/reentry must visibly return to the generic implementation.

Then compare clean actual emission against the selected preceding compiler and
the frozen installed baseline, with chooser admission counters excluded from
timing. Retain only if full-component gains survive, the public/host controls
pass and broad compiler cost remains acceptable. Stop if only the modest
producer-only gain survives, if the extraction needs a new general IR, or if
preserving argument order materially exceeds this bounded proposal. No speedup
from the handwritten prototype is a guaranteed source-compiler result.

## Reviewed successor: nested constructor syntax

The checked04 probe found that the unary shape passes but the existing chooser
declines nested constructor fields. The reviewed successor therefore delegates
the fold-constructor field grammar to a producer-only helper: under `@producer`,
recursively allow constructor syntax whose leaves satisfy the unchanged terminal
atom/primitive grammar. Normal typed constructor and argument checks still run;
helper calls and closures nested inside fields still decline. Other contexts
continue using exactly the previous terminal-field test. The added 25 lines and
three definitions are a real additional admission case, with depth/sibling bounds
plus the existing total source and region-fuel bounds. This does not add a new
Nat selector or a general constructor evaluator.

[P39-005 experiment](../../experiments/phase39/P39-005-unary-producer.md) and
[attempt report](../../implementation/phase39/unary-producer.md) preserve the
initial no-admission result, independent review and pending acceptance status.
