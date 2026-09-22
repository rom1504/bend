# Persistent frontend workers: protocol repair and controlled comparison

The final worker protocol passed 19 tests. On the selected eight-probe workload,
its median process wall time improved by **1.16× for the experimental Bend B1 API**
and **2.19× for the pinned TypeScript reference**, compared with isolated workers.
These are separate within-compiler comparisons. They do not establish a compiler
speedup, a full conformance result, or a 10× opportunity.

The [compact evidence](evidence/persistent-workers-final.json) records all samples,
exact observations, commands, source/host/worker hashes, the upstream revision,
fixture hashes, and the prepared Base-cache digest. Raw reports and retained
request sequences remain in
`selfhost/build/phase3/persistent-final/prepared-run/`.

## Correctness repairs

The supervisor previously checked output overflow on the polled completion-file
path but omitted that check on FD3. Both paths now use one validator, with a
request token, bounded completion message, and response digest. The worker
publishes its response, captured logs, and completion file atomically. Successful
completion also waits for both pipe boundaries, including split markers; raw
file-descriptor output cannot be discarded just because completion arrived first.
Captured stdout/stderr and raw pipe bytes share a 1 MiB request output budget.
Request and completion files are limited to 16 KiB; responses to 4 MiB.

Timeouts and crashes kill the worker process group before a fresh session starts.
Changing identity files starts a fresh session, stale completion files are
removed, and reusing a runner directory cannot overwrite an earlier session.
Unexpected idle protocol failures also prevent a complete suite verdict.

Version 2 retained sessions record the worker, adapter, and identity-file hashes,
plus a chained digest of every request/result prefix. Replay verifies the entire
prefix before executing it and compares every replayed result. It uses the
recorded worker and can reconstruct earlier requests whose successful workdirs
were deleted by `--retain failed`. Altered or incomplete prefixes are rejected.
Old experimental persistent sessions without these integrity fields are rejected
explicitly; isolated replay retains its previous behavior.

## Controlled measurements

All cells used fresh runner processes on CPU 0, Node v24.18.0, a 4 MiB stack,
a 4 GiB heap, one worker, and the same frozen tools/API/runtime/Base. The four
fixtures were `base/list_fold.bend`, `check/alpha_equivalence.bend`,
`check/typed_let_mismatch.bend`, and `parse/law_fill_arrow.bend`, each in parse
and check lanes. Three rounds alternated worker-mode and compiler order; the
middle round reversed request order. Node module compile disk caching was
disabled. Host tracing was disabled equally in both modes.

The validated Base disk cache was prepared outside the timed cells, then its
hash was checked after every cell. An earlier exploratory run let the first
isolated typed check build this cache; that run is retained but excluded here.
The first-run bias is therefore not counted as a persistent-worker improvement.

| Compiler | Isolated wall samples (s) | Persistent wall samples (s) | Median ratio |
| --- | --- | --- | --- |
| Experimental B1 | 12.164, 13.434, 13.559 | 10.643, 11.751, 11.607 | 1.16× |
| Pinned TypeScript | 4.602, 4.479, 4.369 | 2.212, 2.049, 2.023 | 2.19× |

Process wall includes inventory, artifact hashing, startup and report IO. The
median sums of individual probe times were 12.902 versus 11.035 seconds for B1,
and 3.969 versus 1.519 seconds for TypeScript. These are small shared-host
observations; other agents used other CPUs, and three repetitions do not establish
an uncertainty interval or predict a full-corpus gain.

All eight exact result objects and judged observations matched between modes
and across request orders, separately for each compiler. The B1 cells consistently
had four passes, two negative parse observations, and two exact-diagnostic
failures. Both negative check probes still rejected at the expected phase; their
text differs from the upstream fixture oracle. The reference cells had six passes
and two negative parse observations. No cell crashed or timed out. Reference
`selectedComplete` was true, B1 `selectedComplete` was false, and every full-suite
`complete` flag was false. The experiment report's own `complete` field means
that the scheduled comparison finished.

The API hash was
`7740bc5a8ccf098625330e9855eb8c977aabdfc38ee26443155a10ca378a641a`.
This is the experimental named-ABI B1 artifact before the subsequent type-only
`FLoadTrace` relocation. It does not include the upcoming native overlay and is
not an integrated H fixed-point measurement.

## Reproduction and tests

The portable driver is
[`persistent-measure.mjs`](../../selfhost/tools/performance/phase3/persistent-measure.mjs).
It takes a JSON configuration with absolute `project`, `upstream`, and `api`
paths, plus `cpu`, `rounds` and `timeoutMs`, and requires a fresh output directory.
The exact configuration is included in the compact evidence. For the retained
workspace:

```sh
node selfhost/tools/performance/phase3/persistent-measure.mjs \
  selfhost/build/phase3/persistent-final/config.json \
  selfhost/build/phase3/persistent-final/fresh-run
```

Exact artifact reproduction requires the recorded API and host files; a later
compiler build is a new experiment even when the same fixture names are used.
The driver freezes its host inputs, prepares and hashes the Base cache, checks
artifact stability and exact mode/order equality, and records every cell.

The following command passed **19/19**, with no skips, in 6.59 seconds using
local subprocess execution:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --test \
  selfhost/tests/conformance/persistent-worker.test.mjs \
  selfhost/tests/conformance/targeted.test.mjs
```

Thirteen persistent tests cover FD3-only overflow, combined captured/raw limits,
malformed and out-of-sequence protocol, split pipe boundaries, response identity,
stale completions, timeout descendant cleanup, crash recovery, invalid/oversized
responses, RSS recycling, identity changes, directory reuse, and retained-prefix
replay/tampering. The remaining six tests exercise existing isolated CLI/replay
behavior. Syntax checks for the four harness files and the measurement driver
also passed.
