# Phase49: explain generated-code costs through V8

Date: 2026-10-05. Starting installed compiler: Phase48 RNFA04, commit
`2d6e5d81b49bca8c3c9155414df6f2a987ffa7ed`. This is a bounded diagnostic campaign,
not a planned compiler rewrite. The user requested design, execution, reporting
and frequent explanations of findings. Aim for a first useful conclusion in
30–60 minutes; review scope if evidence requires more time.

## Problem and first experiment

Phase48's private aggregate transport removed RLE tuple-constructor evaluations
from 15 to 3, yet its clean screen became slower. Those instrumented constructor
counts do not establish how many physical objects survived V8 optimization.
The experiment also widened private signatures and return/continuation transport.
We need to distinguish those mechanisms before implementing another pass.

Compare the exact, frozen JavaScript from the Phase48 values03 screen:
pinned upstream TypeScript, Phase47 array06 baseline, and rejected scalar values03.
All three run the same RLE public export and complete result oracle. These are
historical diagnostic roles, not a relabeling of the installed RNFA04 compiler.
Record whether the installed RLE output is identical as a separate static fact.
Keep V8/Node pinned to the actual Node24.18.0 executable and V8 version/hash.

## Competing hypotheses and falsifiers

| Claim | Cheapest useful discriminator | Evidence against it |
| --- | --- | --- |
| Original tuples were physically allocated and the pass removes them | Sampled allocations per verified public call; optimized IR for hot helpers | No reliable allocation decrease, or original allocation already eliminated |
| Extra transport prevents inlining or increases optimized work | Inlining decisions, hot helper code, register/stack behavior | Same effective inlining and comparable hot code; no benefit from a narrow transport ablation |
| Measured difference is caused by tiering/deoptimization | Import/warmup/measurement markers aligned with trace-opt/deopt | Both hot paths settle in the same tier without measured bailouts |
| Fixed public-entry work dominates the tiny RLE source | CPU attribution and comparison with already-preserved scaled diagnostics | Most cost is inside the tuple-producing computation |

No single trace proves a causal slowdown. A plausible explanation earns a small
saved-JavaScript ablation followed by clean paired timing. That derivative stays
explicitly unchecked and cannot become a compiler optimization without later
source implementation and semantic qualification. A null result is reportable.

## Execution order

1. Freeze source modules, prior receipts, input/oracle, driver, Node identity and
   relevant V8 flags. Acquire no compiler image and do not rebuild frozen programs.
2. Run short fresh-process clean screens with the same public-call harness,
   consumed/checksummed outputs and rotated role order. Report medians/ranges;
   never mix historical or profiled durations into new speed ratios.
3. Capture separate CPU and allocation samples. Allocation capture includes
   objects collected during the window, preserves unattributed mass and reports
   estimated bytes per completed call, not exact object counts or retained heap.
4. Capture optimization/deoptimization and inlining traces with explicit phase
   markers. Identify functions by module position and compiler ID/address where
   available; names alone are insufficient. Separate warmup and measured events.
5. Inspect only the hottest relevant functions with filtered TurboFan IR and
   optimized assembly. Use compatible V8 tooling. Inspect surviving allocation
   and call operations, not just the original source or deoptimization metadata.
6. If there is a specific supported mechanism, test one narrow output ablation
   with the same result oracle and short clean paired measurements. Otherwise
   stop and report what the observations rule out and what remains unknown.

CPU profiles/AST mapping already exist in `programs/diagnose.py`; reuse their
summarizers and reader conventions. Historical Phase47 traces already found
optimized fold loops without measured bailouts, so collecting another list of
deopt reasons alone is insufficient. First add the missing mechanism evidence,
not a new generic profiling framework or broad full-corpus run.

## Resource and interpretation boundaries

Root owns all target execution, serially under the maintained ExecutionGuard:
CPU3, 1,024MiB Node heap, 2,048MiB process-tree RSS, 4,096MiB available-memory
floor, explicit per-job deadlines. Independent agents inspect source, design the
driver and challenge evidence. Their data work uses CPU0 during clean timing;
no compilation, compression or competing target work overlaps timing.
Filter graph/code dumps to a few hot functions, cap output growth and stop on
excessive diagnostics. Do not dump every function or run full heap snapshots.

Tracing, allocation sampling, counters, forced optimization and special V8 flags
can alter optimization or costs. Keep them separate from clean timing. We do not
infer allocation elimination from zero samples or constructor counts; absence
of deopts does not establish good machine code. V8 flags exposed by the binary
are capabilities to check, not proof their outputs will answer the hypothesis.

All new outputs go under `selfhost/build/phase49` until explicit closure.
Phase45–48 raw trees and consumed evidence stay unchanged. Preserve all failures
and the 103-file unrelated starting inventory. No upstream source, installed
compiler, public contract or PR comment changes are part of this investigation.

## Deliverables and decision

- Small reusable V8-aware public-call diagnostic driver and exact replay recipe.
- Side-by-side CPU/allocation/tiering/inlining evidence for the selected source,
  with at least one optimized-IR/code inspection if the build supports it.
- A report separating observations, causal evidence, hypotheses and non-results.
- One next optimization recommendation tied to measured work, or a justified stop.
- Committed/pushed design and final report/evidence; no installed performance or
  full-conformance upgrade inferred from this diagnostic-only campaign.

References: [V8 Turbolizer](https://chromium.googlesource.com/v8/v8/+/refs/heads/main/tools/turbolizer/README.md),
[V8 Linux perf](https://v8.dev/docs/linux-perf),
[V8 System Analyzer](https://v8.dev/blog/system-analyzer),
[Deopt Explorer](https://github.com/microsoft/deoptexplorer-vscode),
[existing diagnostics](../../selfhost/tools/performance/programs/DIAGNOSTICS.md),
[Phase48 aggregate outcome](../../implementation/phase48/aggregate-transport.md).
