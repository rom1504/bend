# Phase100: useful native applications

Three standalone Bend applications now build and run through the installed
native compiler: a source index, a complete image renderer, and a dependency
planner. The results show why self-compilation speed should not define the
project: our graph program is about three times faster than upstream's generated
program, while text scanning and rendering still have substantial gaps.

[Applications and usage](../../selfhost/apps/README.md) ·
[Design](../../design/phase100/useful-applications.md) ·
[Runner and fast replay](../../selfhost/tools/performance/phase100/README.md) ·
[Results JSON](results.json) · [All runtime summaries](runtime.csv) ·
[Evidence](evidence/README.md).

## What was delivered

| Application | Actual user-visible result | Inputs checked |
| --- | --- | ---: |
| Source index | UTF-8 source summary and declaration names/line numbers | 13 |
| Image renderer | Complete deterministic Mandelbrot P3 image | 16 |
| Dependency planner | Ordered reachable dependency plan, or cycle/missing-node path | 21 |

The applications total **779 physical Bend lines**, with no `@unsafe`
annotations. They use runtime arguments/files, not compiler-known answers.
Independent Python implementations specify complete output, including errors.
There are **318 passing executions across 50 distinct application inputs** in
completed runs, including repeated timings and worker configurations. This is
finite application coverage, not whole-compiler or universal application proofs.

All three pass upstream checking and native B1/B2 compilation. Every complete
B1/B2 C pair agrees exactly, allowing one executable to represent both stages'
generated-program behavior. Both backend roles use the same Clang22 C11/O3 build
recipe. The compiler implementation, installed JS release and installed Phase98
native selection are unchanged. Phase99's faster experimental compiler remains
experimental; this phase did not promote it or rebuild any compiler image.

## Application execution

These numbers compare **native programs from the same Bend application source**:
our native B2's C output versus pinned upstream TypeScript's C output. They do
not compare Bend execution with handwritten TypeScript application code.
Lower own/upstream ratios are better.

| Workload | Our time | Upstream time | Own / upstream |
| --- | ---: | ---: | ---: |
| Dependency DAG, 800 nodes | 230 ms | 693 ms | **0.332×** |
| Dependency chain, 1,000 nodes | 230 ms | 634 ms | **0.363×** |
| Index the 1.75 MB compiler source | 201 ms | 93 ms | **2.152×** |
| Index 10,000 generated definitions | 119 ms | 70 ms | 1.710× |
| Render 512×384, 1,024 iterations, one worker | 346 ms | 257 ms | **1.349×** |
| Same renderer, two workers | 216 ms | 155 ms | 1.392× |
| Same renderer, four workers | 168 ms | 115 ms | **1.465×** |

Graph and index rows are four-round medians with alternating backend order.
Renderer rows pool all nine observations per role/worker: the original four
balanced rounds, one fixture-replay check, and four confirmation rounds. This
keeps the slower replay observation visible; the pooled order is not perfectly
balanced. The separate four-round campaigns show one-worker ratios 1.353× and
1.347×, and four-worker ratios 1.486× and 1.397×.

Small differences should not be overinterpreted. Source indexing has one native
367 ms observation versus three around 200 ms. The renderer's one-worker range
is 344–477 ms native and 256–259 ms upstream; the four-worker range is
159–185 ms native and 106–119 ms upstream. These are observed ranges, not
confidence intervals. The 70–93 ms reference index runs are below the runner's
conservative 100 ms flag. No cross-application geometric mean is reported.

Runtime includes startup, runtime argument parsing, file input, useful work,
complete stdout production/capture and shutdown. Output comparison happens
after the high-resolution child clock. Python references, compiler and Clang
work are excluded. This differs from the historical Phase93 kernel-batch clock;
its 1.115× ratio remains a separate result.

## Real parallelism, with its costs visible

The renderer's explicit fork/join recursively divides consecutive row blocks.
Both emitted programs retain real two-child task nodes and joins. The same
complete PPM is checked for every one-, two- and four-worker execution. Affinity
uses one, two and four distinct physical cores on the recorded Xeon E3-1245 V2;
GPU is disabled.

The pooled renderer medians give **2.05× native speedup** from one to four workers,
versus **2.23× upstream**. A single-tile control computes exactly the same image
without row forks: native times remain 310/310/310 ms at one/two/four workers;
upstream stays around 194–198 ms. Adding workers alone does not help that control.
The row-parallel version also costs more with one worker than the one-tile
version, so parallel structure has a real overhead as well as a benefit.

Peak child RSS in the original production campaign is approximately 79.4 MiB
native and 65.9 MiB upstream at one worker, 79.5/81.9 MiB at four workers.
Graph and text workloads remain serial; their algorithms do not expose
independent tasks merely because more workers are available. These application
tests do not qualify all parallel ownership patterns, the native compiler host
itself under multiple workers, or GPUs.

The native program produced this image; PNG is a lossless presentation conversion
of its checked PPM output, whose provenance is recorded in [rendered.json](rendered.json):

![Complete image produced by the self-hosted native compiler's program](rendered.png)

## Building an application: Clang is a major part of the experience

| Application | B1 request | B2 request | TS/Bun request | Our Clang build | Upstream Clang build |
| --- | ---: | ---: | ---: | ---: | ---: |
| Source index | 0.713 s | 0.991 s | 1.663 s | 3.594 s | 1.476 s |
| Image renderer | 0.599 s | 0.856 s | 1.429 s | 4.445 s | 1.255 s |
| Dependency planner | 0.960 s | 1.410 s | 1.919 s | 5.317 s | 2.599 s |

These are one acquisition observation each, not a repeated compiler ranking.
Our native requests reuse the authenticated prepared Base; upstream loads/checks
Base inside its request. Include the separately recorded whole compiler-process
clock for a fuller comparison. Adding that process time to Clang gives:

| Application | Our B2 process + Clang | Upstream process + Clang |
| --- | ---: | ---: |
| Source index | 4.763 s | 3.190 s |
| Image renderer | 5.478 s | 2.780 s |
| Dependency planner | 6.978 s | 4.588 s |

Our C files are **3.0–3.5× larger** (556–748 KB versus 178–249 KB), and executables
are **2.1–3.1× larger**. The observed native build costs therefore matter even
when the Bend-to-C request is fast. Sizes alone do not establish which emitted
constructs cause Clang's extra work.

## What we learned, and the next priorities

1. **Improve ordinary native application usability.** The maintained host admits
   a single Base-importing source and nine providers, so these examples are
   deliberately single-file. Native module/import support and a qualified
   exit-status effect would make real applications easier to compose and use in
   shell/build pipelines. Our examples currently return normal process status
   for their documented textual errors; scripts must inspect their output.
2. **Use text-heavy applications to drive general backend work.** The index gap
   and renderer's formatting/output costs provide short, complete workloads.
   Profile these next and test a shared text/ownership improvement against both,
   preserving the graph win. No new profile was collected here, so allocation,
   cleanup and String reconstruction remain hypotheses rather than measured
   explanations of the index or renderer gap.
3. **Reduce generated-code and downstream build costs.** The renderer already
   has direct scalar CPU loops in both backends, so merely adding another
   arithmetic fast path is not justified by C inspection. Investigate redundant
   emitted paths/checks and what survives Clang, retaining the target-independent
   compiler structure and parallel behavior. See the
   [renderer code analysis](renderer-analysis.md).
4. **Improve application algorithms where they dominate.** The graph planner
   still performs linear list lookup and membership repeatedly. Its better
   backend result does not remove quadratic scaling. Indexed adjacency and
   visitation state are the natural application-level next step. Constrain the
   rewrite with reachable-node uniqueness, dependency-before-user order, and
   valid error witnesses. The [graph analysis](dependency-analysis.md) connects
   those invariants to the actual work-stack state and observed code shapes.

The graph result supplies a useful concrete connection to earlier optimization:
its native C uses a borrowed String comparison worker, while upstream's shown
path consumes/reconstructs strings. That is evidence that a general optimization
reaches an ordinary application. It is not a causal attribution of the entire
threefold gain; both programs also retain other costs.

## Fast iteration and evidence

The [runner](../../selfhost/tools/performance/phase100/README.md) has separate
acquisition and measurement actions, application/case selection, smoke/survey
inputs, repeat counts, worker counts and bounded jobs. Compiler images are reused;
identical B1/B2 C avoids duplicate native program builds.

Independent Python image generation initially dominated some run duration.
The final method skips unselected images, reuses identical expected images across
tile settings, snapshots current oracles, and can reuse hash-verified inputs and
complete expected outputs from an earlier successful run with `--fixtures`.
The combined correctness smoke occupied 2.7 seconds; a focused filtered loop
occupied 3.1 seconds. Replaying the substantial image across all worker counts
and both backends took 3.0 seconds for one round, **9.7 seconds for four rounds**,
without rebuilding either compiler or program. These are observed costs, not
promised hard deadlines. Fresh independent oracle generation remains available.

The complete root-owned queue contains 349 serial guarded jobs, including
preflights and retained failures: **88.4 seconds of occupied target time** across
a 24m35s first-to-last target span. Peak sampled process-tree RSS was 200 MiB;
no resource stop, OOM or target overlap occurred. Three agents prepared the apps,
references and static analysis; root alone ran compiler/program targets. Most
elapsed time was writing/integrating the applications and reference methods,
not waiting for full compiler builds. Quota percentages are unavailable.

Initial application preflights failed on pattern-match order, forward references
and structural-recursion argument order; the final safe sources fix those issues.
An initial oracle run failed on Python3.9's `Path.write_text` signature. One
control selection used `multiline` instead of `multiline-escape`; its six passing
executions remain in an incomplete receipt and are excluded from the 318 count.
All failures and all generated outputs are retained. Earlier oracle revisions
are identified by their receipts and full generated expectations; later runs
also retain exact oracle snapshots. The current oracles and frozen fixtures are
committed. See the evidence README for restoration and provenance limits.

The final independent oracle audit recomputes all 50 current cases and reproduces
every preserved successful expected output byte-for-byte, without compiler or
program execution. This checks the current reference connection after the
oracle compatibility and fixture-selection changes.

No production compiler change means there is no new broad conformance or formal
law-suite claim. Existing release/law/45-point results retain their documented
scope; selected compiler and runtime identities are authenticated. A future
compiler change must run affected application contracts first, then the relevant
existing law/conformance/runtime gates. No PR comment was posted.
