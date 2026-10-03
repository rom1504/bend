# Compiler analysis experiment status

Static inspection found four planner entry owners: named saturated calls,
worker declarations, residual-loop selection and nested wrapper selection.
Within a successful plan, admission and selection repeat the same bounded
self-reference walk. Wrapper selection additionally reruns complete typed
callee proofs. This is a source cost map, not measured attribution of Phase41's
9.46% increase.

The isolated [candidate patch](../../selfhost/tools/performance/phase42/facts/candidate01/candidate.patch)
threads the root self-reference count through the existing admission and
selection helpers. It changes only `tree.bend` when applied. Source shrinks one
physical line; definitions, types and modules stay constant. The original
production source is untouched. The [identity receipt](../../selfhost/tools/performance/phase42/facts/candidate01/identity.json)
binds both source variants. Expected output is byte-identical for every request,
including conservative refusals. Checked correctness and compiler speed are
not yet established.

Preparation and patch construction were executed with Python only. No compiler
or target workload was executed by this owner. The fresh normal tree profiling
command is [command.sh](../../selfhost/tools/performance/phase42/facts/profile-plan01/command.sh).
It invokes the unchanged Phase30 normal-request worker against the retained
Phase41 checked01 request, retaining all independent expected-emission hashes.
Output paths are fresh. Root owns its resource-supervised execution; preserve
any incomplete run and use a new preparation directory for a retry.

After execution, summarize with:

```sh
python3 selfhost/tools/performance/phase42/facts/profile-summary.py \
  selfhost/tools/performance/phase42/facts/profile-plan01/compiler.cpuprofile \
  selfhost/tools/performance/phase42/facts/profile-plan01/summary.json
```

The CPU profile includes preflight, import and postflight. `requestMs` retains
the maintained worker's normal checked request boundary. Inclusive sample
ancestry overlaps and native trampolines can obscure ancestors; sampled shares
are neither exact invocation counts nor a causal saved-time estimate. A normal
profiled request is diagnostic evidence, not an unprofiled timing comparison.

Before promotion, root must apply the isolated patch, make a new checked B1,
and compare exact ordinary tree, wrappers, scalar/Nat/List exclusions, deep and
mutual-recursion controls. Cost measurements must compare actual checked APIs,
fresh original sources and original complete expected bytes; use the existing
cost worker and alternating serial rotations. This candidate offers a small
deletion with no new cache/IR. Request-wide reuse of complete plans remains a
separate implementation, with the invalid superset shortcut explicitly rejected
in the [design](../../design/phase42/facts.md).

## Fresh compiler profile: completed by root

Root executed [compiler-profile01](../../selfhost/build/phase42/compiler-profile01/result.json)
successfully: independent expected emission SHA256
`64bfc698048c2ebf92c123111a5ce3fd8ccdb47b2fd8a7488243adbd1c2f6e9d`,
109,624 bytes. Worker request time is 2,583.271ms, preflight 1,908.192ms,
host import 4.089ms and total worker 7,228.601ms. Peak process RSS is 542,132KiB.
This profiled diagnostic is not a baseline/candidate timing comparison.

The [initial named-frame summary](../../selfhost/tools/performance/phase42/facts/compiler-profile01-summary.json)
shows `j_component_plan=0`. That is an attribution limitation: generated
`kc` closures carry almost all planner work. The successor
[generated owner analysis](../../selfhost/tools/performance/phase42/facts/compiler-profile01-owners02.json)
maps anonymous API source lines to their enclosing emitted Bend definitions,
then counts each owner once per sample stack. It binds the root CPU capture and
actual equality API SHA256 `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`.
Root raw files were read without mutation.

| Visible owner / family | Inclusive sampled time | Whole capture |
| --- | ---: | ---: |
| `j_component_plan` | 760.218ms | 10.44% |
| `j_component_named` | 632.803ms | 8.69% |
| `j_component_wrapper_calls` | 103.640ms | 1.42% |
| `j_pure_graph` | 753.539ms | 10.35% |
| `j_pure_type_check` | 504.844ms | 6.93% |
| Component-or-purity union | 939.765ms / 767 samples | 12.90% |
| `j_component_refs` | 3.300ms | 0.045% |

Rows overlap and cannot be added. The union avoids overlap between those two
families. Its sampled CPU time is roughly 36% of the reported request wall time;
the denominator mixes sampled CPU and wall time, so this is diagnostic scale,
not an exact request CPU share. It does not count duplicate requests or establish
how much of the time reuse can save. Static canonical callsites plus the named
owner samples justify testing complete-plan reuse. The tiny self-reference patch
is held: its entire visible owner family is only 3.3ms in this capture.

Whole-worker verification dominates separately: `verifyAttempt` inclusive
3,022.339ms, `transformEquality` inclusive 1,227.507ms and crypto `update` self
2,424.277ms. Transformation overlaps verification. `inspectWithMemo` visible
ancestry is 2,462.014ms, consistent with most of the normal request being visible
there. These verification/transformation costs occur while validating the
existing checked image; this run does not build/bootstrap a new compiler.
No removal of provenance or verification is proposed.

## Meaningful derivative: isolated request facts

Root requested an exact request-local component/direct-plan derivative. The
[candidate patch](../../selfhost/tools/performance/phase42/facts/request-candidate01/candidate.patch)
is generated reproducibly by
[request-facts.py](../../selfhost/tools/performance/phase42/facts/request-facts.py).
It captures the currently applied calls/context source in five backend files.
It adds 116 physical lines / 15 definitions, no types/modules/runtime, and leaves
the small self-reference candidate unapplied. Python parsing and whitespace
checks pass; checked syntax, correctness, memory and cost remain pending.

The original `j_component_plan(book,d)` and `j_direct_plan(book,d)` logical
planners stay intact. New cached entry points accept a name and obtain canonical
original `lookup(book,name)` definitions internally. Only canonical callsites
are redirected. No cache may return a plan for a rewritten same-name helper.
Exact ordered graph definitions, remaining fuel and validity are preserved,
including nonempty failed graph results. Context-subset coverage, argument
saturation, runtime proof guards and emitted worker bodies remain uncached.

The existing BookCache's first child remains its original source index. A
dedicated `$js.plans` / `JSPlanContext` second child contains two indexes of
`JSPlanFact` KDefs. Each fact stores the exact original JPure as ctors=defs,
arity=fuel and native=valid. This is private metadata over existing KDefs, not a
new source/optimizer AST. It does introduce a reviewed private encoding; growth
and retained-memory costs must be measured before any simplification claim.

Preparation strips prior fact payloads, makes an immutable original source
context, and invokes logical plans without a fact payload. There is no recursive
cache construction. Component plans are computed once at top level for canonical
selected names whose ordinary emitter already asks for a declaration plan.
Nested wrapper proof walks within an individual logical plan remain intact.
Direct plans are computed for distinct saturated nonprimitive source call targets
found in selected emitted bodies. The discovery scan has an 8,192-node limit per
body; exhaustion only reduces reuse and leaves every missing query on its normal
planner path. This syntax scan can conservatively collect a target that later
emission refuses for another reason; its extra preparation cost is explicit.

Facts exist only in the new emission request context. Existing `book_put`
updates reconstruct the BookCache with the source index alone and therefore
discard facts. Fresh entry preparation also discards any prior fact payload.
Source indexes, maximum binder ID and original KDefs are unchanged. Cache lookup
requires dedicated BookCache/context/fact kinds. Cache misses use the unchanged
logical planner with original lookup input, preserving all refusal and fuel
limits. No earlier runtime guard or wrapper graph can establish a callee fact.

The derivative's expected emission is byte-identical to the current calls/context
candidate, rather than Phase41's different generated output. Root must compare
actual checked module bytes and complete owner results, separately from measuring
the calls/context runtime improvement. Preserve the inherited recursive-expansion
budget refusal once the calls owner applies that successor; the cache does not
change planner bodies and must store its negative result as-is. Compare normal
fresh library request time/RSS for calls/context alone versus calls/context plus
facts. Record priming separately, require all exact controls and keep failures.

The focused [facts controls](../../selfhost/tools/performance/phase42/facts/controls.mjs)
are ready for root's bounded execution against that actual checked successor:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase42/facts/controls.mjs CONFIG NEW_OUT
```

These diagnostic exports preserve the checked API as an unchanged prefix in a
new local module, with separate identities. Controls check original source
index/list/binder-bound identity, hidden request metadata, admitted direct
ordered-graph/fuel equality, refused component equality, arbitrary same-name
logical input, `book_put` invalidation, ordinary misses, fresh request scope,
discovery exhaustion and nonempty failed graph retention. `node --check` passes;
the controls have not yet executed and do not substitute for ordinary checked
module emission or existing runtime proof/host owners. Apply the isolated patch
instead of copying its source snapshots over a later direct-budget successor.

## First checked-build refusal and correction

Root's Phase42 checked04 bootstrap refused the new `j_plan_prepare` local let
`+source = Con{cache, rest}`: constructor inference requires an annotated term.
The original request-candidate01 source/patch remain retained. The isolated
[correction patch](../../selfhost/tools/performance/phase42/facts/request-candidate01-correction.patch)
changes only that let to
`+source = {Con{cache, rest} : List<&2,KDef>}`. The generator now emits the
annotation. Other new local lets call annotated functions or the established
`index_first`; no other bare constructor inference let was found. Root owns
applying the correction and acquiring checked05. No inference failure is
treated as a correctness or timing result.

The separate [Map/BST roadmap screen](../../selfhost/tools/performance/phase42/facts/map-bst/README.md)
prepares one guarded saved-JS Map String-comparison edge ablation and full-content
controls. It performs no target/compiler execution, does not change production
String admission, and reuses the existing executed String-host counterexample.
It is independent of the pending cache correction/build.

The [BST read-only feasibility screen](../../selfhost/tools/performance/phase42/facts/map-bst/bst-closed-data-feasibility.md)
and `bst-plan-probe.mjs` now separate native Sigma/List-frame type refusal from
component prefix/direct-cycle constraints. No mutual helper cycle exists in the
benchmark. Down/build and potentially up can reuse existing single-self workers
only after a scoped closed-data proof, exact specialized type equality and
native match checks. The dependent sequential inorder traversal remains outside
that worker shape. Separate nested-function, vector and dependent-Sigma controls
are prepared as original-predicate observations; they are not evidence for an
unimplemented extension. Probe syntax passes; root execution remains pending.

Root's BST probe02 completed on checked07 with status ok/checked true. The
read-only [summary](../../selfhost/tools/performance/phase42/facts/map-bst/bst-probe02-summary.json)
records source/report/API identities and exact original predicate observations.
Inorder's pure graph is valid with fuel32748, but prefix/component admission
fails. Whole bench proof fails, so the held sequential proposal cannot activate
in ordinary BST bench alone. Closed BST/BFrame pass; Sigma/List-frame and all
nested function/vector/dependent-Sigma controls refuse. Distinct Sigma
specializations currently compare equal by name, requiring exact equality before
new admission. Build additionally refuses its computed scalar alias prefix.
The [matched-set stretch design](../../selfhost/tools/performance/phase42/facts/map-bst/bst-matched-set-design.md)
scopes a stronger container proof to owned scalar roots, preserves ordinary
predicate/cache contracts, and coordinates unchanged-runtime Tuple/List emission
with frames owner. Its 320–520 LOC estimate and held sequential candidate04 are
review artifacts; source promotion awaits actual private entry and complete-value
controls. No additional compiler or target execution was performed by facts.

An [independent minimal-domain review](../../selfhost/tools/performance/phase42/facts/map-bst/bst-minimal-domain-review.md)
now supports reusing the existing scalar-root/fullgraph ownership boundary for
a globally valid strict closed Sigma/List JPure type domain. It supersedes the
initial explicit owned-mode/cache recommendation: public ownership still comes
from guarded runtime entry, not type/capture admission. Audited Nat/fold/flat
selectors retain their independent restrictions, and ordinary generic bodies
already emit guarded saturated helper callsites. The revised estimate is
250–360 LOC including native projection and sequential continuation. No concrete
ownership counterexample was found; this remains conditional design review,
requiring new-domain negatives and actual-entry complete-value evidence before
promotion. The grounded List<U32> algorithm selector stays unchanged.

Root's executed Map native-comparison ablation passed all25 independent controls
(12 Unicode full results/errors, five complete Map-content cases, three host and
five descriptor fallback cases), with277 clean entries/eight fallbacks. The
three-rotation short screen reduced Map32 median12.3191→12.2529ms and Map128
65.6190→63.6162ms, versus pinned TS0.141275/0.786770ms. This near-null0.54%/3.05%
mechanism screen does not justify native String production work. The owner
[summary](../../selfhost/tools/performance/phase42/facts/map-bst/map-native-result01.json)
hashes untouched root raw/module identities. Map String admission remains held.

The isolated [closed native proof candidate04](../../selfhost/tools/performance/phase42/facts/map-bst/closed-types-candidate04/candidate.patch)
now implements strict List/Sigma source proof and parameter-aware equality;
canonical compiler source was not edited by facts. Candidate02 was refused by
review for resetting the equality depth budget at each Sigma sibling, allowing
an exponential alias DAG. Candidate03 serializes `Maybe<remaining fuel>` through
both fields; review accepted the bounded total equality correction. Root's
actual [ABI probe04](../../selfhost/tools/performance/phase42/facts/map-bst/bst-probe04-abi-summary.json)
then showed Sigma Kind as `Typ(Min(Qua1,Qua1))`, so candidate04 adds that exact
header form alongside normalized Qua1. Both native Tuple fields are quantity1;
List uses quantity2 with quantity1 Con fields, as required. All specialized
field and complete terminal type identities are checked, and the List tail is
compared to its current specialization rather than recursively expanded.

The first ABI probe03 refused a malformed injected JS parenthesis; failed tool
bytes are retained. Successor04 uses readable locals and its actual generated
API passes syntax validation. Its consumed producer is preserved byte-exact as
`bst-plan-probe-v04.mjs`; the aggregate alias-DAG successor is a separate
`bst-plan-probe-v05.mjs`. Candidate compiler acquisition, new-domain predicate
controls and matched-set full-value/runtime execution remain root work. The
[control obligations](../../selfhost/tools/performance/phase42/facts/map-bst/closed-types-controls.json)
separate malformed-IR diagnostics from pinned-TS-valid source fixtures.

Root applied the isolated native proof/emitter/sequential candidates after an
exact-context rebase and acquired checked10. Original probe05 now admits native
Sigma/ListFrame, rejects all independent old function/vector/dependent controls,
and returns false for mismatched Sigma equality. AliasDAG20 returns None for
aggregate equality64 and false for type512. Down/up/inorder component plans pass,
and build's full pure graph passes while its computed alias prefix remains
refused. Original bench still fails its full pure graph, so emitted workers and
source compilation are not runtime activation or gain evidence.

The frozen strict `native-proof-controls-v01.mjs` asserts admission, independent
negative field/quantity/dependency/metadata/terminal cases, exact boundedness and
Boolean contracts against a verified checked attempt. Final main graph/component
flags remain observations pending actual outcomes. `bst-plan-probe-v07.mjs`
separately traces first Nat.add/bench source refusal points and original native
flags/eligibility without weakening predicates. Generated diagnostics and tools
pass syntax checks; root owns their execution. The prospective
[P42-006 experiment](../../experiments/phase42/P42-006-closed-native-data.md)
records activation falsifiers, ownership controls and compiler function-count/
fresh-request cost requirements; initial root changes remain uninstalled.
