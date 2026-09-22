# Final small compiler comparison

`final-compiler-compare.mjs` compares historical self-emitted H, final self-emitted H, optional checked B1, and the pinned TypeScript compiler. It does not substitute an unchecked or hand-written compiler model.

The primary comparison uses **one frozen current host** for every Bend API. This isolates compiler/API changes while permitting the old API's legacy diagnostic fallback. Each H retains its own embedded runtime. Every Bend compiler emits against the **same selected output runtime**, allowing direct emitted-byte comparison; TypeScript retains its own emitter and generated runtime. A historical-host product comparison would be a separate experiment and must be labeled separately.

Recommended cases are `tests/fixtures/tree.bend` and pinned `tests/base/list_sort.bend` for parse/check/emit/execution, plus pinned `tests/base/bytes_ops.bend` for exact negative diagnostics. The latter is never treated as a successful compilation. Parse/check/emit measurements are separate fresh-process requests and therefore cumulative: check includes loading; emit includes loading, checking and emission. Do not sum them or subtract independently sampled medians to claim exclusive phase costs.

All variants use the exact canonical pinned Base path. Each Bend API has a separate validated Base cache, primed and hashed before timing. Pinned TS has no corresponding serialized compiler-side Base cache: it loads/checks Base afresh. OS caches are not flushed. Optional `seedCacheDirectory` imports previously primed cache files; their hashes are retained and normal compiler/Base/book cache validation still runs before measurement.

From `selfhost/`:

```sh
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase3/final-compiler-compare.mjs CONFIG.json NEW_OUTPUT_DIRECTORY \
  > LAUNCH.stdout 2> LAUNCH.stderr
```

The tool puts every worker's stdout/stderr and each generated program's stdout/stderr into files using file descriptors. It does not depend on subprocess pipes delivering output. Worker JSON, emitted source, requests, logs, exit status, signals and input identities remain in the output directory.

Configuration paths resolve relative to the JSON file. A configuration under `build/phase3/` can use:

```json
{
  "upstream": "../../.bootstrap/upstream",
  "base": "../../.bootstrap/upstream/bend2/base.bend",
  "runtime": "final-fixedpoint/runtime.mjs",
  "driver": "../../tools/typed-driver.mjs",
  "referenceAdapter": "../../tools/conformance/adapters/upstream.mjs",
  "cpu": 1,
  "repetitions": 3,
  "timeoutMs": 120000,
  "requireBendBytes": true,
  "variants": [
    {
      "id": "historical-h", "kind": "bend",
      "api": "baseline/api/h.mjs",
      "embeddedRuntime": "baseline/src/runtime.mjs",
      "provenance": ["baseline/manifest.json", "baseline/api/fixedpoint.json"]
    },
    {
      "id": "final-h", "kind": "bend",
      "api": "final-fixedpoint/stage2.mjs",
      "embeddedRuntime": "final-fixedpoint/runtime.mjs",
      "provenance": ["final-fixedpoint/report.json"]
    },
    {
      "id": "final-b1", "kind": "bend",
      "api": "native-integrated/api.mjs",
      "provenance": ["native-integrated/report.json"]
    },
    {"id": "pinned-ts", "kind": "typescript"}
  ],
  "workloads": [
    {"id": "tree", "input": "../../tests/fixtures/tree.bend", "expectedStatus": "ok", "expectedStdout": "42\n"},
    {"id": "list-sort", "input": "../../.bootstrap/upstream/tests/base/list_sort.bend", "expectedStatus": "ok", "expectedStdout": "6\n"},
    {"id": "bytes-ops", "input": "../../.bootstrap/upstream/tests/base/bytes_ops.bend", "expectedStatus": "error"}
  ]
}
```

Three repetitions use original/reverse/original variant order, so every pair alternates relative order. All samples run serially on the configured CPU. Node stack and heap are fixed at 4 MiB and 4 GiB. Generated-program execution time is recorded separately and is mainly startup latency for these small cases.

The runner checks the upstream pin and tracked cleanliness of both `bend2` and `tests`, freezes host helpers and its worker, verifies API/source/build provenance, and checks consumed identities before and after each sample. It understands the checked B1 integration report and the self-emission chain's source, Base, initial compiler, host driver and helpers. A still-running fixed-point report is copied before measurement: stage2 must already have succeeded with verified inputs and a matching hash, while `complete:false` remains explicit. **That stage2 artifact is provisional until the separate stage3 equality proof passes.**

Every observed diagnostic and check report is retained verbatim. Comparison uses exact status, phase, checked flag, exit status, diagnostic and check stdout. Additional host metadata is retained without pretending identical JSON schemas are required across different compilers. Successful emissions require expected execution output; Bend emissions additionally require byte equality by default. If any member of a workload/lane comparison fails, the whole comparison cell's medians are withheld. A partial set of passing samples is not presented as a clean speed comparison.

The final recorded matrix passed **96/96 samples**. Evidence is [final-small-compiler.json](../../../../implementation/phase3/final-small-compiler.json); it retains exact observations, the shared artifact inventory, and the complete raw report's hash. Request medians in milliseconds were:

| Request | Historical H | Final H | Final B1 | Pinned TS |
| --- | ---: | ---: | ---: | ---: |
| Tree parse | 975.84 | 982.15 | 481.05 | 148.18 |
| Tree check | 2634.83 | 2603.62 | 1075.50 | 370.03 |
| Tree emit | 3101.40 | 3141.11 | 1683.97 | 391.50 |
| List-sort parse | 1452.24 | 1467.69 | 712.20 | 151.90 |
| List-sort check | 5058.66 | 5078.09 | 2181.43 | 369.43 |
| List-sort emit | 5963.28 | 5879.71 | 2993.00 | 417.48 |
| Bytes-ops parse | 877.87 | 874.79 | 436.93 | 142.43 |
| Bytes-ops rejection | 25716.42 | 2228.13 | 798.41 | 358.92 |

Positive H compilation was effectively unchanged in these small samples. Exact negative diagnostics became 11.54× faster for bytes-ops. Final H emission remained 8.02× slower than TS for tree and 14.08× for list-sort; final B1 ratios were 4.30× and 7.17×. These are workload-specific request measurements with the cache and shared-host scope above, not a whole-compiler speedup. The recorded self-emission proof was incomplete at measurement start; its verified stage2 identity remains in the evidence for linkage to the separate fixed-point proof.
