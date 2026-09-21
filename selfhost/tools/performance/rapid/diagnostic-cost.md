# Isolate diagnostic replay cost

This experiment uses an unchanged checked Bend API. Variant A keeps every API
export. Variant B removes four presentation exports from an in-memory copy:
`check_book_diagnostic`, `diagnostic_render`, `f_load_origins_for`, and
`diagnostic_result_locate`. Both still execute the authoritative checker, ordinary
load/check gates, and the same validated Base prefix cache.

Use a new output directory and paths relative to the configuration file:

```json
{
  "api": "/absolute/checked/api.mjs",
  "runtime": "/absolute/selfhost/src/runtime.mjs",
  "base": "/absolute/pinned/upstream/bend2/base.bend",
  "cpu": 2,
  "timeoutMs": 30000,
  "workloads": [
    {"id":"bytes_ops", "input":"/absolute/pinned/upstream/tests/base/bytes_ops.bend", "expectedStatus":"error"},
    {"id":"list_sort", "input":"/absolute/pinned/upstream/tests/base/list_sort.bend", "expectedStatus":"ok"}
  ]
}
```

```sh
node tools/performance/rapid/diagnostic-cost.mjs CONFIG.json NEW_OUTPUT_DIRECTORY
```

Each workload runs A/B/B/A in fresh Node processes on the requested CPU. Both
variants time the same top-level Bend calls. The setup explicitly prepares or
reuses a cache validated by `check_book`, records its identity, and discovers the
actual dependency files before timing. API, checked source, dependency, runtime,
cache, Node, and consumed host-tool identities must remain unchanged.

The report requires identical authoritative `check_from_exact_prefix` error,
status, phase, `checked`, exit code, and ordinary check output across variants.
It also requires the configured positive/negative expectation. Detailed diagnostic
text may differ and remains in every observation. A successful experiment proves
these specific causal observations, not diagnostic conformance and not that
presentation replay can safely be omitted from production. Timings include
profiling overhead in both variants; two samples per variant are a bounded
hypothesis test, not a general compiler benchmark.

## Phase 2 observation

The final checked B1 API (`794cbf5f…`) passed all eight comparison gates. For
`base/bytes_ops.bend`, mean check time was 10,247.7 ms with detailed presentation
and 622.5 ms without its replay exports: a 16.46× difference in this diagnostic
experiment. The authoritative prefix check returned the identical error and
took 196.9 ms versus 192.0 ms. Detailed checking replay consumed 4,698.0 ms;
origin reconstruction consumed another 4,880.9 ms. Both are substantial costs.

The positive `base/list_sort.bend` control took 2,296.9 ms versus 2,263.5 ms.
No presentation replay ran on that successful check, and these two-sample means
are close. The negative case's existing rejection and changed presentation remain
visible; this experiment neither repairs its semantics nor establishes an exact
diagnostic pass. Full observations are archived in
[the phase 2 evidence](../../../../implementation/phase2/evidence/diagnostic-cost-v2.json).

The next production investigation should reuse the already parsed graph for
source origins and the validated Base prefix when constructing diagnostics.
Preserve the authoritative checker result, source locations, expected/observed
terms, and exact presentation tests. The measured shortcut is only a diagnostic
control: shipping a brief-error bypass would discard the behavior this follow-up
must preserve.
