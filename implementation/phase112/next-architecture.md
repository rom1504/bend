# Phase112: three ranked architecture experiments

The strongest next work removes representation and control-flow boundaries before
they become runtime operations. The [hot-call audit](hot-call-boundaries.md) and
[broad workload audit](broad-gap.md) identify three distinct opportunities. They
should remain separate experiments so a successful counter reduction, semantic
qualification and timing benefit can each be attributed correctly.

## Keep the denominators separate

| Measurement | Current observed scope and ratio to upstream |
|---|---|
| Generated-program execution | Word N2: **24.86798×** geometric time over 44 measurable points in the original 45-program corpus; 38 points outside this phase's initial six give 26.98361×. The 45 points represent 23 historical families, not 45 independent program families. |
| Native compiler request | Word N2: **2.44827×** geometric request time over the three fixed lexer/closures/map inputs, prepared Base. This measures the compiler executing to emit QBE, versus upstream TypeScript/Bun emitting C. |
| Ready executable from source | Word N2: **1.14669×** geometric stage-sum time over those same three inputs, including machine construction. Native reuses its cached runtime object; upstream C/Clang rebuilds its runtime. |

These observations are recorded in the [phase report](README.md). They are not
interchangeable. Being close to upstream's ready-executable construction time does
not establish generated-program speed parity. The newer gap candidate improves
the initial six-program screen; its result does not replace the word N2 broad
denominator. Early ownership-facts qualification/measurement is pending at this
planning checkpoint; no gain is assumed from it.

## 1. Reuse checked scalar facts before ownership and continuation lowering

**Question:** can facts already established by the checked frontend eliminate
generic scalar ownership operations early enough to admit complete ordinary
regions?

The current
[`typed-ownership` prototype](../../selfhost/tools/performance/phase112/typed-ownership/overrides.bend)
reuses `nf_worker_kinds`, typed entry bindings and `nk_binding` alias/literal facts.
It removes keep/sink only for established `N_W32` values; it keeps the physical
U64 Term ABI. Unknown values, fields and unclassified call results preserve their
old ownership behavior. This is a useful first boundary, not permission to infer
representation from a source spelling or a benchmark name.

The [scalar-region `mit` witness](../../selfhost/build/phase111/p112-word-broad01-scalar-region-8192/program.ssa:6017)
saves a frame then keeps a known U32 before calling `asr8`. Pure-gap fusion alone
cannot cross that operation. Removing a proven-trivial keep can expose an already
safe argument computation, making the two optimizations complementary. Compiler
digit parsing has the same kind of known scalar duplication, plus structured
predicate and nested-frame barriers that remain separate.

**Smallest experiment.** Finish the existing facts candidate and its composed
pure-If gap qualification first. Observe the exact emitted bodies of one scalar
loop and one independent typed function with a duplicated scalar and owned String.
Count remaining ownership calls and returning frames. Do not acquire another full
compiler merely to find whether these local boundaries were removed. Only after
this works, extend fact propagation to a finite, checked catalogue of primitive
results and branch joins; retain conservative fallback everywhere else.

**Independent controls.** Reuse the existing alias, shadowing, captured-owner,
unused-scalar, type-alias and lookalike-type refusals. Include U32 wraparound,
F32 signed-zero/NaN bits, Char values, both Bool encodings admitted by the actual
runtime, and wide Nat remaining conservative. Add a branch join where only one
arm is proved scalar and an unknown ordinary-call result: neither may inherit a
scalar fact without a valid join/summary. Observe retained String aliases after
the result is released, in both release orders.

**Stop/go.** Stop widening facts if a supposedly admitted case leaves the same
critical ownership/frame barrier: inspect the lost fact first. Go to the short
matched runtime screen only after exact outputs and ownership controls pass and
the intended calls disappear. Separate a direct keep/sink count reduction from
the additional frame/jump reduction it enables. A full compiler acquisition is
justified only after source/API gates and the small generated programs establish
the mechanism. No whole-program speed multiplier follows from a keep count.

## 2. Carry flat products across ordinary calls and array operations

**Question:** can nonescaping product values retain their separate owned fields
through calls instead of becoming heap carriers?

`local-pair`'s 256×256 grid constructs four array-read tuples and one `Dp` carrier
per cell: **327,680 carrier constructions per pair**, before extra RC wrappers.
The frozen upstream already passes and returns the four array handles separately.
The same edit-distance family provides an immediate independent larger consumer.
This structural category survives local call-gap fixes.

**Smallest experiment.** Introduce a finite product-shape result for checked,
closed calls: a vector of typed values with one ownership credit per owned field.
Start with canonical `Array<U32>` get returning `(array handle, scalar)` and a
nonrecursive function returning a closed two-field product. Then compose through
two ordinary functions and a tail loop carrying four handles. Return multiple
words through an explicit output-slot ABI, never a C aggregate ABI assumption.
Box only when the product escapes to an unknown call, closure, heterogeneous
container or unsupported layout. Public generic entry points retain their
existing boxed contract with explicit adapters.

The implementation should use checked layout/erasure facts and reusable call
summaries. It must not recognize `Dp`, `cell`, edit distance or a particular
field count by source name. Array access itself continues to use the real runtime
semantics; the experiment removes temporary result packaging.

**Independent controls.** Freeze two unrelated product types, field-order
permutations, zero/one/several returned fields, and a loop that swaps two arrays.
Test alias/clone survival, shared and unique handles, array updates after a
flattened read, and both release orders. Include an owned String field so a
scalar-only implementation cannot pass by ignoring ownership. An escaping
product and an unknown callee must retain correct boxing/fallback; wrong result
width or layout must refuse. Compare complete outputs against frozen upstream
results, not against expectations produced by the candidate.

**Stop/go.** First require zero temporary tuple allocations in the admitted
read/consume control while preserving the returned handle and value. Next require
zero temporary state-record boxing around the closed loop. Distinguish these
carrier counters from actual array storage allocation. Only then build the
local-pair/edit-distance cases and measure paired runtime, allocations, memory
and machine-code size. If products still cross the generic ABI boxed, stop and
fix that interface instead of tuning the allocator. The 327,680 source-path bound
does not predict the fraction of CPU time recoverable.

## 3. Admit recursive groups as direct loops, with explicit reconstruction limits

**Question:** can a checked group of mutually tail-recursive functions share a
local control-flow region instead of waiting forever for each other to enter the
ready set?

Current immutable admission ranks require ordinary callees to be ready first.
That works for acyclic dependencies and self-tail loops. It cannot seed an SCC
(a mutually dependent group). `p88_digits ↔ p88_digit` is a useful tail-recursive
example once predicate evaluation is handled. Consuming
`p88_string_eq_go` is an even smaller self-tail witness: its character comparison
creates **964,973** observed returning frames in the profiled compiler request,
and its continuation immediately tail-calls the same function.

`String.append` and `String.cmp ↔ String.cmp.fin` are different. They retain
construction work after the recursive result. The observed append frames number
1,232,243; String.cmp.fin's returning recursion contributes 434,945. Neither count
licenses treating these calls as tail calls. Their reconstruction and unbounded
depth need an explicit continuation/destination contract.

**Smallest experiment.** Qualify the self-tail consuming comparator with the
already-proposed gap rule. Next admit a two-function tail SCC atomically: checked
entry signatures, typed local block parameters, ownership transfer on every
edge, and a local dispatch/branch inside one worker. Bound the initial group and
fall back for unsupported effects, indirect calls and non-tail recursive edges.
Only afterward consider replacing explicit reconstruction continuations with a
verified destination or explicit local stack representation. Do not silently
switch unbounded heap continuations to native C-stack recursion.

**Independent controls.** Use two unrelated mutual-recursion sources with
permuted arguments and different entry arities; a deep countdown must remain
stack-bounded. Include a carried String that is retained, moved and dropped on
different exits, an early-failure path and a generic call escaping the group.
A deliberately non-tail recursive product builder must refuse the tail-SCC
optimization. For any later reconstruction experiment, add long/shared/static
lists and output aliases; zero constructor allocation is not a valid expectation
when the program semantically builds a new result.

**Stop/go.** Require the admitted tail group to have no public runtime
frame/return/jump traffic per internal iteration, while preserving the expected
public entry/exit boundary. Use the two-source controls before the parser or
string workload. Go to matched compiler-request timing only when the same request
shows fewer targeted dispatches/frames with unchanged semantic outputs. If the
first SCC is still blocked by nested argument evaluation, keep that failure and
solve the earlier region boundary; adding admission rounds is not a solution.

## Shared evaluation and resource rules

Freeze each hypothesis, source/ABI boundary, expected outputs and benchmark set
before candidate execution. Use source/API checks, tiny native controls and
cached runtime/object construction before a full compiler image. Root retains
the single target/timing lane; offline agents can prepare disjoint controls and
review the ownership or signature contract.

For each experiment, publish three separate verdicts: semantic qualification,
the predicted structural/counter change, and uninstrumented performance. Run the
existing paired three-round short screen once the first two pass, using its
unchanged commands and counts. Require consistent paired benefit beyond the
baseline repeat variation; preserve regressions and unchanged-code controls.
If the required counter category is unchanged, another broad benchmark is not
the next step. Broaden to the original 45 only for an integrated candidate with a
credible general effect, keeping the 44-point and family weighting explicit.

The priority order is early fact reuse, flat cross-call products, then recursive
groups. It follows the evidence and dependency cost: preserve facts first, remove
whole temporary representations next, and handle recursive control flow under an
explicit contract. None of these experiments currently establishes a speedup
bound or a path to parity by itself.
