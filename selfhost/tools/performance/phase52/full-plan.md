# Final direct-backend comparison and publication plan

Status: prepared, not executed by this plan. The lead selects one checked image
only after its independent semantics pass. `checked-direct05` is the prospective
label below; change every05 attempt/output suffix together if a later image is
selected. Never reuse the direct03 timing rows as measurements of that image.
The Phase51/TypeScript reference remains the frozen `reference01` bundle.

The public contract is `upstream-compatible-direct-v1`, not the additional
legacy mutable-G interface. Selected API, direct runtime, frozen driver, Base,
source book, catalog and emitted-module identities must agree throughout.
All output directories must be fresh. Executable controllers have unpinned
parents and own the shared serial CPU3 execution lock. Every target gets a
1GiB heap,2GiB process-tree RSS limit and4GiB available-memory floor. The inherited
target worker uses a4096KiB stack; smoke uses the default Node stack. No concurrent
build, compiler request, profile, compression or other benchmark is permitted.

## Acquisition and exact-output gate

Use the reviewed successor worker for the full driver. It permits either no
host prefix or the one exact ESM `createRequire` prefix, immediately followed by
the exact checked direct-runtime bytes. The original consumed prototype tools
remain unchanged and pinned as predecessors.

```bash
python3 selfhost/tools/performance/phase52/prepare-v2.py \
  --attempt selfhost/build/phase52/checked-direct05 \
  --catalog selfhost/tools/performance/phase37/catalog.json --set full \
  --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out selfhost/build/phase52/prepared-direct05-full

python3 selfhost/tools/performance/phase52/smoke.py \
  --manifest selfhost/build/phase52/prepared-direct05-full/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase52/smoke-direct05-full
```

Expected acquisition: all45 points from23 distinct sources, with checked-emission
sidecars and the complete generic-row observer. Expected smoke:45 cases pass;
each retained execution worker checks first call, one calibration call and one
measured call. This smoke is an output gate, not speed evidence. Stop timing if
any acquisition or oracle fails; retain all attempted outcomes and report the
case, actual diagnostic and selected image. No extra eight-point screen is needed.

## Three serial timing batches

Use the same command three times with `PHASE52_BATCH` set to0,1,2 in that order.
The shell variable is only a selector into the frozen [profiles](profiles.json).
The command substitution reads JSON; it does not execute generated programs.
Do not begin the next batch unless the previous report has all15 cases complete
and passing. Each command has a fresh output directory.

```bash
PHASE52_BATCH=0
python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct05-full/manifest.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 600 \
  --cases "$(python3 -c 'import json,sys; print(",".join(json.load(open("selfhost/tools/performance/phase52/profiles.json"))["full45Batches"][int(sys.argv[1])]))' "$PHASE52_BATCH")" \
  --out "selfhost/build/phase52/full-direct05-batch$PHASE52_BATCH"
```

The600 preset is unchanged: five rotated rounds, at least three warmup calls and
1000ms warmup,50ms calibration and300ms target batches. The expensive `raytrace`
point retains its three-round exception. Expected samples are219,225,225:669
fresh processes total. Every call keeps its exact oracle. An incomplete batch is
not silently shortened, replaced with a faster point or given a historical
denominator. The budget is bounded; completion is required rather than assumed.

## Aggregate only completed evidence

After all three reports pass, run the data-only [aggregator](aggregate.py).
It never imports a generated module or compiler API.

```bash
taskset -c 0 python3 selfhost/tools/performance/phase52/aggregate.py \
  --attempt selfhost/build/phase52/checked-direct05 \
  --candidate selfhost/build/phase52/prepared-direct05-full/manifest.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --smoke selfhost/build/phase52/smoke-direct05-full/report.json \
  --reports selfhost/build/phase52/full-direct05-batch0/report.json \
            selfhost/build/phase52/full-direct05-batch1/report.json \
            selfhost/build/phase52/full-direct05-batch2/report.json \
  --out selfhost/build/phase52/full-direct05-aggregate
```

The output schema records:

- 45 unique point rows and23 source groups, all669 samples required; point medians
  and ratios are recomputed from retained samples, not copied from prose.
- Equal-point geometric means across45 ratios, and equal-source geometric means
  formed by first taking the geometric mean within each source then weighting
  the23 sources equally. Repeated inputs do not give their source extra weight
  in the latter metric.
- Same-run Phase51/TS, direct/TS and Phase51/direct ratios; minimum/maximum and
  their point IDs; all slowdowns relative to Phase51 and TypeScript, plus a
  descriptive >10% slowdown list. These counts are not significance tests.
- Per-role absolute half drift >20% and fresh-round maximum/minimum >1.2 flags.
  Flagged points remain in every aggregate. Absence of a flag does not establish
  JIT convergence. The raw reports retain first-call/import times and all samples.
- Whole generated-module sizes, with duplicate hashes counted once and separate
  point-mapped totals. Runtime/observer bytes are included; this is not an
  executable-instruction or memory-allocation count.
- Exact attempt/API/direct-runtime/Base/driver/source and catalog identities,
  successful checked acquisitions, matching smoke modules, selected contract
  receipts, and a final rehash of all consumed evidence.

`report.md` gives the full unfiltered table; `ratios.svg` is a standalone paired
log₂-axis plot of all45 direct/TS and same-run Phase51/TS ratios. Each plotted
point uses its own same-run TypeScript denominator. Prototype eight-point
geometric means are documented separately and never plotted as full45 results.

If an oracle fails, publish the failure separately and do not call the successful
subset “full45.” The aggregator deliberately refuses incomplete input rather
than emitting a misleading full-result chart.

## Portable benchmark outputs and review examples

Only after timing, use the small reviewed successors of the existing Phase44
freezers. They perform data copying/compression, not compilation/execution.
The candidate successor changes the generic-row observer proof to the explicit
direct/TypeScript field layout, binds direct-runtime and emission inputs, retains
the new contract field, and preserves the inherited streamed archive/reopen
verification. The original method remains untouched and identity-pinned.

```bash
taskset -c 0 python3 selfhost/tools/performance/phase52/freeze-candidate.py \
  --from selfhost/build/phase52/prepared-direct05-full/manifest.json \
  --attempt selfhost/build/phase52/checked-direct05 \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/tools/performance/phase52/bundles/current

taskset -c 0 python3 selfhost/tools/performance/phase52/freeze-baseline.py \
  --current selfhost/tools/performance/phase51/bundles/current/manifest.json \
  --reference selfhost/tools/performance/phase51/bundles/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --expected-api c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061 \
  --expected-runtime 3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46 \
  --out selfhost/tools/performance/phase52/bundles/baseline
```

Before publication, verify every portable role/point hash against the original
selected acquisition/reference01, and run the maintained reader over all45.
The baseline freezer relabels exact Phase51 candidate bytes as the reference
baseline and preserves pinned TypeScript bytes; no baseline is recompiled.
“Current” identifies the selected benchmark artifact, not an installed-release
claim without the separate release gate. Never replace the preserved prototype
packet or Phase51 bundles.

Publish the selected aggregate JSON/Markdown/SVG and three original reports with
an identity index. Keep a compact representative generated-code comparison for
RLE, lexer and expression128: exact selected direct and pinned TypeScript module
bytes, source IDs/hashes, acquisition-sidecar hashes and a README noting that
runtime support is included. Select these examples for distinct code shapes;
do not edit code to make a visual comparison cleaner or give them independent
speed claims. The row's full public observer belongs in the full bundle even
though it is not one of these three examples.

The final complete raw capsule is a different operation. Stop all raw writers
first, preserve protected historical identities, capture with a bounded streaming
archive, independently reopen/hash members, and write the final external index.
No active-tree archive or compression may overlap the timing batches. The lead
owns closure and the later installed compiler/release decision.
