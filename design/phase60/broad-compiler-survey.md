# Phase60: survey compilation across the runtime benchmark corpus

## Question and scope

Phase59 measured the unchanged Phase58 last01 B2 compiling Lexer and Evening.
It found different bottlenecks: checking/reconstruction on Lexer, and much more
String/dependency processing on Evening. Before optimizing, establish whether
those mechanisms dominate the broader maintained corpus or just these examples.

The user authorized the broad survey on 2026-10-06. This phase collects evidence;
it makes no compiler, runtime, ordinary-driver or installed-release change.
Measure compilation of the benchmark sources, not their runtime workloads.
Commit/push the design, methods and final evidence. Post no PR comment.

The runtime corpus has 45 points mapping to 23 source path/SHA identities. Audit
entry, options, imports and adapters before freezing that as 23 compilation
identities. A post-emission runtime adapter is part of the output/oracle lineage,
not a distinct compiler input. Retain every point in the mapping; do not silently
discard adapted points or count size/seed variants as independent compilations.

## Fixed comparison

- Genuine Phase58 last01 B2 SHA256:
  `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
- Bend source:
  `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
- Pinned upstream TypeScript: `018751270e800bc222a93dad7f257083ee53a5f7`.
- Node 24.18.0, ordinary direct library compilation, no persistent inspector.
- Root runs target processes serially on CPU3, under the existing single guard:
  Node heap 1 GiB, process-tree RSS 2 GiB, available-memory floor 4 GiB,
  stack 4 MiB. Agents only perform source/tool/data work on CPU0.
- Preserve the closed Phase58 and Phase59 campaigns, seven installed files and
  103 unrelated working files. Only fresh Phase60 raw paths may receive evidence.

The compiler implementation and emitted B2 are distinct from installed checked
B1; this survey deliberately retains the same B2 subject as Phase59. It does not
claim that these timings describe a new default installed artifact.

## Preparation and correctness

Build a manifest connecting all 45 points to exact raw library modules and their
qualified Phase58 runtime observations. Retain adapter derivations where present.
Verify source, generator/API, driver, runtime, Base, Node and reference identities
and complete successful qualification. Byte equality must apply to the entire
raw module, not a selected function or output checksum without a verified file.

Private compiler copies and Base disk caches are prepared outside measurements.
Fresh compilations must reproduce their role's qualified raw module bytes and
expected input closure. B2 and TypeScript output text need not equal each other.
This inherits already executed value oracles through unchanged exact artifacts;
it is not a claim that the 45 runtime workloads were newly executed. If a lineage
join cannot be established, record it and perform the smallest necessary fresh
oracle rather than waiving that source or rerunning the full runtime benchmark.

Reuse the Phase59 first-request boundary: actual compiler import, explicit B2 API
load, and one ordinary compile. Provenance preflight, process launch, Base-cache
priming and output validation/hash/save remain outside the measured window.
Fresh process means a fresh compiler instance with a primed disk cache, not a cold
filesystem. Preflight reads can affect OS caches and heap state; document this.

## Sequential measurement plan

1. Audit corpus/lineage, register hypotheses, preserve inputs and freeze reviewed
   successors of the consumed Phase59 methods. Never patch an executed method.
2. Run clean timing for all distinct inputs and both roles: three cyclically
   rotated fresh-process rounds, first compile plus three later calls per worker.
   Keep later calls and positions separate; three calls do not prove steady state.
3. Screen all inputs/roles with one fresh diagnostic stage-clock process each.
   Preserve nonoverlapping exclusive partitions and nested inclusive intervals.
   Use the Phase59 source-aware groups; B2 and TS internal stages are not identical.
   Repeat selected outliers only if necessary to resolve variability, and retain
   the original screen and repeat separately. Stage clocks never replace clean
   timing. A single observation identifies a candidate, not a precise stage mean.
4. Capture separate CPU and sampled-allocation profiles for every input/role,
   each enclosing exactly import/API/one first request with no preceding target
   import or warmup. Stop before output validation and serialization. Reuse 1 ms
   CPU and 128 KiB allocation sampling, including collected objects. Preserve
   refused weighted views; compare CPU counts in a common unit. Do not retry every
   timestamp refusal if count attribution already answers the survey question.
5. Join clean costs, stage screens and conservative profile ancestry/source
   hotspots. Detailed source-operation counters are optional for a small selected
   set only if profiles leave a decision unresolved; do not automatically multiply
   every Phase59 diagnostic by 23.
6. Report coverage, distributions, absolute time gaps, hotspot prevalence and a
   small representative future loop. Preserve failures and confirm all inputs and
   installed/closed artifacts unchanged, close writers, archive and push.

Per-case failure receipts must survive. Continue independent bounded cases where
safe, but do not report a successful complete population from only survivors.
Resource violations stop that workload; they do not justify raising memory caps.
Use elapsed cost and remaining information value to avoid redundant validation.

## Analysis and useful output

Each source gets one population weight. Report the equal-source geometric mean,
median/range and tail ratios alongside absolute B2/TS time and the difference.
If reporting a ratio of summed source medians, label its implied time weighting;
do not call it the same metric as the equal-source geometric mean. Keep the 45
runtime-point mapping visible, with no fabricated 45-independent-compile statistic.

Separate measured clean times, diagnostic stage times, CPU sample counts, sampled
cumulative allocated bytes and source-operation counts. Never add inclusive
weights or infer saved wall time from allocation percentages. Group unknown
profile ancestry explicitly; shared SCC frame names are not single source helpers.

The report should answer which Phase59 findings recur, which new patterns appear,
and which sources discriminate them most cheaply. Propose a small measured-cost
subset spanning front-end, String/dependency-heavy and other observed patterns.
Provide ordinary clean and diagnostic replay commands with selectable inputs and
budgets. A 20/60-second future screen may check fewer requests; it must not pretend
to provide the precision or coverage of the full survey.

The canonical results belong in `implementation/phase60/`, linked from the
experiment frontier. Raw evidence, provenance, methods, unsuccessful captures and
cost accounting remain reproducible. No optimization is promoted by this phase.
