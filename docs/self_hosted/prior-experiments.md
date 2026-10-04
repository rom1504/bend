# Prior optimization experiments and genuinely remaining work

Audit cutoff: installed Phase45 worker23, after commit `55e5b79`. This is a
documentation and source audit, not a new experiment. No compiler, generated
program, benchmark or historical evidence was modified or executed.

Most familiar compiler techniques have already appeared in this project's
research or in a restricted implementation. The useful distinction is **which
facts and program shapes a transformation handles**, rather than whether its
name is new. The largest remaining architectural opportunities extend analyses
across the current private worker IR and retire overlapping special cases.

## Scope and confidence

The bounded search covered Markdown in `design/`, `implementation/` and
`experiments/`, with focused reading of Phases20–45 and relevant earlier work.
It checked current JS IR models, simplifiers, worker lowering/emission, private
proof and plan-cache code. It also reviewed the earlier external-compiler
research collection. It did not exhaustively inspect every archived prototype,
every historical commit or the complete native backend.

“No general pass found” below means absent from the selected JS source and
reports inspected here. It does **not** mean nobody has ever tried the idea.
Chronological reports often retain an early “pending” heading after recording
later results; final release reports and current source determine installation.
Saved-JavaScript experiments are distinguished from checked compiler changes.

The [current steering](../../experiments/STEERING.md) and
[Phase45 report](../../implementation/phase45/README.md) identify the release.
Its 45-point corpus is exposed development coverage, not an untouched holdout.
Phase45 measures 3.0787× TypeScript time by equal-point geometric mean and
4.1467× by equal-source weighting. Those figures are not speed estimates for
any proposal in this document. Compiler request costs increased separately.

## Current architecture matters to the classification

The ordinary [JIR model](../../selfhost/src/back/js/ir/model.bend) represents
locals, globals, applications, lets, lambdas, constructors, primitive operations,
choices and matches. `JIRCallPlan` and `JIRLegacy` preserve source-dependent
compatibility paths as opaque optimization boundaries. A global load may
recompute, throw or observe public mutation; it is not a constant by definition.

Its [facts](../../selfhost/src/back/js/ir/facts.bend) propagate at most 64
Local/Null aliases with shadowing checks. Its
[simplifier](../../selfhost/src/back/js/ir/simplify.bend) preserves evaluations,
removes exact singleton identity lets and folds a limited set of literal U32
operations. It does not provide general effect, escape or use-count analysis.

The private [JW model](../../selfhost/src/back/js/ir/worker-model.bend) explicitly
separates values from instructions: assignment, known direct call, case, return
and impossible. Private calls are statements rather than nested value nodes.
The [emitter](../../selfhost/src/back/js/ir/worker-emit.bend) partitions exact
call components, uses native calls with a shared 32-entry budget, falls back to
continuation machines, and emits proper tail transfers as loops. Tail-only
components omit the unnecessary machine. This is substantial lowering already.

The [worker simplifier](../../selfhost/src/back/js/ir/worker-simplify.bend)
currently removes a narrow class of terminal tuple/Char case tests. There is no
general SSA construction, dominator framework, global value numbering or
cross-call liveness allocator in those inspected modules. Calling the new IR
“SSA” would overstate what has been delivered.

## Idea-by-idea inventory

“Current” describes selected worker23. “Remaining” identifies a different scope
from the cited precursor, not a claim that the idea has never been discussed.

| Idea | Current implementation | Prior attempt and outcome | What remains meaningfully unexplored or unimplemented | Exact evidence |
| --- | --- | --- | --- | --- |
| Direct calls / devirtualization | Known saturated private edges, acyclic helpers, SCC workers and generic fallback. | Phase30 lexical helpers and larger private regions were retained; Phase44 per-callee invocation sites retained generic protocol and lost five of six point medians, so were rejected. | Extend legal call-target coverage; another public invocation helper is not a fresh architecture. | [Phase30 decisions](../../implementation/phase30/decisions.md), [Phase44 rejection](../../implementation/phase44/known-call-dispatch.md), [JW lowering](../../selfhost/src/back/js/ir/worker-lower.bend). |
| Closure conversion | Ordinary descriptors carry closures; narrow inherited callback plans bypass them. General function transport is outside JW. | Phase39 direct callback prototype failed performance admission. Phase43 first-order captured environments and total-U32 construction/application fusion succeeded for a bounded grammar. | Finite lambda sets through factory results, aliases and helper parameters, with explicit captures and staged demand. Already designed, not implemented generally. | [Phase39](../../implementation/phase39/callbacks.md), [Phase43 final findings](../../implementation/phase43/README.md), [known-local-function design](../../design/phase45/known-local-functions.md). |
| Function specialization | Exact erased-type contextual instances and specific callback specialization retain original dependency proofs. | Phase43 contextual Map and callback work was installed; Phase45 broadened ordinary monomorphic graphs and canonical Unit. | Bounded specialization on function-valued arguments and useful value facts, with shared instances and code-size limits. | [Phase43](../../implementation/phase43/README.md), [instance machinery](../../selfhost/src/back/js/jpure.bend), [Phase45 coverage](../../design/phase45/remaining-general-coverage.md). |
| Defunctionalization | Explicit private return stacks already defunctionalize continuations; specialized callback environments also exist. | Phase43 compared materialized first-order environments before fusion; Phase45 replaced private generic dispatch with explicit calls/continuations. | A reusable finite-target representation for ordinary private function values. Do not present continuation defunctionalization itself as missing. | [callback investigation](../../implementation/phase43/callbacks.md), [worker design](../../design/phase45/general-workers.md), [worker model](../../selfhost/src/back/js/ir/worker-model.bend). |
| SSA / CFG dataflow | Structured JIR and numbered JW slots, without a general SSA/phi/dominator optimizer. | Phase38 studied MLton SSA/contification and Cranelift; Phase44 deliberately introduced a structured tree first. | Explicit def-use, joins and dominance where required by measured transformations; no evidence yet justifies an entire new framework. | [Phase44 design](../../design/phase44/README.md), [MLton research](../../design/phase38/research/mlton.md), [Cranelift research](../../design/phase38/research/rust-cranelift.md). |
| ANF / CPS / join points | Ordered let lowering and explicit worker-call statements already provide part of A-normal staging; continuation machines make return control explicit. | Phase30 statement emission and Phase44 general let/choice emission removed binding IIFEs. Phase38 studied GHC join points and MLton contification. | A shared demand-aware administrative form and reusable local joins; full CPS conversion is neither delivered nor shown necessary. | [Phase30 let result](../../implementation/phase30/private-let-compiler.md), [Phase44 report](../../implementation/phase44/README.md), [GHC research](../../design/phase38/research/ghc.md). |
| Worker/wrapper | Public checked descriptors and entry guards surround private workers, with exact fallback and result boundaries. | It is the retained Phase30–45 architecture. Tiny guarded F32 roots and later acyclic wrappers repeatedly regressed. | Better legality/profitability selection and shared worker bodies, not adding another wrapper layer. | [Phase30 decisions](../../implementation/phase30/decisions.md), [Phase45 selection regressions](../../implementation/phase45/selection-regressions.md), [root ranking](../../experiments/phase45/P45-016-root-plan-ranking.md). |
| SROA / scalar replacement | Scalar private state, field vectors, typed Array-read pair elimination, native field projections and private named fields. These do not eliminate every aggregate. | Phase31/32 retained local data optimizations; Phase41 removal of next-argument tuples gave only 0.23–0.40% shifts below noise and was rejected. | General use/escape-driven constructor/projection elimination across JW calls and joins, followed by scalar parameter/return transport. | [Phase32 representation](../../implementation/phase32/local-representation.md), [Phase41 null result](../../implementation/phase41/lists.md), [Phase45 frontier](../../design/phase45/further-frontier.md). |
| Inlining / partial evaluation | Bounded helper expansion, specialized private lowering and direct native constructors already occur; source normalization is a separate frontend operation. | Earlier branch rewrites and Phase42 direct helpers had strict size, recursion and demand constraints. Native constructors were retained in Phase45. | A single budgeted IR inliner using call/use facts, exposing aggregate elimination and simplifying before a size decision. | [region inlining](../../selfhost/src/back/js/region.bend), [Phase42 mechanisms](../../implementation/phase42/mechanisms-and-decisions.md), [native constructors](../../experiments/phase45/P45-014-native-constructors.md). |
| Fusion / deforestation | Narrow total-U32 producer/filter/map/fold and callback construction/application fusion remain selected ahead of weaker plans. | Phase40 established direct-unfused lists; Phase42 added guarded total scalar fusion; Phase43 extended callback fusion. | General producer/consumer facts across helper boundaries and safe multi-use handling; not merely another recognized chain. | [Phase40 lists](../../implementation/phase40/lists.md), [Phase42 mechanisms](../../implementation/phase42/mechanisms-and-decisions.md), [Phase43 callbacks](../../implementation/phase43/README.md). |
| Ownership / reuse | Fresh argument vectors avoid a copy; private regions prove constrained locality; some traversal frames are reused. | Phase30 retained owned vectors and frame reuse. Phase38 studied Lean/Koka reset/reuse but deferred general JS reference counting. | Explicit alias, escape and lifetime facts for surviving private objects; source affinity alone does not establish foreign/public uniqueness. | [owned vectors](../../implementation/phase30/owned-arguments.md), [frame implementation](../../implementation/phase30/frame-compiler.md), [Lean research](../../design/phase38/research/lean.md), [Koka research](../../design/phase38/research/koka.md). |
| Arrays / effects | Older local-region paths support constrained Arrays and typed immediate read/tuple consumption; general JW graphs do not admit Array transport. | Phase30 per-read guards regressed 33.7–43.2%; broader local-array work in Phases31/32 improved complete fixtures and preserved ordered native events. | Typed JW allocate/read/write/swap operations with shared effect/alias facts, plus a separate adapter for escaping handles. | [per-call rejection](../../implementation/phase30/native-array-calls.md), [independent array fixture](../../implementation/phase31/array-fold-control.md), [current coverage](../../design/phase45/remaining-general-coverage.md). |
| Numeric ranges / representation | Proved U32 countdowns, exact private 48-bit Number Nat and literal U32 folding. Public Nat remains BigInt. | Phase30 narrow countdown work was deferred; later phases retained broader proved numeric paths. Phase45 Number Nat plus native lowering had substantial scoped gains. | Dataflow intervals/known bits across branches and joins, or selective representation per operation/component rather than the current whole-graph whitelist. | [Phase30 decisions](../../implementation/phase30/decisions.md), [Nat results](../../implementation/phase45/native-representation.md), [Nat pass](../../selfhost/src/back/js/ir/worker-nat.bend). |
| CSE / value numbering | Bounded local copy propagation is present; no general generated-program CSE pass found in inspected JIR/JW. | Phase32 compiler stop-list/query reuse was investigated; this is analysis reuse, not general target-program CSE. | Pure nonallocating value numbering with explicit effect barriers and dominance. Never equate allocations or mutable global loads solely by syntax. | [IR facts](../../selfhost/src/back/js/ir/facts.bend), [IR model contracts](../../selfhost/src/back/js/ir/model.bend), [compiler reuse boundary](../../implementation/phase32/compact-stop-reuse.md). |
| DCE / unused results | Identity-let removal and known single-constructor case cleanup; general simplification deliberately retains evaluations and bindings. | Source-level cleanup retired obsolete helpers, but does not establish a target-program dead-assignment pass. | Use-driven dead-slot and dead-branch elimination with a distinction between unused value and removable evaluation. | [JIR simplifier](../../selfhost/src/back/js/ir/simplify.bend), [JW simplifier](../../selfhost/src/back/js/ir/worker-simplify.bend), [Phase44 cleanup](../../implementation/phase44/README.md). |
| Liveness / compact continuations | Tail-only SCCs omit machines; non-tail machine calls still save register vectors. Specialized older traversal pools exist. | Phase42 live-continuation prototype shrank four workers from 12,830 to 7,370 bytes, but improved tree points only 1.015–1.029× and was deferred. | General JW live-across-call analysis, compact save sets, slot reuse and bounded retention; distinguish this from repeating the same four-worker rewrite. | [Phase42 frames](../../implementation/phase42/frames.md), [current emitter](../../selfhost/src/back/js/ir/worker-emit.bend), [tail-only components](../../experiments/phase45/P45-015-tail-only-components.md). |
| Proof / analysis memoization | `j_plan_context` stores request-local component/direct JPure facts, including refused results. Runtime proof scope is reused within an entry. | Phase32 complete-state reuse and broad memo wrappers were too expensive; Phase42 installed narrower plan reuse, with mixed net compiler costs. | Shared context-complete summaries for overlapping contextual instances/SCCs beyond existing root caches. Cross-entry caching of mutable runtime guards remains a different, unsafe shortcut without invalidation. | [Phase32 memo results](../../implementation/phase32/compact-counts.md), [Phase42 facts](../../implementation/phase42/facts.md), [current cache](../../selfhost/src/back/js/jpure.bend). |
| Code sharing / outlining | Private lexical functions and SCC partitioning exist; overlapping public roots may still emit repeated specialized graphs. | Phase30 module hoist/dedup cut 7,849 bytes and helper copies from 31 to 8, with no useful whole-program speed gain; deferred. | Sharing typed private component instances across root scopes while preserving per-entry proof capability, dependencies and specialization identity. | [Phase30 hoist](../../implementation/phase30/hoisted-private-helpers.md), [Phase45 compiler costs](../../implementation/phase45/compiler-cost.md), [String-equality growth](../../implementation/phase45/native-string-equality.md). |

## The strongest new implementation directions

### 1. A common use, escape and effect analysis for JW

This is a stronger novelty claim than “try scalar replacement.” Constructor
dispatch removal, private layouts and particular tuple elimination already work.
What is missing is reusable information identifying an aggregate's complete uses,
whether it escapes, and which field computations may throw or observe effects.

A small first implementation can track one fresh single-constructor value across
assignments and direct calls, forward known projections, and remove the object
only when every use is covered. Preserve each field's evaluation exactly once,
including fields whose final values are unused. Add scalar parameter transport
only after the local rule works. Reuse those facts for DCE and frame liveness.

RLE is a useful existing covered graph, but its encoded list has more than one
consumer. That makes “just fuse the list” an invalid starting assumption. The
[coverage audit](../../design/phase45/remaining-general-coverage.md) identifies
this exact distinction. New mixed-feature fixtures should accompany it.

### 2. Finite private function flow, not another callback micro-optimization

The [existing design](../../design/phase45/known-local-functions.md) already
specifies lambda-site identity, evaluated captures, factory prefixes and helper
parameter specialization. Implementing it is new work; inventing the proposal
again is not. The selected callback optimizer handles a much narrower grammar.

Morning returns functions from matched factories and transports them through
finish helpers. Immediate lambda beta reduction alone does not cover that flow.
A bounded alternative set can lift bodies into existing first-order workers;
unknown targets, public escape and effectful prefixes initially refuse.

Preserve `factory(a)` evaluation and forcing before evaluating a later `b` in
`factory(a)(b)`. Simply emitting one call with both arguments can reorder errors.
Keep original source dependencies even when specialization removes their calls.
The existing SCC and deep-stack machinery should consume the resulting graph.

### 3. Typed Array effects in the common worker representation

Arrays have been optimized before. The new scope is making their operations
composable with the general JW backend, rather than an additional cell-pattern
recognizer or per-read descriptor guard. Preserve aliasing, sequencing, bounds,
returned handle/value pairs, native dependencies and F32 rounding.

Start with arrays allocated inside a root and a scalar result. This can isolate
the internal effect analysis. It does not solve generic-row's public `Dp` result,
which contains escaping Array handles; an identity-preserving boundary adapter
is an independent requirement. Evening also has Array/F32 boundaries, so closure
conversion or Unit support alone cannot explain or repair its missing coverage.

The earlier independent [array fold](../../implementation/phase31/array-fold-control.md)
already contains discriminating delayed-write witnesses. Reuse its semantic
lessons, without describing the new JW operation family as the first array work.

### 4. Shared typed component facts and code instances

There is already a root-plan cache. There was already an unsuccessful hoist
experiment. A different proposal must identify duplicate work in the current
contextual graph pipeline and show which immutable proof context can be shared.

An instance key needs original definition identity, erased specialization,
argument/result layouts and relevant ownership/entry assumptions. An SCC body
shared between public roots must not retain another invocation's proof state,
captured input or error/reentry state. Shared analysis and shared emitted code
are separate ablations; either may help without the other.

The uninstalled String-equality candidate25 grew its affected module by 56.4%
while benefiting one source. That supplies a current reason to measure emitted
duplication, not a promise that outlining speeds execution. Likewise, Phase45's
four compiler request regressions justify measuring repeated proof construction,
not reinstating the broad memo wrappers rejected in Phase32.

### 5. General liveness and value facts, with a concrete consumer

JW already exposes calls and returns. A backward live-across-call analysis could
identify dead references and opportunities for slot compaction. The current
emitter saves the parent register vector by reference; packing a live subset can
introduce copying and allocation. Clearing dead references, compacting slots and
allocating child argument vectors are separate hypotheses, not an assumed saving.
A forward value analysis could support pure CSE, branch simplification and
known-bit/range facts. These are general passes absent from the inspected JS
backend, but their precursors and theory have been researched.

Begin with an observed unnecessary save or repeated pure operation. Count the
executed opportunity before implementing global infrastructure. Phase42's compact
live-frame result was small; Phase41's transfer-tuple result was below variation.
Neither justifies a broad forecast, nor rules out a different current bottleneck.

Do not merge separate facts: a value can be unused while evaluating it still
throws; an object can be private while aliased; a call can be known while its
result is deferred. Those distinctions are prerequisites for deleting work.

## Research already available: do not rediscover it

The [Phase38 collection](../../design/phase38/README.md) explicitly researched
the following mechanisms. Its gain ranges were prospective estimates against
Phase37, not results or forecasts against installed worker23.

| Existing study | Mechanisms already considered | What a new investigation must add |
| --- | --- | --- |
| [Bend TypeScript](../../design/phase38/research/bend-typescript.md) | Saturated calls, tail components, native layouts and boundary marshalling. | Compare current private/public contracts and actual residual output, not rediscover direct calls. |
| [MLton](../../design/phase38/research/mlton.md) | Monomorphization, finite lambda sets, closure conversion, contification and deep flattening. | A supported Bend function-flow slice or use/escape analysis with actual demand boundaries. |
| [GHC](../../design/phase38/research/ghc.md) | Demand/usage distinctions, worker/wrapper, constructor specialization and join points. | Reusable facts; a call graph alone is not a demand or sharing proof. |
| [Flambda](../../design/phase38/research/ocaml-flambda.md) | Known closures, invariant arguments, simplify-before-costing and specialization budgets. | A bounded implementation and growth measurement across independent sources. |
| [Lean](../../design/phase38/research/lean.md), [Koka](../../design/phase38/research/koka.md) | Borrowing, liveness, reset/reuse and private builders. | An explicit JS ownership contract; source affinity is not a reference-count uniqueness test. |
| [Chez](../../design/phase38/research/chez.md) | Arity-directed calls, SCCs and small pass invariants. | Retire duplicated proof/emission paths rather than add a framework with no consumer. |
| [Cranelift](../../design/phase38/research/rust-cranelift.md) | SSA, rewrite extraction, e-graphs and cost limits. | Two concrete missed compositions before considering a general equality-saturation engine. |
| [Stream fusion](../../design/phase38/research/stream-fusion.md) | Staging, producer/consumer composition and elimination of Step/callback protocols. | Generalize beyond the already retained total-U32 chain; preserve sharing and errors. |
| [Zig](../../design/phase38/research/zig.md), [earlier Zig study](../../design/phase31/zig-lessons.md) | Compact stage representations, canonical identity and dependency-aware incremental work. | Fresh compile/edit-latency evidence; self-hosting and faster target programs are different outcomes. |
| [JS engines](../../design/phase38/research/js-engines.md) | Guard cost, fixed-arity calls, shapes and code-size effects. | Actual optimized-function/allocation evidence and public mutation preservation. |
| [Compiler engineering](../../design/phase38/research/compiler-engineering.md) | Souper, Alive2, bounded translation validation and adversarial case generation. | An explicit modeled IR subset, rather than treating solver success as whole-compiler correctness. |

## Earlier history changes the interpretation

Phases20–22 primarily pursued parser, loader, declaration/context and diagnostic
conformance/performance. Their indexes and caches optimize compiler requests;
they are not evidence of a general target-program optimizer. See the
[Phase22 final bundle report](../../implementation/phase22/final-bundle-cost.md)
and [Phase23 graph conversion](../../implementation/phase23/upstream-graph-conversion.md).
Phases25–29 established generated-code analysis, direct U32 decisions, matcher
experiments, broader programs and the small-program iteration loop.

Much earlier, [Phase7 architectural trials](../../implementation/phase7/architecture-report.md)
already compared shared traversal, semantic values and checker-owned output.
Generic traversal was larger and slower; semantic closures helped substitution
but hurt closed constructor data and failed a later demand witness. That is
evidence against indiscriminate unification, not against sharing precise facts.

Do not confuse compiler semantic reuse with program optimization. The
[Phase32 complete-state cache](../../implementation/phase32/reuse-counts.md)
found genuine repeated checks but paid too much to compare and freeze their
worlds. A definition-only cache was not sound. The
[compact-query prototypes](../../implementation/phase32/compact-counts.md)
also found repeats but failed performance admission. Narrow request-local plan
reuse later survived; “memoization works” and “memoization failed” are both too
broad to summarize this history.

## Rules for the next proposal

State the exact delta from the table: new domain, shared fact, new composition,
or a new profitability rule. Link the nearest negative experiment before
predicting benefit. Keep runtime execution, compiler latency and code-size
effects separate; none is an automatic consequence of another.

For implementation novelty, require an IR operation or analysis that serves at
least two unrelated compositions, plus evidence of the costly executed work it
removes. For simplification, name the existing recognizers/walkers it retires.
For correctness, preserve demand, aliases, exceptions, host/public mutation,
reentry and deep-stack behavior at the original boundaries.

No speed or line-count gain is claimed by this audit. It identifies where a
fresh experiment can differ materially from the substantial work already done.
