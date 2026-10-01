# Phase37 generated-program coverage

This adds a frozen coverage catalog to the maintained
[execution loop](../programs/README.md). The original fifteen-point catalog and
portable Phase32 reference remain unchanged. Phase37 compares against explicitly
acquired **Phase36 checked03**, API
`93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75`,
and pinned upstream TypeScript at
`018751270e800bc222a93dad7f257083ee53a5f7`.

The designed catalog has **45 points in23 source files**: the historical15,
14 additional algorithm/input points, and16 points across8 new application
families. Two additional source files are wrappers over historical algorithm
bodies; a source-file count does not imply23 independent applications. See the
[coverage design](../../../../design/phase37/coverage.md) and
[application design](../../../../design/phase37/applications.md).

| Group | Points | Purpose | Suggested ceiling |
|---|---:|---|---:|
| `fast` | 5 | unchanged historical canaries | 20s |
| `core` | 8 | unchanged historical core | 60s |
| `historical` | 15 | all original regression points | 600s |
| `coverage-variation` | 14 | seeds, scales, viewport and active-ray distributions | 600s |
| `coverage-development` | 10 | five new families available for investigation | 300s |
| `coverage-holdout` | 6 | BST, expression and record-aggregation families | 300s |
| `full` | 45 | complete inventory for acquisition | no single-run time promise |

These are ceilings and proposed selections, not measured completion promises.
The enlarged `broad` set aliases the ten development application points; always
state the explicit catalog when naming a set. Keep the heldout families out of
profiling and optimization choices until the candidate is frozen. They test
transfer to independent program families; extra seeds of a tuned algorithm do
not constitute such a holdout. Full language, native/GPU, realistic external IO
and large-service memory coverage remain outside this suite.

## Run from a normal clone

The checked-in [reference](baseline/manifest.json) includes both compilers’ frozen
outputs and checked emission receipts in a verified 769,150-byte archive. Normal
execution requires neither historical build directories nor either compiler.
Use Node24 and every output directory must be new:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase37/baseline/manifest.json \
  --budget 20 --set fast --out /tmp/bend-coverage-fast-NEW \
  --node /absolute/path/to/node --cpu 3
```

Use `--budget 60 --set core` for the historical core, or `--budget 300 --set broad`
for the ten new development points. For other groups, obtain their exact IDs with
`catalog-cases.py` and supply `--cases`; the budget remains independent of coverage.
The CPU must be available on your host. Absolute paths inside preserved receipts
are historical provenance, not dependencies of the portable timing bundle.

## Acquire and freeze the reference

Run from the repository root. Root alone executes jobs serially on CPU3. Set
`PHASE37_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node`; every output directory
must be new. The maintained preparer owns the shared execution guard, so do not
wrap it in another supervisor using that lock. Its children have a1GiB heap,
2GiB process-tree ceiling,2GiB free-memory floor and180-second per-source limit.

Before optimization, the root freezes the selection with:

```sh
python3 selfhost/tools/performance/phase37/fixtures-new/oracles.py \
  --out selfhost/tools/performance/phase37/fixtures-new/points-v1.json
python3 selfhost/tools/performance/phase37/coverage-catalog.py \
  --out selfhost/tools/performance/phase37/catalog-draft01.json
```

Those files are authored/generated once, not overwritten on repetition. The
draft has exactly two pending ray values. It must never be used for timing.
Acquire only their checked TypeScript output:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog-draft01.json \
  --role typescript --upstream selfhost/.bootstrap/upstream-phase23 \
  --cases variation-ray-active-64-2440,variation-ray-active-256-2240 \
  --out selfhost/build/phase37/ray-oracle-ts01 \
  --node "$PHASE37_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 2048
```

Run `reference-oracles.mjs TS_MANIFEST DRAFT_CATALOG NEW_REPORT` under the
maintained bounded supervisor. It verifies the checked TypeScript receipts and
executes those two exports. Finalize a **new** catalog:

```sh
python3 selfhost/tools/performance/phase37/coverage-catalog.py \
  --ray-oracles selfhost/build/phase37/ray-oracles01.json \
  --out selfhost/tools/performance/phase37/catalog.json
```

The report path above is a proposed name; use the exact completed report. These
two F32 results are explicitly **differential** oracles. The integer algorithm
references are independent Python calculations, cross-checked on four retained
goldens; the application references separately specify their computations.
Checksums can collide. Unicode text and record aggregation observe complete
returned strings. No expected result is inferred from the compiler candidate.

Prepare all final catalog sources with each reference compiler, once per distinct
source rather than once per point:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --attempt selfhost/build/phase36/checked03 --role baseline --set full \
  --out selfhost/build/phase37/baseline01 \
  --node "$PHASE37_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 2048
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --upstream selfhost/.bootstrap/upstream-phase23 --role typescript --set full \
  --out selfhost/build/phase37/typescript01 \
  --node "$PHASE37_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 2048
python3 selfhost/tools/performance/programs/freeze-reference.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase37/baseline01 \
  --typescript selfhost/build/phase37/typescript01 \
  --out selfhost/build/phase37/reference01
```

Packaging executes no compiler or program. Run it under a bounded root
supervisor. It preserves checked preparation receipts and logs in a portable
archive, verifies every archived byte by reopening it, and checks unchanged
inputs. It does not manufacture a timing result. Preserve any failed preparation;
corrected sources require explicit new identities and attempt directories.

## Select and measure

`catalog-cases.py GROUP` prints validated IDs without executing generated code.
The maintained `--cases` option accepts these groups without another timing
engine. For example:

```sh
PHASE37_CASES=$(python3 selfhost/tools/performance/phase37/catalog-cases.py coverage-development)
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase37/reference01/manifest.json \
  --budget 300 --cases "$PHASE37_CASES" \
  --out selfhost/build/phase37/development-reference01 --node "$PHASE37_NODE" --cpu 3
```

For candidates, run the same preparation command with `--role candidate` and the
new checked attempt, then add `--candidate NEW_PREPARATION/manifest.json` to the
timing command. Do not use historical medians as the denominator. Roles rotate
in fresh processes under the unchanged protocols. Exact results, partial rounds,
failures, raw samples, import/first-call costs and drift all remain visible.

For a quick focused screen, use explicit IDs rather than shortening inputs:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase37/reference01/manifest.json \
  --budget 60 \
  --cases variation-lexer-6-17,coverage-closures-64,coverage-list-pipeline-128 \
  --out selfhost/build/phase37/coverage-screen01 --node "$PHASE37_NODE" --cpu 3
```

CPU/allocation profiling and generated-code syntax comparisons use the unchanged
`programs/diagnose.py --catalog ... --from-run ... --cases ... --mode all` interface.
Diagnostics have a separate budget and cannot replace clean timing. Do not
profile heldout families while choosing the optimization. The final report must
identify measured groups, unmeasured points, shared failures, compile-time costs,
source growth and any subsequently exposed holdout.

The additive `--catalog` support in maintained preparation confines sources to
the catalog directory, rejects path traversal and file/directory symlinks, and
verifies exact source hashes. The existing default catalog behavior stays intact.
Root runs `programs/tests/test_catalog_preparation.py` and existing worker/harness
controls separately from benchmarks; authors do not run heavy jobs concurrently.
