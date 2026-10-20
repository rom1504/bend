# Phase114 native qualification and wall accounting

`native-plan.py` invokes the exact SHA-pinned Phase113 qualification preparer,
without modifying that gate or its comparer. `native-binding01.json` freezes
the original preparer, comparer, transport selector and staged emitter. The
original gate first authenticates the full source, checked API, source snapshots,
actual array native hook, runtime build and unchanged semantic manifests.

The adapter retains that never-executed base plan, then changes only output
paths and time limits. Every path replacement and limit change is recorded in
`derivation`; the derived input list pins the adapter, binding and base plan.
The plan keeps `kind=phase113-native-qualification-plan`, so the original
verification and exact-QBE comparison tools accept it unchanged.

```sh
python3 -B selfhost/tools/performance/phase114/evidence/native-plan.py \
  --api selfhost/build/phase111/p114-SELECTED-api/api.mjs \
  --source selfhost/build/phase113/p114-SELECTED-source/compiler.bend \
  --runtime selfhost/build/phase113/runtime-products-build01/runtime.o \
  --tag p114-native-final01 \
  --out selfhost/build/phase114/native-final01-plan.json
```

This preparation executes no targets. The default hosted-emission limit is900s
and native self-request limit is900s. The latter retains the base gate's400s
additional outer-job allowance for its unchanged machine build and supervision,
so its job cap is1300s. Builder/fixture limits, flags, CPU3/4GiB/128MiB guard
policy and all other commands remain unchanged. `--hosted-seconds` and
`--native-seconds` can set explicit alternatives before freezing a plan.

Root may execute the returned `rootGuardCommand` or split the frozen jobs into
separately pinned batches with fresh guard/job directories, preserving dependency
order. The outer ceiling is the sum of job caps plus60s, not a forecast or
resource quota. Only the derived plan is executable; the adjacent `-base.json`
exists to prove the path/time-only derivation.

Products use `phase111/p114-*`; serial-job and guard directories use
`phase113/p114-*`, as required by the unchanged runner. The comparison lives at
`phase113/p114-…-qbe-comparison/report.json`, ensuring the Phase114 evidence
scope includes it. No loose out-of-scope Phase113 comparison file is created.

The stages remain full hosted array emission → N1 build → focused19 → actual
N1 self-emission/N2 build → exact raw QBE comparison → N2 focused19 → N2 full45.
Focused19 includes16 positive executions and3 expected refusals. Full45 is the
unchanged one-shot conformance corpus, not the batch45 runtime benchmark. This
chain does not claim N2-to-N3 output reproduction or program runtime parity.

## Optional unchanged compiler-request screen

`native-transport.py` uses the SHA-pinned, unchanged Phase113
`prepare-native-transport.py` gate and Phase112 transport method. It can run only
after the original exact-QBE comparison and authenticates the actual hosted
emission, N1 build, native self-request and N2 build. The retained `-base.json`
manifest is the original gate's result. The derived manifest changes displayed
Phase113 lineage to Phase114 and adds provenance; it preserves every source,
complete output oracle, Base/cache, upstream product, build flag, clock and
per-stage limit. Legacy role keys `phase111`/`phase112` mean Phase114 N1/N2.

The source-only prepared orchestration is:

```
selfhost/build/phase114/native-final01-with-transport-plan.json
```

It retains every original job and its original plan/comparison references,
inserting one optional job immediately after `exact-hosted-native-qbe` and before
the N2 semantic suites. Use this plan's `rootGuardCommand` **instead of** the
original plan's command. Both reserve the same native artifact destinations.
The original `native-final01-plan.json` remains unchanged.

The optional job follows `native-final01-transport-plan.json`: authenticate and
freeze the actual generation manifest (30s cap), then run the original transport
method on lexer, closures256 and map-churn128, three rotated rounds and three
roles in cache mode (27samples,120s cap). It retains the original full-output
checks. Prior comparable screens took55–89s and retained21–24MiB. The outer
wrapper adds160s to the original native guard ceiling; this is a cap, not a
forecast. No image is assumed to exist until the gate verifies it.

```
Attempt: selfhost/build/phase114/native-final01-transport-attempt/report.json
Manifest: selfhost/build/phase114/native-final01-transport-manifest.json
Measurement: selfhost/build/phase112/p114-native-final01-transport/report.json
```

`optional-transport.py` records a failure or timeout and returns control to the
original N2 suites. Wrapper exit0 and a complete native job sequence do not
imply transport success: require `measurementPassed=true` in the attempt and
`complete=true, passed=true` in the original measurement report. Timeout cleanup
reuses the existing guard's process-tree cleanup because the unchanged method's
compiler children have separate sessions. Original compiler-request and build
clocks exclude this wrapper. No native qualification gate becomes optional.

The screen distinguishes request time (native QBE versus upstream C) from
ready-executable request+build time (cached-runtime QBE/as/link versus Clang-O2).
It does not measure program runtime, same-format throughput, or N2-to-N3
reproduction. N1/N2 are generation names for this route, not the installed
production compiler labels.

## Disk forecast from retained earlier products

The actual catalogue full acquisition retained57.68MiB in `phase114/catalogue-full01`
and81.19MiB in `phase111/p114-catalogue-native01`. Main files were57.56MiB QBE,
52.52MiB assembly,17.06MiB object and11.60MiB ELF. Two comparable generations,
two prior focused19 output sets and one prior one-shot full45 output set total
about339.32MiB. The prior final31 batch45 emission/build products add90.23MiB.
These are forecasts from different source versions, not final-product bounds.

The unchanged128MiB file-cap guard needs more than416MiB free at startup. The
unchanged transport method separately requires256MiB free before every sample;
allow about290MiB before its27-sample screen. Running broad45 first and the
complete native chain in one later guard avoids another guard-start floor after
N2. If space is needed, root can losslessly compress superseded catalogue `.s`
and `.o` (69.58MiB raw), verify decompression against original hashes and retain
a restore receipt. Keep its QBE/ELF and all final qualification products intact.
This tooling does not compress, remove or archive machine products.

## Recorded occupancy

`occupancy.py` reads only `process.json` guard receipts in the Phase114 evidence
scopes. It reuses pinned Phase112 timestamp/interval-union helpers without
running that helper's old categorization or Phase112-specific scanner.

```sh
python3 -B selfhost/tools/performance/phase114/evidence/occupancy.py \
  --start 2026-10-20T21:31:00Z --until now \
  --out selfhost/build/phase114/occupancy-checkpoint01.json
```

Use the actual recorded campaign start/cutoff and fresh output names. Finished
guard intervals, including failures, are clipped to the window and unioned;
nested clocks are not added twice. Pending guards remain separate with no
invented finish. Time outside recorded finished guards is **unattributed**:
source work, analysis, scheduling, pending guards and unrecorded activity may
occupy it. It is not measured idle time, CPU time, agent labor or quota
compliance. The script assigns no heuristic work categories.
