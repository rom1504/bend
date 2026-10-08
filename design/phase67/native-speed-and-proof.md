# Phase67: native speed, bounded compiler work, and a proof pilot

Authorized October 8, 2026; started 09:01:10 UTC at `2035010`.
The user asked us to execute the recommended native/C investigation, bounded
compilation-speed experiment, and small real compiler proof, efficiently.

## Baseline and objective

Keep upstream `059266225b77c8ca256ac6b25ee5c21449bab151` fixed. Phase66 ships
checked B1 `bb6c6e2a…`; its genuine B2 is `0067736c…`. Its 23-source compilation
ratios are 1.402065× and 1.321100× TypeScript, with import-inclusive ratios
0.982634× and 0.990389×. Generated JavaScript averages 1.049282× TypeScript
across 45 points. These remain historical baseline measurements.

The Phase46 native experiment found much larger gaps, caused by generic call,
closure, tuple and continuation traffic. Those old six-workload numbers must
not be reported as current performance. The primary objective is a general
native-lowering improvement supported by a fresh baseline and a short loop.
No numerical speedup is promised before measurement.

## Three bounded work streams

1. **Native baseline and improvement.** Reuse the six maintained native batch
   programs and independent expected-output calculation. Begin with numeric,
   arrays and closures; reserve tree, Map and lexer for generalization. Measure
   checked Bend-to-C emission, Clang build time, and executable runtime
   separately. Both compiler roles use the same pinned Clang, flags, CPU and
   input workloads. Compile once and reuse executables during runtime iteration.
   Inspect current generated C before selecting a source change. Prefer removal
   of unnecessary continuations, known-call transport and nonescaping tuples
   over a new backend or workload-specific recognizers.
2. **Compilation-speed side experiment.** Spend about twenty minutes inspecting
   current code and existing evidence for one affordable repeated-work reduction.
   Reject already disproved ideas. Run a small controlled screen only if there
   is a credible affected-request benefit of roughly five percent or more.
   A documented deferral is an acceptable outcome; this lane must not turn into
   another independent multi-hour architecture campaign.
3. **Actual proof pilot.** Select one transformation connected to production
   lowering. State its semantics and assumptions explicitly, write the theorem
   and proof in Bend, and seek independent checking through the pinned BendTT
   route. Locate an existing compatible kernel before building one. A proof
   checked using unsafe assumptions is not success. Report whether the result
   proves the actual implementation, an explicit model, or only a restricted
   part of the transformation; preserve the connection and remaining gap.

The native implementation, benchmark method, bounded compilation investigation
and proof each have one agent owner. Root alone executes targets and integrates
production changes. Agents do source/data/review work on CPU0. Use an additional
reviewer only for a concrete candidate or proof, not speculative planning.

## Iteration and acceptance

Freeze inputs before comparing. Each candidate has a separate patch and fresh
output directory; keep all failures. Start with source/output inspection and
focused semantic controls, then a checked B1 and the small timing screen.
Stop or revise a candidate if benefits are negligible or ownership/evaluation
order cannot be justified. Do not repeatedly run full compiler qualification
for candidates that have not passed this screen.

Native transformations must preserve live-value ownership, sharing, destruction,
evaluation/error order, arithmetic bounds, partial applications, effects, and
the CPU/device fallback contract. Independent held-out programs must demonstrate
that improvement is structural. Unsupported native APIs remain explicit.

Qualify the final selected production source once: relevant native correctness
and source tests; strict checked B1; actual B2 own-source/reproduction and
appropriate JavaScript/compilation checks. Reuse prior evidence only with a
specific unchanged-boundary argument. A native-only change does not establish
faster JavaScript programs. Any measured B1/B2 timing must identify its image.
Promote only after release and installed-interface checks pass.

Count maintained Bend modules/lines and host/runtime changes separately. Prefer
shared helpers over duplicated special cases. Keep the compiler implemented in
Bend and never hand-edit upstream `bend2/bend.ts`.

## Resource and evidence policy

One CPU3 target tree at a time; Node heap 1 GiB, stack 4 MiB, tree RSS 2 GiB,
available-memory floor 4 GiB. Existing job/bounded-run helpers own the sole guard.
Short screens precede larger work; failed deadlines do not silently expand.
No diagnostics overlap clean timing. Report target time separately from setup,
review and publication, and keep aggregate versus per-program results distinct.

Fresh raw output is under `selfhost/build/phase67`. The initial baseline receipt
preserves seven installed files and verifies 110 inherited files. All earlier
raw trees and archives remain closed; use them as read-only prerequisites.
Reuse methods and keep concise experiment files, one report and compact evidence
links rather than building another elaborate duplicated qualification framework.
Preserve new raw results durably at closure. Commit and push useful checkpoints;
no PR comments are authorized.

## Deliverables

- A reusable native fast loop and current measured baseline.
- A qualified general improvement if the prototype proves worthwhile, with
  rejected attempts and limits retained.
- A bounded compilation experiment result, including an honest deferral if needed.
- A concrete proof artifact and exact independently checked scope or blocker.
- [Implementation report](../../implementation/phase67/README.md), updated native
  documentation, five-metric impact, and committed/pushed evidence.
