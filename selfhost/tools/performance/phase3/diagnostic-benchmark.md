# Complete diagnostic-path comparison

`diagnostic-benchmark.mjs` measures a complete `typed-driver.inspect(..., {mode:'check'})` request. Both variants use the same frozen host tools, runtime, Base bytes, input paths, Node version and CPU. It preserves rich diagnostics and requires exact equality of the entire returned result, including the status, phase and checked flag.

Create a JSON configuration with paths relative to the configuration file:

```json
{
  "baseline": "baseline/api/b1.mjs",
  "candidate": "diagnostic-reuse-rebuild/api.mjs",
  "runtime": "../../src/runtime.mjs",
  "base": "../../.bootstrap/upstream/bend2/base.bend",
  "cpu": 1,
  "rounds": 3,
  "timeoutMs": 60000,
  "workloads": [
    {"id": "bytes-ops", "input": "../../.bootstrap/upstream/tests/base/bytes_ops.bend", "expectedStatus": "error"},
    {"id": "list-sort", "input": "../../.bootstrap/upstream/tests/base/list_sort.bend", "expectedStatus": "ok"}
  ]
}
```

From `selfhost/`, run with an available CPU:

```sh
node --stack-size=4096 --max-old-space-size=4096 tools/performance/phase3/diagnostic-benchmark.mjs CONFIG.json NEW_OUTPUT_DIRECTORY
```

The tool checks each API's adjacent `.bootstrap.json` against its API, assembled source, module snapshots and Base hashes. It records whether the original build included verified bootstrap provenance; historical reports do not acquire that guarantee retroactively. It freezes the current host helpers and worker into the output directory, then prepares a separate validated Base cache for each compiler. Preparation is reported separately and finishes before any timing sample.

Three rounds produce three baseline and three candidate samples per workload, with pair order baseline/candidate, candidate/baseline, baseline/candidate. Each sample starts a fresh Node process with 4 MiB stack and 4 GiB heap. Its request and result retain all consumed artifact identities. The tool checks these before and after every sample, including the warmed cache files. `checkMs` covers the entire inspect call; `processWallMs` additionally includes Node startup, API loading, artifact validation and report IO. These scopes must not be conflated.

The primary correctness companion is:

```sh
node --stack-size=4096 --max-old-space-size=4096 tests/diagnostic-reuse.mjs CANDIDATE_B1 BASELINE_B1 NEW_OUTPUT_DIRECTORY
node --stack-size=4096 --max-old-space-size=4096 tests/frontend/trace-component.mjs NEW_OUTPUT_DIRECTORY
```

The first compares complete diagnostic structures, rendered messages and origins across rejection categories, imports, Unicode, exact-prefix mismatches, source/path seed changes, and the real Base seed. The second checks and runs the standalone loader module set without depending on diagnostic modules.
