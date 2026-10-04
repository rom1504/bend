# Phase46: bounded JavaScript versus C investigation

Frozen pre-execution design, 2026-10-04. Budget: approximately 90 minutes from
21:57 UTC, with a first feasibility decision after about 20 minutes. The selected
compiler remains Phase45 worker23. This investigation changes no compiler source.

## Question and hypothesis

Compare the installed compiler and pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`, each emitting JavaScript and C.
Determine whether representative slowdowns survive changing output target.
The native path uses a separate lowering and runtime: differences identify
directions for investigation, not a clean causal ablation of JS versus C.

Keep JS primary unless evidence supports a different decision. No direct LLVM,
assembly backend, GPU test or native compilation of the compiler is in scope.

## Selection and correctness

Use six existing Phase37 catalog sources, with exact source hashes and wrappers:

| Mechanism | Source | Maintained input | Expected U32 |
| --- | --- | --- | ---: |
| Numeric recurrence | fixtures-new/numeric-recurrence.bend | 1024, 123 | 1376326140 |
| Recursive tree | fixtures-historical/tree-bitonic.bend | 8, 0 | 971629740 |
| Captured closures | fixtures-new/closures.bend | 256, 123 | 33019 |
| Mutable array transport | fixtures-historical/local-fold.bend | 4096, 17 | 2339999928 |
| Immutable collection updates | fixtures-new/map-churn.bend | 128, 123 | 3714872484 |
| Mixed control and strings | fixtures-historical/lexer.bend | 8, 0 | 1822208108 |

Sources are under `selfhost/tools/performance/phase37/`. Import each under a
namespace and provide a new bounded main. Never run original benchmark mains:
several select enormous parallel workloads. First establish correctness on the
numeric and closure cases in all four cells; stop expansion if native/toolchain
repair would consume the investigation. Preserve failures rather than dropping
them from the denominator. F32 output comparisons are exact.

The six cases are a mechanism sample of a tuned corpus, not general language or
application coverage. No geometric mean here replaces Phase45's 45-point result.

## Measurement boundaries

1. Fresh checked emission: capture API, JS/native runtime, Base, upstream source,
   source graph, tool and output hashes, versions, command and elapsed time.
   Reuse the installed image; do not rebuild the compiler or modify pinned code.
2. Compile C with the same available Clang, `-std=c11 -O3 -pthread -lm`, without
   fast-math. Record compile/link separately from Bend checking and emission.
3. Run all targets on CPU3, native `--threads 1 --gpu off`, Node heap 1024MiB.
   Use the existing exclusive ExecutionGuard, 2048MiB process-tree RSS ceiling
   and at least 4096MiB free memory. Do not limit native virtual address space:
   its runtime reserves a large sparse heap. Run one target job at a time.
4. First capture complete one-shot results and process turnaround. For sustained
   work, use the same Bend batch wrapper in all targets, dynamic CLI repetition
   counts, varied inputs and an observed checksum. Warm separately. The wrapper
   must force results before stopping its clock; if IO.now and checksum printing
   are used, include that observation overhead explicitly. Never compare cold
   native process time with warm JS library time.
5. Aim for at least 100ms measured batches and three rotated rounds per cell;
   retain pilot/calibration runs and every timed attempt. Record clock granularity,
   warmup, workload count, exact checksum, peak RSS and startup boundaries.
   Short or incomplete results remain diagnostic, not precise speed claims.
6. Investigate at most two revealing cases using generated-source structure and
   separate profiles. Profiling is excluded from timing. If perf is unavailable,
   preserve that outcome and use available V8 profiles/source evidence without
   pretending to have native sampled attribution.

Native selfhost embeds the retained 6018e28 runtime with documented adaptations;
upstream embeds the pinned 0187512 runtime. Measure these compiler/runtime
products as shipped. Swapping runtimes would require a separate ABI experiment.
The common benchmark wrapper also differs from the existing public JS-library
boundary, so its JS ratios must be reported independently.

## Decisions and time budget

First 20 minutes: source/tool discovery, frozen design, two-case feasibility.
Next 30: acquire the six cases and bounded measurements. Next 30: inspect two
discriminating cases. Final 10: review, publish evidence and recommendation.
Time allocations are limits on exploration, not reasons to wait or fill time.
Permit a nearly finished job to complete; do not start an unbounded repair.

If only JS has a large relative gap, prioritize JS lowering and representation.
If both have a gap, examine high-level work and analogous missing optimizations.
If both native implementations win materially, evaluate native deployment for
those workloads while including compilation and startup costs. These are clues
requiring source/profile confirmation, not automatic causal conclusions.

Deliver a report in `implementation/phase46/`, small raw receipts, reproducible
tools and source wrappers, and one prioritized next hypothesis. Preserve unrelated
working-tree files and closed historical evidence. Commit and push the design
before measurement, then commit and push the report. No PR comment is authorized.
