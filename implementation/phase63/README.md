# Phase63: ready worlds and a reusable lowering plan

Work started2026-10-07 at20:04:24UTC from commit5cb1afc. The user authorized
implementation toward TypeScript compilation parity. State05 has measured
prototype gains; no Phase63 release is selected yet. Phase61 state08 remains installed.

[Design](../../design/phase63/ready-world-and-lowering-plan.md) ·
[World experiment](../../experiments/phase63/P63-001-ready-semantic-world.md) ·
[Transport](../../experiments/phase63/P63-002-sharing-transport.md) ·
[Lowering](../../experiments/phase63/P63-003-lower-once.md).

Six agents own source/data work; root alone executes guarded serial CPU3 targets.
Root reviews and freezes integration states, preserves failures, and reports
separate correctness, timing and promotion decisions. Current architecture notes:
[Base world](base-world.md), [frontend](frontend.md),
[backend plan](backend-plan.md). These are prototype descriptions, not results.

## Early discriminating evidence

The [transport probe](../../selfhost/build/phase63/codec01/report.json) passes
exact decoded values and11 malformed/sharing controls. Existing Base+old prefix
data shrinks5,667,458→1,145,743 bytes. Five alternating in-process rounds give
median parse/decode+validation105.53→29.50ms (0.2795 ratio). The graph sample
excludes outer-frame hashing/header dispatch and does not yet carry the new
ready world. This is a transport result, not end-to-end compiler speed.
Preparation encoding is recorded separately. Guarded occupancy1.61s, peak253MB.

The first baseline preparation correctly refused a changing workflow helper;
its failed receipt is retained. The source-frozen retry passes and the four-worker
Numeric/Map baseline screen reproduces the earlier scale: B2 compilation491ms
and1,567ms versus TS326ms and645ms. These single-round figures are only a
baseline sanity check. The complete candidate comparison is still pending.

Checked build states01–03 fail early during bootstrap parsing: nested binder
matches and then a computed match scrutinee violate Bend's required parameter
matching form. Their snapshots/logs remain intact; correction uses small helper
functions with unchanged algorithms. No failed compiler is measured or promoted.

## State05 checkpoint

State05 is the first qualified prototype, not yet an installed release. It keeps
an authenticated Base world and parser indexes, transports them as a shared
validated graph, and saves rendered reachable definitions in one lowering plan.
The compiler algorithms remain in Bend. Four early source snapshots were rejected
by bootstrap parsing; none contributed a timing result.

Checked build36, ready-world33 plus producer/bound controls, frontend16 sources
plus producer/order controls, reach22+21, cache admission28, and exact94-export
admission pass. Six valid backend-context fixtures agree across45 runtime
observations. Genuine B2 construction and its driver checks pass. All23 maintained
benchmark modules still match the previous selected compiler byte for byte.
Fresh self-host reproduction and full release qualification remain pending.

The short clean screens use one fresh process per cell, prepared persistent Base
caches, and exact output checks outside the clocks. They are screening evidence,
not the balanced23-source headline or OS-cold measurements. TS means the pinned
Bend TypeScript compiler. B1 and B2 campaigns must not be pooled.

| Image / input | Previous compilation ms | State05 ms | TS ms |
| --- | ---: | ---: | ---: |
| Checked B1 / Numeric | 539.51 | 448.15 | 320.47 |
| Checked B1 / MapSet | 2157.50 | 1783.85 | 638.74 |
| Genuine B2 / Numeric | 476.04 | 408.02 | 320.44 |
| Genuine B2 / MapSet | 1544.67 | 1353.51 | 630.73 |

B2 combined import/API plus first compilation is505.07ms versus TS580.25ms for
Numeric, and1451.68ms versus894.11ms for MapSet. Compilation alone remains slower.
Raw screens: `selfhost/build/phase63/state05-b1-latency/screen/report.json` and
`state05-b2-latency/screen/report.json`. The preceding release's balanced broad
baseline remains2.071828× compilation and1.433877× combined first request.

Stage probes confirm the new paths actually execute. They also disprove a tempting
hypothesis: actual selected B1 and B2 use named-layout APIs and perform zero
positional ABI encodings, so the proposed owned-ABI patch is not selected.
The generic graph decoder regresses fresh-process cache time (~153→179ms), despite
its warm microbenchmark improvement. Shared data and warm throughput do not alone
prove a faster first request. The new world and loader save enough elsewhere to
make the complete prototype faster.

A diagnostic host-only experiment holds the B2 image, driver, Base, runtime and
cache bytes fixed. Specialized validated constructor decoding improves Numeric
417.73→337.21ms and MapSet1337.22→1231.98ms in its own one-round screen. Exact output
checks pass. This variant is not production-qualified; compatibility controls and
balanced confirmation precede selection. A different literal-shapes-only campaign
showed smaller improvements and is retained separately.

Profiles show repeated host-wrapper field conversion and repeated reconstruction
of checker-known application types as remaining backend opportunities. These are
new experiments, not measured gains. Failed changing-input preparation, mistyped
fixture path, overstrict frontend controllers and an invalid ordinary recursion
fixture remain failed; corrected successor controls have separate receipts.

State05 source SHA256: `d9855a5ac29a1602c7e49a42aace17646c89f36ee3dc4510c1203259b4637e07`.
Checked B1 API: `d8d0c45a14fd143a4eafa447ad70d961cfe95e03c96caf7c7212073461a8a4ed`.
Genuine B2: `9b5d260b08e015cd1c2911a6ef0b880130978a3933416db704731f9028dc8cc2`.
The seven installed artifacts remain the previous release.

State05 architecture checkpoint pushed as `79c3e5f`. Decoder V2 confirmation
passes eight workers: mean Numeric ratio0.7613 and MapSet0.8549 against the same
State05 image with the generic decoder. The V2 differential gate passes206 valid
and1331 malformed cases. State06 now integrates it with shared host field
conversion; source checking and subsequent measurements are pending.

## State06 checked candidate

State06 integrates decoder V2 and a44-line Bend host-field plan that computes each
constructor's converter once, reusing it for tail selection and output. Strict
checked36 and94-root admission pass. A clean single-round checked-B1 screen passes
all six output checks: Numeric543.02→374.93ms (TS323.86), MapSet2291.32→1511.50ms
(TS641.26). These are compilation-only values within this campaign; no B2 speed
or full release claim follows. Build58.49s; peak supervised RSS1.61GB.

Raw evidence: `selfhost/build/phase63/checked-state06/attempt.json`,
`state06-b1-latency/screen/report.json`. State07 tests the separately registered
checker-annotation reuse hypothesis on top of State06. Unused positional-ABI
patches remain rejected for this named-layout B1 **and B2** configuration.

Root starts State06's frozen B2 construction before its full final checked matrix
so the next performance decision uses a genuine self-hosted image. The generated
plan's generic checked-first barrier is intentionally reordered for this
measurement-only step: checked36, exact export admission and the initial output
screens already pass; installation is still blocked on all final semantic gates.
No pending checked/fresh-source/reproduction gate is treated as passed.

## Current second-stage result and negative experiments

State06 genuine B2 construction/driver checks pass. A three-round, rotated-role
Numeric/Map screen passes18 workers and all exact raw-output checks. Median
compilation: Numeric478.65→360.15ms, with TS322.69ms; Map1543.27→1232.37ms, with
TS629.48ms. Median combined first request: Numeric585.96→457.46ms versus TS586.08;
Map1650.92→1330.49ms versus TS890.68. Compilation and combined latency give
different comparisons; this is still only a two-source screen. Broad23×3 is
running separately. Raw: `state06-b2-latency/screen-balanced/report.json`.

State07 annotation reuse passes389 exact internal argument comparisons and full
module equality with its fallback, but no clear whole-request improvement.
Its49-line source change is restored to State06; the isolated patch and counts
are retained. The frontend suffix-carry simplification is also only a proposal.

The first full checked matrix preserves a failed composition receipt: both TS
and candidate child observations agree, but `spawnSync ... EPERM` makes all18
unhealthy. It is not a semantic pass. A fresh permission-correct retry is planned,
reusing the already qualified B2 image without relabelling the failed parent.

Exact-identity query hooks are diagnostic only. Initial Map arity caching has
523/756 hits, avoids8,075 WNF entries and reduces its single diagnostic request
1443→1331ms. General WNF caching saves less; combining it adds no clear benefit.
The original Numeric baseline prepared the cache and is invalid for timing
comparison. A successor requires a preexisting, unchanged frame. Production
compiler algorithms remain Bend; no JavaScript memo hook is selected.
