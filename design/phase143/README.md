# Phase143 — return to full cold compiler throughput

2026-10-26, starting at `4fd100d5cac64e168d0288cde0db04922e858107`.
The user has authorized a cold-build investigation and optimization campaign.
Preserve Phase140–142 incremental work, but do not extend its caches in this
phase. Keep QBE, the qualified Phase137 fallback and installed selection.

## Objective and definitions

Target150s, then75s and ultimately about50s for a complete cold compiler build,
without weakening source/proof checks, final verifiers, ownership, stack safety
or generated-program quality. These are milestones to investigate, not forecasts.

Cold means a fresh compiler process with no source-specific semantic/edit/object
state. The immutable prepared Base, prebuilt runtime, compiler executable and
machine tools are explicit common inputs; OS caches are not flushed. Separate
their acquisition from each build. Count source reading, compiler execution,
output writing, QBE, assembly and linking through a usable executable. Focused
readiness checks and campaign/qualification costs are separate additional clocks.

The latest346.870s was an incremental session's cold stage sum on historical
Phase137 source. It was not complete current-source cold compilation. The old
346.960s fresh executable measurement and historical52s JS/144–164s C observations
refer to different versions/pipelines and cannot establish a speed ratio today.

## Freeze the comparisons before changing the compiler

Use exact Phase142 indexed compiler source SHA`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`,
its checked hosted API and native image SHA`f23c1c05db96f3f7ad5a5a41b110e9c1d39b422c0166fc773eb79ccc82f671c5`.
Primary input is that same current compiler source. Its complete QBE oracle is
the qualified Phase137 emission retained at
`selfhost/build/phase130/p142-indexed-emit01/program.ssa`.
Retain Phase137 source SHA`2620d59a…ecf38` as a separate historical control;
never pool the two input sizes or call them identical self-builds.

1. Measure the ordinary current native entry on the current source and verify
   the whole independent output before interpreting its time.
2. Execute the same Bend compiler source under JS/Bun, producing the same QBE.
   Start with a small exact-output screen, then use bounded streamed full output.
   Keep API/runtime acquisition and Base preparation visible. Do not turn host
   code into an alternative compiler or silently patch its generated code.
3. Compare ordinary compilation and cold incremental-session setup on the same
   engine/input where the extra measurement can change the decision. Reuse old
   matching artifacts as labeled historical evidence, not newly paired timing.
4. Add native C execution only if an exact current-source image can be obtained
   economically. Record missing capability/acquisition cost rather than treating
   a historical C backend emission number as a native-C compiler measurement.
5. Measure machine construction separately or account explicitly for overlap;
   never add QBE time twice to a streamed source-to-executable pipeline.

## Investigation and decision gates

Reuse the Phase136–138 detailed stages and physical profiles plus the recent
Phase142 cold-window evidence. Check which paths are still active. Distinguish
runtime reference management from the dedicated affine ownership checker.
Investigate source-size scaling on valid independently checked workloads; a
constructed AST kernel is only a discriminator, not a full compiler benchmark.

For each candidate, write its dynamic work, measured cost/ceiling, expected
total-build saving, uncertainty, semantic invariant, smallest falsifier and
implementation cost before changing production code. Prefer removing repeated
whole-book walks, redundant products or unnecessary representation transfers
over optimizing individual runtime operations. A credible major saving is more
valuable than a high static hit count.

First investigate exact suffix lookup and ordered-book publication, parser
prior-definition scans, constructor lookup, repeated annotation/erasure/lowering
preparation, and output construction/reclamation. Existing indexes are often
present: check whether the caller actually supplies their prepared representation.
Do not replace first-match/raw definitions with a differently ordered scope map.

Use independently checked Bend prototypes and finite counterexamples first.
Require exact whole products/errors and unrelated workload transfer before one
integrated native candidate. Keep the old verifier/proof declarations byte-exact
unless an independently justified design explicitly changes their contract.
If output is unchanged, reuse exact-artifact runtime evidence. If it changes,
run appropriate independent semantics/runtime checks; do not silently disable
optimization to make compilation faster.

## Research budget and reproducibility

Use one coordinating owner and bounded independent agents for frontend,
backend and cross-execution audits. Only the coordinator runs resource-intensive
jobs: one CPU3 lane,3GiB process-tree cap,16GiB available-memory floor and an
explicit disk budget (about3.2GiB free at start). Do not accumulate many full
compiler binaries. Preserve failed runs and exact methods/artifact identities.

The first decision block aims to spend roughly20min establishing boundaries and
auditing,30–60min on decisive small experiments, then one integrated acquisition
and full comparison if justified. Do not launch an expensive full qualification
for an early idea. Report all acquisition, failed attempts, validation, profiling,
agent work and elapsed time separately; quota billing is unavailable.

Maintain one concise prediction-versus-result ledger per hypothesis, commit/push
validated work, and write the actual outcome in `implementation/phase143/`.
Do not claim150s or recursive acceleration until the corresponding complete,
controlled measurements exist.
