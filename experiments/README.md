# Compiler experiment workflow

Use this directory to retain what was tried, what the evidence establishes and
what should happen next. The compiler remains implemented in Bend; experiments
must identify changes to compiler source, generated compiler images, host tools
and emitted user programs separately.

## Active implementation: Phase67 native speed and proof pilot

[Design](../design/phase67/native-speed-and-proof.md) ·
[Report](../implementation/phase67/README.md).
Fresh native comparison and general value-transport contraction, a bounded
compilation-speed review, and a small independently checked proof model.
Phase66 remains installed until a surviving candidate passes integration.

## Completed implementation: Phase66 upstream and five metrics

[Design](../design/phase66/upstream-and-five-metrics.md) ·
[Report](../implementation/phase66/README.md) ·
[Experiment](phase66/P66-001-upstream-migration.md).
The migration targets upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
Selected final07 (`f9667c2`) closes all 3,174 frontend comparisons and has no
TypeScript-passing candidate JS failure. Its scoped Node/Bun union has 1,045
distinct golden passes, 123 exemptions, one shared Process.run failure and one
graphics deferral. Genuine B2 checks its own source and reproduces B3 exactly.

Closed 23-source compilation ratios versus new TypeScript are **1.402065× B1**
and **1.321100× B2**; including imports/API loading gives **0.982634×** and
**0.990389×**. All 669 runtime samples over 45 points pass; generated programs
are **1.049282× new TS** with equal-point weighting and **1.046987×** with
equal-source weighting. Speed is essentially retained versus the paired old
Bend outputs. Maintained Bend source is 28,490 physical lines (+0.331% versus
Phase65), with 115 modules; this is not a simplification claim.

Final07 is [installed and verified](../implementation/phase66/evidence/installed-release07.json),
with five release jobs, legacy42/default24/helper5 and selected native/Base
admission complete. The prior Phase65 release remains a preserved historical
baseline. Root sealed the raw tree and the [complete archive](../selfhost/tools/performance/phase66/artifacts/README.md)
passes verification of every member: 119,393 files in five parts, each at most
50 MiB. Prior raw/archive preservation also passes.
Read [STEERING](STEERING.md) for remaining work and the
[report](../implementation/phase66/README.md) for exact receipts and finite
coverage limits. The original experiment registration remains prospective and
unchanged.

## Completed implementation: Phase65 reusable backend products

[Design](../design/phase65/reusable-backend-products.md) ·
[Report](../implementation/phase65/README.md) ·
[Typed facts](phase65/P65-001-typed-backend-products.md) ·
[Base products](phase65/P65-002-base-backend-products.md) ·
[Term reuse](phase65/P65-003-composite-term-reuse.md) ·
[Output metadata](phase65/P65-004-output-metadata.md) ·
[Constructor index](phase65/P65-005-base-constructor-membership.md) ·
[Closure structure](phase65/P65-006-structured-closure-return.md) ·
[Boolean lookup](phase65/P65-008-boolean-lookup.md).
State10 selects optional Bend-produced Base annotations and static JS transport
readers. Its [final broad comparison](../implementation/phase65/evidence/state10-b2-broad.json)
passes 207 exact outputs: compilation **1.41737× → 1.28945× TS (−9.025%)** and
imports plus compilation **1.04969× → 0.969256× (−7.662%)**. All 23 sources improve;
compilation-only parity required about 22.45% less time at that checkpoint.
State10 was installed and verified and is now superseded by Phase66: [compiler qualification](../implementation/phase65/evidence/state10-qualification.json)
and [release checks](../implementation/phase65/evidence/state10-release.json)
pass, including self-reproduction, legacy42/default24 and helper5. Exact Base
content permission preserves custom/future Base fallback. Historical raw trees,
failed methods and rejected candidates remain preserved. The [size audit](../implementation/phase65/size.md)
records +117 Bend lines and +146 host lines; no simplification or generated-
program speed gain is claimed. [Decoder experiment](phase65/P65-007-decoder-tiering.md).

## Completed implementation: Phase64 retained facts and indexed state

[Design](../design/phase64/typed-facts-and-compact-state.md) ·
[Report](../implementation/phase64/README.md) · [Experiment](phase64/P64-001-residual-costs-and-typed-facts.md).
Phase64 State09 was installed and verified and is now superseded by Phase65. Its balanced genuine-B2 comparison
improves compilation **1.64387× → 1.43894× TS** (12.47% less time), and imports
plus first compilation **1.18920× → 1.06173×** (10.72%). All 23 sources improve;
207 output checks, full compiler/runtime/reproduction and installed CLI gates
pass. Generated programs remain byte-identical. Source grows 0.58%; child-type
avoidance was rejected and compact semantic representation deferred. Read the
[final report](../implementation/phase64/state09-results.md) for methods,
limitations and the remaining 30.5% reduction needed for compilation parity.

## Completed implementation: Phase63 ready worlds and lower-once plans

[Design](../design/phase63/ready-world-and-lowering-plan.md) ·
[Report](../implementation/phase63/README.md) · [Hypotheses](phase63/).
Phase63 State09 was installed and verified as checked B1, and is now superseded
by Phase64. Its genuine-B2 balanced
207-worker comparison improves compilation **2.05505× → 1.63275× TS** and combined
import/first compilation **1.40665× → 1.15092×**. All 23 source medians improve
versus the previous compiler; compilation parity remains unfinished. Read the
[final State09 report](../implementation/phase63/state09-results.md) for exact
clocks, selected mechanisms, correctness/release gates and rejected experiments.
The following Phase61 section is historical; its installed identity is superseded.

## Completed investigation: Phase62 remaining compiler costs

[Phase62 results](../implementation/phase62/README.md) explain the remaining
gap on unchanged Phase61 state08 using 23-source CPU/allocation/stage surveys,
same-source B1/B2 comparisons, repeated requests, logical work counters and
synthetic scaling. Compiler code and installed images are unchanged. See
[P62-001](phase62/P62-001-remaining-compiler-cost.md) and the
[design](../design/phase62/compiler-parity-investigation.md).

## Completed campaign: Phase61 architectural compiler speed

[Current results](../implementation/phase61/README.md) ·
[Current frontier](STEERING.md) · [Research map](../implementation/phase61/research-map.md).
State08's [balanced broad campaign](../implementation/phase61/state08-results.md#balanced-broad-compiler-measurements)
passes **207/207 workers across 23 sources**, with three position-balanced rounds
per source/role. Equal-source B2/TS geometric means improve **2.476542× →
1.433877×** for import + API load + first compilation, and **3.816429× →
2.071828×** for compilation alone. All sources improve versus same-campaign
Phase58 B2, but compilation alone remains slower than TS on every source.
Complete raw modules match; there is no new generated-program speed claim.

The clocks use genuine B2 fresh processes with prepared persistent Base caches;
preparation and post-return validation are excluded. They do not measure the
installed checked-B1 CLI or claim cold operating-system caches. Earlier short
confirmation, state06 and state04 campaigns remain separate. The
[historical results matrix](../implementation/phase61/state08-results.md) records
completed checked-B1 logical14, native3, smoke45, B2 own-source type acceptance,
B2/B3 equality, the 96/34/18/2 B2 semantic matrix and 23/45 emission equality.
Installed legacy42, default24 and final identity verification pass. Unsafe proof-trust refusal remains
expected; failed launch/receipt-validation attempts are preserved.

State08 retains private leaf reuse and maximum-bound hoisting on state06.
The backend cursor was reverted; cross-context caching is deferred without a
general proof and binary transport was rejected. **Phase61 state08 was installed
and verified as checked B1 at that checkpoint.** The daemon-interrupted release wrapper stays
incomplete; complete child receipts and the fresh two-step resume bind the
release. Phase58 remains the frozen comparison baseline.

The [final qualification index](../selfhost/build/phase61/final-state08/qualification.json)
binds all selected correctness/release receipts and preserves the failed and
interrupted predecessors. The [timing account](../implementation/phase61/timing-account.md)
separates supervised occupancy from clean request clocks and uncovered wall time.

The [closed Phase61 evidence capsule](../selfhost/tools/performance/phase61/artifacts/README.md)
preserves 17,386 reopened-verified raw files, including failed and interrupted
attempts. Follow its restoration guide before replaying a historical raw path.

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
