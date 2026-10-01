# Private tree mechanism attempts

This file records tool/correctness/measurement decisions separately. All runs
are executed by root under the shared serial resource guard.

## Derivation 01: rejected tool assumption

`selfhost/build/phase37/tree-derive-outer01` fails before creating derived
modules. The v1 tool expected four syntactically identical saturated `warp`
sites, but there are three outer `callOwned` transfers and one outer tail `jump`
from `warp_node`. This is a derivation assertion failure, not a compiler or
program result. No timing follows from it.

The unchanged v1 remains
[`tree-derive.mjs`](../../../selfhost/tools/performance/phase37/optimizer/tree-derive.mjs).
Its explicit successor is
[`tree-derive-v2.mjs`](../../../selfhost/tools/performance/phase37/optimizer/tree-derive-v2.mjs),
which validates three `callOwned` sites and one `jump`, rewrites both forms and
retains each exact generic fallback. The successor manifest binds the v1 tool
identity and reason.

## Derivation and controls 02: selected mechanisms pass the named controls

Root's v2 acquisition at `selfhost/build/phase37/tree-derived02` succeeds.
`selfhost/build/phase37/tree-controls02/report.json` reports complete/pass with
**313 structural/numeric oracle observations, 112 public boundary observations
and 25 admission observations**. Its outer supervisor takes 2.313 seconds and
peaks at approximately 146 MiB, as reported by root.

Each direct variant visibly enters through the real `bench` computation. At
depth 4 / seed 17, zip adds 31 direct zip entries; finite adds 31 zip and 80 leaf
entries; warp adds 49 direct warp entries; component adds 49 warp and 80 leaf
entries. Every named dependency-mutation refusal both blocks the private root
and executes a nonzero generic hook. The source compiler is still unchanged.

These controls establish their stated finite observations, not general compiler
admission. The clean seven-role screen is separate. The consumed v2
deriver and controls are frozen; any correction must use a successor file and
fresh output directory.

## Confirmed mechanism comparison 02

Root's `tree-confirm02` runs five rounds at three input sizes, with seven
variants (105 samples), in 176.383 seconds. These are saved-output experiments,
not release-compiler results. Medians below compare each mechanism with the
byte-identical original Bend module within that same acquisition.

| Mechanism | Depth 6 / seed 17 | Depth 8 / seed 0 | Depth 9 / seed 123 |
| --- | ---: | ---: | ---: |
| Zip only | 1.030× | 1.098× | 1.057× |
| Zip plus leaf selection | 1.327× | 1.333× | 1.324× |
| Recursive warp plus zip | 1.694× | 1.976× | 2.078× |
| Warp, zip and leaf component | 2.604× | 3.234× | 3.559× |

Zip-only ranges overlap at depths 6 and 9. The finite and complete-component
ranges are disjoint at all three sizes. Merely adding the proof boundary is
slower at every size: original medians are 2.888, 20.119 and 58.836 ms; guard-only
medians are 3.014, 20.986 and 65.893 ms. The finite medians are 2.177, 15.091 and
44.435 ms. Even the full component remains roughly 30.1×, 22.8× and 22.6× slower
than the pinned TypeScript modules; this is a useful mechanism, not parity.

The production decision is therefore to test the smallest reusable finite
prefix mechanism that reaches both zip and leaf selectors. A zip-only patch
does not earn its complexity from these observations. The larger recursive
tree-to-tree mechanism remains a separate proposal: its explicit continuation
and ownership proof cannot be treated as a free extension of this patch.

## Actual-source candidate and pre-build review successors

The candidate introduces one bounded, acyclic selector admission/emission module
and reuses the original typed Lam/Mat prefix, existing `JPure`, proof scope,
constructor layout, generic fallback and scalar guards. It creates no new IR or
recursive worker. A complete scalar root gives ownership of fully materialized
private trees; a covered saturated selector can then inspect inert tags/fields.
Public trees, partial calls and changed descriptors retain generic behavior.
The complete proof argument and open cost concerns are in
[`finite-review.md`](finite-review.md).

Two proposals were corrected before any build:

- [`finite-v1.patch`](finite-v1.patch) / [`finite-v1.json`](finite-v1.json):
  root→matcher→root tail cycles could nest `force` frames. The successor opens
  this root only when `regionProof===null`; nested roots return their original
  generic jump to the outer trampoline. It also moves callee lookup behind the
  named-call tag gate.
- [`finite-v2.patch`](finite-v2.patch) / [`finite-v2.json`](finite-v2.json):
  Bend Boolean operators are eager. Conjunctions did not schedule expensive
  readiness checks conditionally, and match discovery traversed annotation
  types excluded by the node budget. V3 uses nested `kc` gates, checks saturated
  arity before readiness, short-circuits useful-definition discovery and strips
  annotations in the already-bounded match scan.

These are preserved **unexecuted proposal versions**, not measured compiler
failures. V3 is frozen for root's first checked build together with the separately
reviewed native-cast/DataView guard change. The independent host-hook review
found that the prior guard omitted mutable `DataView` methods and the retained
float-view instance; that correction is required for promotion of both changes.

The actual checked-source fixture and controls are
[`finite-fixture.bend`](../../../selfhost/tools/performance/phase37/optimizer/finite-fixture.bend),
[`finite-acquire.py`](../../../selfhost/tools/performance/phase37/optimizer/finite-acquire.py)
and [`finite-controls.mjs`](../../../selfhost/tools/performance/phase37/optimizer/finite-controls.mjs).
They require a fresh matched baseline/candidate/TypeScript acquisition. The
diagnostic derives counters only from emitted finite branches; it does not add
a hand-written worker. Mandatory evidence includes complete alias-preserving
trees, first/last Bool and multiple sum matches, declined helper/native/higher-
order/array shapes, 30,000-step self and mutual tail cycles with one outer force
owner, actual argument overflow with Error callback mutation/reentry, changed
dependencies and raw/public/staged boundaries. At this writing those actual
source controls and compiler costs are pending.

## Checked build 01: source-parser rejection, successor prepared

The first actual checked build fails in bootstrap parsing after 2.56 seconds,
before a compiler is produced. Its immutable snapshot and stderr are under
`selfhost/build/phase37/checked01`. The error points to `match args` in
`j_finite_emit`: this source form attempts a parameter match after preceding
local bindings, which the upstream structural parser treats as a consumed
binder context.

The source successor moves the parameter match to the start of that definition.
The empty case computes its normalized leaf directly; the nonempty case binds
the same normalized body/type inside its branch. Admission, emitted JavaScript,
proof scope and runtime changes are otherwise identical. The optimizer owner
made this source edit without running a compiler or control; root's fresh
`checked02` is required to validate it.

## Actual finite fixture acquisition 01: unannotated local refused

Root's `finite-cohort01` fails the historical baseline checker before candidate
acquisition: `+leaf = BoxLeaf{x}` cannot infer a constructor result type. The
checked receipt `finite/baseline.mjs.json` records the expected annotated-term
diagnostic. This is a fixture admission error, not a compiler regression. The
consumed v1 fixture/acquirer remain unchanged.

The explicit `finite-fixture-v2.bend` successor annotates that sole constructor
local as `(BoxLeaf{x} : FiniteBox)`. Its `finite-acquire-v2.py` binds the v1 tool
and names the v2 fixture; all checked worker, hash and resource protocols remain
unchanged. Root must use a fresh cohort directory. No fixture was executed by
the optimizer author.

`finite-cohort02` also fails baseline inference at the same constructor despite
the parenthesized RHS annotation. Preserve that receipt and both v2 inputs.
The v3 successor uses **`+leaf: FiniteBox = BoxLeaf{x}`**, the typed-let form
already present in checked compiler sources (`check/kernel.bend:1257` and
`check/specialize.bend:374`). This is a known accepted constructor-binding form,
not another proposed term-annotation spelling. `finite-acquire-v3.py` binds v2
as its parent and requires a fresh cohort directory. Root must validate the v3
fixture before any actual finite behavior is claimed.

`finite-cohort03` passes the typed constructor binding but then refuses the
forward call from `finite.cycle.root` to its as-yet-unfilled mutually recursive
helper. The pinned language requires unsafe mutual recursion here; adding a law
alone does not permit live use before its definition. The v4 fixture follows
`tests/run/unsafe_mutual.bend` from the pinned upstream: explicit laws and
`@unsafe` definitions for the six cycle functions, retaining all typed scalar
inputs and the same decrementing computations. This runtime stack control does
not claim a termination proof. Remaining fixture functions stay unchanged.
`finite-acquire-v4.py` records v3 as parent and this exact reason; prior failed
receipts and source versions remain unchanged.

## Actual fixture/control successors and passing final control

`finite-cohort04` checks and emits the v4 source with all three compilers. Its
`finite-controls01` then fails **before execution** because the tool incorrectly
requires `choice_check` to have the new finite root. Inspection shows the older
scalar/fold root legitimately wins there and in `leaf_check`. Those ordinary
paths remain useful differential controls, but they cannot prove entry to the
new finite route. This is a diagnostic admission assumption, not a compiler
behavior mismatch. Frozen v1 controls and that failed report remain unchanged.

The coverage reviewer owns the explicit v5 fixture/acquirer and v2 controls.
`leaf_scoped` routes the finite leaf result through the aliased multi-input zip,
giving a real finite root with independent expected result `4*(x+y) mod 2^32`.
Mutation tests for leaf/Bool.xor use that actual scope. Root's fresh
`finite-cohort05` checks/emits the same source in Phase36, checked03 and pinned
TypeScript. `finite-controls02` passes in **1.307 seconds**, reported peak
101 MB, with **154 oracle observations, 9 admission observations and 76 boundary
observations**. No consumed tool was edited after that run.

The actual module has 44 inline finite sites covering exactly `finite.choose`,
`finite.change`, `finite.score`, `finite.zip` and `finite.leaf`. Its eight new
roots are `empty_check`, `alias_check`, `leaf_scoped`, `opaque_check`,
`argument_check`, `finite.cycle.root`, `finite.mutual.root` and
`finite.mutual.next`. Actual benign tests enter all five selector families:
22 choose, 14 change, 16 score, 25 zip and 20 leaf entries before boundary tests.
Shared children remain identical references and complete nested values match.
Both 30,000-step cycles add exactly one outer root scope and one terminal
choose/score entry; the mutual `next` wrapper does not open a nested scope.
Proof state is false after each completed/throwing observation.

Read-only hash comparison confirms every final baseline/candidate/TypeScript
module's bytes equal both its checked emission receipt and the control input
record. All three receipts name fixture SHA-256
`c8d68da2cb6ddd292651ecdb304fa915b7035f79af165bb2f954b0f7f2749d58`.
Candidate module SHA is
`52587879f63ea022c863cf7c4830b2d24a6ecb3aded46f7632ba18b22dd19b5f`,
and its diagnostic names that exact parent. The checked03 API is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`;
runtime SHA is
`51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`.
The checked receipt reports source/type acceptance; mathematical proof trust is
explicitly not assessed. In particular the mutual-cycle fixture uses the
language's `@unsafe` recursion convention, and claims runtime behavior only.
