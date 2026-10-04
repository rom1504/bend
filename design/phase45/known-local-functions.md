# Bounded first-orderization of known local functions

Read-only proposal, 2026-10-04. No implementation, build, timing or admission
claim. Consume the current worker IR and exact contextual instance machinery;
do not add another public invocation helper or program-name selector.

## The precise opportunity

JPure accepts closed first-order types and saturated known calls. Function-valued
arguments/results fail j_pure_type_head/j_pure_signature and the contextual
collector. Worker jw_expr has no Lam value or local-variable application case.
Ordinary JIR represents JIRLambda and JIRApply, but its lexical facts propagate
only Local/Null; CallPlan and Legacy remain effect barriers. None of those nodes
alone establishes permission to skip public fn/apply/force behavior.

Literal lambda and global returned function are separate cases. A literal
JIRApply(JIRLambda(...), args) has a lexical target and captures. A global
factory result additionally depends on the exact original G binding, code,
arity/env/bound and its complete source prefix; a source name or function type
is not sufficient provenance. Preserve the ordinary fallback in both cases.

The pinned TS backend is a useful architecture comparison, not an ABI proof:
comp.ts term_spine (738) distinguishes saturated named calls from Clo~apply;
call_eta (781) eta-expands partial calls. js_call (3060) emits direct named
functions or f(x), and js_func (3176) walks checked binders/matches/lets.
Its closure tail path bounces; ordinary named calls remain direct. Selfhost's
mutable G descriptor ABI adds contracts that cannot be removed by copying
these TS emission choices.

## Proposed smallest useful pass

Run bounded known-function analysis after exact erased contextual rows are
replayed and before the first-order graph proof/worker lowering. Reuse those
rows for original-source identity. Produce a separate normalized analysis view;
never change canonical checked definitions or their public representations.

1. Summarize known factories with typed first-order inputs, a prefix consisting
   of currently supported pure operations/lets/typed matches, and terminal
   literal lambdas. Every arm must finish in a supported lambda or another
   summarized known factory. Each closure alternative has an exact lambda site,
   live parameter telescope and typed free-variable capture list.
2. Track those finite alternatives through immutable local aliases and known
   helper parameters. Refuse unknown targets, foreign calls, a closure stored
   in public/ordinary data, returned from the root, compared/inspected, or passed
   to an unsummarized function. No general function-type admission is granted.
3. Lift each terminal lambda to a private first-order definition with explicit
   capture parameters. A factory returns a private closure alternative and its
   evaluated captures. Immediate application consumes that value and emits a
   staged direct call. Where a single known alternative is proved, no runtime
   tag dispatch is necessary; branch-dependent alternatives use an ordinary
   worker case over a private finite tag.
4. Specialize a known helper's function parameter only at a finite known closure
   context. Its private signature receives typed captures/private alternatives,
   and local applications become direct calls to lifted definitions. All other
   parameters retain their original ordered evaluation. Keep each original
   helper/factory as a root dependency even if lifting removes its runtime call.
5. Require the complete normalized graph to pass the existing first-order
   type/purity proof and worker lowering. Unsupported closure flow refuses the
   whole root. Feed new recursive edges into the existing SCC/continuation
   machinery, rather than native unbounded recursion or another dispatch layer.

Initial bounds: at most32 closure sites/contextual callback specializations,
32 live capture+application arguments per lifted target and the existing graph
size/fuel limits. Memoize analysis by exact source instance, lambda site and
callback-target context within one compilation request. Exhaustion preserves
ordinary emission; do not accept a partial graph or silently erase a capture.

## Evaluation and mutation contract

For factory(a)(b), preserve this sequence: callee lookup, evaluation of a,
factory-prefix execution/forcing, evaluation of b, then closure-body application
and forcing. Rewriting it directly as factory_apply(a,b) can move b before
prefix matches/initializers/errors. Instead emit explicit administrative stages
in the worker instruction stream. Capture expressions execute once at their
original point; aliases share those evaluated values. A prefix Let retains
outer/parallel RHS scope, while each application chunk introduces fresh binders.

Literal beta reduction similarly needs exact saturation, alpha-safe bindings,
checked erasure and the original demand boundary. A non-tail original call
forces its result before a subsequent argument or expression; inlining the
lambda's tail-mode JIR body without that completion boundary is incorrect.
Partial application of a lifted target is refused in the first slice unless it
is explicitly represented as another finite known stage. Do not flatten across
a matcher/computed prefix merely because the type has several All binders.

The new legality proof covers both prefix and lambda bodies. Effectful or unknown
closure bodies remain generic. Root inputs remain existing scalar domains;
recursive/object captures arise only from proved private graph values. Shared
captures do not authorize mutation or public escape. Existing full descriptor,
prototype, native/host and input guards cover the source operations and generic
ABI callbacks skipped inside the private region. Check all relevant dependencies
before entry on every public call. Preserve Error proof suspension/reentry and
finally cleanup; no cross-entry permission or value cache is introduced.

Primitive capabilities must retain original factory/helper/lambda bodies before
lifting/folding. The P45-012 original-source+complete-graph collection is the
appropriate provenance boundary; a scan of only transformed calls is insufficient.

## Actual workload coverage and limits

Morning contains two direct higher-order patterns: Str.split returns a Char
function through String matching; Str.join.go returns a String function through
List matching. Str.split.fin and Str.join.fin take the recursive function as
an argument and immediately apply it. Thus immediate top-level factory
elimination alone cannot close this workload. Finite helper-parameter
specialization in step4 is necessary. These are general typed patterns; neither
function name nor literal input participates in compiler admission.

Morning is one of45 points / one of23 sources, at63.098× TS in Phase44. It accounts
for approximately5.10% of point log slowdown and8.51% of source log slowdown.
Reaching parity on this source alone would leave approximately5.55× point and
6.93× source slowdown. These are arithmetic counterfactuals, not estimated gains.
Its complete activation also depends on nullary root support (currently reverted)
and all remaining String/Map/native proof obligations; no coverage is promised
until a fresh successful graph and ordinary-entry counters demonstrate it.

Evening has no explicit user-defined function-result/callback chain in the
inspected source. Its blockers include nullary fpart, Array.swap/F32 and parsing/
Map/Set boundaries. Unicode-text's split/join are explicitly first-order, and
lexer helpers also use first-order arguments/results. Known-closure conversion
therefore has no demonstrated coverage for those sources. Do not label their
slowdowns callback cost or use this proposal to widen unrelated native effects.
Base library function-flow sites may provide additional coverage after exact
source inspection; this record supplies no count or prevalence claim for them.

## Cheapest qualification before timing

Use independent renamed sources covering a captured affine factory, branch
alternatives with noncommutative captures, recursive factory→helper transport,
repeated alias application, and a prefix/consumer-argument error-order witness.
Add refusals for public returned closure, unknown callback, ordinary data escape,
effectful prefix/body, partial/oversaturation and malformed erased/live binders.

On actual emitted source compare complete outputs, branch/demand/error traces,
fresh captures and ordinary-entry/lifted-body counters. Mutate factory/helper
G bindings and code/env/bound metadata, function/prototype hooks and Error
construction with reentry. Every changed dependency keeps the original public
ABI path. Only after this qualification run one unrelated source and morning;
a new helper dispatch or partial static rewrite is not evidence of first-order
coverage or speed. Root serializes every target job.
