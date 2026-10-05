# Phase47: private array representation and ordered writes

The selected-candidate decision is still pending the final representative run
and installation checks. Array04 has passed its checked build, focused strict
gate, independent Array controls and all eight maintained semantic suites.
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

This is a reusable type/ownership/effect contract, with no benchmark-name or
source-name selection. The [197-line module](../../selfhost/src/back/js/array-view.bend)
and its small existing-emitter hooks add 206 physical Bend lines overall.
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
screen. These are preliminary case results; the final corpus section below
must determine the representative outcome.

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

Array04 passed:

- The checked B1 build and focused strict gate, with zero exact differences.
- Four-cell independent controls: 24 scalar oracles and 39 public/host boundaries.
- Renamed two/four-array controls: 77 scalar results, 56 public-state/alias cases
  and seven ordering/demand boundaries, with separate activation/refusal checks.
- Eight maintained suites: IR, backend, global initializers, choice, arm,
  primitive guards, provenance and foreign calls. These include 37 IR checks,
  1,129 primitive guards, 25 related observations and 10 provenance constructors.
- All five maintained canaries. Timing interpretation is separate from semantic
  success: the initial generic-row slowdown needed confirmation.

The independent groups overlap; do not add them into a unique conformance-test
count. This phase does not renew the full frontend inventory, GPU execution,
all native backend semantics, or a new self-emitted fixed point. The Phase45
main/broader frontend and 81-backend inventories remain historical evidence.
The Phase46 native IO.args mismatch remains unresolved.
[Control plan](control-plan.md), [qualification plan](qualification-plan.md),
[provisional exact identities](evidence/provisional-array04.json).

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

[Compiler-request cost](compiler-cost.md) is measured independently from program
execution. Across 27 exact-output requests, medians increase 2.97% for fold,
2.74% for local edit distance, and 1.68% for lexer. Requests include normal cached
Base validation and compilation; the resource runner's verification/process
wall is reported separately. This is a small compilation cost, not a compiler
speedup.

Final full-corpus runtime, source/output accounting, installation and durable
publication are pending. No new aggregate ratio or release claim is made here
until those receipts complete. The maintained comparison uses 45 points over 23
sources and 669 rotated role samples against exact worker23 and pinned TypeScript.
See [remaining work](remaining-work.md) for the next unvalidated opportunities.

## Execution and preservation

Root owns all target jobs. Agents work independently on source lowering, IR,
controls, safety review, compiler-cost attribution, accounting and publication.
Target jobs run serially on CPU3 with a 1 GiB Node heap,2 GiB process-tree RSS limit
and 4 GiB available-memory floor. The polling guard is not a hard cgroup limit.
Short ablations and canaries precede the one final corpus run. No OOM or session
restart occurred in the completed jobs.

All raw attempts, including failures, remain under `selfhost/build/phase47/`.
Final writer closure and archive capture are pending. The 103 unrelated starting
files and closed Phase45/46 evidence are preserved. Authorized commits have been
pushed during the work. No PR comment has been posted.
