# Current frontier: Phase62 investigation complete; Phase61 state08 unchanged

The user authorized investigation of the remaining compiler-speed gap.
[Phase62 report](../implementation/phase62/README.md) ·
[Design](../design/phase62/compiler-parity-investigation.md) ·
[P62-001](phase62/P62-001-remaining-compiler-cost.md) ·
[Closed evidence](../implementation/phase62/artifacts.md).

All 23 inputs have current CPU/allocation/stage evidence and logical work counts.
The four-source same-Bend-source comparison finds B2 uses 12.82% less compile
time than equality-derived B1. Diagnostic arithmetic excess is 510.20 ms:
265.99 ms prepared-state/loading/checking, 241.55 ms backend, 2.65 ms other.
The narrow check boundary is similar in time but includes different Base work.
Repeated ordinary requests narrow B2/TS 2.114→1.380 by the fourth request; no
steady-state plateau is established. Scaling shows higher marginal cost, not
observed quadratic growth. All target outputs/oracles pass. Compiler source,
seven installed files and 110 inherited unrelated files remain unchanged.

Next proposals: admitted immutable Base state for library sessions; one coherent
backend analysis/document with valid dependency/context reuse; signature bundles
as a small first prototype; completion/freshening reconstruction; compact/lazy
prepared state for fresh processes. Narrow arity CPU ancestry is only ~2.3%, so
do not promise parity from that cache. Preserve checking provenance, eager-beta
semantics and context/budget contracts. No optimization is selected or executed
by this investigation, no target remains active, and raw writers are closed.

## Closed Phase61 release baseline

**Phase61 state08 is installed as checked B1 and its CLI is verified.** Direct
JavaScript is the default; explicit legacy JavaScript and native C remain
available. Compiler algorithms execute Bend source, without TypeScript fallback
or a fabricated checked sidecar on B2. The campaign evidence is closed and
published. No PR comments or goal creation are authorized.

[Final qualification](../selfhost/build/phase61/final-state08/qualification.json) ·
[Current results](../implementation/phase61/state08-results.md) ·
[Campaign history](../implementation/phase61/README.md) ·
[Experiment records](phase61/) · [Fast protocol](README.md#current-compiler-fast-method-protocol).

## Completed evidence

The [balanced broad campaign](../implementation/phase61/evidence/state08-broad3.json)
passes 207 workers: 23 sources × three roles × three rounds. Each role occupies
each position once per source; source order remains fixed. Equal-source B2/TS
means improve **2.476542× → 1.433877×** combined-first and **3.816429× →
2.071828×** compilation-only. All 23 sources improve over same-campaign Phase58
B2. State08 compilation alone remains slower than TS on every source. The three
samples per cell describe variation; they do not establish significance or
individual-pass attribution.

These are genuine B2 fresh processes with prepared persistent Base caches.
Preparation and post-return byte checks are outside the clocks. They do not
measure installed checked-B1 CLI latency or cold OS caches. All raw modules
match. Campaign wall is 327.660806 s; no extrapolation is made. Earlier subset
confirmations and state06's one-round broad campaign remain separate.

The [selected qualification](../implementation/phase61/state08-results.md#current-qualification-matrix)
passes checked36, carrier29 + five producer + eight bound cases, leaf14,
logical14 checked-B1 qualification, native3 and smoke45. Genuine B2 passes
construction/driver8, fresh own-source type acceptance, exact B2/B3 reproduction,
96 source/34 numeric/18 composition/two overapplication observations, and 23 raw
modules/45-point emission equality. The 3,192 unsafe declarations retain their
expected trust refusal; `kernelChecked:false` remains explicit.

[Release admission](../selfhost/build/phase61/final-state08/release-admission.json),
installed legacy42, default24 and before/after identity verification pass. The
original permission/identity-validator failures stay failed. The daemon restart
left the original outer release receipt incomplete after a healthy legacy42
child; the [fresh two-command resume](../selfhost/build/phase61/final-state08/release-resume02-execution/report.json)
passes separately. Successful children do not relabel their failed or incomplete
parents.

[Final preservation](../selfhost/build/phase61/preservation-final.json) verifies
seven selected installed files, exact preserved copies of the prior release,
32,973 closed Phase58–60 files and 103 protected files. No compiler target remains
required. The [completed timing account](../implementation/phase61/timing-account.md)
records 58.577315 min observed supervised occupancy in the 7 h 47 min target-work
window; uncovered time is not waiting. The [closed evidence capsule](../selfhost/tools/performance/phase61/artifacts/README.md)
preserves 17,386 raw files (882,650,258 uncompressed bytes); reopening/member and
input-stability verification pass. All raw writers are closed. Archive publication
is separate from semantic qualification and speed measurements.

## Selected source and remaining opportunities

State08 is state06 plus private childless-term reuse and maximum-bound hoisting.
State07's backend telescope cursor was reverted after mixed B1 results, with no
isolated or B2 attribution. Canonical frame2 helper `cdd71b72…` is bound to the
selected images. The [request guide](../docs/self_hosted/compiler-request-pipeline.md)
explains prepared Base state, persistent indexes, delayed substitution,
export-local facts and structured emission with their fallback boundaries.

The [remaining practical opportunities](../implementation/phase61/state08-results.md#result-and-remaining-practical-opportunities)
are proposals, not selected source changes. A body-only Base patch model removes
9.69% of one saved frame's bytes but has no measured request gain. Larger
substitution reuse still needs eager-beta/order proofs. The 23-input emission
reuse diagnostic does not establish a general safe context key. Binary decode
plus required validation was 2.260389× JSON and is rejected. Do not restart those
ideas without a new falsifier and whole-request evidence.

Structured output must preserve demand, reference order, SCC behavior and
bounded refusals. Native facts require canonical proofs; prefix carriers require
authenticated leading injection. Identity-bound parsed data alone is not a
checked-world proof. Invalid optional state retains full checking.

## Installed identity and historical comparisons

Attempt: `selfhost/build/phase61/checked-state08`.
B1 API: `97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8`.
Source: `268b3cf2e1f1c2810c372925ccd1ad7eb91225853d432ca9517f05f2ecefd42e`.
B2/B3: `23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477`.
Upstream `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
The package is checked B1; genuine B2 has 86 roots and 3,978,248 bytes.
[Source footprint](../implementation/phase61/source-footprint.md) separates Bend,
runtime/host support and research tooling.

Phase58 generated-program qualification passed 23 sources/45 points/669 samples,
new/old equal-point ratio 0.985287 with no point >10% regression. This historical
speed evidence transfers only to identical program/runtime artifacts. State08's
exact emitted-byte checks and current 45-point correctness smoke do not create
a fresh 669-sample timing result or new generated-program speed gain.

The [closed Phase60 survey](../implementation/phase60/README.md) measured combined
first B2/TS 2.461297× on its own baseline. Its sampled stage shares, 46 CPU count
views, eight refused weighted views and 138,000 unknown TS allocation bytes remain
historical motivation, with the original reader failure retained. TS also checks
Base: source-only omission was never justified.

## Working limits and preservation

Any future heavy jobs remain serial on CPU3 under one process-tree guard: 1 GiB
Node heap, 2 GiB tree RSS and 4 GiB available-memory floor unless root records a
justified successor. Data/source work uses CPU0. Preserve the 103 unrelated
files, selected and prior installed artifacts, closed evidence, consumed tools
and every rejected attempt. Stage explicit owned paths only.

The [October 7 cleanup](../implementation/phase61/cleanup.md) compacted 49 old
profiles with verified restoration mappings; active Phase58–61 and Phase6 were
preserved. Restore historical raw profiles before replay. The campaign is closed;
no new cache, codec or backend-cursor experiment is selected.
