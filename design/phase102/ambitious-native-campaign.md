# Phase102: three hours of architectural native experiments

Approved execution window: 2026-10-16 approximately 20:09–23:09 UTC.
Baseline: commit `41f758c3`, installed Phase98 native B2, pinned upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. This continues the
[ambitious agenda](../phase101/ambitious-native-agenda.md) and
[Phase101 evidence](../../implementation/phase101/README.md).

## Objective and evidence

Make useful native applications materially faster through general compiler and
runtime mechanisms. Keep compiler throughput, generated-program runtime,
correctness, complexity, and release qualification separate. The immediate
targets are complete source indexing, image rendering, and dependency planning;
the independent frozen fixtures cover 50 inputs. Source indexing the compiler
is an application workload, not a compiler latency measurement.

Phase101's chunk String plus iterative append makes rendering about 1.7× faster
and cuts its memory to one-third, but indexing is neutral/slower and graph work
regresses 4–6%. It is not installed. We must find which mechanism earns the gain
and avoid promoting a new representation merely because one application wins.
The source-index profile instead points to large continuations and repeated
saved state. These are the two principal architectural bets.

## Schedule

| Minutes | Work | Decision/output |
|---|---|---|
| 0–15 | Freeze criteria, prepare reusable experiments, commit this design | One short command per hypothesis, authenticated existing products and fixtures |
| 15–50 | Iterative append on linked storage; adaptive small strings and cached chunk cursors where justified | Attribute the renderer gain and remove indexing/graph regressions |
| 50–110 | Whole-function typed lowering, extending existing scalar/direct workers | General elimination of continuation/state traffic in scanning and state machines |
| 110–140 | Construction/fusion/parallel joins; separate reusable-runtime build experiment | A structural runtime or build-time gain with costs included |
| 140–180 | Integrate earned winners into the Bend compiler; targeted correctness and wider performance; report and push | Reviewable source, exact evidence, explicit qualified versus experimental boundary |

The schedule is adaptive: start an independent promising lane as soon as its
preparation is ready. Do not wait for a nominal time slot. The first test of each
mechanism gets about 10–15 minutes; extend it for a clear gain or a concrete
identified fix. Preserve rejected variants instead of repeatedly polishing a
neutral candidate. Aspirational gains of 1.5–2× on applicable workloads are
hypotheses, not promised aggregate or multiplicative improvements.

## Three focused lanes and serial measurement

1. Text/ownership: original linked-String iterative append, then representation
   ablations. Own `selfhost/tools/performance/phase102/text/`.
2. Typed lowering: inspect actual hot continuations and existing Bend emitter
   plans; prototype a general structural extension with fallback. Own `typed/`.
3. Fusion/build: identify removable construction or reusable runtime build work;
   prepare isolated transformations and full-cost commands. Own `build/`.

The leader owns integration, the shared runner, target scheduling, measurements,
and commits. Agents inspect and prepare offline; they do not run compilers,
Clang, or timed applications. This avoids CPU/memory contention and misleading
parallel benchmarks. No new ultra-agent escalation or broad research campaign
is required. Existing research is the starting point.

## Fast loop and gates

Reuse Phase100 authenticated baseline/upstream C and binaries, Phase101 frozen
fixtures, independent String controls, and the guarded serial execution helper.
Do not regenerate independent oracles or rebuild unchanged products each time.
Each candidate records source/helper/tool hashes and complete output equality.
Keep transformations general, and distinguish generated-C interventions from
Bend-produced compiler implementations. Keep old methods and evidence immutable.

Screen one relevant input and a likely regression control first, then the six
large application points, then all 50 fixtures plus ownership/String controls
for retained runtime changes. Use alternating paired runs and report medians,
memory, raw samples and complete output hashes. A large observed gain can earn
the next gate quickly; small differences need confirmation before a claim.

Before compiler integration, require a concrete causal mechanism and meaningful
gain without unexplained regressions. Preserve full U32 String characters,
strict argument order, affine ownership, shared/static tails and parallel joins.
Use existing fallback when a structural precondition is not proved. The host-only
chunk prototype cannot silently cross GPU boundaries. Finite tests are not a
whole-compiler correctness proof.

Use checked B1 for routine Bend edits. Only a winner earns compiler-image
acquisition and broader qualification. If a large integration cannot be qualified
within the window, retain it as an explicit candidate and keep installed releases
unchanged. Do not install a partially checked image to satisfy a deadline.

## Efficiency and delivery

Aim for roughly two-thirds of work on discovery and implementation, with
validation increasing as candidates mature. Record target occupied time,
build time, end-to-end campaign wall time, failures and resource use. Do not
infer quota percentages from elapsed time or token counts unavailable here.
Use bounded process guards, serial heavy work, and monitor disk space.

Maintain one evolving [report](../../implementation/phase102/README.md) and
separate experiment records. Commit/push the design, meaningful checkpoints and
final report. User-facing updates explain findings and next decisions. No PR
comment is authorized by this task. Preserve unrelated working-tree changes.

## Compiler-scale feedback: bound composed inlining

The first integrated candidate passes application/control screens but its native
B2 Clang build reaches the420s limit. Retain this failure. The direct-worker
dependency graph explains why a local8KiB size cutoff is insufficient: forced
inlining can expand through a long chain even when every individual body is
small. A lexical source-size estimate rises from1.38MB to115.12MB at outer calls;
this is a diagnostic proxy, not a measurement of LLVM IR.

Test ordinary Clang inlining first as an ablation. Then retain the local8KiB
limit with three immutable selection passes: eligible leaves, their eligible
callers, and one more caller level. Use final worker dependency metadata after
observer routing, not only original code calls. Compute the set once and carry
it through prototype/body emission. This constrains forced-worker chains; Clang
can still choose additional inlining. Worker legality and ownership are unchanged.

Require actual Bend-emitted app C to differ only in hints, then repeat complete
outputs and the six-point application screen. Only a viable successor earns a
new genuine B1/B2 chain. Prefer this small bounded policy over a new cost-model
framework during the current window. Keep the old native build failure, hint
ablations and source recipes. Report any application-runtime cost alongside the
compiler construction benefit. Further tuple-projection and fault challenges
remain independent experiments and cannot silently enter the frozen candidate.

## Earned follow-up: compose owned observer results

The separate saved-C experiment removes two private Tuple shells between an
owning observer adapter and its immediate scalar projection. Focused ownership
controls pass, and a six-round alternating comparison against the bounded
candidate measures about30% less graph-planning time,4–6% less indexing time,
and no established one-worker renderer gain. This warrants a bounded source
integration attempt while the prior candidate finishes qualification.

Prefer the existing observer certificate and owned adapter cleanup. Recognize
only a bounded, pure source composition whose wrapper reduces to the existing
scalar-result variable; preserve identity argument flow and ordinary fallback.
Do not add a generated-C text rewrite to the compiler or a new borrowed caller
ABI. The source successor must get its own reversible recipe, API/ownership
controls, actual emitted-C app comparison, authority audit and genuine B1/B2
chain before it can replace the frozen candidate. If it is not ready within
the remaining useful window, publish the qualified predecessor and the exact
experimental successor separately. Never transfer qualification by similarity.
