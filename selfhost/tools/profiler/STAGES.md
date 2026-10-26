# Exact native stage observations, version1

These utilities associate sampled native execution with **data-defined stage
boundaries**. They work with the existing native Bend dispatcher and retained
program object. They do not change a Bend program, weaken a checker or run an
optimization. A stage is a declared entry boundary, not a logical call stack.

Status: the generic observer passes retained full-compiler and small Lexer
captures plus10 synthetic contract tests. The versioned generic runtime/map
also passes a fresh native Lexer gate:192 samples, the complete independent
577,297-byte QBE oracle, exact marker addresses/order and a pinned native-v1
sidecar. See `selfhost/build/phase144/generic-gate01/qualification.json` and its
replay plan. This qualifies that sequential workload and packaging, not every
program or instrumentation neutrality. Use a small independent-output gate
when defining new boundaries before a large capture.

## Describe the actual program

First create an exact owner map with the existing tool:

```sh
python3 -B selfhost/tools/profiler/owners.py \
  --qbe PATH/program.ssa --output FRESH/owners.json
```

Create a `bend-native-stage-spec-v1` JSON file. `ownerMap`, `programObject` and
`unwindTable` are ordinary `{file,bytes,sha256}` pins. Each marker names an exact
FID and symbol from that map; IDs must not be guessed or reused after rebuilding
another program. Choose real direct dispatcher entries: a function inlined or
called as a private worker may have a definition but no dispatcher entry.

```json
{
  "schema": "bend-native-stage-spec-v1",
  "ownerMap": {"file": "ABS/owners.json", "bytes": 0, "sha256": "ACTUAL_HASH"},
  "programObject": {"file": "ABS/program.o", "bytes": 0, "sha256": "ACTUAL_HASH"},
  "unwindTable": {"file": "ABS/table.json", "bytes": 0, "sha256": "ACTUAL_HASH"},
  "markers": [
    {"label": "prepare", "fid": 123, "symbol": "EXACT_SYMBOL", "multiplicity": "once"},
    {"label": "consume", "fid": 124, "symbol": "EXACT_SYMBOL", "multiplicity": "first"},
    {"label": "optional_pass", "fid": 125, "symbol": "EXACT_SYMBOL", "multiplicity": "optional"}
  ],
  "requiredOrder": ["prepare", "consume"],
  "intervals": [
    {"label": "preparation", "begin": "prepare", "end": "consume"},
    {"label": "consumption and exit", "begin": "consume", "end": "@exit"},
    {"label": "optional suffix, nested", "begin": "optional_pass", "end": "consume"}
  ]
}
```

The example IDs and pins are placeholders. Marker labels are bounded ASCII
identifiers; interval labels are ordinary JSON prose. At most32 markers and a
65,536-entry FID space are admitted. Modes mean:

- `once`: required exactly once, in the declared required order.
- `first`: required at least once; its first entry is the ordered boundary.
  Later entries are counted, not silently reclassified as new stages.
- `optional`: separately observed. Absence or repeated entries makes an interval
  using it unavailable. It does not weaken the order of required stages.

All invocation counts and the first eight observations per marker are retained.
Truncation is explicit. Repeated optional entries do not imply a single interval.
Nested or overlapping intervals must not be summed. `@exit` is the runtime's
stage-output exit hook, not a claim that the entire process has finished.

## Materialize the diagnostic plan

An existing generic `runtime.py` plan supplies authenticated runtime source,
headers and compile/link flags. An existing successful CFI sampler build receipt
supplies the frozen sampler source, compiler and unwind table. Neither is changed.

```sh
python3 -B selfhost/tools/profiler/stages-build-v1.py \
  --spec ABS/stages.json \
  --runtime-plan ABS/original-diagnostic-runtime/plan.json \
  --sampler-build ABS/original-cfi-sampler/report.json \
  --out FRESH/stage-runtime
```

This command writes source files and a compatible `build-runtime.py` plan only.
It makes reversible support insertions and adds an exported atomic
`bend_sample_delivered_count` getter. **The asynchronous signal handler stays
byte-unchanged.** Clock reads occur only at selected dispatch entries. The exact
spec SHA256 is compiled into the bounded map and written to the sidecar.

The coordinator executes the frozen three-job build plan in the existing
resource guard: build the small sampler/runtime, then relink the same retained
program object. This does not compile the Bend program again. Bind actual build
products, the spec and all source/build receipts into a fresh ordinary profiler
manifest. Its pinned `sampler` must be the new ordinal sampler; its `binary` and
command must select the new diagnostic executable. Keep the independent output
oracle, one-thread command, CFI table and owner map. Use existing
`dispatchInstrumentation: true`, sample mode and counters disabled. Do not set
an events-output path.

No new environment override is required. The runtime derives the fresh sidecar
path from `BEND_SAMPLE_OUT`:

```text
samples.txt.stages-v1.json
```

Its schema is `bend-native-stage-observations-v1`. It records spec identity,
actual function addresses, invocation counts, clocks and delivered sample
ordinals. A missing, duplicated or reordered required stage invalidates the
stage capture. The ordinary output oracle must also pass.

## Observe an existing capture

```sh
python3 -B selfhost/tools/profiler/stages_v1.py observe \
  --spec ABS/stages.json --run ABS/capture/report.json --row 0 \
  --out FRESH/stage-report.json
```

This is offline. It verifies the capture's actual manifest/output contract,
inputs, ELF addresses and sampled-owner mapping. It writes an explicit versioned
sidecar binding containing the sidecar SHA256, capture SHA256, run receipt and
row index. It does not rewrite the original capture. Native v1 captures must
have pinned the exact spec in their manifest before execution.

`--legacy-dispatch-v1` is an explicit read-only bridge for the retained
`bend-sampled-dispatch-stages-v1` format. It preserves original FIDs, addresses,
labels, counts, clocks and ordinals. The old format retained only the first
observation of repeated render-drain entries; the bridge labels that limitation
and does not invent later timestamps. It also preserves the conditional marker
as an explicitly optional point. Failed legacy captures remain failed. This
bridge supports offline transfer tests, not relabeling old executables as the
new generic runtime.

## Interpretation and bounds

Measured entry intervals include scheduler transitions, continuation and
ownership work. Sample ordinals provide actual observed ordering, avoiding an
assumption that timer ordinal×period is a measured timestamp. Clock reads and
ordinal reads are not atomic with signal delivery, so one sample at each edge
is excluded from distributions. Unknown contexts stay in every denominator.
A short interval may have accurate diagnostic clocks but too few samples for
quantitative attribution; fewer than500 samples or failed loss/coverage checks
keeps its distribution descriptive.

Only a sequential main-thread sample stream is supported. The versioned runtime
refuses initialization or a selected marker on another thread. Physical leaves,
active dispatch and physical callers are different views and may overlap.
An active helper name does not reveal its source caller. Diagnostic durations
include instrumentation, sampling and possible code-layout overhead. Compare
with a clean pinned image before inferring a speed change. No confidence
interval, zero-overhead guarantee or general correctness theorem is implied.

Retained offline transfer evidence is under
`selfhost/build/phase144/generic-stages01/`: successful full/pilot reports,
exact-clock comparison, failed metadata attempt and method snapshot. The failure
came from an older binary-framed cache file with a `.json` extension; manifest
discovery now admits valid JSON documents by content, not extension alone.
