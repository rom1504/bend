# Phase159 — what bendc's speed actually teaches us

**A dominant allocator search hid bendc's execution advantage on our captured
compiler computation.** A private one-line search bound reduces its time from
13.836s to2.585s: **5.35× faster**, four balanced pairs, with exact output gates
and only0.23% more median peak RSS. This is a third-party runtime experiment on
one extracted workload, **not a5× improvement to our compiler**.

[Metrics](metrics.json) · [Research cost](cost.json) ·
[Design](../../design/phase159/README.md) ·
[Reproduction](../../experiments/phase159/README.md) ·
[Independent audit](../../experiments/phase159/final-audit.md) ·
[Evidence](evidence/capsule.json).

## Two separate questions, two pinned revisions

The historical bendc9c54842e compiler reproduces its2,802,777-byte C seed in
about4.5s locally, as Phase158 established. Its source, target, checking and
machine-construction boundary differ from our roughly249s full native build.
Dividing those times would be misleading.

We investigated (a) what that historical self-emission actually does, and (b)
why the newer bendc56edcc65 runtime performed poorly on Phase157's identical
captured compiler workload. These are separate executables and runtimes. The
successful allocator ablation applies to (b), not automatically to (a).

The common workload executes the same387,345-byte Bend source against the same
2,979,167-byte captured compiler book. Five real compiler owners run lowering,
scalar optimization, independent IR verification and QBE rendering. Its output
oracle is the complete173,582-byte qualified-compiler result. It excludes the
full frontend, all other owners and full machine construction.

## The causal experiment

Fresh original-GC profiles at4ms and7ms put77.77% of period-weighted samples in
`gc_refill`. Disassembly maps its hottest PCs to the loop searching candidate
bytes across the heap, including repeated loads, bit checks and wraparound.
This is reuse-search work. Previously measured collection intervals did not
capture it, so their roughly1s total did not explain the13.8s request.

The original loop can examine the whole heap. The diagnostic bounds **only the
tracing-GC private search** to64 iterations (up to512 candidate block entries).
Shared-RC behavior, block/class/ownership checks, atomic claims, collection,
and the partial-block/new-block fallback remain intact. No unseen candidates
are cleared, and the cursor is not advanced on a miss. The
[runtime audit](../../experiments/phase159/refill-audit.md) records the exact
line, control flow and resource risks.

We rebuild the same already-generated C with the same pinned Clang-O3 flags;
only the private runtime header changes. No Bend optimization, verifier or
benchmark code changes.

| Sixteen complete batches, fresh process | Original GC | Bounded search |
|---|---:|---:|
| Median wall, four balanced pairs |13.8355s|2.5852s|
| Individual times |13.8319,13.8391,13.9258,13.7680|2.5805,2.5748,2.5899,2.5906|
| Median peak RSS |1,211,954KiB|1,214,772KiB|
| Physical refill share |77.77%|7.79%|
| Accepted pooled samples |5,477|1,033|

The reference/candidate comparison removes81.31% of elapsed time. Candidate
sampling uses four8/13ms captures; zero reported loss/overruns, adequate CPU
coverage and at least500 pooled samples. The refill CPU estimate drops from
about10.7s to0.20s. The candidate now spends measurable time in actual function
application, index lookup, marking and sweeping. The timing and machine evidence
agree that the dominant search cost disappeared.

Complete oracle checks pass before and after the paired block. Each timed batch
still runs the original independent IR verifier and sinks the rendered output;
the independent full-output comparison uses `oracle1`, not an invented
`oracle16`. No finite suite proves this foreign allocator correct in general.

Memory remains a serious tradeoff: about1.16GiB, roughly15× our QBE executable's
memory on this workload. A bounded search can miss reusable blocks and increase
collection or memory demand elsewhere. No multiworker, full-compiler or broad
program qualification was performed. The successful diagnostic is retained,
not installed or presented as an upstream-ready allocator patch.

## Same-work comparison and fixed costs

Before the ablation, two fresh scaling rounds give these medians:

| Repeated owner batches | Upstream C | Our QBE | bendc GC |
|---:|---:|---:|---:|
|0: input/setup/teardown|0.270s|1.023s|0.472s|
|1|0.623s|1.286s|0.973s|
|4|1.771s|2.173s|3.388s|
|16|6.480s|6.262s|14.020s|

The new bounded-GC2.585s result is about2.4× faster than that QBE16-batch median.
These were different timing blocks; the tightly paired causal claim is the
5.35× original-GC/capped-GC comparison. The QBE two-round16-batch observations
were5.979s and6.544s; retain that variation. Phase157's earlier six-round QBE
median5.935s is also retained, not overwritten by the new two-round estimate.

Original upstream samples put43.73% in `term_drop` and11.45% in `span_fade`.
QBE spreads its cost across reclamation, constructor takes, allocation, index
hashing and register/continuation transport. Its already-qualified direct
workers help, but do not cover every complete owner computation.

The existing [machine comparison](../../experiments/phase157/code-shape.md)
provides a concrete boundary: bendc's candidate construction uses ordinary
calls and a multi-result output interface; our actual candidate owner still
uses an exported state/continuation entry followed by ten continuation entries.
Our lookup is already direct, yet its inspected body has26 call sites versus
bendc's5. These are static clues, not attribution of the entire runtime gap.

The new result **retracts a blanket reading of Phase157's GC negative**. That
negative was real for the measured original runtime, but cannot establish that
tracing/direct execution is inherently unsuitable. Conversely, the experiment
does not isolate GC from direct calls, representation, specialization and Clang
optimization. Those remain confounded in cross-backend comparisons.

## Historical self-emission is not cheap because it avoids work

The [source audit](../../experiments/phase159/bendc-pipeline.md) and private
stage diagnostic establish:

- All3,406 loaded declarations reach lowering:3,044 core and362 retained forms.
  Specialization produces3,407; fusion and raising produce3,461. Reachable
  emission happens afterward, with2,023 `Gen.def` calls. This is not lazy-only
  optimization; source declarations and emitted machine functions are not1:1.
- Counter-disabled diagnostic times include0.153s lowering,0.337s fused
  inlining/simplification,0.538s specialization, **1.632s fusion**, and0.014s
  raising. `Lo.program` is2.789s inclusive; `Gen.program`3.469s inclusive.
  These parent intervals overlap and must not be summed.
- Seven lexer calls total0.738s; final Doc flattening is0.050s. Both compilers
  already have output chunks/ropes. A generic proposal to add streaming would
  repeat existing work without identifying the remaining boundary.
- Allocation counters record **327,833,144 requests /8,067,958,712 requested
  bytes**, before size-class rounding. These are not system malloc calls,
  live memory or peak heap. Counter-enabled execution takes7.400s versus4.789s
  counter-disabled; use the counts, not instrumented timing as a speed claim.
- Both diagnostic executions reproduce the full seed exactly. The clean
  historical profile spends27.45% in String comparison,13.56% in `Opt.size`,
  and substantial time in GC. Its refill share is6.5%, quite different from
  the pathological current-runtime common workload.

Thus low allocation counts, absent optimization, lazy compilation and a novel
text rope do not explain the historical result. Cheap execution of many small
operations is a stronger hypothesis. Its precise cross-layer causes still need
controlled experiments on identical computations.

## What we should do next

| Priority | Experiment | Estimated investigation cost | Gain evidence / decision |
|---|---|---:|---|
|1|Use bounded-GC as a research comparator on two unrelated captured compiler computations, preserving complete oracles and memory accounting.|30–60min if existing products suffice;1–2h if new machine builds are needed.|Current5.35× gain is demonstrated on one workload only. Test whether the advantage transfers before considering any runtime migration.|
|2|On the existing five-owner fixture, preserve a complete borrowed-reader/direct-result region across candidate construction and its immediate consumer.|1–3h prototype, after a30min source/machine admission audit.|Target1.5–2× for that region as an experimental acceptance goal, not a forecast. Remove ownership/continuation work together; include unchanged verifier, input setup and teardown. Require an unrelated owner before production integration.|
|3|Separate captured-input reconstruction from optimizer execution using a checked prepared request, and measure both boundaries.|30–60min bounded experiment.|Zero-batch QBE cost is1.023s. This can improve short research requests; it is not a production frontend win until transferred.|
|4|Integrate Phase156's already-measured canonical publication state into the maintained compiler.|Existing plan; no new speculative architecture needed.|4.62% full-source source-to-QBE reduction was measured. Native integration/qualification remains outstanding.|

The ambitious direction is a verified private computation region whose borrowed
inputs, scalar/product results and lifetimes survive helper calls. That could
remove categories of retain/drop, boxing and scheduler work while keeping QBE.
Use this experiment to discover the required abstraction; do not first rewrite
the runtime or build a universal IR.

The full-source profile's101.45s backend region provides a conditional bound:
making *all* of it1.5×/2× faster saves about34s/51s. It does not follow that the
whole249s build becomes5× faster, or that every backend stage shares the fixture's
headroom. A50s target needs additional frontend and machine-build reductions.

Stop treating allocation count, generated text size or one backend ratio as a
causal explanation. Measure bounded dynamic costs and complete computations.
Keep our efficient memory use and stack-safety obligations visible; a direct
native recursive call is not automatically a legal replacement for a continuation.

## Profiler, negatives, cost and retained state

The main-thread-only sampler initially captured zero useful samples: even
`--threads1` bendc runs the compiler on a child pthread. We migrated the existing
all-created-thread collector into the maintained profiler, preserving its exact
source, and added explicit `argv0` support to avoid instrumenting a shell wrapper.
Default behavior remains unchanged. Thread streams are not a chronological
timeline; the collector has a32-thread admission limit. The comparator now
checks explicit argv0 identity and row/manifest consistency.

Candidate2/3ms samples overran and were rejected. Four8/13ms captures meet the
existing pooled quality gates; none were relaxed. The main-only failed captures,
short-period failures, source audits and exact runtime patch remain in evidence.
All32 focused host-tool tests pass, covering configuration and identity separately
from real child-thread captures. No compiler optimization was implemented in
Python; these are host diagnostic/orchestration tools.

Seventeen guarded jobs total472.859s (7.88min), including123.227s for two private
Clang builds. No production compiler self-build,
upstream migration, broad runtime campaign or PR comment occurred. All guarded
runs are classified and sealed; bulky historical profile outputs are pruned only
after authenticated archival. Research effort and guard time are separated in
the cost receipt; billing/quota data is unavailable.

After sealing the capsule, the completed diagnostic image and original common
profile raw directory were also pruned through their authenticated plans to
retain disk headroom. The winning candidate, original comparators and qualified
compiler remain available; [pruning receipts](evidence/post-seal-pruning.json)
preserve the exact restoration information.

Maintained source, qualified Phase152 N2 and installed selections are unchanged.
This phase improves our profiler and, more importantly, changes the evidence for
which architecture experiments are worth doing next. It does not establish
recursive self-improvement or new compiler conformance.
