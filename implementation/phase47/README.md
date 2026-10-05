# Phase47: private array representation and ordered writes

Array06 is selected after passing its checked build, focused strict gate, four
independent Array control groups, eight maintained semantic suites and the full
45-point comparison. Generated execution improves from 3.0851× to 2.9194× pinned
TypeScript time with equal-point weighting: a 1.0568× speedup. Array06 is installed:
release verification and all 42 ordinary/relocated CLI checks pass. The published
portable bundles also pass their separate 27-sample replay screen.
[Design](../../design/phase47/research-guided-optimization.md),
[compiler mechanism](../../docs/self_hosted/private-array-regions.md),
[experiment ledger](../../experiments/ledger.md).

## What changed

A closed, typed Array<U32> region can carry its backing array directly through
private calls. The public boundary remains scalar. The compiler proves all
arrays originate inside the region, rejects escape and unknown effects, and
checks the host assumptions before entry. It retains the original wrapper,
helpers and fallback for refusals.

Within that context, array writes in existing statement destinations become
ordered statements. The compiler evaluates live arguments once in the original
order, retains Number conversions and length reads, performs the store, and
passes on the same array. It also normalizes equivalent checked source calls
into private native/helper calls. Only a Mat helper's own self call remains in
its original form for the existing Nat-loop emitter. A raw array must never
reach an ordinary public helper call.

The same contract now composes with the existing scalar-tree emitter. Both
checked arms and the complete helper graph must satisfy the array audit. The
compiler reuses the existing frame stack, child order and depth bound; it keeps
the original zero branch and complete fallback. Independent counters verify
that the actual private tree path enters the raw-array closure.

A separate guard refinement proves the absence of floating-point inputs,
results and executable helper work before using the smaller integer hook set.
It retains the exact Math.floor check needed by U32 division. Unused and aliased
F32 inputs still select the full guard. No mutable host identity is cached across
public calls.

This is a reusable type/ownership/effect contract, with no benchmark-name or
source-name selection. The [module](../../selfhost/src/back/js/array-view.bend)
and its existing-emitter hooks add 247 physical Bend lines overall.
The [safety plan](array-safety-plan.md), [independent review](array-safety-review.md),
[ordered-write explanation](array-write-statements.md) and
[coverage diagnosis](array-coverage.md) describe the exact constraints.

## Why this change

The first saved-output experiment used the Phase46 Bend batch context. Five
rotated fresh-process rounds, each with 8192 warmups and 8192 measured calls,
produced these medians:

| Saved-output variant | Batch ms | Original / variant |
| --- | ---: | ---: |
| Original |680|1.000|
| Write-helper expansion only |683|0.996|
| Backing view reuse |186|3.656|
| Also reuse length |186|3.656|

All 20 measured value/digest checks and four short controls passed. These were
diagnostic derivatives, not production-safe compiler outputs. The absent
length-cache gain did not justify another invariant or invalidation rule.
[First-screen evidence](evidence/first-screen.json).

The first source implementation established private raw storage but improved
the maintained public-call fold by only about 6%. A second ablation separated
write shape, pointer identity and guard cost in that actual public call context:

| Public-call variant | Median microseconds/call |
| --- | ---: |
| Released worker23 |90.854|
| Raw-array candidate |84.207|
| Raw arrays plus ordered write statements |63.809|
| Invariant pointer alias only |86.680|
| Ordered writes plus invariant pointer alias |63.986|
| Unsafe guard bypass, diagnostic only |73.694|

Each row has three rotated fresh-process samples and 8192 warmups/calls. The
compiler implements ordered writes, keeps the guard, and adds no invariant
pointer cache. The batch and public-call gains describe different contexts and
must not be multiplied. [Public screen](evidence/array-public-screen.json).

Separate V8 traces show both raw loops reached TurboFan before measurement and
neither deoptimized during it. CPU samples show a large fall in sampled GC time
with ordered writes, while guard samples remain similar. This supports an
allocation-related contribution; it does not prove a particular closure was
eliminated or establish allocation counts. [Trace/profile analysis](v8-analysis.md).

The array02 source implementation reproduced a 1.434× fold gain and approximate
TypeScript parity in its short canary screen. Array04 additionally admitted the
existing local edit-distance region and measured 1.830× there in its short
screen. These were preliminary case results; the final corpus section below
reports the complete maintained-corpus outcome.

## Research used, including proposals we did not keep

The [pinned compiler surveys](../../research/compilers_architecture_and_techniques/README.md)
informed specific experiments:

| Research lesson | Applied decision |
| --- | --- |
| Go: preserve known calls and use escape/effect proofs | Admit raw storage only inside a completely known private graph; normalize equivalent calls consistently |
| Rust/LLVM: expose work, then eliminate temporary representations | Use explicit ordered stores at existing statement destinations; test helper expansion before retaining a broad inliner |
| Lean: keep local calls and evaluation order explicit | Preserve self-tail recognition, original demand and original dependency guards |
| Zig: staged immutable facts and explicit lifetime | Carry a private representation fact in the checked planner context; measure query reuse including lookup/lifetime cost |
| V8: source-level work may already be optimized away | Use saved-output ablations and separate traces/profiles; discard unsupported pointer/length hypotheses |
| Upstream Bend: saturated direct calls and scalar transport | Keep private calls direct while preserving the public host ABI and exact fallback |

The independent 405-line worker cleanup passed its controls but removed small
calls without removing the intended aggregate shells on actual Map/record
outputs. Its short gains were only4.0% and 1.9%, with timing drift. Four other
modules were byte-identical. It is **deferred**, removed from the maintained
compiler, and preserved as a [patch](../../experiments/phase47/patches/worker-cleanup.patch).
[Outcome](worker-outcome.md), [review](worker-review.md).

The separate proof-query census counted 21,664 queries and 11,005 repeated exact
book/type identities. A bounded saved-JS WeakMap counterfactual reduced one
lexer request median 6.64%, with identical output bytes. A 51% query repeat rate
is not a 51% request speedup. No production cache is shipped, and this diagnostic
gain is not combined with the array result. [Memo outcome](compiler-memo-outcome.md).

## Correctness and failed attempts

Final array06 passed:

- The checked B1 build and focused strict gate, with zero exact differences.
- Four-cell independent controls: 24 scalar oracles and 39 public/host boundaries.
- Renamed two/four-array controls: 77 scalar results, 56 public-state/alias cases
  and seven ordering/demand boundaries, with separate activation/refusal checks.
- Binary-tree controls: 159 scalar oracles, 11 boundaries and exact private-entry
  and leaf-call counters over zero and positive depths.
- Integer-guard controls: 153 scalar oracles and 46 boundary comparisons, with
  structural guard-mode and runtime entry witnesses for division and unused F32.
- Eight maintained suites: IR, backend, global initializers, choice, arm,
  primitive guards, provenance and foreign calls. These include 37 IR checks,
  1,129 primitive guards, 25 related observations and 10 provenance constructors.
- All five maintained canaries. Timing interpretation is separate from semantic
  success: the initial generic-row slowdown needed confirmation.
- Installation verification and all 42 ordinary/relocated CLI checks, bound to
  the same checked attempt, API, runtime and source checkout.
- All 45 portable-bundle reader checks and a separate 27-sample replay screen,
  completed in 9.370488 seconds with the nominal 20s profile.

The independent groups overlap; do not add them into a unique conformance-test
count. This phase does not renew the full frontend inventory, GPU execution,
all native backend semantics, or a new self-emitted fixed point. The Phase45
main/broader frontend and 81-backend inventories remain historical evidence.
The Phase46 native IO.args mismatch remains unresolved.
[Control plan](control-plan.md), [qualification plan](qualification-plan.md).
The [array04 identity receipt](evidence/provisional-array04.json) belongs to that
earlier candidate and is retained as historical evidence.

Preserved failed or incomplete hypotheses include the first array producer's
Number-token assertion, the worker's computed-match parser error, an affine
field error in the first independent worker fixture, and the successive array
admission refusals. Array01 missed source-form native calls; array03 normalized
those but still refused a known Ann-bodied helper. Array04 handles both without
letting private storage cross the public ABI. Earlier attempts receive only
their own recorded observations, not later qualification credit.

The first array04 generic-row screen showed a 14.7% slower median. Five rounds
with longer warmup reduced this to 1.56%, with overlapping ranges. Its row function
and all 16 reachable definitions are byte-identical; the added private pair
closure is unreachable from that row. The addition changes initialization and
module layout, but no specific JIT/GC cause was established. Both observations
remain in the [analysis](v8-analysis.md); the smaller difference is not proof
that every variation is noise.

## Cost, complexity and final execution

The final comparison contains 45 points from 23 sources and 669 fresh role
samples. Every oracle passes. [Full results](results.md) preserve all case
medians, ranges, identities and regressions.

| Weighting | Worker23 / TypeScript | Array06 / TypeScript | Worker23 / array06 |
| --- | ---: | ---: | ---: |
| Equal point | 3.0851× | 2.9194× | 1.0568× |
| Equal source | 4.1699× | 3.9958× | 1.0436× |
| Equal family | 4.7316× | 4.4996× | 1.0516× |

Positive-depth edit distance improves 1.850–1.863× to about 1.14× TypeScript;
local pair improves 1.751× to 1.219× TypeScript. Fold at 4096 improves 1.481×;
at 8192 it improves 1.583× to 0.956× TypeScript. These are specific measured
points, not a universal or typical-program speed estimate.

The 128-step fold is a material tradeoff: 7.603 → 14.671 microseconds, **1.930×
slower**. Fixed host admission contributes, but the measured guard ablations
explain only part of this regression. The default tree-bitonic case and its
larger variation are also 4.17% and 5.36% slower, respectively, despite an
identical program body after removing the unused runtime addition; their JIT
cause remains unresolved. Across the corpus, 16 medians improve and 29 regress. Those sign
counts are not significance tests, and the regressions are not all labeled noise.
We retain the general representation improvement for its larger-workload gains
and improved aggregate, with these limitations explicit. This corpus informed
optimization and is not an untouched holdout.

[Array04 compiler-request cost](compiler-cost.md) is measured independently from
program execution. Across 27 exact-output requests, medians increase 2.97% for fold,
2.74% for local edit distance, and 1.68% for lexer. Requests include normal cached
Base validation and compilation; the resource runner's verification/process
wall is reported separately. This is a small compilation cost, not a compiler
speedup.

The [final array06 compiler-cost screen](compiler-cost-final.md) also passes all
27 requests. Relative to its freshly paired worker23, medians increase 1.21% for
fold, 3.75% for edit distance and 0.87% for lexer. Candidate request medians are
1.645, 2.342 and 4.433 seconds respectively. The changed third input covers the
new tree path; the two campaigns are not pooled. Guarded verification/process
overhead lies outside the request timer and is recorded separately.

The complete array04 reference run passed all 45 points and 669 samples.
The equal-point geometric mean is 3.00678× TypeScript versus the freshly paired
worker23's 3.08744×: a 1.02683× improvement. Equal-source means are 4.07916× and
4.16198× respectively. This is a modest aggregate result, despite larger gains
on the targeted paths. [Exact reference results](evidence/corpus-array04.json).

The run exposed two composition/cost issues. Positive-depth edit distance still
used a separate handle-based private tree helper and showed no improvement; an
untimed four-case counter experiment confirms that it bypasses the public raw
entry. A 32-line shared tree adapter now passes the checked build, the previous
controls, eight semantic suites, and 159 independent recursive scalar oracles
plus 11 boundaries. The subsequent tree05 screen and final array06 full comparison
measure that composed path, as reported above and below. Separately, the
128-step fold regresses from 7.705 to 16.362 microseconds per call, while the
8192-step variation improves from 173.065 to 110.662 microseconds. The guard-cost
ablation below separates fixed entry work; neither observation is hidden by the aggregate.

The subsequent two-point tree05 screen measured 1.8404× and 1.8531× gains over
fresh worker23, reaching 1.1435× and 1.1354× TypeScript time. Its independently
measured baseline is worker23, not array04. This supports the diagnosis but is
not a full-corpus comparison of the final array06.

The [guard ablation](array-guard-cost.md) found approximately two microseconds of
removable checks per call. It cannot eliminate the short-fold regression; the
unsafe guard-bypass experiment is not production code.

[Final source/output accounting](accounting.md) records 23,254 physical / 19,175
code Bend lines, 2,622 definitions, 87 types and 86 modules. Source grows 1.07%
over worker23. The 23 generated libraries grow 100,476 bytes (2.58%), including
the common runtime addition; 20 retain identical bodies after that addition is
removed. This is an explicit speed/size tradeoff, not a line-count reduction.

Installation and portable benchmark publication are complete. The
[installed-release receipt](../../selfhost/tools/performance/phase47/evidence/installed-release.json)
binds the checked attempt, live source/API/runtime, eight maintained suites,
42 CLI checks, protected 103 files and portable publication. Its version-two
producer corrects a data-only relative-path assertion; no install or CLI run was
repeated for that correction. The
[selected qualification](../../selfhost/tools/performance/phase47/evidence/selected-qualification.json)
records the final gate identities. The maintained comparison uses exact worker23
and pinned TypeScript; it does not pool intermediate attempts.
See [remaining work](remaining-work.md) for the next unvalidated opportunities.

Final append-only outcomes are recorded for the
[backing-view hypothesis](../../experiments/phase47/P47-001-array-view.md),
[proof-query census](../../experiments/phase47/P47-003-compiler-proof-census.md),
[private representation](../../experiments/phase47/P47-004-private-array-layout.md),
[tree composition](../../experiments/phase47/P47-005-tree-array-composition.md)
and [integer guard](../../experiments/phase47/P47-006-integer-array-guard.md).
Their earlier checkpoint statements retain their original scope.

## Execution and preservation

Root owns all target jobs. Agents work independently on source lowering, IR,
controls, safety review, compiler-cost attribution, accounting and publication.
Target jobs run serially on CPU3 with a 1 GiB Node heap, 2 GiB process-tree RSS limit
and 4 GiB available-memory floor. The polling guard is not a hard cgroup limit.
Short ablations and canaries precede broad runs. The first full run exposed the
missed private tree path; future fast gates should witness the enclosing private
entry before paying for a full corpus. A second full run measures final array06.
No OOM or session restart occurred in the completed jobs.

The [time-use audit](time-use.md) covers 152.10 minutes through raw closure.
Recorded supervisor intervals cover 68.64 minutes (45.1%), including 41.44 minutes
of performance work and 16.67 minutes of builds. The remaining 83.46 minutes
include analysis, documentation, handoffs and any unrecorded or idle intervals;
they are not a measurement of active reasoning or CPU utilization.

All raw writers closed at 2026-10-05 01:32:22 UTC. The
[verified evidence archive](../../selfhost/tools/performance/phase47/evidence/README.md)
retains all 16,355 files, including failures, in two parts totaling 51,899,688
compressed bytes. Every member and the original inventory were rehashed; the
parts' concatenation matches the complete gzip stream. The
[evidence index](../../selfhost/tools/performance/phase47/evidence/index.json)
binds publication, selected qualification and prerequisites. All 103 unrelated
starting files and closed Phase45/46 evidence are preserved. Authorized commits
have been pushed during the work. No PR comment has been posted.
