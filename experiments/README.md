# Compiler experiment workflow

Use this directory to retain what was tried, what the evidence establishes and
what should happen next. The compiler remains implemented in Bend; experiments
must identify changes to compiler source, generated compiler images, host tools
and emitted user programs separately.

## Newest campaign: Phase61 architectural compiler speed

[Current results](../implementation/phase61/README.md) ·
[Current frontier](STEERING.md) · [Research map](../implementation/phase61/research-map.md).
State06's [broad180 screen](../selfhost/build/phase61/state06-b2-latency01/broad180/report.json)
passes all **69 workers across 23 sources**. Equal-source geometric mean B2/TS
improves **2.468310× → 1.432999×** for import + API load + first compilation,
and **3.802103× → 2.098952×** for compilation alone. All 23 raw outputs match
qualified references; no generated workloads were rerun. This is one fixed-order
round. Preparation/output validation stay outside clean clocks; no wall-time
extrapolation or individual-mechanism gain follows from the combined candidate.

The earlier three-source confirmation passed 18/18 workers and remains distinct.
State06 checked36, focused native/carrier controls, 86-root B2 construction and
eight ordinary-driver comparisons also pass. Earlier state04 results and its
original broad deadline remain in the [historical analysis](../selfhost/tools/performance/phase61/validation/state04-broad-analysis.json),
without pooling campaigns. Installed Phase58 last01 is unchanged. The next work
is JDText duplication research and selected final qualification; completed
controls/bootstrap are no longer future gates for the measured state06 image.
New source or maintained-helper changes need their own exact image lineage.

The experiment records cover [shared frontend state](phase61/P61-001-shared-frontend-state.md),
[owned contexts](phase61/P61-002-compact-owned-contexts.md),
[structured emission](phase61/P61-003-structured-emission.md),
[fast iteration](phase61/P61-004-fast-iteration.md),
[proved native host types](phase61/P61-005-native-host-type-facts.md),
[private prefix provenance](phase61/P61-006-private-prefix-provenance.md), and
[segmented JSON transport](phase61/P61-007-segmented-json-transport.md).
P61-007 is explicitly indexed retrospectively; it is not claimed preregistered.
The [completed Phase60 survey](../implementation/phase60/README.md) remains the
historical motivation, with its separate baseline, unknown samples and failures.

This adapts the research method in `rom1504/math` at commit
[`e2795031b5a35300d5c82613125c3bf9f3bd2b16`](https://github.com/rom1504/math/commit/e2795031b5a35300d5c82613125c3bf9f3bd2b16),
read on 2026-09-22:
[README](https://github.com/rom1504/math/blob/e2795031b5a35300d5c82613125c3bf9f3bd2b16/README.md),
[STEERING](https://github.com/rom1504/math/blob/e2795031b5a35300d5c82613125c3bf9f3bd2b16/STEERING.md),
and the beginning and final campaign entries of
[ledger](https://github.com/rom1504/math/blob/e2795031b5a35300d5c82613125c3bf9f3bd2b16/ledger.md).
We adopt explicit hypotheses, bounded investigations, independent challenge and
preserved negative evidence. Its mathematical, environment and authorization
instructions do not become instructions for this repository.

## Working files

- `ledger.md`: chronological decisions and evidence index, using stable IDs such
  as `P4-001`; each completed wave ends with an **Updated frontier**.
- `STEERING.md`: the lead agent's current ranked choices, evidence cutoff,
  blockers, falsification criteria, remaining authorized budget and next review.
  Keep it below 150 lines; distinguish user objectives from investigator ideas.
- `phase4/P4-001-short-name.md`: one record per distinct hypothesis, using
  [TEMPLATE.md](TEMPLATE.md). Subsequent attempts keep their identities and failures.
- Existing `implementation/phase*/` reports remain canonical evidence. Link them
  instead of copying competing versions of the same conclusion.

An experiment can freeze its plan before timing. In that case, leave its
pre-execution status and bytes unchanged, and put outcomes in the linked
implementation report, ledger and current steering. The frozen plan is a dated
input, not a competing statement of current completion.

The [preservation audit](PRESERVATION.md) records which historical tool versions,
failures and artifacts are tracked, how to restore them, and any remaining gaps.

Read steering and the latest frontier before choosing work. Review older records
when an idea overlaps them. An independent reviewer may first derive a proposal
without seeing the preferred explanation, then check the archive for duplicates.

## A bounded iteration

1. State a falsifiable claim and its domain: public compiler, private immutable
   image, native host, validation loop or emitted program. Name the invariant
   that permits the change and the observation that would disprove the claim.
2. Rank a few plausible alternatives by expected user benefit, evidence,
   cheapest discriminating test, risk and interference with other experiments.
   Do not invent ten ideas or launch agents for a trivial fix.
3. Assign one owner, files and a bounded deliverable. A useful default is a
   20-minute investigation with five-minute progress checks. A long compile
   gets its own justified deadline and resource allocation. Parallelize only
   independent work; coordinate CPU and memory for timed runs.
4. Start cheaply: inspect code/profile, count the proposed opportunity, test
   boundary counterexamples, then build a checked B1 and run focused differential
   cases. Use separate ablations before combinations. Escalate a surviving idea
   to a real compiler subset and representative programs before full-source
   compilation, broad conformance or another fixed-point build.
5. Freeze before measuring. Capture exact source/API/runtime/Base/host/helper,
   toolchain and harness identities, commands, affinity, resource limits and
   input hashes. State cache priming, process reuse, startup and timing boundaries.
   Alternate variants serially, retain every attempt and measure memory when
   caching or allocation changes. Do not report medians from only the survivors.
6. Have another reviewer challenge ownership, evaluation/error order, ABI,
   import identity, cache invalidation and the benchmark comparison. Record
   findings and corrections. Promote only after the relevant scoped gates;
   an attractive timing never compensates for a semantic mismatch.
7. Record the decision and remaining question, update the frontier, and checkpoint
   within the existing user authorization. Revisit strategy after a decisive
   result or several unproductive rounds. New counters or renamed hypotheses
   alone are not progress; stop at the authorized campaign boundary.

## Current compiler fast-method protocol

Use the [Phase61 method recipes](../selfhost/tools/performance/phase61/latency/README.md)
and [P61-004](phase61/P61-004-fast-iteration.md), with the exact consumed method
and image bindings recorded by each run. State04 used frozen `latency-method03`;
state06 uses `latency-method05`, including reviewed stable-input verification
and the selected frame decoder. Earlier versions remain historical inputs, not
interchangeable tools. Complete campaign wall includes changed harness work and
is not a pure compiler-speed comparison across these methods.

- First screen Numeric recurrence and MapSet with one fresh request per role;
  then add active raytrace for two rotated rounds. The 20/60 labels identify
  coverage, not guaranteed deadlines; adding the TS role requires its own budget.
- Keep Lexer and Evening held out, then cover all 23 sources. The reported
  state04 and state06 one-round broad screens are exploratory, not repeated gates.
- Bind actual checked B1 or genuine B2 lineage and private API-keyed preparation.
  Do not fabricate B2 checked metadata. Preparation/cache priming and post-return
  full-byte validation stay outside import/API-load/first-request clocks.
- Root alone runs serial CPU3 jobs under the process-tree resource guard. Keep
  failures, deadlines and skipped rows; complete fresh triples can supplement an
  interrupted queue without relabeling it successful or pooling partial roles.
- Correctness, output identity, compiler latency and emitted-program performance
  remain separate gates. Final source, B2, native/legacy and release checks still
  precede any installed change.

The [tracked October 7 cleanup report](../implementation/phase61/cleanup.md) compacted
49 old raw profiles only, with decompressed-byte hash verification and retained
restoration mappings. Active Phase58–61, Phase6, source/reports and all seven
installed-file hashes were preserved. Restore a profile through that recipe
before replaying a historical reader that expects its original raw path.

## Evidence labels are separate

| Axis | Record explicitly |
| --- | --- |
| Correctness | Unchecked, named selected gates passed, broader gates passed, or counterexample; list their exact scope. |
| Measurement | Not run, valid for a stated workload, inconclusive, or invalid with the reason. |
| Decision | Investigate, defer, reject or promote; state the deployed scope. |

A mathematical proof can establish a universal statement under assumptions.
Compiler tests, timing samples and equal self-emissions establish narrower facts.
A checked fixed point is not a proof of compiler soundness or complete upstream
conformance. A parse failure cannot count as a successful type-check probe;
retain exact verdict, phase, checked flag, diagnostic and output observations.
Keep known reference mismatches visible. Distinguish compiler throughput,
complete developer-loop latency and generated-program execution speed.

Preserve counterexamples, timeouts, OOMs, null results and invalidated samples
with their original status. Corrections supersede an earlier claim without
erasing it. At checkpoints, inventory ignored experiment material. Track small
reproducers, commands, seeds, manifests and informative results; retain large
artifacts durably or give their exact regeneration recipe and prerequisites.
An ignored local path or a checksum alone is not durable preservation: identify
any missing artifact/storage dependency explicitly. Do not change evidence
status merely because its record was archived.
