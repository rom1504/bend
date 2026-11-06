# Phase173: owned state machines fall between direct and continuation admission

Audit of frozen `selfhost/build/phase173/store-native-candidate-source02/compiler.bend`
and `store-native-candidate02/program.ssa` (QBE SHA256
`c972155b36f743945b55b36fef95e1343f56672447587a780da5045cdc449cdd`). No target was
executed by this audit. Parent measurements subsequently found exact outputs but
a 2.003× slower complete native store workload: 0.078725→0.157692s median.

## Concrete obstruction

The [code census](store-code-shape.json) shows direct node/edge accessors using
`p113_rt_array_pair`, while import/export/reference/compaction state-machine
entries retain generic scheduler segments. This is not evidence of slow native
array addressing. It is evidence that complete computations are not selected
for the direct execution model.

The existing `p126sc_candidates` in
[product-composition.bend](../../selfhost/src/back/qbe/product-composition.bend)
is **a two-function tail-cycle fuser**, not general strongly connected component
(SCC) lowering. `p126sc_pair_safe` requires reciprocal calls, `p126sc_shape`
requires one result and at most eight parameters. No pair can represent these
cycles in the frozen source:

| Computation | Source SCC members | Largest source arity | Direct reciprocal pairs |
| --- | ---: | ---: | ---: |
| import | 9 | 8 | 0 |
| export | 11 | 11 | 0 |
| push child edges | 3 | 5 | 0 |
| ordered references | 6 | 6 | 0 |
| compact | 36 | 16 | 0 |

These counts came from a bounded read-only lexical call-graph extraction of the
frozen definitions, followed by ordinary SCC discovery. They are source-level
evidence, not a dump of final lowered candidates. Lowered flat signatures can
increase arity and change targets; candidate errors still need to be reported
when the experiment runs.

For example the smallest cycle is:

```text
p173s_push_edges -> p173branch_13 -> p173take_12 -> p173s_push_edges
```

`p173branch_13` first calls the already-direct edge getter, then tail-transfers to
`p173take_12`, which unpacks the result and tail-transfers back. There is no
semantic need for a generic scheduler between these three states. The current
pair fuser cannot find a reciprocal pair. The larger loops similarly consist
of ordinary branch/match/take helpers plus explicit work-stack values.

After pair fusion, `p113d_passes` in
[direct-lower.bend](../../selfhost/src/back/qbe/direct-lower.bend) admits a
candidate only when all its callees are already ready. It stops when a pass adds
nothing. This deliberately preserves acyclic machine calls and stack safety,
but leaves an uncollapsed multi-member cycle permanently waiting.

There is a second independent barrier: all these `Store & X` loops naturally
have **two-result flat workers**. `p126sc_shape` excludes those workers even for
a two-member cycle. Their boxed variants may call a flat worker and then box
the result, so their lowered cycle edges need not be syntactically tail. Merely
raising the pair count is insufficient; a component must agree on its complete
result vector and retain that vector through its tail edges.

The fallback local-continuation machinery in
[local-continuations.bend](../../selfhost/src/back/qbe/local-continuations.bend)
recognizes recursion to one owner plus already-ready outside helpers. It does
not establish mutual readiness for an arbitrary source SCC. Its arity/capture
and frame-table bounds are additional limits. Raising those limits alone does
not fix the circular admission dependency.

## Smallest general fix being prototyped

Extend the existing candidate transformation, keeping `P113DStmt`, runtime
ownership operations and the independent final verifier unchanged:

1. Discover complete SCCs among unique, error-free direct candidates.
2. Admit a bounded component only if all members have the same result width
   (1–8), each internal call is immediately followed by a return of exactly its
   destination vector, and argument counts agree. Preserve the ordinary owned
   values; this is not a borrowing or alias relaxation.
3. Emit one private worker with a scalar state tag, padded argument lanes and
   renamed member bodies. Every internal transfer becomes `P113DAgain`, whose
   existing emitter snapshots arguments before assignment and jumps locally.
4. Retain wrappers with the original signatures. External calls retain their
   original order and must become ready through the existing dependency closure.
5. Run the existing final direct verifier. Do **not** mark cyclic machine calls
   ready, skip a rejected body, or add a recursive native call to bypass it.

The prototype bounds are 64 members and 31 input lanes per member, plus one
private dispatch lane (32 total). Oversized, incompatible, ambiguous or non-tail components
fall back unchanged. Scratch and code-size budgets additionally bound the
combined worker; original ownership calls and allocation effects remain in
their original order. This removes scheduler transitions, not the store's
owned node accesses or work-stack allocations.

The first decisive test is the three-state edge-push loop and an unrelated
three-state owned accumulator, then the complete real store computation. Check
actual worker emission and machine calls before interpreting timing. Controls
must reject non-tail cycles, mismatched result vectors, duplicate identities,
missing targets and generated-name collisions. Permuted argument transfers,
branch exits, owned accumulators and depths exceeding normal native-stack
capacity test the intended stack-safe semantics.

No speedup is predicted from source SCC counts. A general loop can still pay
for too much dispatch, padded lanes, work-stack construction or owned payload
traffic. If scheduler removal gives little benefit, that is the next useful
falsification—not a reason to force unsafe readiness or disguise the same
algorithm in a foreign runtime.

## Prototype files and implementation limits

* [scc.bend](../../selfhost/tests/phase173/scc.bend): one explicit-stack Tarjan
  traversal, indexed candidate facts, bounded fusion and ABI-preserving wrappers.
* [scc-prelude.bend](../../selfhost/tests/phase173/scc-prelude.bend): the entry
  law visible before the canonical replacement point; internal laws are hoisted
  inside the module for the pinned sequential loader.
* [scc-overlay.bend](../../selfhost/tests/phase173/scc-overlay.bend): the private
  replacement for `p126sc_candidates`; no production file is edited.
* [scc-controls.bend](../../selfhost/tests/phase173/scc-controls.bend): positive
  multi-result cycles plus admission rejection and independent-verifier controls.
* [scc-owned-workload.bend](../../selfhost/tests/phase173/scc-owned-workload.bend):
  an unrelated three-state owned-list accumulator, expected output 200000.
* [scc-owned-swap.bend](../../selfhost/tests/phase173/scc-owned-swap.bend): two
  owned lists rotate across 200000 transitions, expected weighted sum 400098.

Discovery traverses the graph induced by eligible candidates, not every source
function. A cycle through an ineligible/missing candidate remains an external
dependency and cannot pass the unchanged topological dependency closure/final
verifier. Actual structured body calls are recomputed once; auxiliary candidate
call metadata is not trusted to omit edges. The prototype's fresh `$p173scc.*`
namespace must be absent from previously admitted seed workers. Candidate names
are collision-checked, but eventual general integration must also pass the full
occupied seed identity set into name allocation.

Independent audit caught and corrected a budget mistake before execution:
`p113i_add` saturates at 4096, so it cannot enforce larger limits. Body aggregation
now uses an 8193 rejection sentinel (and conservatively rejects a saturated
single-body count); stack aggregation uses the existing 65536-saturating stack
counter against a 16384 limit. Controls exercise both aggregate overruns.

The size budget counts source bodies before dispatcher/binding overhead; it is
not a claim that emitted code has at most 8192 instructions. The scratch budget
counts explicit allocas and renamed scratch regions; machine spills and the
ordinary emitter frame are additional. These limits bound extra construction,
not total process RSS.

The audit also found that fresh `p173sc_*_local_scratch` names fail the existing
array-pair import authentication. The implementation now uses a unique fixed
two-digit base16 nesting of the existing authenticated `p113i_0..15` names. No
verifier rule is relaxed. Controls check the renamed array imports through both
the legacy verifier and selected compact final verifier, plus tag63 and distinct
prefixes. These are structural tests; actual runtime ownership is checked by the
independent source workloads and complete store oracle in the parent campaign.

The first implementation uses a tag dispatch chain rather than direct member
labels. It may replace scheduler overhead with excessive local dispatch for
large components. It also preserves every owned payload and work-stack
allocation. These are explicit limits to evaluate after correctness, not claims
of an already demonstrated speedup. Source acquisition and target validation
are performed by the parent campaign, not this audit.

## First qualification evidence

The parent's `scc-api03` acquisition passes source checking. All 18 finite
controls pass in `selfhost/build/phase173/scc-finite02/report.json`, including
both unchanged direct verifiers for the admitted multi-result and array-import
workers. The finite-control process took 1.261s; this is a validation cost, not
a compiler or generated-program speed claim. `scc-owned-emission01` also passes
the complete source-request lowering/verification and produces 60270 QBE bytes.
Native execution and the real store workload remain separate parent gates.

Preserved failed attempts include a malformed ring fixture, a missing explicit
type on a test constructor binding, and the initial finite harness rejecting
the lowercase `:pass` row format. These were fixture/harness failures, not
evidence that a rejected semantic candidate was made legal.
