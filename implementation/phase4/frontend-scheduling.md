# Persistent frontend scheduling (P4-021)

Four persistent workers reduced the full frontend gate from **17 minutes
16 seconds to 4 minutes 59 seconds**, using four CPU cores. The two four-core
runs bracketed the otherwise-idle serial run and measured 299.376 and 297.699
seconds; their 298.537-second median is **3.47× throughput / 71.18% less wall**
than the 1,036.017-second serial run.

All four full attempts preserve exactly the same 2,756 raw observations and
harness verdicts: 1,920 pass, 459 observed, and 377 fail. Both complete
comparisons also verified every actual worker-history result digest and replay
prefix. Existing conformance failures remain failures. This is a scheduling
and resource benefit, not a compiler algorithm improvement or full conformance.

The earlier loaded-host serial attempt took 1,129.720 seconds, 9.04% longer
than the idle-host serial attempt. It remains in the evidence but is excluded
from the primary ratio. This difference justified the extra idle-host bracket.
There is one idle serial sample and two four-core samples, not a large
statistical study.

## Fixed workload and boundaries

The experiment freezes the completed Phase 4 frontend harness, host and adapter,
final checked B1 API, runtime, canonical pinned Base, and fixtures. Both full
schedules use exactly 1,378 fixtures / 2,756 parse/check requests, a previously
validated immutable Base cache, a 4 MiB stack, 4 GiB heap/RSS recycling threshold,
64 requests per worker generation, and a five-minute per-request deadline.
Changing worker count changes resources and scheduling, not compiler code.

The supervisor records complete child-process wall time, including startup,
hashing, dispatch and worker recycling. It samples the sum of live runner and
worker RSS every 500 ms. This is a sampled simultaneous RSS sum, not an exact
OS peak or unique physical-memory count. Actual process affinity and CPU/core
identities are retained. Failed fixture reproductions and each actual worker
history are retained instead of treating previous isolated calls as evidence
for a new persistent execution history.

## Completed observations

A 12-fixture mixed acceptance/rejection/import smoke passed all 24 observations
with one worker and four workers, both confined to CPU 0. Recycling every four
requests exercised multiple worker histories. This smoke is a correctness gate;
it supplies no parallel-throughput claim. The separate history audit also passed:
all actual session result digests and replay prefixes validated, with identical
1,494-entry imported/foreign input maps and recorded CPU masks.

The first full serial child ran from 18:08:01.261 to 18:26:50.982 UTC on CPU 0.
It used 44 clean worker lifetimes, recycled 43 times, and recorded zero worker
failures or timeouts. The sampled live RSS sum peaked at 860,872 KiB. All captured
inputs remained unchanged, every historical observation matched exactly, and
all recorded child processes had exited before CPU 0 was released.

The comparable sequence had no competing compiler jobs:

| Attempt | Child UTC interval | Wall seconds | Sampled live RSS sum, KiB |
| --- | --- | ---: | ---: |
| Four workers, shared cores 0–3 | 18:39:29.051–18:44:28.428 | 299.376 | 1,536,424 |
| One worker, core 0 | 18:45:03.592–19:02:19.609 | 1,036.017 | 856,864 |
| Four workers, shared cores 0–3 | 19:02:56.593–19:07:54.293 | 297.699 | 1,602,432 |

All four workers share the allowed 0–3 mask; they are not each pinned to an
individual core. The machine exposes four distinct physical cores for these
IDs. Other agents limited activity to light metadata/documentation work during
the comparable sequence. Both four-worker runs recorded zero worker failures
or timeouts. Each generated its own real request histories; scheduling did not
reuse results from the serial run.

The [durable evidence archive](frontend-scheduling-evidence/README.md) retains
all attempts, full observations, failed reproductions, session histories,
frozen tools/cache, comparisons and their hashes. Raw working copies are under
`selfhost/build/phase4/frontend-scheduling/`. The snapshot contains 35 frozen
files and identities for original inputs, proof inputs, Node and the validated
cache. Both full comparison audits passed all 2,756 result/verdict comparisons,
1,494 imported/foreign input mappings, recorded CPU masks, session result
digests and replay-prefix checks. Raw harness exit status 1 is retained because
377 observations are still conformance failures; the scheduling report's
`complete` flag means complete, unchanged observations only.

## Reproduction

From `selfhost/`, prepare a fresh snapshot using a configuration with
`completedSweep`, `historicalReport`, `api`, `provenance`, `base`, `runtime`,
`upstream`, and `seedCacheDirectory` paths, resolved relative to that file:

```sh
node tools/performance/phase4/frontend-scheduling.mjs prepare CONFIG.json NEW_SNAPSHOT
node NEW_SNAPSHOT/frontend-scheduling.mjs run NEW_SNAPSHOT 1 0 NEW_SERIAL
node NEW_SNAPSHOT/frontend-scheduling.mjs run NEW_SNAPSHOT 4 0,1,2,3 NEW_PARALLEL
node tools/performance/phase4/frontend-scheduling-compare.mjs NEW_SERIAL/report.json NEW_PARALLEL/report.json NEW_COMPARISON.json
```

Use the recorded Node 24 executable and keep all consumed sources unchanged.
The full comparison requires four distinct physical cores for the four-worker
run and explicit resource clearance. A shorter selection can be supplied as
the fifth `run` argument, with recycle count `4` as the sixth, for correctness
smoke tests. Never interpret a successful scheduling report as a conformance
pass: it intentionally retains the same known failed checks.

For the recorded experiment, the preparation configuration was:

```json
{
  "completedSweep": "../frontend-combined",
  "historicalReport": "../frontend-combined/combined-b1.json",
  "api": "../combined-checked/api.mjs",
  "provenance": "../combined-checked/report.json",
  "base": "../../../.bootstrap/upstream/bend2/base.bend",
  "runtime": "../baseline/src/runtime.mjs",
  "upstream": "../../../.bootstrap/upstream",
  "seedCacheDirectory": "../frontend-combined/host/build/typed/cache"
}
```

Place that file in a new `selfhost/build/phase4/` experiment directory, or use
absolute paths. The historical checked API is `0653f21e…`, runtime `26f5eee2…`,
and canonical Base `b8c2734d…`; full hashes are retained. The source/tool
snapshots referenced by those reports must still verify. These build artifacts
are historical evidence, not defaults for a newly edited compiler. For the
usable current-development command, see the [four-worker frontend guide](../../docs/PHASE4_DEVELOPMENT.md#run-the-full-frontend-gate-with-four-workers).
