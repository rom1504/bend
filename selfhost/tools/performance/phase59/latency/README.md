# Phase59 first-request compiler measurements

This method compares the selected Phase58 `checked-last01` direct B2 with the
pinned upstream TypeScript compiler. It changes measurement tools only. No new
compiler source or image is synthesized by this method. Preparation, clean,
CPU/allocation and stage requests passed. The [report](../../../../../implementation/phase59/README.md)
links results and the closed evidence capsule. Use fresh paths for another run.

The selected B2 is `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`,
emitted from source `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
Its genuine checked attempt and full-emission receipts are verified by the setup;
the direct image receives no fabricated checked-bootstrap sidecar. Upstream stays
at `018751270e800bc222a93dad7f257083ee53a5f7`.

## Preserved method and changed diagnostic boundary

`make-method.py` derives `run.py`, `worker.mjs`, `setup.mjs` and `profile.mjs` from
the frozen Phase58 method04 and setup-v2. It records every exact edit and parent
hash. Output confinement and all private project/cache paths change to Phase59.
The ordinary compile operations, source catalog, output checks, resource guard,
CPU accounting policy and allocation estimator remain the inherited methods.

Clean measurements use two inputs, Evening and lexer, three rotated rounds and
two roles: 12 fresh processes / 48 ordinary requests. Each process measures host
import, actual API loading and the first request separately, then three later
ordinary requests. Each request creates a fresh source book; there is no persistent
inspector. Preparation separately executes the full catalog value oracle for each
role/input; every subsequent request must emit the exact prepared bytes for its
own role. Bend and TypeScript output text need not match each other.

CPU and allocation diagnostics use separate fresh processes. The profiler starts
**before actual compiler imports**, encloses API loading and **exactly one first
compile**, and stops before output validation, hashing or file saving. The result
is retained through post-stop profile serialization, then validated. No first or
warm request precedes capture;
`maxRequests` is one and diagnostic `warmRequests` is zero. Thus the captured work
corresponds to the combined import/API/first-request boundary behind the reported
2.6× gap, unlike the Phase58 profiles of later requests. Individual phase clocks
are retained, but sampled frames are not assigned to phases without separate
stage instrumentation.

The diagnostic has a one-millisecond nominal target solely to satisfy the shared
helper interface; one complete request always runs regardless of duration. CPU
sampling remains 1 ms; allocation sampling remains 128 KiB and includes objects
collected by minor and major GC. Weighted CPU accounting can refuse and retain a
sample-count view. No weighted thresholds are relaxed. Profiling overhead and
inspector setup are diagnostic; their durations are never clean latency ratios.

Private Base disk caches are prepared outside samples. Worker provenance reads
also precede clocks and can warm OS caches or affect process state differently
between roles. This measures a fresh compiler process, not a cold filesystem.
Actual compiler/API imports still occur inside the measured or captured window.

## Root-owned execution

The runner owns the sole `ExecutionGuard`: CPU3, 1 GiB Node heap, 2 GiB process-tree
RSS and 4 GiB available-memory floor. Do not put it inside another shared guard.
Do not launch it under `taskset -c 0`, which would hide CPU3 from its affinity
check. Data-only derivation may run on CPU0.

The original materialization below already exists and must not be overwritten.
Use a fresh method directory to replay the derivation, and use that generated
runner for all commands in a replay.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase59/latency/make-method.py \
  selfhost/build/phase59/latency-method01
```

After independent static review, execute serially from the repository root:

```sh
python3 -B selfhost/build/phase59/latency-method01/run.py \
  selfhost/build/phase59/preparation01 --prepare-only --seconds 180

python3 -B selfhost/build/phase59/latency-method01/run.py \
  selfhost/build/phase59/clean01 \
  --preparations selfhost/build/phase59/preparation01/report.json \
  --mode clean --rounds 3 --seconds 180

python3 -B selfhost/build/phase59/latency-method01/run.py \
  selfhost/build/phase59/first-cpu01 \
  --preparations selfhost/build/phase59/preparation01/report.json \
  --mode cpu --rounds 1 --seconds 120

python3 -B selfhost/build/phase59/latency-method01/run.py \
  selfhost/build/phase59/first-allocation01 \
  --preparations selfhost/build/phase59/preparation01/report.json \
  --mode allocation --rounds 1 --seconds 120
```

Each diagnostic command runs four fresh workers: both inputs and both roles.
Use `--cases lexer` for a deliberately smaller two-worker probe, or increase
rounds explicitly before interpreting variability. All source identities, byte
oracles, execution receipts and raw profiles remain recorded. No command writes
closed Phase54–58 evidence. Preserve failures and consumed method bytes; fix any
defect with a successor method and fresh outputs.

## Separate first-request stage clocks

`make-stage-method.py` creates a distinct stage-only worker and runner from the
consumed method01. It does not change clean/profile workers. The stage worker
uses the reviewed [clock and insertion-only driver producer](../stages/README.md),
leaves the real compiler API unchanged, and reuses the original private Base cache
and prepared output oracle. It measures one first request in each fresh process,
without an inspector or later requests. Stage timings include instrumentation
overhead and must never replace clean timing results.

The diagnostic driver is a new adjacent file in the already private Phase59
project. Its receipt must bind the original driver identity, exact insertion
inverse, output bytes, producer and clock. The original driver remains unchanged.
The sample records both identities; it does not label the modified driver as an
ordinary compiler input. The shared symbol sink exists only during the diagnostic
window. Successful observations require exactly three root intervals and zero
incomplete spans; nested inclusive intervals must not be summed.

After static review, the root can run the data-only producer, then the guarded
stage campaign. This adds no compiler build or Base-cache priming:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase59/stages/derive-driver.py \
  selfhost/build/phase59/preparation01/prepare-direct/stage/project/tools/typed-driver.mjs \
  selfhost/build/phase59/preparation01/prepare-direct/stage/project/tools/typed-driver-stages.mjs

python3 -B selfhost/build/phase59/stage-method01/run.py \
  selfhost/build/phase59/stages01 \
  --preparations selfhost/build/phase59/preparation01/report.json \
  --driver-receipt selfhost/build/phase59/preparation01/prepare-direct/stage/project/tools/typed-driver-stages.derivation.json \
  --seconds 120
```

This is four observations, both inputs and both roles, in one round. The clock
records `host-import`, `api-load` and `first-request` roots. TypeScript gets nested
`ts.book-load`, `ts.book-valid` and `ts.js-lib` intervals; the Bend driver separately
records its validation, checking and emission boundaries. Their conceptual stages
are not automatically identical, and uninstrumented residual time remains visible.
