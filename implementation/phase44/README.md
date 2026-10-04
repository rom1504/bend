# Phase44: composable JavaScript backend

Phase44 introduces a typed JavaScript IR with separate lowering, lexical facts,
simplification and expression/statement emission. Checked04 is selected and
installed; release verification and all 42 ordinary/relocated CLI checks pass. The [design](../../design/phase44/README.md) and
[IR guide](../../selfhost/docs/JAVASCRIPT_IR.md) describe the implementation.

The full 45-point benchmark passes all 669 samples. Execution is effectively
flat: **6.1214× → 6.0832× pinned TypeScript time**, comparing freshly sampled
Phase43 and Phase44. The general transformations establish a shared optimization
base but do not deliver a broad runtime improvement. A separate known-call
prototype also fails its screen and is rejected. Map compiler request time falls
15.61%; three other request probes cost 2.81–3.57% more. Source grows 1.74%.

The migration is deliberately bounded: ordinary expressions use the new IR,
while private layouts and guarded call plans retain explicit compatibility nodes.
No PR comment is posted.

## Controlled architecture baseline

The first frozen compiler, `selfhost/build/phase44/checked01`, builds in 45.15s
under the serial CPU3/1GiB Node heap/2GiB process-tree policy. It routes ordinary
applications, lambdas, matches and parallel bindings through typed runtime IR.
Seven previous KTerm-to-text helpers were retired. This first snapshot does not
activate simplification or statement emission.

All 45 maintained benchmark points (23 sources) have **byte-identical emitted
modules** to the frozen Phase43 release. This is artifact-specific equivalence,
not a proof for arbitrary programs. Acquisition took 153.73s and is excluded
from execution timing. The independently authored composition fixture also has
identical output. Its 35 shared scalar oracles agree with pinned TypeScript;
11 public-runtime boundary controls and 26 higher-order observations pass
against the preceding Bend compiler. Existing synthetic backend tests pass all
15 cases, including 14 emission byte comparisons, and the new lexical-scope
controls pass against this unoptimized snapshot.

## General transformations

The next snapshot makes ordinary construction, compact literals, proven primitive
operations and Boolean choices explicit. Independent passes perform bounded copy
propagation, exact identity-binding elimination and nine safe literal-only U32
folds. Statement emission removes return-position binding/branch IIFEs while
preserving parallel RHS scope, delay, erasure and tail-message demand.

Repeated instance-body rewriting and one identical planner proof are shared.
Literal admission uses semantic provenance rather than rendered text where
possible. No new workload-family recognizer or public runtime relaxation is used.

The selected-image measurements and qualification are recorded below. These
source transformations do not by themselves establish an execution improvement.

## Focused optimized snapshot

`checked03` builds and passes the strict focused workflow in 46.05s, peak
process-tree RSS 1,390,063,616 bytes. All 37 IR functional controls pass,
including actual statement and nine-operation constant-fold activation. The
optimized composition fixture passes the 35 scalar oracles, 11 boundary and
26 higher-order observations, plus four delayed mixed-feature points. The
15 maintained basic backend execution cases also pass. The final selected image is checked04, qualified below.

`checked02` is a retained failed bootstrap (4.11s): constructing the original
primitive node before matching its operand violated the source language's binder
rule. Passing it to a fresh-parameter helper fixes the source; no admission or
semantic rule changed.

## Selected architecture and complexity

The selected candidate is **checked04**, API
`0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea`.
Its JavaScript runtime is unchanged. The build takes 45.86s under the stated
resource policy, with peak process-tree RSS 1,397,559,296 bytes. Build time is an
acquisition observation, not a controlled compiler-throughput comparison.

| Maintained compiler metric | Phase43 | Phase44 checked04 |
| --- | ---: | ---: |
| Physical Bend lines | 21,440 | 21,813 |
| Nonblank, noncomment Bend lines | 17,770 | 18,025 |
| Definitions | 2,413 | 2,452 |
| Source modules | 70 | 78 |
| Checked API bytes | 1,460,868 | 1,487,170 |

Eight small IR modules contain 524 physical lines, 52 definitions and 16 operation
kinds. Existing modules shrink by 151 lines; 15 obsolete helpers are removed.
The net source increase is 373 lines (1.74%), and the API grows 1.80%. These are
size proxies, not a numerical measure of conceptual complexity. The useful
architectural change is that ordinary runtime operations now have explicit
contracts and one pass schedule. The [IR guide](../../selfhost/docs/JAVASCRIPT_IR.md)
documents those contracts and extension points.

The first migration preserves all 45 prepared modules byte-for-byte. The later
cleanup also preserves all 45 modules from optimized checked03 to checked04.
The optimized candidate changes 41 points across 21 sources relative to Phase43;
the full corpus contains 45 points and 23 sources. Emitted module size grows
0.133% geometrically with point weighting, or 0.149% with equal source weighting.
Static changes and marker counts are not evidence of hot-path execution.

This is a partial migration. The dependent checker still owns `KTerm`. Private
layouts, compressed constructors and deep closure factories retain `JIRLegacy`;
guarded call selection retains `JIRCallPlan` and still reads source facts during
emission. The simplifier treats their hidden uses/effects conservatively. There
is no new general ownership or effect analysis, SSA graph, closed-world ABI or
unguarded direct-call convention in this release.

## Final selected-image qualification

Checked04 freshly agrees on all 81 retained backend observations: 69 execution
passes, eight not-applicable results and four unchanged shared check failures.
This took 254.47s enclosing wall time, peak process-tree RSS 632,016,896 bytes.
Exact agreement and fixture success remain separate counts.

The fresh main frontend gate agrees on all 3,026 observations, with the same four
shared failures. It takes 774.99s enclosing wall time using one worker, peak
process-tree RSS 664,842,240 bytes. The broader gate agrees on all 196 observations
in 38.21s. Its peak process-tree RSS is 730,861,568 bytes.
Only the pinned, identity-verified TypeScript reference is reused; checked04's
candidate observations are fresh.

All eight maintained semantic suites pass in 13.48s: the 37-control IR suite,
15-case basic backend suite, global initializer observations, Boolean choices,
matcher arms, primitive guards, constructor provenance and foreign boundaries.
The guard suite retains 1,129 admission assertions and 25 operand/order/ABI
observations. Ten user constructors deliberately named like primitive
constructors retain their own fields. Foreign controls retain effects, erased
callbacks and deep marshaling behavior. These tests exercise the actual selected
compiler; no test-only public compiler exports were introduced.

Two launcher failures are retained. The first assumed a host test helper was
included in the frozen snapshot; it now pins the current helper and verifies its
implementation dependencies against the snapshot. The second set a marker
expectation for the unselected historical exact-arm optimization. All 72 ordinary
and 22 exact-arm behavioral observations passed before that marker assertion;
both Phase43 and checked04 have zero such markers. The corrected launcher uses
the maintained test's default expectation and retains its behavioral assertions.
Neither failure is relabeled as a passing run.

The final checked04 composition fixture is freshly acquired in 6.14s and passes
35 shared scalar oracles, four mixed-feature cases, 11 boundary observations and
26 higher-order observations. Renamed helpers and arbitrary Cargo/Envelope data
types exercise combinations outside the maintained performance sources. This is
an independently authored correctness control, not an untouched performance
holdout or evidence of typical application speed.

## Controlled compiler-request costs

All 36 fresh requests produce their exact independently acquired output. Three
rotated processes per role and source compare normal checked-library requests
from Phase43, checked04 and pinned TypeScript. The [complete cost report](compiler-cost.md)
separates request, host import and process time and retains every sample.

| Source | Phase43 request median | Checked04 request median | Change |
| --- | ---: | ---: | ---: |
| Local pair | 2,104.90 ms | 2,175.49 ms | +3.35% |
| Lexer | 3,396.08 ms | 3,517.26 ms | +3.57% |
| Map churn | 8,933.89 ms | 7,538.97 ms | −15.61% |
| Closures | 1,446.04 ms | 1,486.65 ms | +2.81% |

The Map reduction is useful, while the other three regressions remain explicit.
These combined changes do not isolate the planner reuse causally or establish a
general compiler-throughput gain. Checked04 requests still cost 4.78–17.00 times
TypeScript request time on these four probes. Generated-program execution is a
separate measurement.

## Initial execution screen

The six-point, 60-second preset completes 54 fresh role samples in 46.15s.
The table compares fresh Phase43 and checked04 execution in that same run.

| Point | Phase43 / TS | Checked04 / TS | Phase43 / checked04 |
| --- | ---: | ---: | ---: |
| Lexer | 7.699 | 7.769 | 0.991 |
| Map churn 128 | 28.191 | 28.147 | 1.002 |
| BST 64 | 2.366 | 2.365 | 1.000 |
| List pipeline 512 | 0.535 | 0.539 | 0.991 |
| Record aggregation 256 | 80.472 | 80.515 | 0.999 |
| Closures 256 | 0.424 | 0.443 | 0.956 |

The geometric baseline/candidate ratio is 0.98978. This is **flat**, and establishes
no generated-program speedup. It does not justify adding more similar passes on
the assumption that textual simplification makes execution faster. V8 may
already remove much of the changed binding/IIFE overhead; that explanation is an
inference and has not been isolated causally.

The [known-call experiment](known-call-dispatch.md) tested stable invocation
targets against this exact checked04 compiler. It changes 1,465 static sites
across 24 module artifacts, preserves the existing runtime checks, and remains an
unchecked saved-JavaScript derivative. A fresh 54-sample screen completes in
46.17s with checked04/prototype ratio 0.991918. Five medians regress, one improves;
the broad-gain criterion is not met. **The prototype is rejected for production.**
This is a negative result for that implementation, not evidence that every form
of devirtualization is ineffective. The final corpus result below retains this negative result.


## Full generated-program execution

The [complete results](results.md) contain all 45 points, 23 sources and 669 fresh
role samples, acquired in three serial batches in 19.16 minutes. Both Bend
versions use the same pinned TypeScript modules and timing protocol. No profiles
or builds overlap these clean execution samples.

| Weighting | Phase43 / TypeScript | Phase44 / TypeScript | Phase43 / Phase44 |
| --- | ---: | ---: | ---: |
| Equal point | 6.121411 | 6.083199 | 1.006281 |
| Equal source | 8.364874 | 8.301479 | 1.007637 |
| Equal family | 8.474624 | 8.433978 | 1.004819 |

Twenty point medians improve and 25 regress; two candidate points beat
TypeScript. No point regresses by 5% or more, but these descriptive comparisons
do not establish significance. The clearest time reductions are 5.7–8.9% on two
raytrace points and 8.3–9.8% on Unicode text points. Overall performance is flat.
This maintained regression corpus informed optimization and is not an untouched
holdout or an estimate of the typical Bend application.

Separate [diagnostics](diagnostics.md) compare emitted JavaScript, CPU profiles
and sampled allocation for Map, BST and record aggregation. Profiling is outside
the clean timing runs. Static site counts and sampled stacks do not establish
causal speedup or prove that every generated worker executes.

## What this changes for future optimization

The old ordinary expression emitter mixed source inspection, legality decisions
and printing. The new modules let one local transformation apply to every
matching runtime operation while sharing erasure, demand and lexical-scope
contracts. Independent composition tests exercise the interactions, including
renamed helpers and data types. Fifteen superseded helpers are gone.

The measured gap remains in the execution representation. Binding cleanup alone
is insufficient, and inserting another guarded call helper is not an effective
replacement. The next architectural step is to lower call plans and private
adapters into explicit runtime operations, so one conservative effect/escape and
call-target analysis can govern direct calls, scalar values and allocation
removal. It must preserve public mutation, partial application and fallback.
This is remaining work, not a delivered general ownership analysis.

For that work, use the [portable short loop](../../selfhost/tools/performance/phase44/README.md)
and mixed-feature correctness controls first. Require evidence that the costly
operation is executed and removed across unrelated sources before paying for
another full corpus run. Retain rejected experiments and compiler-request cost
alongside runtime gains.


## Installed release and evidence

The normal release installer selects checked04; `release.mjs --verify` passes.
All 42 ordinary and relocated CLI checks pass in 44.06 seconds enclosing wall
time, with peak process-tree RSS 614,563,840 bytes. The installed API hash is the
checked04 hash recorded above; the JavaScript runtime is unchanged. This is a
checked B1 derivative, not a new self-emitted fixed point.

The selected-image closure rehashes the actual compiler tuple and gate inputs,
with 8,446 assertions over 3,095 input files. It binds 90 maintained source/runtime
files; the installed manifest separately verifies its 134 checkout files. These
counts have different scopes and are not added together. The closure includes
this phase's named suites and observed conformance; it does not claim to rerun
Phase43's 34 mechanism-owner or 41-group composite postinstall campaign.

The [evidence index](../../selfhost/tools/performance/phase44/evidence/selected-release.json)
identifies the selected qualification, installed release, compiler costs, full
timing and closed raw archive. Failed attempts and the rejected JavaScript
prototype are retained. The [time and source accounting](accounting.md) separates
job time from the mixed coding, review and documentation intervals. All 103
unrelated starting files are protected from this phase's commits.


Raw writers are closed. The streamed archive contains 23,611 files and
276,375,685 uncompressed bytes in 48,721,950 compressed bytes. Every member was
reopened and hash-checked, and the original inputs were rechecked for stability.
The selected portable bundle covers all 45 points; the full timing comparison
already ran from that portable bundle. Archive/source preservation is separate
from the finite semantic and performance qualification above.
