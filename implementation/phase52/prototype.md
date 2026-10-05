# Phase52 direct JavaScript prototype: measured checkpoints 02 and 03

The eight-point prototype value gate passed. Checked direct03 executes this
subset at **1.03522× pinned TypeScript**, versus **5.23997×** for the unchanged
Phase51 compiler in the same run: a **5.06169× speedup**. All eight points improved
over Phase51, and all 72 fresh timing samples passed their exact output oracle.
This is evidence for continuing the general direct backend, not a full-corpus
parity or release claim.

The first measured prototype, direct02, already improved the subset geometric
mean but regressed four cases. Its complete results remain preserved. Direct03
changes general call lowering and arity handling; it removes those regressions
on this screen. No benchmark source, input, expected result, or timing worker
changed between these runs.

## Comparison contract and method

The three roles are Phase51's selected legacy/guarded backend, the checked
Bend-written direct backend, and upstream TypeScript pinned at
`018751270e800bc222a93dad7f257083ee53a5f7`. Each reported ratio uses the
TypeScript median from its **own run**. The direct compiler provides the new
`upstream-compatible-direct-v1` callable/record contract. It does not promise
the legacy mutable `G`/descriptor interface. This is explicitly a new-contract
comparison, rather than silently replacing the old ABI in an old result.

The [frozen screen](../../selfhost/tools/performance/phase52/profiles.json)
mixes an RLE roundtrip, a larger example program, an expression interpreter,
a lexer, numeric recurrence, a generic row containing arrays, captured closures,
and a recursive tree benchmark. It was selected to expose different lowering
shapes and known gaps; it is not a random sample or an estimate of all programs.

Both acquisitions compiled eight distinct sources using the checked derived-B1
API and explicitly selected `backend:'direct'`. The emission receipts require
that backend tag, the frozen direct runtime identity, its presence in the
driver's consumed files, and its exact emitted prefix. The legacy runtime is
pinned as part of the attempt but is not prepended to direct programs.

Before each timing run, the unchanged execution worker checked every point with
zero warmup, zero calibration milliseconds, target 1 ms and maximum repetitions
1. Despite the convenient name “one-call smoke,” the retained worker performs
three checked invocations: first call, one calibration call, one measured call.
These smoke receipts make no speed claim.

Timing then used the unchanged `programs/run.py` and `programs/execute.mjs`:
three rotated rounds × eight points × three roles = **72 fresh processes per
run**. Each process checked its first call and every warmup, calibration and
timed result. The 60 profile uses at least three warmup calls and 350 ms warmup,
40 ms calibration, and a 150 ms target batch. The row observer includes all four
arrays, using the public layout appropriate to each role; serialization remains
inside the timed call. No compilation or diagnostics are included in the ratios.

## Exact timing results

Times below are median microseconds per call. A candidate/TS ratio below one
means the candidate was faster in that run.

| Point | 02 TS µs | 02 Phase51 µs | 02 direct µs | 02 direct/TS | 03 TS µs | 03 Phase51 µs | 03 direct µs | 03 direct/TS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| RLE roundtrip | 0.577389 | 31.694198 | 1.077734 | 1.86656 | 0.568814 | 31.814700 | 0.499258 | 0.87772 |
| Morning | 3.356012 | 192.175091 | 13.269572 | 3.95397 | 3.342346 | 192.103541 | 3.581166 | 1.07145 |
| Expression 128 | 9.358932 | 44.682274 | 27.407098 | 2.92844 | 8.818511 | 43.630385 | 9.878136 | 1.12016 |
| Lexer | 1671.425833 | 2594.947414 | 7747.081950 | 4.63501 | 1679.412989 | 2572.246328 | 1868.580469 | 1.11264 |
| Numeric recurrence 1024 | 8.149456 | 19.076125 | 32.162459 | 3.94658 | 7.648341 | 19.023558 | 7.648255 | 0.99999 |
| Complete generic row 32 | 6.953992 | 29.159356 | 22.737243 | 3.26967 | 6.553633 | 28.511365 | 7.302747 | 1.11431 |
| Closures 64 | 5.809258 | 9.481227 | 11.334585 | 1.95112 | 6.028646 | 9.513145 | 6.220564 | 1.03183 |
| Tree bitonic | 283.025351 | 387.541744 | 885.533234 | 3.12881 | 281.541108 | 384.694249 | 275.571766 | 0.97880 |

| Same-run geometric mean over eight points | Direct02 run | Direct03 run |
|---|---:|---:|
| Phase51 / TypeScript | 5.170823× | 5.239968× |
| Direct / TypeScript | 3.070041× | 1.035221× |
| Phase51 / direct speedup | 1.684285× | 5.061691× |

Direct02 improved RLE, Morning, expression and generic row, but was slower than
Phase51 on lexer, numeric recurrence, closures and tree. Direct03 improved all
eight: its speedups against the same-run Phase51 medians range from 1.37658×
(lexer) to 63.72401× (RLE). The largest recorded absolute within-batch half drift
was 29.51% in run02 and 19.24% in run03 across all roles. Three rounds and short
batches support this rejection screen, not precise claims of a few percent
advantage over TypeScript.

## Architectural finding and attribution limit

The main result is that the former multi-fold deficit on this varied subset is
not inherent to writing the compiler in Bend. General lowering to ordinary
JavaScript calls, native closures and upstream-compatible values can approach
the reference's execution speed without recognizing these benchmark names.

The checked02→checked03 snapshots change `direct/core.bend`,
`direct/model.bend`, and add `direct/calls.bend`. They introduce general call
analysis and selective forcing: acyclic known calls can remain ordinary direct
calls; tail-cycle handling and forcing are retained where needed. They also
raise common lambda prefixes within the checked type telescope and refine
expression/tail contexts and self-tail handling. The direct runtime and host
driver bytes are unchanged between these two checkpoints.

The removal of four regressions is consistent with avoiding unnecessary
trampoline/forcing and partial-call overhead in ordinary code. However, these
changes were measured together. There is no isolated ablation assigning a
percentage to call analysis, arity raising, tail handling, or the JavaScript
engine's response. Likewise, comparing the new contract to the legacy backend
does not isolate mutable-interface guards from all other representation and
lowering changes.

## Iteration cost and resources

Node was 24.18.0. Heavy work was serialized with a 1 GiB V8 heap, 2 GiB
process-tree RSS limit and 4 GiB available-memory floor. Checked compiler builds,
emissions and timings used CPU3; build/emission and timing commands used a
4096 KiB stack. The smoke worker used Node's default stack. RSS polling is not
a kernel hard limit and summed process-tree RSS may double-count shared pages.

| Recorded operation | Direct02 wall seconds | Direct02 peak tree RSS bytes | Direct03 wall seconds | Direct03 peak tree RSS bytes |
|---|---:|---:|---:|---:|
| Guarded checked build, including workflow qualification | 56.872707 | 1,486,135,296 | 56.890582 | 1,467,514,880 |
| Eight serial checked emissions, sum of child walls | 41.628306 | 552,914,944 | 42.286186 | 568,897,536 |
| Eight output smoke children, summed walls | 0.673822 | 69,304,320 | 0.635587 | 63,389,696 |
| Complete 72-sample comparison, controller wall | 57.658198 | 99,590,144 | 58.486885 | 99,684,352 |

These are recorded job costs, not a complete accounting of human/agent analysis,
coding, orchestration or elapsed phase time. They deliberately do not add nested
bootstrap/equality timings to the outer build. The measured build-to-screen
work is about 2.6 minutes per checkpoint, excluding intervening work and small
controller overhead outside the separately reported child sums. This preserves
a useful short iteration loop before the more expensive final corpus gate.

## Artifact and receipt identities

The [compact tracked packet](../../selfhost/tools/performance/phase52/evidence/prototype/README.md)
contains verbatim completed reports and input/output identities for GitHub
review. Its [index](../../selfhost/tools/performance/phase52/evidence/prototype/index.json)
maps copies to original `selfhost/build/phase52/` paths and SHA256 hashes.
Absolute paths inside copied receipts remain historical provenance. Full checked
attempts, raw execution modules and most per-scenario files are not duplicated.
The raw evidence remains open; this packet is not a final archive or release.

| Identity | Direct02 | Direct03 |
|---|---|---|
| Checked API SHA256 | `2e82befa2d61945012d433fc92981cf852779c2ff89b43877d7fcd26930caf3e` | `4604934649a93a548ae3c225b42b18a4b9f7b161b422d0655679f1c4cf31c4a3` |
| Compiler source SHA256 | `4718073400bf0c627177adfef42c1d474a6cb2cee742e15c772a6eddd8e36afa` | `73d35e50e26179b26d2f4564dd2904f687e9caccaa97267ac5bf75fb2a48591d` |
| Attempt receipt | [checked-direct02/attempt.json](../../selfhost/build/phase52/checked-direct02/attempt.json) | [checked-direct03/attempt.json](../../selfhost/build/phase52/checked-direct03/attempt.json) |
| Attempt receipt SHA256 | `d04d462cdc5e020eb2ca10f0e7086d66d410f1e4b6078172e0d7c2801ccc4090` | `28cf736d943b9470e28a4b545a06365a99e9e8f27665ea0d457c756039dee534` |
| Preparation manifest | [prepared-direct02/manifest.json](../../selfhost/tools/performance/phase52/evidence/prototype/prepared-direct02/manifest.json) | [prepared-direct03/manifest.json](../../selfhost/tools/performance/phase52/evidence/prototype/prepared-direct03/manifest.json) |
| Preparation manifest SHA256 | `8e814c1cf398d7c80e5bb6ead6cd8525add57e8eba7fd99fe6eccc05d28917b9` | `62f5ceb5d1e3b8d8f0274f744e84fa6cf9b4ee6fa864ac80d609ed9bdd139a61` |
| Smoke receipt | [smoke-direct02/report.json](../../selfhost/tools/performance/phase52/evidence/prototype/smoke-direct02/report.json) | [smoke-direct03/report.json](../../selfhost/tools/performance/phase52/evidence/prototype/smoke-direct03/report.json) |
| Smoke receipt SHA256 | `5a48c709e2089fb9bdc7a02710184db1b4e863f68d192d70b38518b969549006` | `466b1ffe68e1efef296a4875a101ca3be9bd3ed03bd903ca84600b81342ccd41` |
| Timing receipt | [screen-direct02/report.json](../../selfhost/tools/performance/phase52/evidence/prototype/screen-direct02/report.json) | [screen-direct03/report.json](../../selfhost/tools/performance/phase52/evidence/prototype/screen-direct03/report.json) |
| Timing receipt SHA256 | `58fa3a49086c671515ab0d04f82ed7d98ac80d86b7934ef60e553b1b2784224b` | `4d29c795acc81a7dce0062ec0fae367880bf37b34094ae3463f71e612cab8316` |
| Explicit comparison contract | [screen-direct02/phase52-comparison.json](../../selfhost/tools/performance/phase52/evidence/prototype/screen-direct02/phase52-comparison.json) | [screen-direct03/phase52-comparison.json](../../selfhost/tools/performance/phase52/evidence/prototype/screen-direct03/phase52-comparison.json) |
| Contract receipt SHA256 | `393120189ddf34e659b3918a43ad60c5c90a0e6d36de87ae4a89551135742e9d` | `d64e2c49ef3c43d92c92c913071b1759d60d51021261aca53ea5c2fab5458d56` |

Both direct runtimes have SHA256
`417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a`;
both frozen typed drivers have
`7adba9713be6b73b77082fb3d93170e4d8f27ccf673ea7e16b0937433e93d6ec`.
The unchanged [reference manifest](../../selfhost/tools/performance/phase52/evidence/prototype/reference01/manifest.json)
is `b64c2be861da1a69dc51cfddae6d90c64942d1e9a106ae240cb18752b6117930`.
It binds the exact saved Phase51 API
`c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`
and legacy runtime
`3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`
alongside the pinned TypeScript outputs. The unchanged execution worker is
`5a37e3bdcc390cdc9a9745fcfacdcca75fc8a16a5b02405345aa618f770692c5`.

The build resource receipts are
[build-guard02/run.json](../../selfhost/tools/performance/phase52/evidence/prototype/build-guard02/run.json)
(`d704a3b9665597666e9faa0ef3728200639b50ca15c5eb05c0237ccff8866270`)
and [build-guard03/run.json](../../selfhost/tools/performance/phase52/evidence/prototype/build-guard03/run.json)
(`383782cccba8bbd42f2eedc7aaa2b1dd69399bc85b95caa66d4b7d1d029fabd3`).
Per-emission commands/resources and the row adapter are in each preparation's
`preparation.json`; per-process timing commands/resources and values are embedded
in the timing receipts and retained sample files.

## Independent direct03 library semantics

A separate [differential report](../../selfhost/tools/performance/phase52/evidence/prototype/semantic-direct03-controls01/report.json)
passed **55/55 scenarios across 14 library fixtures** for the exact checked03
image against pinned upstream. This includes callable currying/partial calls,
erasure, returned closures and recursive factories, named ADTs/getter order,
Nat and F32 boundaries, Unicode/Char behavior, selected mutable host hooks, and
a 50,000-step tail witness. The report SHA256 is
`11bcfd2a8a166d6c5cf897c4b01ad0be179ca2410123313fc8ee77cafb7c2240`.

The explicit [subset catalog](../../selfhost/tools/performance/phase52/evidence/prototype/catalogs/semantic-catalog-library-v1.json)
comes from the full 18-fixture/59-scenario catalog. Four program/FFI fixtures
remain excluded and unqualified here: `marshal_erased_binders`,
`shared_module_state`, `foreign_arrow_arity`, and `marshal_nat_bigint`.
The [upstream-only reference run](../../selfhost/tools/performance/phase52/evidence/prototype/semantic-reference-controls03/report.json)
passed all59 independent expectations, but is not a candidate differential pass.

Earlier reference runs exposed sandbox subprocess refusal and test-harness
mistakes: five Nat public-result expectations used the wrong host type, four
programs used the wrong JavaScript module host, and Array.isArray hook logging
could recursively instrument the controller itself. Corrected versioned
controllers/oracles preserve those failures; the [packet index](../../selfhost/tools/performance/phase52/evidence/prototype/index.json)
pins the two large failed raw reports without duplicating their stacks. A
nested-lock acquisition refusal is also retained separately. These are explicit
harness/environment corrections, not omitted candidate semantic failures.

## Limits and next gate

This checkpoint has eight benchmark output oracles and the separate 55-case
library semantic gate described below, not completed language/FFI coverage. It does not establish full45 performance, all deep
recursion behavior, compiler request cost, installed-release usability, or
equivalence to the additional legacy descriptor interface. Subsequent core,
tail-cycle, export or FFI changes require fresh selected-image checks; the
direct03 timing rows cannot be relabeled as measurements of a later image.

The next selected image should compile all45 unchanged points, pass its
independent semantic controls, and run the three frozen fifteen-point batches.
Use the commands below only after the lead freezes and authorizes that image.
`checked-direct04` is a planned label, not a completed result here. All output
directories must be fresh; change the attempt and output suffix together if the
selected image is a later version. Run serially, with an unpinned parent so the
existing children can select CPU3.

```bash
python3 selfhost/tools/performance/phase52/prepare-v2.py \
  --attempt selfhost/build/phase52/checked-direct04 \
  --catalog selfhost/tools/performance/phase37/catalog.json --set full \
  --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out selfhost/build/phase52/prepared-direct04-full

python3 selfhost/tools/performance/phase52/smoke.py \
  --manifest selfhost/build/phase52/prepared-direct04-full/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase52/smoke-direct04-full
```

The following three invocations share the same catalog, baseline, candidate,
Node, resource settings and 600 profile; only `--cases` and the fresh `--out`
differ. They correspond exactly to `full45Batches` in `profiles.json`.

```bash
python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct04-full/manifest.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 600 \
  --cases local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32,mandelbrot,editdist,tree-bitonic,lexer,symreg,test-morning-program,test-evening-program,test-rle-roundtrip,test-map-set-ops,raytrace \
  --out selfhost/build/phase52/full-direct04-batch0

python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct04-full/manifest.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 600 \
  --cases variation-editdist-0-17,variation-editdist-3-123,variation-lexer-6-17,variation-lexer-10-123,variation-tree-bitonic-6-17,variation-tree-bitonic-9-123,variation-symreg-4-17,variation-symreg-7-123,variation-local-fold-128-0,variation-local-fold-8192-123,variation-mandelbrot-grid-4-7,variation-mandelbrot-grid-5-31,variation-ray-active-64-2440,variation-ray-active-256-2240,coverage-closures-64 \
  --out selfhost/build/phase52/full-direct04-batch1

python3 selfhost/tools/performance/phase52/compare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase52/reference01/manifest.json \
  --candidate selfhost/build/phase52/prepared-direct04-full/manifest.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 600 \
  --cases coverage-closures-256,coverage-list-pipeline-128,coverage-list-pipeline-512,coverage-unicode-text-16,coverage-unicode-text-64,coverage-map-churn-32,coverage-map-churn-128,coverage-numeric-recurrence-256,coverage-numeric-recurrence-1024,coverage-bst-32,coverage-bst-64,coverage-expression-32,coverage-expression-128,coverage-record-aggregation-64,coverage-record-aggregation-256 \
  --out selfhost/build/phase52/full-direct04-batch2
```

Expected completed sample counts are 219, 225 and 225 (669 total), reflecting
the retained three-round exception for the expensive `raytrace` point. A
deadline, failed oracle or incomplete rotation remains a failed/incomplete gate;
do not silently aggregate only the successful subset. The 600 profile is a
bounded runner configuration, not a promise that every requested batch completes.
