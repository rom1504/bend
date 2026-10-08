# Native lowering: close the semantic gap before building another backend

Phase68 proposal; starting installed Phase67, upstream `0592662`. Source review
only at registration. Performance forecasts below are hypotheses, not results.
Actual admission and measurements belong in the Phase68 implementation report.

## First experiment: matcher-aware known calls

Our direct JavaScript backend already computes complete source-call arity:
`jd_arity` combines declared formals with a lambda prefix common to every matcher
arm, caps that prefix by the checked type telescope, and `jd_live_arity` removes
erased slots. These are general typed queries, despite their historical names.
The native backend's `nd_leading` instead stops at the first `Mat`.

The maintained array fold exposes the consequence without any workload-specific
rule: `fold.loop` has native arity zero instead of three; `fold.cell` one instead
of two; `fold.step` two instead of three. Inspection of the selected generated C
finds four curried closure allocations, two boxed Tuples, five generic closure
applications and eight continuation cuts in a positive iteration. Upstream's
corresponding loop carries the array and scalar words directly. These are static
path counts, to be checked by separate operation counters, not timing samples.

The first prototype shares the existing typed arity query and eta-opens the
native direct entry to that arity. Fully applied matchers consume constructor
fields followed by residual arguments in the selected branch. Fresh aliases
before matching preserve ownership if a scrutinee also occurs in another
argument or a branch capture. Single-argument Nat pattern compression remains;
multiargument matching initially uses the ordinary matcher. Partial and unknown
calls retain the existing closure entry, and bang calls retain their dispatch.

Arity is computed on the original annotated `KDef`, before native erasure. An
erased matcher records live fields; feeding it to the source-arity query would
mix two different binder counts. Existing raw-core tests with intentionally
incomplete type declarations retain the old leading-lambda lower bound.

Fully saturated named calls follow upstream's positional argument-evaluation
contract. This may correct an inherited native discrepancy: the old curried
path could inspect an early matcher before evaluating later actuals. The
IO.OP-prefix-versus-Nat-overflow discriminator must compare both compilers to
the pinned upstream oracle. A baseline difference is not automatically a new
regression; partial application boundaries remain a separate obligation.

Candidate: `selfhost/tools/performance/phase68/architecture/arity-v1.patch`.
Production remains root-owned. First discriminate with a checked build, the
small independent arity controls, and array/numeric/closures. Then run the
six-family short loop and held-out programs. A plausible array improvement is
several-fold if closure traffic dominates; the remaining two Tuples and segment
calls prevent promising parity from this change alone. Allow roughly 30–60
minutes for a value test and fixes, excluding final release qualification.

## What the current representations can share

| Existing representation | Useful shared content | Boundary |
| --- | --- | --- |
| Typed `KTerm` and `back/common/queries.bend` | Source types, constructors, application spines, erased slots | Keep dependent checking outside the runtime optimizer |
| Direct JS call analysis | Full arity, exact named targets, tail components | JS bounce/host behavior remains target-specific |
| Direct JS ordered lowering | Explicit sequencing and delayed closure scopes | It presently stores JS text; do not translate that text into C |
| Older `JWInstruction` worker IR | Named assignments, calls, cases, returns; aggregate values | It belongs to the legacy private-worker admission domain, not today's general JS backend |
| Native `N_Segment` | Existing scheduler/closure/ownership compatibility boundary | String bodies lose the high-level information needed for aggregate optimization |

After the prototype works, move the unchanged arity helpers into a narrow
`back/common` module and include that module plus its already-shared query
prerequisites in standalone native assembly. Keep names/bodies initially to make
JS executable-closure equality review simple. Remove obsolete native prefix/body
helpers only when no caller remains. This gives two real consumers of one
analysis; it does not create a competing optimizer merely to claim a shared IR.

## Second experiment: virtual local aggregates

Represent a known nonescaping constructor as ordered fields until a real escape.
Constructor followed by its own matcher becomes field bindings, preserving the
constructor's child-evaluation order and ownership actions. Start with local
Tuple producer/consumer pairs, including native Array.get/size/update result
transport; do not globally change the public/runtime Tuple representation.

The semantic pass should expose a small structured operation list: evaluated
values, known calls, constructors, projections/matches, explicit ownership and
returns. C materializes a box only at a generic call, capture, heap store, dynamic
join or runtime boundary. JavaScript can use the same escape/field facts with
its own representation. Avoid pretending a general constructor's tag check or
shared ownership disappears merely because its apparent field shape matches.

First distinguish local producer/consumer fusion from cross-call transport.
Local fusion alone cannot remove both hot array-loop Tuples: Array.get passes
its pair to the named fold.step worker, and loop state crosses another named
worker boundary. A private two-word Tuple argument/result convention must span
those boundaries, while ordinary closure wrappers retain boxed values. Native
N_Segment.result, ne_ret and the frame return machinery already support multiple
words; NC_Binding currently cannot retain their aggregate identity. The narrow
missing layer is an explicit flat-value layout shared by each admitted caller
and callee, with materialization at escapes. Escaping tree/Map nodes remain
boxed.

Expected gain is workload-dependent; a further 1.5–4× on an allocation-heavy
array path is a useful falsifiable target, not a forecast for all programs.
A bounded local fusion prototype should take about 1–2 hours, but the useful
cross-call prototype needs additional ownership and ABI work and should be
budgeted separately. Measure the arity change first before choosing this cost.

## Third experiment: ordinary C function regions

Only after arity and aggregate facts are explicit, lower an admitted synchronous
region to ordinary C functions and self-tail loops. A wrapper segment transfers
its already-owned words to the worker and returns its word/result tuple through
the existing scheduler ABI. A worker may call another admitted worker or an
explicit primitive. Unknown callbacks, foreign effects, forks and bangs retain
the segment path; do not synchronously re-enter that scheduler from an ordinary
worker without a separately specified bridge.

Initial admission: known full calls; explicit result layout; no parallel let,
bang or unknown call; an acyclic call graph except self-tail recursion. Expand to
mutual tail SCC dispatch only after the single-loop path passes. Preserve stack
behavior for non-tail recursion rather than replacing unbounded continuation
execution with uncontrolled native recursion. Boxed one-word values are a valid
initial ABI: direct C calls need not wait for whole-program unboxing.

A direct C lane can remove residual continuation traffic and expose local
optimization to Clang. It may yield another factor on numeric/array workloads,
but ordinary C alone cannot erase escaping allocation or callback dispatch.
Prototype cost is approximately 2–4 hours if a small shared operation plan is
available; complete ownership/parallel/GPU parity is outside that estimate.

## Known callback specialization and growth control

A known function passed through a helper can become an explicit target plus
capture arguments. Specialize by target identity, erased runtime signature and
layout, never by benchmark name or observed runtime input. Reuse the same key
across calls, bound variants per source function, and retain the generic version
for escaping/unknown functions. Simplify before duplicating continuations; use
join blocks instead of copying a suffix into every branch.

This ordering follows the existing research: [Lean's staged LCNF, specialization
and ownership](../../research/compilers_architecture_and_techniques/lean.md),
[LLVM aggregate/escape constraints](../../research/compilers_architecture_and_techniques/llvm.md),
and the [Bend TypeScript source study](../../research/compilers_architecture_and_techniques/bend-typescript.md).
Those surveys retain their older source pins; the Phase68 upstream owner audits
current `0592662` directly. No external research benchmark is a Bend gain claim.

Do not build three independent optimizing emitters. Share the smallest semantic
facts and structured operations with two demonstrated consumers, keep target
ownership/layout policies explicit, and delete superseded paths only after
coverage is measured. Compilation speed, emitted size and production line count
are admission metrics alongside executable speed; faster code is not permission
for unbounded specialization or a slower development loop.
