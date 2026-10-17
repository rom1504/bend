# Phase102: ambitious native campaign

> Current native default: corrected candidate04 (`63ef222c…9cda237`), promoted
> after its own native qualification, performance acceptance, public CLI and
> actual default smoke. See the [promotion report](default-promotion.md) and
> [current native guide](../../docs/self_hosted/NATIVE_PHASE102.md). The campaign
> below records candidate03 (`b3927732…902d1f`) and earlier experiments. Its
> measurements and default-status statements describe that historical checkpoint.

[Design](../../design/phase102/ambitious-native-campaign.md). Execution began
2026-10-16 at 20:09 UTC for a three-hour campaign, followed by final regression
diagnosis and publication. Candidate03 completes native qualification and is
available as an [explicit opt-in compiler](../../docs/self_hosted/NATIVE_PHASE102.md).
**Phase98 remains the default:** three fold points regress by 10–19%. The cause
is isolated and a small Bend-source successor is tested separately below.

## Application result

General worker composition and constructor loops improve all three complete
applications. The final Bend source is `projection-cold-source01/compiler.bend`,
SHA256 `b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
The immutable [lowering03 source profile](../../selfhost/tools/native/profiles/phase102-lowering03/profile.json)
replays it exactly; source replay is separate from native qualification.

Four alternating rounds check 72 complete outputs. Ratios below are elapsed
candidate time divided by the named comparator; lower is better.

| Complete application | Candidate / installed Phase98 | Candidate / pinned upstream |
|---|---:|---:|
| Generated10000 source index |0.531|0.915|
| Compiler-text source index |0.510|1.102|
| Renderer, one worker |0.731|0.988|
| Renderer, four workers |0.792|1.129|
| DAG800 planner |0.653|0.220|
| Chain1000 planner |0.682|0.246|

These are complete application processes, including startup and IO, from
`final-screen03`. They are not compiler latency or a universal Bend speed ratio.
The independent 50-input fixture suite passes 165 complete output observations
in `final-broad03`. Its one-round small-input timings are correctness coverage,
not evidence of small speed differences. Renderer memory falls from about79.4
to51.5 MiB RSS in the production fixture. Upstream remains pinned to
`059266225b77c8ca256ac6b25ee5c21449bab151`.

## Broad generated-program runtime

The final03 broad comparison freshly measures all **44 positive-work points**
in the 45-program catalog; the zero-work point has no meaningful speed ratio.
Each comparator uses three alternating rounds with complete-result validation.
These measurements time execution inside each generated program; compilation,
Clang construction and startup are excluded from this metric.

| Weighting | Candidate / installed Phase98 | Candidate / pinned upstream C |
|---|---:|---:|
| Equal catalog point geometric mean |0.95532253|1.06279906|
| Equal original source geometric mean |0.96082418|1.08219293|

The equal-point aggregate is about **4.5% less runtime than Phase98**, while
remaining **6.3% above upstream**. Giving each original source equal weight
leaves an **8.2% upstream gap**. These aggregate improvements do not establish
that every program improved. They come from
`phase99/phase102-runtime-phase98-03/summary.json` and
`phase99/phase102-runtime-upstream-03/summary.json`, with the raw samples
retained beside each summary.

The first full screen records list-pipeline128/512 at **0.647×/0.668× Phase98**,
but raytrace at **1.451×**, local-fold at **1.194×**, and its 128/8192 variants
at **1.101×/1.193×**. Raytrace samples span both fast and slow modes in both
roles. These initial results remain part of the evidence; they are not removed
from the aggregate. Eight balanced four-role rounds compare Phase98,
candidate02, candidate03 and an isolated hint ablation in `hint-ablation-run01`.
Raytrace is 0.992× Phase98 in that repeat, with overlapping narrow ranges;
the original 45% median gap does not reproduce. The three fold points do
reproduce at 1.191×, 1.105× and 1.191×. Restoring just four prior inline-hint
tokens, while retaining the new observer body, gives 0.998×, 1.018× and 0.992×.
All 128 complete outputs pass. This isolates the forced-hint change as the
cause of the fold slowdown; the exact machine-code/layout mechanism remains
unmeasured. These controlled results do not replace the original broad samples.
[The regression review](runtime-regression-review.md) records the exact source
comparison: these ray/fold products change only an observer-projection body and
two workers' inline hints, with no TRMC state change. Candidate03 is retained
as an opt-in version, with no claim of regression-free default promotion.

## What changed and what we learned

1. **Compose existing direct workers.** Scoped local calls and early owning
   observer forwarding let ordinary source compositions retain efficient paths.
   This reduces continuation creation and saved state without replacing the
   public runtime or adding a new String representation.
2. **Turn constructor recursion into loops.** Generic final-field construction
   uses a private destination and one reusable uniquely owned cell. Existing
   admission and fallback protect unsupported bodies, sharing and error paths.
3. **Remove temporary observer results.** A bounded source-IR reduction proves
   when an owned observer's nested product is immediately projected to its
   scalar result. The actual Bend emitter bypasses two Tuple allocations, checks
   errors, then releases both roots. It changes the intended caller in all
   three apps and five controls; public adapters remain available.
4. **Bound forced inlining across composition.** The first integrated native
   image exceeded its 420 s Clang limit. A local 8 KiB body cutoff was insufficient
   because eligible callers compose. Three immutable dependency rounds bound
   the forced chain while leaving ordinary Clang inlining available. The
   successor built in 377.2 s, with 2.58 GB peak process-tree RSS; this is a real
   compiler-image build, not an inferred benefit from a source-size proxy.
5. **Respect each destination's ownership policy.** The broad runtime screen
   exposed an avoidable reference-count wrapper in newly lowered cold lists.
   A six-round saved-C ablation changed the two list cases from roughly 1.3×
   installed time to 0.65–0.66×. The integrated fix records the previous
   destination constructor's policy, including terminal publication. Five
   mixed-policy diagnostics pass preprocessor checks and 15 full-output runs.

The cold-list512 case initially measured 2.54× installed time; the follow-up
three-way screen reproduced a smaller 1.34× median regression, with visibly
bimodal samples. Both datasets are retained. The improvement is clear in the
matched follow-up; the first regression magnitude should not be generalized.

A chunk-String representation was not selected. Structural changes to control
flow and construction earned the broad gains while retaining existing storage.
The independent C projection prototype guided integration, but its measurements
are not substituted for the actual Bend-generated results above.

## Correctness, self-hosting and complexity

Final-source preflight passes 171 output observations, 23 projection acceptance/
refusal checks, and the independent mixed-constructor policy diagnostics. The
source audit retains all 159 existing types, 658 laws, 13 safe statements and
reviewed authority closures; it records 17 changed and 83 added declarations.
Finite checks do not establish a whole-compiler or ownership proof.

Final candidate03 completes the genuine native chain. B1 and B2 emit exactly
**30,372,406 bytes of the same self C**, SHA256
`b0048997f35830b8a97a4c8b187185108d4673050765b680734009c74427f0c7`,
with complete diagnostic agreement. The installed baseline emits 39,731,345
bytes on that same source. Final B2 Clang construction takes 374.6 s and 2.60 GB
peak process-tree RSS, inside its unchanged 420 s / 6 GiB guard.

| Producer compiling the exact final source | Request seconds |
|---|---:|
| Installed Phase98 native B2 |203.635|
| Final native B1, built by upstream |123.969|
| Final self-hosted native B2 |140.614|

These are single observations from qualification, not repeated timing medians.
The same-stage B2 comparison is 0.691× installed time; B2/B1 is 1.134×. B1 is the
Bend compiler built by upstream, not the upstream TypeScript compiler itself.

The completed six-source comparison uses four balanced rounds at each native
stage. Every one of the 48 requests per stage reproduces its complete expected
C and diagnostic. Ratios are equal-case geometric means against **the same
stage of installed Phase98**, not against upstream TypeScript:

| Native producer | Compiler request time | Whole compiler process time |
|---|---:|---:|
| B1, upstream-built Bend compiler |1.020672|1.019881|
| B2, self-hosted Bend compiler |0.721661|0.686957|

B1 request latency is about **2.1% higher** overall (map_closed is 1.074×).
B2 request latency is about **27.8% lower**, and its process wall time is about
31.3% lower. Request clocks exclude preparation; whole-process clocks include
startup, preparation, output writing and teardown. Neither includes Clang
compiling the output C. These figures describe how quickly the compiler emits
programs; they are distinct from the generated-program runtime table above.
The receipts are `phase99/phase102-b1-screen03/report.json` and
`phase99/phase102-b2-screen03/report.json`.

This phase does not supply a new matched upstream TypeScript compiler-latency
ratio. The remaining measured gaps are the broad program-runtime 6.3–8.2%
aggregate above upstream, specific workload outliers under investigation, and
the B1 compilation overhead relative to installed Phase98. A same-source
self request still takes B2 13.4% longer than B1 in the single observation;
that is a bootstrap-stage gap, not an upstream-language comparison.

Candidate02 completed actual native B1/B2 construction, exact self reproduction,
69 eligible conformance cases per stage, broad45-program qualification and all
backend gates. It remains unselected because its list-runtime regression was
unacceptable. Final candidate03 has independently completed its own exact native fixed point,
broad 45-program qualification, 69 eligible conformance cases at each stage,
and backend semantic gates. No candidate02 image or result is relabeled as
candidate03. Semantic admission and default promotion are separate decisions.
The final five image controls, the 70-obligation backend bridge and all nine
public CLI controls pass. Three separately compiled semantic fault challenges
are detected, with zero survivors or inconclusive executions. The staged
request capsule verifies all 36 assets with zero missing files; this verifies
the archive and current assets, not a missing-file restoration experiment.

The final flattened native source has 39,370 physical lines, versus 38,790 in
installed Phase98: **+580 lines, about 1.5%**. This phase improves performance;
it does not claim a line-count reduction. The canonical compiler modules and
selected JS implementation are unchanged. Experimental runners and immutable
failed variants are research artifacts, separate from these compiler counts.
The experimental tooling itself is substantial: at the closing source audit,
105 Python files contain 11,393 lines, 15 JavaScript modules contain 1,018,
and 33 Bend experiment/fixture files contain 2,103. These include retained
successive methods and rejected experiments, not additional production compiler
lines. Consolidating the active runner interfaces is worthwhile; immutable
evidence methods should remain available for replay.

## Experimental correction after the final screen

Candidate04 (`projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`)
changes one expression: projected workers retain the union of their original
and new dependencies for the existing bounded-inline policy. All actual calls
remain represented; each forced-inline round can only select fewer workers
than candidate03. This preserves a conservative dependency cost after wrapper
elimination, without selecting function names or benchmark programs.

The checked Bend testing API passes. Seven actual emitted products include
the three applications and four runtime diagnostic programs. Source04 has not
received a native B1/B2 chain or semantic admission; candidate03's qualification
does not transfer. The follow-up uses saved products and focused application
timings instead of starting a third full image-qualification cycle during this
campaign. Its final activation/timing receipts are described in
[projection integration](projection-integration.md).

The [closing unchanged-B2 profile](native-profile-final.md) supplies1,041 samples
over eight exact-output map compilation requests. `term_drop` and `span_fade`
together account for49.3% of physical leaves. This is a concrete next question
about ownership traffic, not a claim that half of every compilation is removable.

## Time and efficiency

The measured target window ends at23:20:45 UTC: **3h11m45s** from the declared
start. The [full account](time-accounting.md) covers4,919 guarded intervals,
101m37s of target occupancy and90m08s of unclassified wall time. Recorded targets
never overlap. Native acquisition/chain/gate directories account for62m52s of
that target time, including the failed first build. No OOM is recorded.

That is still too much bootstrap work before all important runtime sentinels
were present. The fold diagnosis required only53.4s of guarded builds/runs.
Future campaigns should screen folds, cold lists and composed inline depth
before constructing an image. Exact-C reuse avoided no builds this round
because all45 products changed. Final archival, documentation and Git publication
occur after the target cutoff; no quota-percentage estimate is inferred.

## Evidence and reproduction

The [experiment history](experiment-history.md) retains intermediate screens,
failures and rejected approaches. See [typed lowering](typed-notes.md),
[construction](trmc.md), [projection integration](projection-integration.md),
[projection safety review](projection-review.md), [build experiments](build-notes.md),
[backend qualification](backend-qualification.md), and
[the native release path](native-release-plan.md).

The [verified evidence archive](evidence/README.md) preserves34,940 files,
including raw failures, all final receipts and the nine public CLI request
directories. The [machine-readable result summary](results.json) binds the
principal measurements. The smaller request capsule in the opt-in guide lets
the qualified candidate run without restoring the complete research archive.

The [scheduler investigation](scheduler-pruning-investigation.md) identifies a
future build-size opportunity, with explicit dynamic-call boundaries that must
be closed before pruning is safe. The [remaining opportunities](next-opportunities.md)
are hypotheses unless an actual retained experiment supports them.

The full broad runtime, stage comparisons, native admission and explicit CLI
release are complete. Initial runtime regressions and their balanced follow-up
remain separate retained experiments. Phase98 native and Phase90 JS remain
the defaults. No PR comment was posted.
