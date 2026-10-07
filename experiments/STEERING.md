# Current frontier: Phase61 architectural compiler speed

**Installed Phase58 last01 remains unchanged.** Direct JavaScript is the default;
explicit legacy JavaScript and native C remain available. Compiler algorithms
execute Bend source, without TypeScript fallback or a fabricated checked sidecar
on B2. Root owns source integration, target scheduling and promotion. No PR
comments or goal creation are authorized.

[Current results](../implementation/phase61/README.md) ·
[Experiment records](phase61/) · [Fast protocol](README.md#current-compiler-fast-method-protocol) ·
[Research map](../implementation/phase61/research-map.md).

## Current evidence and next gates

State06 is the latest measured broad candidate. Its checked B1/36 strict probes,
native host-fact controls18, carrier controls29 + five producer cases, six-step
86-root bootstrap and eight-driver comparison pass. B2 is 3,977,511 bytes,
SHA256 `f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`.
Full construction took 71.729 internal seconds /71.952 supervised seconds;
source checking was inherited, not a fresh B2 self-check or fixed point.

Its [screen45](../selfhost/build/phase61/state06-b2-latency01/screen45/report.json)
passes 6/6 workers. The separate
[confirm90](../selfhost/build/phase61/state06-b2-latency01/confirm90/report.json)
passes 18/18 over Numeric recurrence, MapSet and active raytrace, two rounds and
no later requests. Equal-source median combined-first ratios are **0.569145×
baseline** and **1.468267× TS**; compilation-only ratios are **0.532443× baseline**
and **2.030508× TS**. Pilot/confirmation are separate; all three inputs remain
slower than TS. Preparation/output validation are outside clean clocks.

The [state06 broad180 screen](../selfhost/build/phase61/state06-b2-latency01/broad180/report.json)
passes 69/69 workers, all 23 sources × three roles × one fixed-order round, with
no later requests. Equal-source B2/TS means improve **2.468310× → 1.432999×**
combined and **3.802103× → 2.098952×** compilation-only. All 23 raw modules match
qualified references; no generated workloads were rerun. Campaign wall is
108.100775 seconds, with no new extrapolation. No within-cell spread or balanced
position estimate is available. Earlier confirmation and state04's broad screen
remain separate; the original state04 deadline remains failed. These combined
candidate measurements do not isolate each mechanism's contribution.

State06 uses frozen method05; state04 used method03. Changed untimed verification
work affects campaign wall, so do not attribute the whole wall reduction to
compiler speed. Final broad semantics, self-check/reproduction, emitted-program
preservation and release remain required. No installed change is admitted here.

## Ranked work at this checkpoint

1. Investigate repeated JDText emission/metadata work with a bounded source
   census and falsifiable general proposal. Preserve exact rendered bytes,
   reference/use order, demand, SCC behavior and resource refusals; no gain is
   inferred from duplicate code or text counts alone.
2. Finish selected final-source semantic/B2 self-check/reproduction and broad
   preservation gates. State06's focused controls and six-command bootstrap
   already pass. New source/helper changes require fresh bound lineage rather
   than silently reusing the pilot's qualification.
3. Close native/legacy/generated-program-performance and release gates. Root
   schedules targets. Keep failed builds/timeouts and prior methods unchanged;
   the completed one-round compiler screen is not final release admission.

The hypotheses remain [P61-001 checked frontend state](phase61/P61-001-shared-frontend-state.md),
[P61-002 owned contexts](phase61/P61-002-compact-owned-contexts.md),
[P61-003 structured emission](phase61/P61-003-structured-emission.md), and
[P61-004 fast iteration](phase61/P61-004-fast-iteration.md).
New records are [P61-005 native host type facts](phase61/P61-005-native-host-type-facts.md),
[P61-006 private prefix provenance](phase61/P61-006-private-prefix-provenance.md),
and [P61-007 segmented JSON transport](phase61/P61-007-segmented-json-transport.md).
P61-007 is retrospectively indexed. Profile shares motivate these tests; they
are neither clean gains nor additive removable fractions.

Structured output must preserve demand, reference order, SCC behavior and
bounded refusals. Native facts require actual canonical proofs; prefix carriers
require authenticated leading injection. Parsed or identity-bound cached data
alone is not a checked-world proof. Invalid optional state retains full checking.

## Installed baseline and historical context

Attempt: `selfhost/build/phase58/checked-last01`.
B1 API: `641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Source: `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
B2/B3: `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Upstream `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
Source acceptance, unsafe trust refusal and fixed point remain distinct from
kernel validity. Known TS NaN oracle defects do not waive a new mismatch.

Phase58 generated-program qualification passed 23 sources / 45 points / 669
samples, new/old equal-point ratio 0.985287 with no point >10% regression. It is
separate from compiler-request latency and has not been replaced by this screen.

The [closed Phase60 survey](../implementation/phase60/README.md) measured combined
first B2/TS 2.461297× on its own baseline run; do not mix it with fresh state04's
2.436× baseline. Checking/completion dominated 22/23 inputs; index allocation
recurred on 23/23, substitution on 22/23 and String on 18/23 at the descriptive
5% threshold. TS also checks Base: source-only omission was never justified.
Its 46 CPU count views, eight refused weighted views and 138,000 unknown TS
allocation bytes remain preserved with the original reader failure.

## Working limits and preservation

Run heavy jobs serially on CPU3 under one process-tree guard: 1 GiB Node heap,
2 GiB tree RSS and 4 GiB available-memory floor unless root records a justified
successor. Keep data/source work on CPU0 and away from clean timing interference.
The Numeric/MapSet screen and active-raytrace confirmation remain cheap rejection
loops, not substitutes for broad acceptance or guaranteed 20/60-second durations.

Preserve all 103 unrelated files, installed artifacts, closed evidence, consumed
tools and rejected attempts. All new raw belongs to Phase61. The
[October 7 cleanup](../implementation/phase61/cleanup.md) compacted 49 old
profiles with verified restoration mappings; active Phase58–61, Phase6 and all
seven installed-file hashes were preserved. Restore historical raw profiles
before replay. Stage only explicit owned paths; installation waits for root's
completed qualification and release decision.
