# Active frontier: Phase70 installed observers and broader native coverage

[Design](../design/phase70/observers-and-compilation.md) ·
[Report](../implementation/phase70/README.md) ·
[Qualified evidence](../implementation/phase70/evidence/summary.json).
Installed compiler03: checked B1 `386ae358…`, genuine B2 `d069204f…`, flattened
source `d583e187…`; selected source commit `d6d6049`, upstream `0592662`.
Fresh B2 own-source acceptance, exact B3 and installed legacy42/default24/helper5
all pass. The compiler algorithms remain Bend; runtime ABI is unchanged.

Native runtime: original six **1.12124× upstream**, six independently selected
additions **1.84036×**, respectively **12.95% / 18.90% less time** than Phase69
in the same campaigns. Keep cohorts separate; optional equal-weight twelve GM
is 1.43649×. Map0.888× and String ordering0.812× beat upstream; Array-map2.446×,
Tape2.970×, list2.146× and BST2.186× expose substantial remaining gaps. Measured
compiler02 binaries transfer to final03 through24 exact complete C emissions
(B1+B2 across12 programs) and56 identical host/runtime support files. Historical
1.033× Phase69 is not a contemporaneous baseline; see the retained noise audit.

Selected P70-001 bounded root-preserving observers, P70-004 lazy product-demand
checks, P70-005 compact-body reuse and P70-007 checked Bool arrays. Removed
P70-006 occurrence shortcut after its failed retention gate; P70-008 observer
skip was not selected. Compiler source31,444 physical/25,722 code lines,128
modules: +1,183 physical lines (+3.91% overall, +30.58% native production).
This is a performance/coverage tradeoff, not simplification.

Final three-source C request ratios **3.41827× B1 / 2.16517× B2** upstream.
Separate same-campaign Numeric old/new screen finds final03 **6.54% / 1.09%**
slower (four balanced rounds); do not claim whole-phase compiler speed gains.
Base preparation and imports are separate from requests; Clang and program
execution are different clocks. Selected native candidate100/100, raw31,
frontend36, B2 driver8 and unchanged2992 JS functions pass. Reference93/100
leaves seven preexisting unused-error-demand disagreements and the paired gate
false. Broader13 native API gaps remain. No new full JS/GPU sweep or formal proof.

Next runtime experiment: saved-C scalar product/loop-state transport, initially
Array-map and independent state loops, then integrate only demonstrated general
wins. Next compiler experiment: reuse native layout/arity and Base planning
products, guided by retained stage/V8 profiles. Root observer reconstruction
elimination transfers, but does not explain arbitrary tree/list allocation.
Do not repeat ineffective occurrence or ordinary-ready skip experiments.

All Phase70 raw/method writers are closed; the
[verified capsule](../selfhost/tools/performance/phase70/artifacts/evidence01/README.md)
preserves successes, failures and rejected variants. Guarded target occupancy
38m39s over2h06m12s target span, peak1.506GiB. New experiments need fresh paths.
One guarded CPU3 target tree; source/data agents CPU0. Preserve inherited
unrelated changes. No PR comments without explicit authorization.

---

# Historical frontier: Phase69 installed native near parity

[Design](../design/phase69/native-parity.md) ·
[Report](../implementation/phase69/README.md) ·
[Qualified evidence](../implementation/phase69/evidence/summary.json).
Installed checked B1 `674e7960…`, genuine B2 `c858dfa5…`, source `75e10b92…`,
upstream `0592662`. Source/release commit `f1655d0` is pushed. B2 own-source
acceptance, exact B3 reproduction and installed legacy42/default24/helper5 pass.

Six-family native runtime is **1.0332× upstream**, versus compiler23's **1.5285×
in the same campaign**: 32.4% less time. Numeric/arrays are near parity;
closures0.299×, tree1.429×, Map1.595×, lexer1.816×. The aggregate does not mean
every-program parity. Implemented: reachable bangs, immutable static images,
known closure factories/linear combinators, cold owned constructor stores and
typed native worker parameters. No new runtime or host compiler algorithm.

Selected native71, raw28 result rows, static7 helper queries and frontend36 pass.
JS/frontend executable continuity covers2,992 functions, not a new full-suite
run. Existing native13 API gaps remain. Three-source C request screen gives
B1/B2 **3.231×/2.183×** upstream; keep separate from generated-program runtime
and historical broad JS compilation. Source30,261 physical/24,768 code lines,
121 modules; +440 physical lines. Final target occupancy21m44s, peak1.516GiB.

Strongest next opportunity: implement the bounded
[root-preserving observer design](../design/phase69/root-preserving-observers.md).
Saved-C Map prototype722→390ms versus upstream429ms proves potential, not
production correctness. Structural root-origin analysis, representation guards,
error/poll preservation and independent admission/refusal controls are required.
Estimated350–600 lines/4.5–9h. Lexer state transport and scoped tree reuse are
secondary; result/packed metadata probes gave<1% and were deferred.

Phase69 raw and methods are now closed and
[verified in a capsule](../selfhost/tools/performance/phase69/artifacts/evidence01/README.md).
New authorized work uses fresh raw paths, preserving all history and inherited
unrelated changes. One guarded CPU3 target tree; source/data agents CPU0.
No PR comments without explicit authorization.

---

# Historical frontier: Phase68 native parity investigation

[Design](../design/phase68/c23-parity-investigation.md) ·
[Current report](../implementation/phase68/c23-parity-survey.md).
Source candidate23 (`b2ec0a2`) and installed Phase67 remain unchanged.
P68-022 adds40 profiles, allocation sites/categories and optimized assembly.
Dead imported bangs select pool mode: P68-023 saved-C BANGS0 removes14.9%
tree /11.9% lexer time. P68-024 static constructor data removes10.1% lexer time;
combined with mode correction removes21.8% (614→480ms, upstream247ms in that
same five-arm campaign). Counted static-only removes473088 allocations and
233472 RFC redirects, exactly predicted. No new compiler promoted or whole-set
ratio claimed; previous six-family compiler23 runtime remains1.724× upstream.
Next: integrate reachable bang facts and immutable constructor images, then
saved-C closure factory / typed loop-and-scheduler transport / tree reuse proofs.
Map products+redirects explain98.32% of excess allocation calls, not time.
Closure dispatch machine code nearly matches upstream but runs twice as often.
Keep raw demand/drop/ownership semantics; no speculative weakening for speed.
C-request B1/B2 ratios3.389×/2.284× remain previous three-source observations.
Selected native37/37, raw12 and query23 belong to unchanged23; no fresh broad
gate. B2 self-check/B3 and installed promotion remain separate qualification.
Installed B1 `c76f1113…`, B2 `cbffd1f8…`; upstream `0592662` unchanged.
New raw parity-survey23* closes with this report; preserve all earlier evidence.
One guardedCPU3 target tree, source/dataCPU0, no PR comments.

---

# Current frontier: Phase67 installed native improvement

[Design](../design/phase67/native-speed-and-proof.md) ·
[Report](../implementation/phase67/README.md) ·
[Installed release](../implementation/phase67/evidence/installed-release01.json).
Selected source checkpoint `204f671`: B1 `c76f1113…`, genuine B2 `cbffd1f8…`,
source `e4a4105e…`; upstream remains `0592662`.

All six native families improve: 33.3% less runtime, 18.4% less Clang time,
20.0% smaller C. The limited-corpus gap remains 10.41× upstream C; arrays,
closure/aggregate transport, flat layouts and borrowing are the next native
opportunities. Use the verified seven-second Bend-only loop for new edits;
keep slow TS-resolved qualification separate. No new work is authorized merely
by this frontier note.

B1/B2 compilation screens show no regression. All 45 JS point modules are
byte-identical and the unchanged non-native executable closure retains finite
frontend/JS conformance evidence. B2 self-check/reproduction, native controls
and installed-interface checks pass. Production costs +46 lines, no new module.
The proof model typechecks, but independent checking is blocked on Lean4.34.

Raw Phase67 and all older raw/archive evidence are closed. New authorized work
must use a fresh phase directory, preserve the installed baseline and inherited
110 files, and retain one guarded CPU3 target tree at a time. Source/data agents
can work on CPU0. No PR comments without an explicit new request.

---

# Previous closed frontier: Phase66 upstream migration

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
