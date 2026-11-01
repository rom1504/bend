# Phase152 generated-program regression screen

This plan uses the maintained `bench/acquire.py`, `bench/bench.py` and native45
catalog unchanged. It compares explicit Phase147 qualified N2 and Phase152
experimental N2 images, the same prepared Base, runtime, toolchain, fixture
bytes, arguments and independent catalog oracles. It launches no target and
does not change an installed selection. The acquisition preflight must wait
until `selfhost/build/phase152/native-n2/{program,report.json}` is complete.

After native integration qualification, prefer the **full45** commands below
for this change's broad QBE and machine-layout reach. Allow roughly 200 seconds
each for acquisition and execution, with separate 300-second ceilings. These
are planning allowances, not a measured cost or a 100-second promise.

The smaller alternative is **25 points covering all 23 catalog source groups**, including
the zero-work control and both local-pair/generic-row lowering shapes. It is
not full45: twenty additional within-source input variations are omitted.
The selection is frozen before observing Phase152 benchmark performance.
Two rounds rotate two roles, balancing their first/second positions. The
single zero-work control remains correctness-only; it cannot contribute a
timing ratio. Two rounds provide a regression screen, not stable confidence
intervals.

Phase147 ordinary45 acquisition/validation took 66.94 seconds for one image
(`selfhost/build/phase147/integrated-sequel02/qualification-broad/report.json`).
Those ordinary sources omit the timed wrapper, so two complete timed45 sets
are not supported as a roughly 100-second promise. Retained Phase149 timed
wrapper requests cost 1.02–2.24 seconds on expression/mandelbrot/map and
machine construction costs 0.13–0.26 seconds. Fifty fresh products therefore
fit an approximately 80–120-second planning estimate more plausibly than
ninety products; the explicit acquisition deadline is 180 seconds. The
benchmark runner only offers 20/60/300/600-second ceilings, so execution uses
300 with two rounds. The ceiling is not an instruction to consume all 300
seconds. No repetitions, warmups or inputs are reduced to meet it.

Run these commands from the repository root after the N2 build has completed.
The shell variable is only an explicit catalog-case list, with no compiler
policy or source-selection logic:

```sh
P152_CASES='local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32,mandelbrot,editdist,tree-bitonic,lexer,symreg,test-morning-program,test-evening-program,test-rle-roundtrip,test-map-set-ops,raytrace,variation-mandelbrot-grid-5-31,variation-ray-active-256-2240,coverage-closures-256,coverage-list-pipeline-512,coverage-unicode-text-64,coverage-map-churn-128,coverage-numeric-recurrence-1024,coverage-bst-64,coverage-expression-128,coverage-record-aggregation-256'

python3 -B selfhost/tools/bench/acquire.py \
  --recipe selfhost/tests/phase152/native45-acquire.json \
  --cases "$P152_CASES" --seconds 180 --cpu 3 \
  --out selfhost/build/phase152/programs25-acquire01 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/programs25-acquire01-guard \
  --run-root selfhost/build/phase152/programs25-acquire01 \
  --disk-mib 512 --seconds 195 --rss-mib 2048 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/bench/acquire.py \
    --recipe selfhost/tests/phase152/native45-acquire.json \
    --cases "$P152_CASES" --seconds 180 --cpu 3 --guarded \
    --out selfhost/build/phase152/programs25-acquire01

python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/phase152/programs25-acquire01/programs.manifest.json \
  --cases "$P152_CASES" --budget 300 --rounds 2 --scale 1 \
  --out selfhost/build/phase152/programs25-bench01 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/programs25-bench01-guard \
  --run-root selfhost/build/phase152/programs25-bench01 \
  --disk-mib 128 --seconds 315 --rss-mib 2048 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/bench/bench.py run \
    --manifest selfhost/build/phase152/programs25-acquire01/programs.manifest.json \
    --cases "$P152_CASES" --budget 300 --rounds 2 --scale 1 \
    --cpu 3 --guarded --out selfhost/build/phase152/programs25-bench01
```

Acquisition pins both actual image bindings and every consumed asset before
running. It performs a fresh complete compiler request and machine build for
each role/case, then validates that executable against the catalog oracle.
It automatically writes `programs.recipe.json` and its frozen
`programs.manifest.json`. Benchmark acquisition is excluded from execution
timing. Inspect complete status, all 25 oracle checks per role, all paired
rounds and the 100 ms resolution rule before interpreting ratios. A partial
or low-resolution result does not become a passing aggregate. Keep all failure
receipts and close both jobs through the maintained retention workflow.

## Full45 integration checkpoint

The same recipe supports full45 unchanged. These commands perform ninety
product acquisitions and 180 timed child runs, including four correctness-only
zero-work executions. Only a complete run is a full45 screen.

```sh
python3 -B selfhost/tools/bench/acquire.py \
  --recipe selfhost/tests/phase152/native45-acquire.json \
  --set full --seconds 300 --cpu 3 \
  --out selfhost/build/phase152/programs45-acquire01 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/programs45-acquire01-guard \
  --run-root selfhost/build/phase152/programs45-acquire01 \
  --disk-mib 512 --seconds 315 --rss-mib 2048 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/bench/acquire.py \
    --recipe selfhost/tests/phase152/native45-acquire.json \
    --set full --seconds 300 --cpu 3 --guarded \
    --out selfhost/build/phase152/programs45-acquire01

python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/phase152/programs45-acquire01/programs.manifest.json \
  --set full --budget 300 --rounds 2 --scale 1 \
  --out selfhost/build/phase152/programs45-bench01 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase152/programs45-bench01-guard \
  --run-root selfhost/build/phase152/programs45-bench01 \
  --disk-mib 128 --seconds 315 --rss-mib 2048 \
  --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/bench/bench.py run \
    --manifest selfhost/build/phase152/programs45-acquire01/programs.manifest.json \
    --set full --budget 300 --rounds 2 --scale 1 \
    --cpu 3 --guarded --out selfhost/build/phase152/programs45-bench01
```

## Retained-product reuse

No complete authenticated set of **Phase147 timed-wrapper products** was found
in the bounded search. Its retained `qualification-broad` executables use
`selfhost/tests/consolidation/native-broad/*.bend`, whose bytes and interface
differ from `tools/bench/catalogs/native45/fixtures/*.bend`; they cannot be
substituted into these timing commands. The Phase147 corpus-identity receipt
covers those ordinary products, not the timed wrappers. Phase149 retains a
small subset of policy0 timed products, but their producer is a different
experimental N1 image. Those products are not silently relabeled Phase147.

If an exact Phase147 timed-product receipt is located, the existing
`bench.py freeze` route can reuse its pinned executable and generated QBE,
retaining the source, producer, Base, runtime, toolchain and oracle receipts
as product/role inputs. `acquire.py` itself exposes no retained-product
provider or mixed fresh/reuse role. Reusing products therefore requires a
concrete new `kind: programs` recipe combining those authenticated products
with freshly acquired candidate products, followed by `bench.py freeze`.
Both roles must then execute in the new balanced timing block; no retained
timing can supply the denominator. Fresh two-role acquisition is the simpler
currently supported plan.
