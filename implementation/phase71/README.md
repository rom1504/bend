# Phase71: tuple transport has value; balanced parallelism already scales

This was a bounded, single-agent investigation of installed Phase70 release
`b18a183`, not another compiler implementation. One saved-C intervention reduced
Array.map time **735 → 567ms (22.86%)**, versus upstream302ms. A separate balanced
fork-join workload matched upstream at1/2/4physicalcores and achieved **3.75×**
speedup on four cores. The installed compiler and all production source remain
unchanged. [Design](../../design/phase71/bounded-native-diagnosis.md),
[machine-readable results](summary.json), [usage checkpoint](usage-summary.json).

## 1. A concrete cost: materializing products between loop iterations

The existing Array.map benchmark maps1024elements from U32 to Bool and back,
then folds a list. Both emitted private map loops allocate an array/value Tuple
at a backedge and immediately unpack it on the next iteration. Upstream passes
the two fields separately. The candidate already has a flat two-result Array.get
path; the unnecessary allocation occurs when those results become the next
loop's boxed argument. This is a missing connection between existing mechanisms.

The diagnostic patch keeps the original private entry ABI and initial tuple
unpack. Subsequent iterations carry two owned fields in local C variables;
the zero-count exit sinks those fields separately. Array accesses, scalar
operations, error checks and loop polling remain. No permission macro changes,
benchmark-answer substitution, global runtime changes or production source-name
rule are involved. It removes one heap allocation and two sealing sites from
each of two loop bodies; this is a source-site count, not an allocation profile.

| Saved binary | Three measured intervals, ms | Median | Relative to upstream |
| --- | --- | ---: | ---: |
| Installed-release-equivalent original | 738 /735 /730 | 735 | 2.434× |
| Virtual loop product prototype | 568 /567 /566 | 567 | 1.877× |
| Pinned upstream | 302 /302 /303 | 302 | 1.000× |

Nine intervals pass the independent sixteen-input oracle, warm/measured digests,
exit checks and100ms floor. Every role performs15360measured repetitions and
1920warmups; roles rotate across three rounds on CPU3. Execution clocks exclude
emission, Clang and warmup. Original C is compiler02's exact output, already
qualified byte-identical to final compiler03 B1/B2 in Phase70. Pins and the exact
patch are retained in the evidence archive.

This is a **1.296× speedup** on one workload. It removes38.8%of the excess time
above this upstream baseline, but leaves an87.7%runtime deficit. The two scalar
types exercise one algorithm family, not two independent generalization cases.
Correct outputs do not prove the transformation safe for all alias/error paths.

## 2. Parallel execution on actual physical cores

The new deterministic fixture computes a balanced1024-leaf tree. Each leaf runs
four million U32 linear-congruential steps; joins add results modulo2^32. The
Python oracle independently composes affine maps by exponentiation and sums the
leaf results. Both compilers accept the corrected source and reproduce the
oracle. Clang may optimize the arithmetic; both roles compile identical work
with the same pinned `-O3` recipe.

| Physical cores | Self-hosted C, ms | Upstream C, ms | Self-hosted/upstream |
| --- | ---: | ---: | ---: |
| 1 | 546.65 | 546.12 | 1.001× |
| 2 | 277.84 | 277.09 | 1.003× |
| 4 | 145.67 | 145.76 | 0.999× |

Four-core speedups are **3.753× self-hosted /3.747× upstream**. All18intervals
pass output, process and100ms checks. These are whole-binary process times,
including startup and the single printed checksum; unlike the Array.map clock,
they are not internal measured-loop times. Three rounds vary role/core order;
this small screen has no confidence interval or universal scaling claim.

Affinity is CPU3 for one worker,2–3for two,0–3for four. Topology confirms four
distinct physical cores; their SMT siblings4–7are excluded. There are no agents
or concurrent benchmark targets. The same2GiBtree-RSS/4GiBavailable guard applies.
The old CPU3-only rule is deliberately relaxed only for this scaling test.

**Conclusion:** the basic balanced, compute-heavy fork-join path is working and
near upstream throughput. This does not assess parallel tree construction,
collection, shared-value atomics, imbalanced work, task granularity extremes or
GPU execution. It does not establish parallel execution of the compiler itself:
our measured B1/B2 images still execute sequential JavaScript.

The first250000-step version passed all checksums but ran below100ms. All18short
observations remain unqualified calibration; workload increased16×in a fresh
source/recipe/acquisition, not by selecting favorable timings.

## 3. Transfer check and compiler-cost boundary

Read-only inspection of List pipeline, BST, expression and Tape confirms that
one rule will not explain every gap. In BST, a flat two-result `bst.down` call
is boxed into a Tuple in `p37.bst.insert`, then immediately unpacked by
`insert.fin`. That is a related **call-boundary** opportunity, but its frequency
and benefit were not measured. The corrected function inventory identifies the
69-line caller's single Tuple site; it is not itself a recursive loop. List
folding and the selected Tape observer worker have no such Tuple allocation.
Their costs need separate attribution. A preliminary scanner joined adjacent
functions incorrectly; `other-shapes-v2.json` corrects it and the first output is
retained as rejected analysis.

No second saved-C intervention was attempted: the first gave a useful signal,
and the budget checkpoint favored reporting it over starting another pass.
The next smallest falsifier is the BST boundary, not a large new compiler IR.
Only repeated benefit on independent families should justify production work.

Compiler source and installed images are unchanged, so this phase claims **no
compiler-speed improvement**. Fresh acquisition of the longer parallel fixture
recorded one B1 load/check/C-emission request at537.00ms and upstream load/check
299.56ms plus emission47.95ms. B1's Base-cache preparation76.22ms and initialization
883.52ms are separate; upstream initialization234.59ms is also separate. These
single acquisition observations are not a paired B1/B2 performance campaign.
The existing three-source ratios3.418×B1/2.165×B2 remain the qualified baseline.

Clang took5.324s for the Array.map prototype; balanced upstream/self-hosted C took
0.577s/0.678s. Those are acquisition costs, not generated-program runtime or a
controlled before/after Clang improvement. An eventual compiler implementation
must reuse existing product/type facts and receive early exact-output B1/B2
cost screens; saved-C success cannot establish its analysis overhead.

## 4. Efficiency, failures and decision

The investigation started around03:26UTC and reached its decision checkpoint
around03:38UTC, about12minutes. No subagent was used. At the checkpoint, local
telemetry records18453output tokens, including7812reasoning tokens, across one
active thread. Comparable account-limit events moved51%→52%used: **one observed
percentage point**, not an exact per-task bill. Documentation/preservation follows
this checkpoint. Historical thread totals are not attributed to this phase;
private account/thread telemetry stays local, with only the aggregate summary
published. The summary also records the later closing checkpoint; the advisory
20000-output-token threshold was exceeded during documentation/preservation,
after experimental targets had stopped. Repeated prompt input was mostly cached; token totals are not quota.

Failures were bounded and preserved: an affine fixture initially used an
unshared predecessor twice; the original emitter hid the checker error, a JSON
formatter encountered its cycle, and the diagnostic successor exposed it. The
fixture now marks that parameter shared. The initial C-body extractor also
needed correction. Neither issue required production compiler changes. Small
fixtures and reused saved binaries avoided full conformance or bootstrap reruns.

**Decision:** investigate product transport across existing private-worker
boundaries next, first with the BST saved-C falsifier. A production change is
not yet justified by evidence of broad benefit. Keep sequential native timing
and parallel scaling as separate gates, and add an allocation-heavy parallel
case before making claims about Bend's overall parallel efficiency. Do not
rewrite the scheduler or add another thousand-line recognizer on these results.

## Reproduction and preserved evidence

[Methods](../../selfhost/tools/performance/phase71/README.md) document exact inputs,
commands and failed predecessors. The compact archive beside those methods
contains generated C, binaries, patches, reports, source/recipe predecessors
and logs. It excludes private usage snapshots. Earlier baseline binaries and
compiler/toolchain dependencies remain pinned external inputs, retained by the
Phase70 capsule and repository; this is not a hermetic environment.

No PR comment was posted. Unrelated inherited changes remain untouched.
