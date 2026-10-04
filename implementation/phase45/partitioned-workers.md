# Partitioned worker checkpoint

This is an experimental checked compiler, not an installed release or a new
full-corpus result. Phase44 remains installed. The selected checkpoint is
`selfhost/build/phase45/checked-worker05`, API SHA-256
`af2776fee3b04d0f448af890e86fbba11b2a2d119801e949cd2896d6636a0f50`.

The first worker removed generic dispatch from proved first-order graphs, but
emitted one approximately 71 KB function. Both exact CPU profiles reported
`Function is too big to be optimized`. The replacement computes exact bounded
call components from worker IR. Acyclic functions use positional parameters and
scalar locals. Recursive components use separate iterative machines with explicit
continuations. Calls between components follow an acyclic graph, bounding native
stack depth independently of program input. Unsupported or oversized graphs
retain the previous implementation.

The five worker modules contain 683 lines at this checkpoint. A shared typed
projection plan also removes temporary String/Char field vectors, and private
roots can return native immutable Strings. Public entry guards, descriptor
mutation behavior and generic fallbacks remain in place. These are general
type/call-graph rules; they do not select benchmark names or algorithms.

## Focused execution screen

Fresh alternating processes, CPU3, Node24.18.0, 1 GiB heap, 2 GiB process-tree
limit, 60-second preset; execution excludes compilation. All 18 samples pass.
The two-point screen took 16.72 seconds.

| Point | Phase44 ms | Checkpoint ms | Pinned TypeScript ms | Improvement | Checkpoint / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map churn 128 | 22.548 | 7.263 | 0.796 | 3.105× | 9.119× |
| Record aggregation 256 | 101.461 | 11.056 | 1.261 | 9.177× | 8.770× |

These are medians from `runtime-worker05/report.json`, not a replacement for
the previous 45-point aggregate. Earlier short runs showed significant JIT
warmup drift. Longer selected qualification remains necessary before a release.

The isolated tail-vector reuse attempt did not show a useful win. It is excluded
from this checkpoint, which retains allocating recursive tail transfers. The
runtime permission-state experiment was also deferred after an essentially flat
six-point screen. Both attempts remain recorded.

## Correctness scope

- Strict checked B1 workflow and all eight maintained semantic suites pass.
- Independent composition tests pass 135 scalar oracle points, five complete
  constructor observations, five activation checks and five mutation fallbacks.
- Five recursion families pass depths 4,096 and 50,000 with independent iterative
  oracles and separate untimed activation counters.
- The actual Bend graph algorithm passes 15 graph cases and five auxiliary
  controls against an independent DFS oracle, including word boundaries, the
  96-node limit, malformed edges and failure propagation.
- The earlier isolated String-result implementation passes four actual-record
  oracles, 57 boundary differentials and 61 activation/refusal observations.
  Those are isolated-result controls, not fresh combined-checkpoint observations.

Full frontend/backend conformance, installation and the complete benchmark are
reserved for the integrated survivor. No full-conformance or parity claim follows
from these selected controls.

## Reproduction and next step

Use the existing checked workflow with a copy of
`selfhost/tools/performance/phase44/checked-config-v1.json` whose `project` points
at the current selfhost directory. Acquire the two cases above using
`programs/prepare.py`, then use `programs/run.py` with the Phase37 catalog and the
saved Phase44 checked04 control. The exact commands and failed attempts are in
`selfhost/build/phase45/campaign.jsonl`, `wave05-commands.json` and
`test05-commands.json`. All earlier raw campaigns remain closed.

Next measure the partitioned profiles, then test a bounded native-call path
whose overflow enters the same private iterative component. Separately, extend
the complete proof to demanded nullary definitions. Neither proposal may relax
public mutation, argument order, initializer demand or deep-stack correctness.
