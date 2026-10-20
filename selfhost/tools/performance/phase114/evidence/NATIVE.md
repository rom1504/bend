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
