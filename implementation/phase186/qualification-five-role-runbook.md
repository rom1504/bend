# Optional final five-role native timing

Prefer this plan once both actual N2 images,64-case gates,assembly runtime10 and90-product native45 acquisition have passed, provided at least13minutes remain before12:11 UTC. It preserves all45 catalog points and independently frozen whole-output/count oracles.

Roles are retained C, actual Phase185 QBE N2 products, actual Phase186 QBE N2 products, actual Phase185 assembly N2 products, and actual Phase186 assembly N2 products. Five rotated rounds balance each role in every execution position. Expect1125 timed observations (44 timing-eligible cases plus one correctness-only control), with adaptive calibration retained separately.

This measures both new/C and new/old in the same campaign. Role ratios use medians; this does not establish paired statistical significance. Estimated runtime7–9minutes adds roughly3–5minutes over the earlier three-role plan. The outer guard allows11minutes plus2minutes reserved for metadata/closure, so the latest recommended start is11:58. Do not begin beyond the hard deadline.

The pinned qualification plan is unchanged. This separate plan replaces only its final runtime-merge/timing/analysis steps when chosen. New N2 acquisition paths are deferred; no future hashes or completion are invented. Exact old product/method/catalog pins are in `selfhost/tests/phase186/qualification-five-role-plan.json`.

## Merge complete products

```sh
python3 -B selfhost/tests/phase185/runtime-loop.py merge --role c selfhost/build/phase184/bend-products01/programs.manifest.json bend-c --role oldqbe selfhost/build/phase185/release-native45-acquire01/programs.manifest.json phase185-qbe-n2 --role newqbe selfhost/build/phase186/release-native45-acquire01/programs.manifest.json phase186-qbe-n2 --role oldx86 selfhost/build/phase185/release-native45-acquire01/programs.manifest.json phase185-x86-n2 --role newx86 selfhost/build/phase186/release-native45-acquire01/programs.manifest.json phase186-x86-n2 --reference c --cases mandelbrot,editdist,tree-bitonic,lexer,symreg,test-morning-program,test-evening-program,test-rle-roundtrip,test-map-set-ops,raytrace,local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32,variation-editdist-0-17,variation-editdist-3-123,variation-lexer-6-17,variation-lexer-10-123,variation-tree-bitonic-6-17,variation-tree-bitonic-9-123,variation-symreg-4-17,variation-symreg-7-123,variation-local-fold-128-0,variation-local-fold-8192-123,variation-mandelbrot-grid-4-7,variation-mandelbrot-grid-5-31,variation-ray-active-64-2440,variation-ray-active-256-2240,coverage-closures-64,coverage-closures-256,coverage-list-pipeline-128,coverage-list-pipeline-512,coverage-bst-32,coverage-bst-64,coverage-unicode-text-16,coverage-unicode-text-64,coverage-expression-32,coverage-expression-128,coverage-map-churn-32,coverage-map-churn-128,coverage-numeric-recurrence-256,coverage-numeric-recurrence-1024,coverage-record-aggregation-64,coverage-record-aggregation-256 --out selfhost/build/phase186/release-full45-five-merged01
```

## Run once under root CPU3 guard

```sh
python3 -B selfhost/tests/phase186/job.py release-full45-five-runtime01 660 128 python3 -B selfhost/tests/phase185/runtime-loop.py run --manifest selfhost/build/phase186/release-full45-five-merged01/manifest.json --out selfhost/build/phase186/release-full45-five-runtime01 --rounds 5 --seconds 640 --target-ms 250 --guarded --cpu 3
```

## Authenticate and analyze

```sh
python3 -B selfhost/tests/phase186/analyze-runtime.py --report selfhost/build/phase186/release-full45-five-runtime01/report.json --pair oldqbe newqbe --pair oldx86 newx86 --out implementation/phase186/release-full45-five-runtime01-analysis.json
```

Keep original measurements immutable. Inspect dispersion per role: a C-only anomaly should not be described as unstable target-vs-target timing. Repeat unstable cases separately, preserving original full45; never silently replace or exclude their rows.
