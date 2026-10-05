# Final direct-backend comparison and publication plan

Status: the lead selected frozen `checked-direct06` after rejecting the ordered
IIFE07 experiment. Its separate semantic suite passes95/96 scenarios; the one
pre-existing NaN-payload case remains failed (TypeScript1, direct39, independent
source oracle40). This prevents a blanket semantic/full-conformance claim.
The atomic06 screen measured1.074256× benefit against05, below its prewritten
1.10× target. The lead explicitly retains06 for its five>5% source improvements,
no>10% screen regressions and exact byte proof; this is a selection judgment,
not a retroactively passed threshold. Every final benchmark oracle remains
mandatory. Direct mode remains explicit and has the documented semantic limit.
Final06 acquisition, all45 smoke oracles and all three timing batches are
complete:45 points/23 sources/669 fresh passing samples. The aggregate is
`selfhost/build/phase52/full-direct06-aggregate/report.json`, SHA256
`9e3debe07b378a48e1b3f1850b61f15fbd2b34a79f5d6abca114eb037bec150b`.
No direct03 or incomplete05 timing row is reused. Both portable bundles are now frozen and reopened through the maintained
reader:45 cases and135 role/point mappings match the measured acquisitions.
Release qualification remains a separate step.
The Phase51/TypeScript reference remains the frozen `reference01` bundle.

Historical checkpoint: direct05 checked acquisition and smoke passed all45 points.
Batch0 completed15 points/219 samples in368.268s; batch1 completed15 points/225
samples in380.042s. At the lead's request, batch2 was held before starting while
a general primitive-lowering successor is considered. Thus only30/45 points and
444 samples are measured for05 at this checkpoint. No full45 aggregate or chart exists for05. Both completed05 reports remain
unaltered. The commands below are a reproducible method; consumed06 output
directories now exist and must not be overwritten. A replay needs fresh paths.

The public contract is `upstream-compatible-direct-v1`, not the additional
legacy mutable-G interface. Selected API, direct runtime, frozen driver, Base,
source book, catalog and emitted-module identities must agree throughout.
All output directories must be fresh. Executable controllers have unpinned
parents and own the shared serial CPU3 execution lock. Every target gets a
1GiB heap,2GiB process-tree RSS limit and4GiB available-memory floor. The inherited
target worker uses a4096KiB stack; smoke uses the default Node stack. No concurrent
build, compiler request, profile, compression or other benchmark is permitted.

## Next selected image: choose once before running

The commands below are parameterized for the next full campaign. After the lead
selects checked direct06 or direct07, set one variable and retain its value for
all acquisition, smoke, three batches, aggregation and candidate packaging:

```bash
PHASE52_IMAGE=direct06
```

Use `direct07` instead only if that image is selected and frozen. This variable
does not authorize execution. A fresh complete campaign needs23 source
acquisitions,45 smoke points and219+225+225 timing samples; the incomplete05
batches remain historical evidence and are not mixed into the new aggregate.
The same fixed Phase51/TypeScript reference01 remains the full-corpus baseline.
The separate atomic experiment uses direct05 as its baseline, and the ordered
experiment uses direct06. Neither is the Phase51 full-corpus denominator.

## Acquisition and exact-output gate

Use the reviewed successor worker for the full driver. It permits either no
host prefix or the one exact ESM `createRequire` prefix, immediately followed by
the exact checked direct-runtime bytes. The original consumed prototype tools
remain unchanged and pinned as predecessors.

```bash
python3 selfhost/tools/performance/phase52/prepare-v2.py \
  --attempt "selfhost/build/phase52/checked-$PHASE52_IMAGE" \
  --catalog selfhost/tools/performance/phase37/catalog.json --set full \
  --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out "selfhost/build/phase52/prepared-$PHASE52_IMAGE-full"

python3 selfhost/tools/performance/phase52/smoke.py \
  --manifest "selfhost/build/phase52/prepared-$PHASE52_IMAGE-full/manifest.json" \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out "selfhost/build/phase52/smoke-$PHASE52_IMAGE-full"
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
  --candidate "selfhost/build/phase52/prepared-$PHASE52_IMAGE-full/manifest.json" \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 600 \
  --cases "$(python3 -c 'import json,sys; print(",".join(json.load(open("selfhost/tools/performance/phase52/profiles.json"))["full45Batches"][int(sys.argv[1])]))' "$PHASE52_BATCH")" \
  --out "selfhost/build/phase52/full-$PHASE52_IMAGE-batch$PHASE52_BATCH"
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
  --attempt "selfhost/build/phase52/checked-$PHASE52_IMAGE" \
  --candidate "selfhost/build/phase52/prepared-$PHASE52_IMAGE-full/manifest.json" \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --smoke "selfhost/build/phase52/smoke-$PHASE52_IMAGE-full/report.json" \
  --reports "selfhost/build/phase52/full-$PHASE52_IMAGE-batch0/report.json" \
            "selfhost/build/phase52/full-$PHASE52_IMAGE-batch1/report.json" \
            "selfhost/build/phase52/full-$PHASE52_IMAGE-batch2/report.json" \
  --out "selfhost/build/phase52/full-$PHASE52_IMAGE-aggregate"
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
  --from "selfhost/build/phase52/prepared-$PHASE52_IMAGE-full/manifest.json" \
  --attempt "selfhost/build/phase52/checked-$PHASE52_IMAGE" \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/tools/performance/phase52/bundles/current

taskset -c 0 python3 selfhost/tools/performance/phase52/freeze-baseline-v2.py \
  --current selfhost/tools/performance/phase51/bundles/current/manifest.json \
  --reference selfhost/tools/performance/phase51/bundles/baseline/manifest.json \
  --verified-reference selfhost/build/phase52/reference01/manifest.json \
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


## Completed packaging checkpoint

The current archive contains178 preserved members (520,407 compressed bytes);
the baseline archive contains57 members (2,365,007 compressed bytes). The
maintained reader reopened all archived modules, and all135 role/point hashes
match `prepared-direct06-full` plus `reference01`. The data-only verification
receipt is `selfhost/build/phase52/portable-verification06.json`, SHA256
`012278f03c9ecf97790fdaaa719382624b36ebe1b120735e4ba555adbff6952d`.
No generated program was executed by that reader check.

The inherited baseline freezer first failed because Phase51 uses a minimal
manifest/archive schema without an adjacent provenance receipt. Its original
producer and72 extracted work files are retained under
`selfhost/build/phase52/baseline-freeze-v1-failure/`. The reviewed versioned
successor explicitly joins the actual Phase51 archives to the previously frozen
reference01 derivation and verifies all45 two-role hashes. It does not invent a
missing preparation receipt. The successful successor preserves this schema
correction in its provenance; the failed producer remains unchanged.

The [generated-code packet](../../../../implementation/phase52/generated-code/README.md)
contains exact selected/TypeScript RLE, lexer and expression modules and their
catalog Bend sources. Runtime support remains included; these are source-shape
examples, not independent performance measurements.
