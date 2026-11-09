# Phase186 measurement support

Preparation and analysis here execute no target. The coordinator owns the only
CPU3 target lane; each command below uses a fresh output root, one outer guard,
2GiB RSS, the default5GiB disk reserve, and at most90 seconds. Close every actual
guard using its observed outcome. Production compiler/runtime files and prior
products remain unchanged.

## Frozen references and a bounded screen

- [reference45-01](../../selfhost/build/phase186/reference45-01/manifest.json): all45 frozen catalog points, roles `p185-qbe`, `c`, `p185-x86`.
- [screen10-reference01](../../selfhost/build/phase186/screen10-reference01/manifest.json): the same actual Phase185 final native N2 QBE/x86 and retained C products on ten points. Inherited input pins were verified by the existing Phase185 merger.

| Case | Purpose |
|---|---|
| local-pair | Product transport and scalar assembly overhead |
| local-fold | Array fast path, scratch stores and simultaneous loop transfers |
| coverage-numeric-recurrence-256 | F32 arithmetic and a prior QBE regression sentinel |
| tree-bitonic | Tree ownership and reconstruction |
| coverage-map-churn-128 | Map traversal, ownership and constructor/take traffic |
| coverage-unicode-text-64 | Text and pending continuations |
| coverage-record-aggregation-256 | Map-backed aggregation and call composition |
| complete-generic-row32 | Generic row/continuation transport |
| variation-ray-active-256-2240 | Active floating ray work with inexpensive calibration pilots |
| coverage-closures-256 | Closure elimination and a prior regression sentinel |

Use a target-specific three-role comparison: retained target, candidate target,
and C, with three rotated rounds. Five roles require five rounds for balanced
positions; that leaves less headroom within90 seconds on ten cases. The existing
`selfhost/tests/phase185/runtime-loop.py merge` accepts each role's explicit
manifest and original role name. Its `run` command uses adaptive250ms batches,
retains calibration, and rejects low-resolution or wrong-output comparisons.

Example for the already prepared reference screen:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase186/screen10-reference-runtime01-guard \
  --run-root selfhost/build/phase186/screen10-reference-runtime01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase185/runtime-loop.py run \
    --manifest selfhost/build/phase186/screen10-reference01/manifest.json \
    --rounds 3 --seconds 80 --target-ms 250 --guarded --cpu 3 \
    --out selfhost/build/phase186/screen10-reference-runtime01
```

## Current-image physical profiles

The small [profile-current.py](../../selfhost/tests/phase186/profile-current.py)
adapter creates its plan inside a fresh guarded root and reuses Phase185's
planner/dispatcher. It requests one clean capture and two sampled captures at
8ms/13ms, with original binaries and exact catalog outputs. It requests no
runtime relink or compiler execution. Five mocked guard/deadline controls plus
the maintained owner/comparison and Phase183 receipt controls pass42 tests.

The retained acquisition has separate emission and machine receipts. Its
machine receipt has no compiler request, so it cannot satisfy `owners.py`'s
combined-build provenance contract. The adapter records both receipts and omits
that unsupported owner option explicitly. Linked ELF/FID checks remain exact;
lexical owners remain conditional, with no fabricated current emitter lineage.

Read-only preview jobs exist under
`selfhost/build/phase186/profile-qbe-preview01/plan/jobs.json` and
`profile-x86-preview01/plan/jobs.json`. Their directories are **not** fresh
execution roots. Actual runs use the wrapper and a new root:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase186/profile-map-tree01-guard \
  --run-root selfhost/build/phase186/profile-map-tree01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase186/profile-current.py \
    --role p185-qbe --case coverage-map-churn-128 5200 --case tree-bitonic 7800 \
    --out selfhost/build/phase186/profile-map-tree01 --seconds 80 --guarded --cpu 3
```

For assembly use the same guarded pattern with a fresh `profile-x86-01` root,
`--role p185-x86 --case local-fold 104000 --case raytrace 19`. These counts
predict roughly4 seconds of measured work per capture and about800 pooled
samples, using Phase185's final clean medians. Startup/warmups add work,
especially for raytrace. Do not lower the500-sample or95% CPU-coverage gates if
a capture is rejected. Retain original periods, losses, unknown samples and
per-capture quality. One clean capture supports approximate CPU budgets, not a
multi-round speed comparison. C uses the retained pthread-aware sampler.

The coordinator prioritized and completed
[record/morning](../../selfhost/build/phase186/profile-record-morning01/plan/comparison.json),
using `--case coverage-record-aggregation-256 3600 --case test-morning-program 420000`.
The [derived analysis](profile-record-morning01-analysis.json) records accepted
748/818 pooled samples, zero loss, and at least99.932% whole-child CPU coverage.

| Physical leaf cost, period weighted | Record256 | Morning |
|---|---:|---:|
| Constructor helpers | 15.33% | 4.72% |
| Take helpers | 16.15% | 13.87% |
| Register set/jump/return helpers | 7.09% | 11.17% |
| Closure/application/destination/extend/finish helpers | 1.29% | 14.89% |
| Generic primitive helper | 0.83% | 4.06% |
| Nat divmod helper | 2.71% | 0.36% |
| Map-named generated leaves | 30.13% | 3.83% |
| String/Str-named generated leaves | 2.76% | 11.42% |

After transport and Char lowering, owned pair/triple take/rebuild paths and
continuation composition are the larger visible opportunities. No runtime
counts, contexts or callers were captured. Runtime helper costs cannot be
assigned to a specific Map/String owner; formal lexical ownership covers only
4.99%/15.67% of these samples, while many named private/composite leaves remain
unowned. These are baseline physical costs, not predictions for pending passes.

## Layout falsifier for prior normalized regressions

The [static audit](regression-layout-audit.json) finds that all three selected
hot functions move416 bytes with unchanged size. Loop headers change mod64
from16 to48, while mod32 remains16. The closures256 callback is literally the
same45 linked bytes; its25-byte loop crosses a64-byte boundary only in the
final image. Numeric loops have identical instruction sequences; their only
linked-byte differences are six RIP-relative constant displacements. Constant
contents and runtime object are unchanged. Layout is therefore a concrete
hypothesis, not an established cause of the cross-campaign regression.

[layout-probe-source01/plan.json](../../selfhost/build/phase186/layout-probe-source01/plan.json)
contains exact original copies and nine variants: closures256 and numeric256/1024,
each with one `.p2align 4`, `.p2align 5`, or `.p2align 6` inserted immediately
before the identified `.Lbb252` loop. Existing16-byte alignment remains. Removing
that single insertion reproduces every original byte. Align4 is a redundant
alignment/rebuild control. Later code/data addresses may move too, so the
experiment tests layout sensitivity rather than isolating one hardware effect.

The plan records exact parent hashes, assembler/linker argv, runtime identity
and independent one-repetition/zero-warmup output contracts.
[build-layout-probe.py](../../selfhost/tests/phase186/build-layout-probe.py)
validates those identities and edits, assembles/links/checks the nine products,
then freezes a five-role comparison manifest (`c`, `p185-qbe`, `align4/5/6`).
No Bend/QBE compiler runs. Four offline mutations verify refusal of a wrong
insertion point, undeclared instruction, changed assembler flags and changed
oracle count. The actual target execution belongs to the coordinator:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase186/layout-probe-build01-guard \
  --run-root selfhost/build/phase186/layout-probe-build01 \
  --seconds 90 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tests/phase186/build-layout-probe.py \
    --plan selfhost/build/phase186/layout-probe-source01/plan.json \
    --out selfhost/build/phase186/layout-probe-build01 --seconds 80 --guarded
```

After a complete build, run the existing runtime adapter under another fresh90s
guard with `--manifest selfhost/build/phase186/layout-probe-build01/programs.manifest.json`,
`--rounds 5 --seconds 80 --target-ms 250 --guarded --cpu 3` and a fresh runtime
output root. Five rounds balance all five positions. Check the recorded align4
binary identity before interpreting alignment effects. Neither a positive nor a
negative result promotes a production compiler change by itself.

Close each actual guard, substituting its real classification and paths:

```sh
python3 -B selfhost/tools/build-retention/close.py \
  --run selfhost/build/phase186/layout-probe-build01-guard \
  --classification completed --keep-root selfhost/build/phase186/layout-probe-build01 \
  --out selfhost/build-retention/phase186/layout-probe-build01-close
```

The coordinator subsequently completed the layout build and five-round runtime
screen. [Analysis](layout-runtime01-analysis.json) revalidates all150 retained
sample/pilot output contracts. Align4 preserves `.text` and every executable/data
section; only symbol/string metadata and the GNU build-ID note differ. Align5
and align6 both move the selected header to mod64=0 at distinct addresses.
All workload medians remain within0.40% of retained final QBE; their geometric
time changes are+0.080% and-0.003%. This intervention does not recover the prior
5–9% normalized regressions. Broader layout and cross-campaign variation remain
unresolved; no production alignment change follows from this result.

## Actual-context continuation admission probe

[continuation-probe.mjs](../../selfhost/tests/phase186/continuation-probe.mjs)
accepts `--api PASSED_B1/report.json --binding BASE_BINDING.json --out FRESH_ROOT
--cases unicode64,record256` (canonical catalog IDs also work). Root executes it
with the exact pinned Bun engine inside a45-second guard after the API gate.
The adapter authenticates checked B1/source/export/Base/engine and catalog pins,
calls `p88_cache_prepare`, `p86_plan`, `p169np_plan`, then
`p186hp_probe(prepared.cursor, names)`. It retains the raw proper `List<String>`
result and diagnostic preparation/probe times. It runs no generated program and
contains no host admission or compiler logic. Syntax was checked without loading
an API; actual planner execution belongs to root.

Defaults query stable sjoin/aggregate/Map names and selected historical
continuation IDs supplied by the semantic agent. Renumbered IDs may report
`missing`; that observation is preserved. Optional `--names` supplies an explicit
comma-separated query list for other catalog points. Probe fields `old-H` and
`view-H` mean the current planner under ready/view registries respectively;
they do not denote historical and candidate compilers. Actual before/after
admission requires separately pinned checked APIs.
