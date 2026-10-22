# Phase126 final validation recipes

These are root-only execution recipes. This preparation ran no compiler or
target. Substitute one final frozen source manifest and its checked API report
throughout. Retain failed attempts; never merge products from different source,
API, or runtime identities. The comparison parent is the selected Phase125
`verified-source06`, not the older Phase118 image.

## Broad hosted emission and execution

Use the unchanged `phase118/emit-integrated.mjs` and original
`phase112/benchmark45/manifest01.json`. Split `partitions.all45` in its frozen
order into batches of at most eight names (8/8/8/8/8/5). Each batch gets a fresh
output directory and subprocess; this limits retained hosted state and makes
an interrupted batch independently recoverable. There is no compiler
transformation in this batching. For each batch, root runs:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/final-emit-batch01-guard --seconds 300 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  env P118_RUNTIME_REPORT=selfhost/build/phase125/runtime-verified01/report.json \
  BUN selfhost/tools/performance/phase118/emit-integrated.mjs \
  FINAL_API_REPORT FINAL_SOURCE_MANIFEST \
  selfhost/build/phase118/p126-final-emit-batch01 CASE_NAMES
```

`BUN` is the exact executable from the checked API report. Replace batch01 for
each batch; do not launch batches concurrently. Prior completed final-source
batches may be reused only with exactly matching source/API/runtime and
disjoint case names. The existing merger authenticates these conditions:

```sh
python3 -B selfhost/tools/performance/phase125/merge-emissions.py \
  --out selfhost/build/phase126/final-emission01.json BATCH_REPORTS

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/final-screen01-guard --seconds 1200 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase126/screen.py \
  --emission selfhost/build/phase126/final-emission01.json \
  --out selfhost/build/phase126/final-screen01 --label final01 --rounds 3 --scale 4

python3 -B selfhost/tools/performance/phase126/summarize.py \
  --screen selfhost/build/phase126/final-screen01/report.json \
  --out selfhost/build/phase126/final-summary01.json
```

Before the screen, assert the merged names equal `partitions.all45` exactly.
Keep all 45 complete-output controls; only the original zero-work
`scalar-region-0` is omitted from the 44 timing ratios. The summary reports
same-run case/round medians, spread, geometric ratios to selected Phase125 and
upstream, positive log slowdown, threshold counts, original families, and
equal-observed-family aggregates. Three-case screens remain explicitly partial.
Do not use Phase125's hardcoded Phase124 broad-analysis denominator. At campaign
end, `summarize.py --account-guards` adds completed, nonoverlapping outer guard
durations; unfinished/missing receipts are not invented as elapsed work.

## Matched hosted compiler requests

Use unchanged `phase118/cost-v2.mjs`. The fixed two-case request set below
matches the previous checkpoint; extra requests are separate subsets.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/final-cost01-guard --seconds 300 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  env P118_PARENT_SELECTION=implementation/phase125/candidate.json \
  P118_PARENT_API_REPORT=selfhost/build/phase111/p125-verified06-api/report.json \
  P118_RUNTIME_REPORT=selfhost/build/phase125/runtime-verified01/report.json \
  P118_PARENT_EMISSION_REPORT=selfhost/build/phase125/broad-emission06.json \
  P118_EXPECT_EMISSION_REPORT=selfhost/build/phase126/final-emission01.json \
  BUN selfhost/tools/performance/phase118/cost-v2.mjs \
  FINAL_API_REPORT FINAL_SOURCE_MANIFEST \
  selfhost/build/phase118/p126-final-cost01 test-rle-roundtrip lexer
```

The method keeps one warmup and three rotated pairs, verifies exact expected
emission bytes for each producer, and measures request preparation, checking,
lowering, verification and rendering. Serialization/hash accounting is separate.
This is hosted request cost, not native qualification or target runtime. The
previous two-case guard took about 111 seconds and peaked below 1 GiB.

## Native checkpoint and storage

Use [native/README.md](native/README.md) and the new path-only `native/plan.py`.
It preserves exact source-contract replay, independent native source checking,
the aligned Phase123 assembler, all focused19/full45 oracles, and raw QBE
comparison. `native/rebind-abi.py` explicitly binds the new source/API to the
unchanged Phase125 runtime/authority before any native job. The old Phase125
ABI receipt remains immutable. The source must export all six required native
API functions; a smaller API requires a fresh checked acquisition.

Measured Phase125 native06 evidence:

| Stage | Seconds |
| --- | ---: |
| Hosted full emission | 742.68 |
| N1 build | 12.94 |
| N1 focused19 | 22.14 |
| Native self-emission and N2 build | 438.70 |
| Raw QBE comparison | 1.62 |
| N2 focused19 | 21.57 |
| N2 full45 | 112.53 |
| Entire guarded plan | 1353.10 |

Source receipts are `phase113/p125-native06-qualification/report.json` and
`phase125/p125-native06-qualification-guard/process.json`. Peak tree RSS was
5,538,947,072 bytes (5.159 GiB); minimum available memory was 19.779 GiB. The
6 GiB cap therefore had approximately 0.841 GiB historical margin. Raw QBE was
93,049,182 bytes; assembly 68,668,267; object 20,316,352; N1 ELF 15,227,496.
The 128 MiB file limit admits those historical products, not arbitrarily larger
ones. Default timeout is 4020 seconds (67 minutes); an observed 22.55-minute
run does not establish a new worst-case bound. Freeze early enough to retain
this window, or explicitly record any shortened budget and resulting refusal.

The prior artifact directories occupied 471,953,408 allocated bytes by path
(450.09 MiB) before counting shared inodes once; current unique physical size
is 286,412,800 bytes (273.14 MiB). Existing exact dedup already accounts for that
difference, so it cannot be recovered again. For a new chain, reserve roughly
450–550 MiB plus broad-screen products. At approximately 700 MiB free, the
chain can fit yet leave too little free space for the next guarded block:
the 128 MiB-file guard requires more than 416 MiB free at startup, and the
64 MiB-file guard requires more than 288 MiB.

After actual source-generation comparison, new hosted/self QBE, N1/N2 assembly
and object may be exact duplicates. The prior three pairs represented
182,054,912 allocated bytes (173.62 MiB). A separately recorded, exact SHA-256
**and byte comparison** can atomically hardlink such completed pairs while
preserving all paths/bytes. Do this only after both products and comparison
receipts exist; never assume equality from intended determinism, normalize
QBE, or link actively written files. The existing frozen dedup tool intentionally
excludes p126 artifacts and must not be reused blindly. There is no deletion,
compression, relocation, or automatic dedup step in the native adapter.

The old `phase125/native/timing-plan.py` still has Phase125 path/tag policy and
an optional Phase118 comparison block. Do not mislabel that as a matched
Phase125-parent comparison or substitute the old unaligned Phase118 builder.
If time remains after qualification, a separate explicit timing path/parent
adapter is needed; the hosted matched request recipe above is already usable.
