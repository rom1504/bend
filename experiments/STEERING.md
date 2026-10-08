# Current frontier: Phase66 upstream migration

The user authorized updating to upstream while protecting five metrics:
compiled-program execution speed, B1 compilation speed, B2 compilation speed,
conformance and simplicity. [Design](../design/phase66/upstream-and-five-metrics.md) ·
[Report](../implementation/phase66/README.md) ·
[Experiment](phase66/P66-001-upstream-migration.md).

## Frozen endpoints

Start: `ef7c657` on 2026-10-08 at 05:02:20 UTC. Phase65 release files are
preserved as a historical baseline; they do not qualify the migrated checkout. Old upstream is
`018751270e800bc222a93dad7f257083ee53a5f7`; new target is
`059266225b77c8ca256ac6b25ee5c21449bab151` (95 intervening commits).
The target has its own `.bootstrap/upstream-phase66` checkout. Historical
references and Phase65-and-earlier raw evidence stay unchanged.

Old checked B1 is `3a7fedb77003aecc797cd9a9ac4c6d1bd15bd21dd1230806b6719565eca10f72`;
old genuine B2 is `239f79702c13339d1044e7fe497c4946299d36ce2d7b5eb7850d0d43514a8fae`.
Phase65's 1.28945× compilation and 0.969256× import-inclusive ratios apply only
to that B2 and its old TypeScript reference. They are not measurements against
new upstream. [Previous results](../implementation/phase65/state10-results.md).

## Selected07 installed frontier

Source freeze: `f9667c2`. Selected checked B1 is `bb6c6e2a…`, raw checked B1
`ee717187…`, assembled source `1b29d5c4…`, and genuine B2 `0067736c…`.
Final07 is [installed and verified](../implementation/phase66/evidence/installed-release07.json).
No TypeScript fallback or host migration of compiler algorithms was introduced.

| Axis | Closed evidence | Remaining boundary |
| --- | --- | --- |
| Program runtime | 669/669 samples, 45 points/23 sources; 1.049282× new TS with equal-point and 1.046987× with equal-source weighting; exact B1/B2 emitted-byte mapping | Finite corpus; Mandelbrot/raytrace source gaps are 1.337×–1.619×, all other sources ≤1.090× |
| B1 latency | 207 exact-output workers/23 sources; 1.402065× new TS compilation, 0.982634× including imports/API loading | Keep this prepared fresh-process scope distinct from CLI/runtime |
| B2 latency | 207 exact-output workers/23 sources; 1.321100× new TS compilation, 0.990389× including imports/API loading | Same explicit clock boundaries; earlier04 timing remains historical |
| Conformance | 3,174 frontend observations exact; 1,045 distinct Node/Bun golden passes; no TS-pass/Bend-fail gap; B2 own-source/reproduction and all four final Base gates pass | 123 exemptions, shared Process.run failure, graphics deferral; 13 native methods unsupported; selected native/Base and release joins pass |
| Simplicity | 28,490 physical/23,353 code Bend lines; 115 modules; 313 frozen/live source pairs match | +94 physical lines versus Phase65; host/runtime costs are separate, not a concept-reduction claim |

Full identities, denominators and scopes are in the
[phase report](../implementation/phase66/README.md),
[conformance summary](../implementation/phase66/evidence/conformance-final07.json),
[measurement report](../implementation/phase66/measurement.md) and
[size audit](../implementation/phase66/simplicity.md).

## Remaining work in order

1. Commit and push the closed release, report and [verified archive](../selfhost/tools/performance/phase66/artifacts/README.md);
   do not post a PR comment. All 119,393 raw files and 22,049 directories are
   captured in five parts of at most 50 MiB; every member was verified. Prior
   Phase65 raw/archive bytes and the inherited/installed/baseline copies also
   pass preservation. Raw writers remain closed. Release-target time ends at
   08:32:27 UTC (3 h 30 min 7 s); archive completion at 08:46:39 adds a separate
   14 min 12 s documentation/publication interval, excluding later commit/push.
2. For the next authorized experiment, start with a short controlled screen of
   repeated compilation work in Map/set operations, the largest relative
   compilation gap. Keep B1/B2 roles and startup/compilation clocks separate.
   If generated-program speed is the priority, profile the measured
   Mandelbrot/raytrace tail before changing emission. Retain finite conformance
   exceptions and source-size costs explicitly in either direction.

Root explicitly authorized the actual final seal after all owners acknowledged
closure; earlier draft skeletons remain non-authorizing history. Old04/05 results,
failed06, full target outputs and captured Bun remain preserved in the archive.
Historical and Phase66 raw trees stay closed.

## Gates and resource policy

No performance success compensates for a semantic mismatch. Do not treat changed
expected output as a regression when upstream deliberately changes a contract;
identify and test that change explicitly. Cache invalidation must retain ordinary
fallback. Requalify optional Base products before permitting new Base content.

One root-owned CPU3 compiler target at a time, with one guard: 1 GiB Node heap,
4 MiB stack, 2 GiB process-tree RSS and 4 GiB available-memory floor. Agents own
separate source/data/review lanes on CPU0. Phase66 raw is now immutable; a future
authorized campaign must use a fresh raw directory.
Use frozen snapshots, fresh output paths, focused screens before broad gates,
and separate time accounting. Preserve failures and rejected attempts.
