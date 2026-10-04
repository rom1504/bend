# Phase43 complexity and elapsed-time accounting

Read-only snapshot refreshed 2026-10-04T04:45:04.103376+00:00.
Protected baseline `714c5f5dbdc9a434e7272c21b6216c3a70f5a33c`; current checkout HEAD `0b97c465814cafa67f7b6822b462051bea3abd73` plus the selected checked14 source. The maintained 70-module compiler graph and
runtime are verified byte-for-byte against the canonical checkout by the selected
source binding. Other repository and tooling inventories describe this accounting
cutoff; later publication files are outside that inventory.
Generated compiler/module images and `selfhost/build` artifacts are excluded from
source/tool growth. Physical lines include blank lines/comments; Bend definitions
count declarations beginning `def` at column zero, not compiler AST nodes.

## Repository source inventory and maintained production graph

| Scope | Baseline files | Current files | Baseline lines | Current lines | Net lines | Baseline defs | Current defs |
|---|---|---|---|---|---|---|---|
| All selfhost/src Bend modules | 72 | 72 | 21595 | 22979 | 1384 | 2369 | 2533 |
| JS backend Bend modules | 16 | 16 | 6043 | 7427 | 1384 | 706 | 870 |

No new production Bend modules were introduced at this snapshot; growth expands existing JS backend modules.

### Comparable maintained production module graph

Phase42's published20,056lines/2,249defs/70modules count uses exactly the
`selfhost/src/compiler.json` module inventory, not every .bend file under src.
The protected baseline graph is verified here against every frozen per-file
SHA256 in `selfhost/tools/performance/phase42/facts/complexity-source16.json`.
Use this comparable graph table for Phase42→Phase43 compiler-growth claims;
keep the broader repository inventory above separate.

| Graph scope | Modules | Physical lines | Nonblank lines | UTF8 bytes | Defs | Types | Laws |
|---|---|---|---|---|---|---|---|
| Protected Phase42 baseline | 70 | 20056 | 17198 | 844184 | 2249 | 71 | 640 |
| Current maintained graph | 70 | 21440 | 18414 | 927243 | 2413 | 72 | 640 |
| Delta | 0 | 1384 | 1216 | 83059 | 164 | 1 | 0 |

Bend source files excluded from the maintained graph:

| Path | Baseline lines | Current lines | Baseline defs | Current defs |
|---|---|---|---|---|
| selfhost/src/back/native/fixtures/override_add.bend | 11 | 11 | 2 | 2 |
| selfhost/src/compiler.bend | 1528 | 1528 | 118 | 118 |

`src/compiler.bend` is the earlier unchecked compiler retained for historical
comparison (selfhost/README.md:163), excluded by the maintained modular inventory;
`src/back/native/fixtures/override_add.bend`
is a native override fixture. Their combined1,539lines/120defs explain the
entire72-versus70 module and21,595-versus20,056 line baseline discrepancy.
They are unchanged at this snapshot. Parser/lexer production modules remain
included by both scopes. No source decline or new exclusion is claimed: the
same maintained graph grows by the same1,384lines/164defs as the full inventory.
Counts follow Phase42's physical/nonblank/UTF8 and column-zero ^def/^type/^law
conventions. This maintained 70-module graph is bound to the selected checked14 snapshot,
with unchanged membership, by `source-accounting-binding-final01.json`.

Changed production files (git diff additions/deletions include replacements):

| File | Added | Deleted | Net lines | Baseline lines | Current lines | Net Bend defs |
|---|---|---|---|---|---|---|
| selfhost/src/back/js/emit.bend | 3 | 1 | 2 | 1034 | 1036 | 0 |
| selfhost/src/back/js/finite.bend | 22 | 6 | 16 | 350 | 366 | 2 |
| selfhost/src/back/js/jpure.bend | 907 | 20 | 887 | 527 | 1414 | 120 |
| selfhost/src/back/js/local.bend | 1 | 1 | 0 | 176 | 176 | 0 |
| selfhost/src/back/js/producer.bend | 1 | 1 | 0 | 281 | 281 | 0 |
| selfhost/src/back/js/projection.bend | 1 | 1 | 0 | 69 | 69 | 0 |
| selfhost/src/back/js/region.bend | 222 | 5 | 217 | 1040 | 1257 | 20 |
| selfhost/src/back/js/tree.bend | 275 | 13 | 262 | 905 | 1167 | 22 |
| selfhost/src/runtime.mjs | 40 | 12 | 28 | 666 | 694 | — |
| selfhost/src/runtime/js/core.mjs | 40 | 12 | 28 | 328 | 356 | — |

Runtime source inventory (assembled runtime.mjs remains separate above):

| Scope | Baseline files | Current files | Baseline lines | Current lines | Net lines |
|---|---|---|---|---|---|
| Canonical JS runtime modules | 9 | 9 | 792 | 820 | 28 |
| Native C runtime files | 46 | 46 | 6823 | 6823 | 0 |
| Native C headers | 0 | 0 | 0 | 0 | 0 |

`runtime/js/core.mjs` is the edited runtime source; `runtime.mjs` is its assembled
copy and contains the same growth. Report both on-disk inventories but count
runtime implementation growth once. This is source line accounting, not emitted
program size, runtime heap usage, compiler latency or complexity proof.

## Mechanism contributions

The file-level net totals above are exact. Shared predicates and rewrites overlap
families, so they cannot be honestly divided into additive net totals by feature.
The following narrower counts attribute newly introduced definition names and
nonblank, noncomment definition-span lines; they exclude edits to existing defs,
comments, decorators, new type declarations and runtime JS. They are an inventory
of added machinery, not a partition of net physical source growth.

| Mechanism | New defs | Definition-span code lines |
|---|---|---|
| Closed scalar callback capture/application fusion | 19 | 157 |
| Contextual erased instances / exact native Map proofs | 100 | 499 |
| Full U32 fusion guard selection | 1 | 7 |
| Native String / exact Bool / scalar-prefix admission | 28 | 147 |
| Other shared admission/emission machinery | 1 | 3 |
| Scalar pair loop proof and emission | 15 | 134 |

Runtime changes comprise String-family capture metadata and exact String host
descriptor checks, callback U32 capability plumbing, full-U32 fusion host subset
selection, and broader native function snapshots. The exact runtime total is the
single canonical core.mjs row above. Deferred AfterHost clones, resume liveness,
and wrapper-hop proposals live in experiment tools and do not contribute to
production source growth. Exact nominal/type/ownership checks and fallback paths
are substantial code; the campaign does not claim this is a smaller compiler.

## Experiment tool inventory

Count current files under `selfhost/tools/performance/phase43`, excluding
`__pycache__`/`.pyc`. Baseline snapshots are listed separately: they are preserved
inputs, not newly authored implementation. All other files include frozen failed
versions, patches, JS workers/controllers, Python orchestration, fixtures and
metadata. These totals are not production source costs. Binary gzip files count
bytes/files only, with zero text lines; compressed bytes are not source lines.


Protected commit contains 0 files in the Phase43 tool subtree.

| Tool family | Files | Physical lines | Bytes |
|---|---|---|---|
| (orchestration) | 3 | 191 | 10077 |
| baseline | 3 | 1229 | 10158158 |
| callbacks | 59 | 6157 | 454274 |
| current | 3 | 2896 | 1550276 |
| guards | 34 | 2165 | 193611 |
| map | 116 | 30844 | 1909381 |
| products | 101 | 13380 | 681904 |
| review | 31 | 1917 | 101083 |
| strings | 81 | 12377 | 879190 |
| validation | 57 | 18719 | 764432 |

| File extension | Files | Physical lines | Bytes |
|---|---|---|---|
| .bend | 104 | 34270 | 1913582 |
| .gz | 2 | 0 | 11530115 |
| .js | 2 | 27 | 3518 |
| .json | 122 | 36917 | 1271037 |
| .md | 16 | 1296 | 72345 |
| .mjs | 120 | 6454 | 1106028 |
| .patch | 54 | 6296 | 397550 |
| .py | 67 | 4609 | 407760 |
| .txt | 1 | 6 | 451 |

Non-baseline experiment inventory totals: 485 files, 88646 text lines, 6544228 bytes. This includes fixtures and copied reference sources; it is not a claim that every line was newly authored.

The refresh script itself is included. Tool inventory can grow through reporting
without changing compiler code. Version counts are intentionally not deduplicated:
frozen versions and rejected variants are part of the retained research cost.

## Recorded enclosing job time

Ledger `selfhost/build/phase43/campaign.jsonl`, SHA256
`e87d49b832fd7cc0d62a306e73541f10277d7687d7d76f10ac803b9630ab8851`, 410 complete JSON records;
latest sequence 410.
Clock scope begins at the ledger's explicit setup start (2026-10-04T00:20:05.124281+00:00); earlier
conversation/delegation is outside this clock. Cutoff is the latest ledger
recorded timestamp (2026-10-04T04:44:37.691865+00:00), not the time this document was generated.

| Quantity | Value |
|---|---|
| Completed enclosing interval records | 409 |
| Successful recorded jobs | 360 |
| Failed/incomplete recorded jobs | 49 |
| Sum of failed/incomplete intervals | 453.566s (7.56min) |
| Sum of enclosing wall intervals | 6642.165s (110.70min) |
| Union of enclosing wall intervals | 6642.165s (110.70min) |
| Sum minus union (overlap) | 0.000s (0.00min) |
| Recorded wall span | 15872.568s (264.54min) |
| Wall span outside recorded interval union; unclassified | 9230.402s (153.84min) |
| Sum of reported toolElapsedSeconds | 6641.697s (110.69min) |

Each ledger event is an enclosing job interval. Nested child durations are not
added again. The sum counts overlapping enclosing intervals more than once; the
union measures covered wall time. Neither is CPU time, person-hours or model
inference time. The residual wall span is **unclassified**, including activity
outside recorded jobs and recording gaps; it must not be described as waiting,
model time or overhead. Jobs still running/unrecorded at cutoff are not charged.
A zero exit status says the supervising command passed; it does not mean every
hypothesis was useful or promoted. Nonzero status can be a sandbox/tool/control
failure and is not automatically a compiler semantic failure.

Failed/incomplete enclosing records:

| Sequence | Label | Return code | Interval seconds |
|---|---|---|---|
| 3 | job-products-derive01 | 1 | 0.261 |
| 5 | job-guards-oracle01 | 1 | 0.326 |
| 10 | job-strings-derive01 | 1 | 0.441 |
| 12 | job-guards-oracle03 | 1 | 0.263 |
| 18 | job-map-controls01 | 1 | 1.183 |
| 26 | job-prepare-checked01 | 1 | 180.520 |
| 32 | job-bst-trace01 | 1 | 16.564 |
| 40 | job-checked03 | 1 | 0.963 |
| 41 | job-checked04 | 1 | 4.591 |
| 48 | job-strings-controls05 | 1 | 0.989 |
| 50 | job-screen-checked05 | 1 | 0.561 |
| 53 | job-callback-proof-trace05 | 1 | 5.726 |
| 58 | job-string-fixture-baseline01 | 1 | 0.052 |
| 59 | job-product-fixture-baseline01 | 1 | 0.056 |
| 60 | job-string-fixture-baseline02 | 1 | 3.945 |
| 62 | job-product-fixture-baseline02 | 1 | 3.961 |
| 68 | job-strings-controls06 | 1 | 0.365 |
| 70 | job-callback-actual-controls06 | 1 | 0.176 |
| 73 | job-string-fixture-baseline03 | 1 | 3.593 |
| 74 | job-product-fixture-baseline03 | 1 | 8.924 |
| 76 | job-string-fixture06 | 1 | 3.596 |
| 77 | job-callback-source-fixture06 | 1 | 0.364 |
| 79 | job-checked07 | 1 | 5.730 |
| 82 | job-product-ignored-baseline01 | 1 | 3.598 |
| 88 | job-strings-controls08 | 1 | 1.513 |
| 109 | job-pair-source-fixture08 | 1 | 0.673 |
| 110 | job-pair-ignored08-controls | 1 | 0.364 |
| 114 | job-strings-controls08-v3 | 1 | 1.002 |
| 121 | job-pair-target08-baseline | 1 | 3.730 |
| 122 | job-pair-target08-candidate | 1 | 4.138 |
| 123 | job-pair-ignored-target08-baseline | 1 | 3.571 |
| 124 | job-pair-ignored-target08-candidate | 1 | 3.934 |
| 139 | job-pair-target09-controls | 1 | 0.875 |
| 140 | job-pair-ignored-target09-controls | 1 | 0.465 |
| 191 | job-map-fixture12-baseline | 1 | 2.749 |
| 197 | job-map-actual12-controls | 1 | 0.414 |
| 202 | job-map-actual13-controls | 1 | 0.390 |
| 231 | final-semantic-preflight-fold | 1 | 13.948 |
| 237 | final-independent01-remaining-phase35-owners | 1 | 140.057 |
| 277 | final-semantic03-phase41-wrapper-control | 1 | 2.657 |
| 286 | final-semantic04-phase42-fusion-derive | 1 | 0.062 |
| 288 | final-semantic05-phase42-layout-actual | 1 | 2.551 |
| 302 | final-semantic06-phase42-hybrid-derive | 1 | 0.634 |
| 303 | final-semantic07-phase42-native-owned-assay | 1 | 0.200 |
| 354 | final-semantic08-phase43-close-callbacks-number-count-noncommutative | 1 | 1.093 |
| 388 | final-semantic10-close-phase42 | 1 | 0.178 |
| 395 | job-inventory-recipe05 | 1 | 0.084 |
| 397 | final-semantic11-close-phase42 | 1 | 0.218 |
| 407 | job-portable-fast01 | 1 | 21.318 |

Repeated enclosing labels: []. Invalid/inverted intervals: none (asserted).

The selected source binding and completed ledger cutoff are recorded above;
later publication activity is outside this receipt.
Compiler-cost measurements, full timing/profiles and qualification decisions belong
in their respective receipts/reports; this accounting does not infer those costs
from line counts or elapsed job intervals.

The exact generated accounting snapshot and source binding are retained as
`accounting-final01.md` and `source-accounting-binding-final01.json` in the
[published raw evidence](../../selfhost/tools/performance/phase43/evidence/selected-release.json).
This document changes only final-status wording from that frozen generated snapshot.
