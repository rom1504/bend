# V8-aware generated-program diagnostics

Phase49 adds bounded inspection of V8's optimization decisions to the existing
[CPU/allocation/AST diagnostics](../programs/DIAGNOSTICS.md). Start with a measured
slow program and a specific question. The [completed RLE report](../../../../implementation/phase49/README.md)
shows why constructor counts alone missed the dominant entry-check cost.

The installed compiler is unchanged. `inputs/` contains exact historical
TypeScript, array06 and rejected values03 RLE modules, with provenance in
`inputs/manifest.json`. Current RNFA04's RLE module is byte-identical to array06.
The baseline is not the TypeScript implementation of our compiler: it is a Bend
program compiled through the respective backends.

## Small reusable driver

`v8-probe.mjs CONFIG_JSON NEW_OUT` invokes a numeric-result public export,
checks every result with `Object.is`, consumes it in a U32 digest, and records
input hashes, the exact Node executable, phase markers and resource usage.
It imports the existing CPU/allocation summarizers without executing their CLI.
It does not rebuild or instrument the generated module.

```json
{
  "module": {"path": "/absolute/path/to/module.mjs", "sha256": "EXACT_SHA256"},
  "exportName": "main.out",
  "args": [],
  "expected": 11,
  "calls": 32768,
  "warmups": 16384,
  "mode": "cpu"
}
```

Choose `clean`, `cpu`, `allocation` or `trace`. Profiles include only the repeated
public-call window plus profiler boundary overhead, with import/first call/warmup
separated. Allocation sampling includes collected objects and estimates bytes
per completed call. Preserve unattributed mass and accounting warnings. The
harness itself contributes some cost; it is identical within each comparison.
Other observer/result types remain available through the maintained diagnostic
runner rather than this small numeric-result probe.

Use `run-probes.py` to retain the normal guard and avoid unbounded execution.
Its `--jobs` input is a JSON list such as:

```json
[
  {"label":"baseline-cpu", "config":"/absolute/path/to/baseline-cpu.json"},
  {"label":"baseline-trace", "config":"/absolute/path/to/baseline-trace.json",
   "flags":["--trace-opt","--trace-deopt","--trace-turbo-inlining","--trace-gc-nvp"]}
]
```

Each config must use the corresponding mode. The queue records commands, inputs,
stdout/stderr, process limits and success/failure. It runs one target at a time,
uses CPU3, a 1 GiB Node heap, 2 GiB tree-RSS limit and 4 GiB available-memory floor,
and limits each output file to 64 MiB. It pins this workspace's Node24.18.0 path;
the driver records its actual V8 version and executable hash.

```sh
python3 selfhost/tools/performance/phase49/run-probes.py \
  --jobs /absolute/path/to/fresh-jobs.json \
  --out selfhost/build/phase49-live/cpu-trace-NEW --seconds 45
```

Create genuinely fresh configs/output paths. Adjust module paths and recheck
hashes when replaying in another checkout; do not edit historical receipts.
No profile, trace or forced-optimization duration belongs in a clean timing
aggregate. Run several fresh rotated clean processes for any claimed speedup.
For fast TypeScript exports, use enough calls to avoid a roughly 10 ms window.

## Inspect the optimizer, then selected machine code

Trace mode requires `--trace-opt --trace-deopt`. Inlining output can reveal
candidate/selected calls, while phase markers distinguish setup, warmup and
measurement. `--trace-turbo-inlining` is global in this V8 version; a graph filter
does not restrict its log. Bind function names to exact source positions and
module hashes, because names may repeat.

For a filtered graph/code run, set the job's `driver` to the absolute path of
`v8-probe-graphs.mjs`, use a trace config, and supply:

```json
[
  "--trace-opt", "--trace-deopt",
  "--trace-turbo", "--trace-turbo-graph",
  "--trace-turbo-filter=$native10",
  "--trace-turbo-path={dump}",
  "--trace-turbo-cfg-file={dump}/graph.cfg",
  "--print-opt-code", "--print-opt-code-filter=$native10"
]
```

The queue replaces `{dump}` with a fresh per-job directory before Node starts.
Keep the function name as literal JSON text; shell expansion of `$native10`
would destroy the filter. The graph driver adds only reviewed flag validation
to the original driver; `probe-graphs-derivation.json` pins that exact difference.

Inspect graphs with compatible
[Turbolizer](https://chromium.googlesource.com/v8/v8/+/refs/heads/main/tools/turbolizer/README.md),
or read the graph JSON and disassembly as in the [IR report](../../../../implementation/phase49/v8-ir.md).
First require valid complete JSON and the intended function/source identity.
A passing public-call job can still leave an unfinished graph; Phase49 preserves
one such failure and a successful fresh longer run. Do not repair partial JSON.
Final zero `Allocate` nodes can mean lowering into memory operations and runtime
slow paths, not allocation elimination.

`--trace-turbo-escape` is debug-only in this pinned release; inspect successive
graph phases instead. `--trace-turbo` enables concurrent tracing in this version,
so older claims that it always disables concurrent compilation are unreliable.
V8 behavior must be checked against the actual bundled source, not generic flag
recipes. No tier disabling or forced optimization was needed for this campaign.
The current tools do not yet integrate IC/map logs or Linux hardware counters;
those are optional next diagnostic layers, not claimed completed features.

## Preserved experiment and safety boundary

`derive-guard-probe.py --out FRESH_PHASE49_RAW_DIR` reproduces three exact
single-condition diagnostic derivatives from pinned modules. It performs no
target execution. These deliberately omit checks and are **unsafe under the
current public contract, unchecked and ineligible for installation**. Their
clean-host timings identify an opportunity; they do not authorize guard removal.
Once the Phase49 raw root is closed, recover the retained products or make a
versioned successor recipe instead of appending new files there.

`summarize.py --raw RECOVERED_RAW --out NEW_JSON` recomputes the recorded
campaign comparison where original absolute input paths remain available. It
checks module/config/driver/profile identities and nonoverlapping target jobs.
Historical receipts retain their absolute paths; the raw capsule is an audit
artifact, not a promise that every historical command relocates unchanged.

See [evidence and recovery](evidence/README.md) for the complete frozen campaign.
