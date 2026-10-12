# Phase70 bounded observer analysis

This is the analysis-only implementation lane for the
[Phase69 observer design](../phase69/root-preserving-observers.md). It changes
no production compiler source. The installed baseline is commit `32d159b`,
checked B1 `674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`.
Phase69 artifacts are closed; every new tool/result belongs to Phase70.

## Actual core shape

Root ran `observers-analysis/capture-core.mjs` under the guarded target lane.
`selfhost/build/phase70/observer-core01/report.json` captures nine actual
definitions, their erased/compacted bodies and fourteen dependencies (4,559
visited nodes), without C emission. It took 2.71 seconds, about 220 MiB, and
preserved the original API. The source-only lane did not execute the query.

Both important recursive bodies start with **raised matchers**, rather than
leading lambdas. For example the bit traversal is `Mat SNil ... (Mat SCon ...
Efq)`, and its branch closures consume the remaining scalar arguments. A
normalizer must apply explicit parameters to callable matchers; stripping
leading lambdas is insufficient.

The actual helpers have small acyclic bodies that only unpack/repack fixed
Tuples and reconstruct String/Char constructors. The scalar leaf calls are
the already recognized native `Nat.sub`, `U32.shrn`, `U32.and`, `U32.is_ne`
and `U32.cmp`. Thus the first general pass can restrict residual scalar calls
to existing scalar primitives, avoiding a broader scalar-worker effect proof.
Function names select diagnostic captures only; none is an admission rule.

## Plan schema version 1, agreed with emitter lane

An accepted plan contains:

| Field | Contract |
| --- | --- |
| `owner` | Actual definition identity; private worker is `$observer.<owner>`. |
| `params` | Ordered fresh runtime parameter IDs with `BorrowRoot(descriptor)` or immediate scalar kind. |
| `roots` | Original parameter indices retained by the adapter. Each appears exactly once in the result wrapper. |
| `resultId`, `resultKind` | One fresh runtime result ID and checked immediate representation. |
| `wrapper` | Existing `Ctr` KTerm tree of at most two fixed result shells, containing only original-root Vars and the result Var, each exactly once. |
| `descriptors` | Instantiated owner, constructor identity, field order/kinds, storage and matcher behavior. |
| `body` | Residual KTerm grammar below, with globally fresh generated binder IDs. |
| `budget` | Total spent/remaining nodes, helper expansions and maximum depth; never reset for a branch. |
| `proof` | Root-result projection mapping and admitted/refused reason; diagnostic only, not a user-controlled capability. |

The adapter stores owned roots in stable locals. The observer receives separate
by-value cursor parameters. Tail updates may only mutate the latter. An
optional plan must not replace or invalidate any ordinary worker when it fails.

Residual syntax deliberately reuses `KTerm` storage:

| Node | Encoding |
| --- | --- |
| Return | `NO_Return`, kids `[atom]`. |
| Scalar binding | `NO_Let`, id=binder, kids `[NOp-or-approved-NFCall, body]`. V1 admits only scalar `NOp`. |
| Match | `NO_Match`, name=descriptor ID, kids `[scrutineeVar, NO_Fields(vars), hit, miss]`. |
| Self-tail transition | `NO_Loop`, kids=ordered argument atoms. |
| Error | `NO_Error`, name=fixed runtime error identity. |

Atoms are Vars, immediate NWords, or validated nullary scalar constructors.
All runtime locals stay `Term` initially. No cast/word-narrowing assumption is
introduced by this pass. Match descriptors distinguish boxed reads, Nat
predecessor, identity Char view and nullary cases. Do not use allocating
`nc_field_word` U32/F32 Word views, arrays or unsupported unary packed roots.

## Analysis algorithm

Use bounded symbolic evaluation over the actual compacted core, with an
explicit continuation and a lexical symbolic environment. A symbolic value
is a runtime atom with an origin, a virtual constructor with symbolic fields,
or a callable lambda/matcher/known reference. Virtual constructors are never
emitted inside an observer. Their argument computations remain ordered residual
statements, so removing a wrapper never removes a failing computation.

Applying a lambda extends its lexical environment. Applying a raised matcher
matches its first actual and reapplies remaining actuals to the selected branch
closure, exactly as native lowering does. A matcher on a virtual known
constructor reduces locally; a matcher on a runtime borrowed cursor emits a
qualified `NO_Match` and extends only that branch's origin environment.

Every fresh runtime binder/origin is globally distinct within the candidate.
Helper expansion must alpha-rename all nested binders per invocation, or use
separate invocation-scoped lexical bindings and fresh runtime origins that are
provably equivalent to alpha-renaming. Reusing source binder IDs as origin
identities across two calls is forbidden.

For a successful constructor match at origin `p`, its field `i` receives
`Field(p, instantiated-owner, ctor, i)`. Reconstructing that exact constructor
from its exact ordered fields becomes `p`. Facts belong to the successful
branch only. A literal matched nullary constructor likewise equals its root.
Changing/reordering fields, crossing branch origins or using another root's
field prevents this reduction.

A candidate proposes a wrapper projection mapping from its typed result. On
every successful exit, normalize the virtual result and prove that each root
projection equals the corresponding original argument origin. All remaining
result structure must match the one fixed wrapper and one immediate scalar.
Types propose projections; they do not prove identity.

At a recursive call, substitute a virtual result with the proposed preserved
root projections and a fresh observation marker, retaining a mandatory
recursive statement. Analyze its continuation without unfolding another
recursive body. Accept only if that continuation proves the outer root mapping
and reduces to returning the same observation without additional dynamic work.
Then replace the mandatory call with `NO_Loop` over the evaluated actuals.
Otherwise refuse as non-tail residual recursion. This is induction on finite
successful executions, not an assumption of termination. A dead recursive
result must not delete the call.

Recognized native scalar operations produce an ordered `NO_Let`, even when
their resulting value later becomes unused. Calls with no scalar primitive
rule may be unfolded only under a bounded acyclic helper stack. Unknown,
foreign, bang, dynamic, parallel or cyclic helper behavior refuses the plan.
Any future admitted scalar-worker call requires an immediate result mapping
and the final admitted transitive dependency closure, with error propagation.

## Stages and validation

1. Capture real core and finalize this schema before production edits.
2. Build a pure reference analysis over captured core, plus positive/refusal
   cases. It is a diagnostic specification, never a host compiler fallback.
3. Translate the bounded analysis into a Bend proposal snapshot and query it
   through the checked helper loop. Root alone runs targets and integrates.
4. Connect independently reviewed plans to the emitter, preserving checked
   host permission and ordinary raw/device paths, only after analysis controls.

Decisive controls: unrelated one/two-root ADTs; two invocations of the same
helper; changed/reordered fields; branch-origin crossing; duplicate/missing
root in wrapper; dead failing scalar and recursive computations; non-tail and
mutual recursion; unknown foreign effects; descriptor refusal for native
Word views and packed/array roots; cumulative budget exhaustion. A refusal
report distinguishes unsupported shape, budget limit and invalid proof.

Current source/data artifacts are under
`selfhost/tools/performance/phase70/observers-analysis/`. Emission and independent
controls are owned by separate agents. This document records a proposal,
not a claim that a compiler optimization is already implemented or qualified.

## Source proposal v1 and its exact boundary

The first frozen source gate consists of `observer-layout-v1.bend` (286 lines),
`observer-literals-v1.bend` (30), `observer-analysis-v1.bend` (465), and
`observer-plan-v1.bend` (53). These 834 physical lines plus the separate
emitter/adapter exceed the original 350–600-line estimate. Generic raised
matcher application, scoped helper expansion, demand preservation and bounded
constructor telescopes account for the extra machinery. This is a real
complexity cost to assess against measured production gains; the saved-C
speedup alone does not justify promotion.

`no_observer_plan(book, name, permission)` returns
`NO_Plan{owner, schema, analysis, error}`. A false permission returns before
schema discovery or body analysis. The checked production caller must also
exclude bang owners and preserve raw/device fallback. The schema provides
parameter Vars with exact canonical types, root indices, fixed wrapper,
observation kind/result ID and descriptor specifications. The analysis provides
residual body, next fresh counter, remaining global fuel and refusal reason.
`no_plan_params` converts ordered parameter Vars to existing `NC_Binding`s.

All fresh fields are **counters**, where `nc_id(n) = 4294967295 - n`; they are
never absolute variable IDs. Parameters, result and residual binders consume
one monotone counter. Analysis also reserves the compiler's high-ID range.
Invocation-scoped lexical environments preserve source-binder meaning while
fresh runtime field origins prevent two helper expansions from aliasing.

A correctness review found two important demand traps before installation:
zero-argument references are immediately demanded by ordinary lowering, and
native `Succ` constructor evaluation can fail with overflow even when its
result is discarded. V1 conservatively declines every evaluated zero-argument
reference and native `Succ`, `U32` or `F32` constructor. It uses
`nc_definition_plain` directly, avoiding prepared static bodies and preserving
`KLiteral` types before ordinary numeric compaction erases them. Numeric
literals carry their exact Nat/U32/F32 kind into emitted `NWord` atoms; incoming
untyped `NWord` is refused. String literals expand one structural step per
budgeted evaluation. A virtual Char constructor requires exactly one U32 field.
There is no wildcard immediate kind in the Bend gate.

The initial Python `reference-core03.json` establishes only that the captured
Map core can be structurally transformed. It predates the zero-argument demand
and exact-kind fixes and is not a semantic validator or executable compiler
input. Its String refusal records a metadata limitation of existing product
layout queries; the new bounded schema expands actual result constructor
telescopes and does not inherit that limitation. Production qualification must
use the Bend proposal and independent positive/refusal controls.

Source-only preflight found balanced delimiters, unique helper declarations,
no production-name collisions and no unresolved nonlibrary helper references.
Those checks are not a Bend syntax/type check or a runtime correctness claim.
Root owns the first checked analysis query and every later target run.

## First checked analysis results

Root's checked `observer-analysis04` build uses analysis-v3, layout-v2,
plan-v2 and literals-v1. The changes from v1 are explicit sharing and a local
list annotation, not a weakening of admission. Production emission is not
activated by these query results.

| Own checked fixture query | Definition | Accepted | Residual scalar operations | Residual loop sites | Fuel remaining /4096 |
| --- | --- | --- | ---: | ---: | ---: |
| `observer-query01` | `Map.bit.go` | yes | 4 | 1 | 3945 |
| `observer-query01` | `String.cmp` | yes | 1 | 1 | 3935 |
| `observer-query02` | unrelated `strand:compare` | yes | 5 | 3 | 3685 |
| `observer-query03` | unrelated `strand:probe` | yes | 0 | 1 | 4044 |

False-permission queries return before schema/body work and retain the full
budget. One deliberately retained query mismatch is informative: asking for
`strand:probe` inside the two-root fixture queries an imported, unreachable,
unelaborated definition, so the first matcher descriptor declines. Querying its
own one-root fixture accepts. Production enumeration must use the actually
checked reachable names, and diagnostic manifests must pair each requested
function with its own checked entry point.

An independent pure-data audit, `residual-audit01.json`, checks those actual
Bend-produced plans against primitive signatures captured from the checked
book. It verifies scalar parameter/result kinds, descriptor owner and ordered
field types, branch-local bindings, globally fresh ID counter ranges, exact-once
wrapper projections and strict same-root recursive descent. It runs no compiled
target and does not reconstruct the removed source return-identity proof; that
proof remains in the reviewed Bend analysis. All four plans pass this finite
audit. No generated-program speed or raw/device correctness claim follows yet.

Schema discovery currently collects scalar reader descriptors only after the
entire parameter/root/result schema qualifies. A false permission or refused
signature does not scan the book. Before broad integration, measure whether
multiple qualifying candidates justify sharing this immutable descriptor list
per checked request. A two-stage batch planner can discover basic schemas first,
then compute one list only if at least one qualifies. No user-controlled book
marker or second intermediate language is needed for that cache.
