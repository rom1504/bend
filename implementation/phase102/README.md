# Phase102: ambitious native campaign

[Design](../../design/phase102/ambitious-native-campaign.md). Execution began
2026-10-16 at20:09 UTC for a three-hour campaign. The final candidate is now
undergoing native image qualification; installed Phase98 remains selected.

## Result so far

General worker composition and constructor loops improve all three complete
applications. The final Bend source is `projection-cold-source01/compiler.bend`,
SHA256 `b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
The immutable [lowering03 source profile](../../selfhost/tools/native/profiles/phase102-lowering03/profile.json)
replays it exactly; source replay is separate from native qualification.

Four alternating rounds check72 complete outputs. Ratios below are elapsed
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
The independent50-input fixture suite passes165 complete output observations
in `final-broad03`. Its one-round small-input timings are correctness coverage,
not evidence of small speed differences. Renderer memory falls from about81MB
to53MB RSS in the production fixture. Upstream remains pinned to
`059266225b77c8ca256ac6b25ee5c21449bab151`.

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
   image exceeded its420s Clang limit. A local8KiB body cutoff was insufficient
   because eligible callers compose. Three immutable dependency rounds bound
   the forced chain while leaving ordinary Clang inlining available. The
   successor built in377.2s, with2.58GB peak process-tree RSS; this is a real
   compiler-image build, not an inferred benefit from a source-size proxy.
5. **Respect each destination's ownership policy.** The broad runtime screen
   exposed an avoidable reference-count wrapper in newly lowered cold lists.
   A six-round saved-C ablation changed the two list cases from roughly1.3×
   installed time to0.65–0.66×. The integrated fix records the previous
   destination constructor's policy, including terminal publication. Five
   mixed-policy diagnostics pass preprocessor checks and15 full-output runs.

The cold-list512 case initially measured2.54× installed time; the follow-up
three-way screen reproduced a smaller1.34× median regression, with visibly
bimodal samples. Both datasets are retained. The improvement is clear in the
matched follow-up; the first regression magnitude should not be generalized.

A chunk-String representation was not selected. Structural changes to control
flow and construction earned the broad gains while retaining existing storage.
The independent C projection prototype guided integration, but its measurements
are not substituted for the actual Bend-generated results above.

## Correctness, self-hosting and complexity

Final-source preflight passes171 output observations,23 projection acceptance/
refusal checks, and the independent mixed-constructor policy diagnostics. The
source audit retains all159 existing types,658 laws,13 safe statements and
reviewed authority closures; it records17 changed and83 added declarations.
Finite checks do not establish a whole-compiler or ownership proof.

Candidate02 completed actual native B1/B2 construction, exact self reproduction,
69 eligible conformance cases per stage, broad45-program qualification and all
backend gates. It remains unselected because its list-runtime regression was
unacceptable. The final candidate03 must repeat its own native qualification;
no candidate02 image or result is relabeled as candidate03.

The final flattened native source has39,370 physical lines, versus38,790 in
installed Phase98: **+580 lines, about1.5%**. This phase improves performance;
it does not claim a line-count reduction. The canonical compiler modules and
selected JS implementation are unchanged. Experimental runners and immutable
failed variants are research artifacts, separate from these compiler counts.

## Evidence and reproduction

The [experiment history](experiment-history.md) retains intermediate screens,
failures and rejected approaches. See [typed lowering](typed-notes.md),
[construction](trmc.md), [projection integration](projection-integration.md),
[projection safety review](projection-review.md), [build experiments](build-notes.md),
[backend qualification](backend-qualification.md), and
[the native release path](native-release-plan.md).

The [scheduler investigation](scheduler-pruning-investigation.md) identifies a
future build-size opportunity, with explicit dynamic-call boundaries that must
be closed before pruning is safe. The [remaining opportunities](next-opportunities.md)
are hypotheses unless an actual retained experiment supports them.

Raw final evidence, time accounting and release status will be consolidated
when the serial native qualification and runtime measurements finish.
