# Final native qualification runbook

Execute steps serially from the repository root. All target steps already use the existing `job.py` guard-and-close wrapper; do not nest guards. Stop on any failed/partial gate. Exact frozen sources, seed and method pins are in `selfhost/tests/phase186/qualification-plan.json`. Both seed preflights passed maintained `native.py --plan`; no compiler/target executed.

The full compiler source is3213774 bytes versus Phase1853202029; assembly source1589782 versus1525646. The retained pipeline took about37.3minutes. Planned outer ceilings total52.5minutes, fitting11:15–12:11 with3.5minutes for metadata/closure. A later start reduces that margin; preserve the absolute deadline.

Default file limit128MiB remains; the existing wrapper accepts `--file-mib 192` only if evidence requires a fresh retry. Every target job uses CPU3,2GiB RSS,16GiB available-memory floor and5GiB disk reserve.

## release-qbe-seed01

```sh
python3 -B selfhost/tests/phase186/job.py release-qbe-seed01 300 256 python3 -B selfhost/tools/build/native.py --assets selfhost/manifests/assets-native.json --image selfhost/build/phase185/release-qbe-chain01/n2/program --image-receipt selfhost/build/phase185/release-qbe-chain01/n2/report.json --host native --stage N2 --target qbe --mode cache --source selfhost/build/phase186/release-source01/compiler.bend --output-stage N0 --output-protocol qbe-source-v1 --seconds 290 --out selfhost/build/phase186/release-qbe-seed01
```

Require complete=true, unchanged inputs and the named fixed-point/gate checks before the next step.

## release-qbe-chain01

```sh
python3 -B selfhost/tests/phase186/job.py release-qbe-chain01 720 768 python3 -B selfhost/tools/build/bootstrap.py --assets selfhost/manifests/assets-native.json --image selfhost/build/phase186/release-qbe-seed01/program --image-receipt selfhost/build/phase186/release-qbe-seed01/report.json --host native --stage N0 --target qbe --mode cache --source selfhost/build/phase186/release-source01/compiler.bend --seconds 710 --out selfhost/build/phase186/release-qbe-chain01
```

Actual N1 and N2 builds plus Q3/S3 emitted by actual N2; fixed point does not substitute for finite semantic qualification.

## release-x86-seed01

```sh
python3 -B selfhost/tests/phase186/job.py release-x86-seed01 240 256 python3 -B selfhost/tools/build/native.py --assets selfhost/manifests/assets-native.json --image selfhost/build/phase185/release-qbe-chain01/n2/program --image-receipt selfhost/build/phase185/release-qbe-chain01/n2/report.json --host native --stage N2 --target qbe --mode cache --source selfhost/build/phase186/release-source01/compiler.x86.bend --output-stage N0 --output-protocol native-x86-source-v1 --seconds 230 --out selfhost/build/phase186/release-x86-seed01
```

Require complete=true, unchanged inputs and the named fixed-point/gate checks before the next step.

## release-x86-chain01

```sh
python3 -B selfhost/tests/phase186/job.py release-x86-chain01 840 768 python3 -B selfhost/tools/build/bootstrap.py --assets selfhost/manifests/assets-native.json --image selfhost/build/phase186/release-x86-seed01/program --image-receipt selfhost/build/phase186/release-x86-seed01/report.json --host native --stage N0 --target x86 --mode cache --source selfhost/build/phase186/release-source01/compiler.x86.bend --seconds 830 --out selfhost/build/phase186/release-x86-chain01
```

Actual N1 and N2 builds plus Q3/S3 emitted by actual N2; fixed point does not substitute for finite semantic qualification.

## release-qbe-native64

```sh
python3 -B selfhost/tests/phase186/job.py release-qbe-native64 120 128 python3 -B selfhost/tools/build/qualification.py --assets selfhost/manifests/assets-native.json --catalog selfhost/tests/phase182/qualification-catalog.json --image selfhost/build/phase186/release-qbe-chain01/n2/program --image-receipt selfhost/build/phase186/release-qbe-chain01/n2/report.json --host native --stage N2 --target qbe --mode cache --suite all --seconds 90 --build-seconds 30 --execute-seconds 20 --out selfhost/build/phase186/release-qbe-native64
```

Qualification --seconds is per compiler request; outer guard bounds whole64-case job.

## release-x86-native64

```sh
python3 -B selfhost/tests/phase186/job.py release-x86-native64 150 128 python3 -B selfhost/tools/build/qualification.py --assets selfhost/manifests/assets-native.json --catalog selfhost/tests/phase182/qualification-catalog.json --image selfhost/build/phase186/release-x86-chain01/n2/program --image-receipt selfhost/build/phase186/release-x86-chain01/n2/report.json --host native --stage N2 --target x86 --mode cache --suite all --seconds 90 --build-seconds 30 --execute-seconds 20 --out selfhost/build/phase186/release-x86-native64
```

Qualification --seconds is per compiler request; outer guard bounds whole64-case job.

## release-x86-runtime10

```sh
python3 -B selfhost/tests/phase186/job.py release-x86-runtime10 60 64 python3 -B selfhost/tests/phase183/runtime-controls.py --assets selfhost/manifests/assets-native.json --image selfhost/build/phase186/release-x86-chain01/n2/program --image-receipt selfhost/build/phase186/release-x86-chain01/n2/report.json --host native --stage N2 --out selfhost/build/phase186/release-x86-runtime10
```

Require complete=true, unchanged inputs and the named fixed-point/gate checks before the next step.

## release-native45-acquire01

```sh
python3 -B selfhost/tests/phase186/job.py release-native45-acquire01 360 256 python3 -B selfhost/tools/bench/acquire.py --recipe selfhost/tests/phase186/qualification-native45.recipe.json --set full --seconds 350 --cpu 3 --guarded --out selfhost/build/phase186/release-native45-acquire01
```

90 freshly emitted/built/oracle-checked products from actual final N2 images.

## release-full45-merge

```sh
python3 -B selfhost/tests/phase185/runtime-loop.py merge --role c selfhost/build/phase184/bend-products01/programs.manifest.json bend-c --role qbe selfhost/build/phase186/release-native45-acquire01/programs.manifest.json phase186-qbe-n2 --role x86 selfhost/build/phase186/release-native45-acquire01/programs.manifest.json phase186-x86-n2 --reference c --cases mandelbrot,editdist,tree-bitonic,lexer,symreg,test-morning-program,test-evening-program,test-rle-roundtrip,test-map-set-ops,raytrace,local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32,variation-editdist-0-17,variation-editdist-3-123,variation-lexer-6-17,variation-lexer-10-123,variation-tree-bitonic-6-17,variation-tree-bitonic-9-123,variation-symreg-4-17,variation-symreg-7-123,variation-local-fold-128-0,variation-local-fold-8192-123,variation-mandelbrot-grid-4-7,variation-mandelbrot-grid-5-31,variation-ray-active-64-2440,variation-ray-active-256-2240,coverage-closures-64,coverage-closures-256,coverage-list-pipeline-128,coverage-list-pipeline-512,coverage-bst-32,coverage-bst-64,coverage-unicode-text-16,coverage-unicode-text-64,coverage-expression-32,coverage-expression-128,coverage-map-churn-32,coverage-map-churn-128,coverage-numeric-recurrence-256,coverage-numeric-recurrence-1024,coverage-record-aggregation-64,coverage-record-aggregation-256 --out selfhost/build/phase186/release-full45-merged01
```

Reuse exact retained C; preserve native N2 compiler identities in target role metadata.

## release-full45-runtime01

```sh
python3 -B selfhost/tests/phase186/job.py release-full45-runtime01 360 128 python3 -B selfhost/tests/phase185/runtime-loop.py run --manifest selfhost/build/phase186/release-full45-merged01/manifest.json --out selfhost/build/phase186/release-full45-runtime01 --rounds 3 --seconds 350 --target-ms 250 --guarded --cpu 3
```

Three rotated rounds of C/QBE/x86. Historical performance comparison is explicitly normalized across campaigns; this run is not paired with Phase185 timings.

## release-full45-analysis

```sh
python3 -B selfhost/tests/phase186/analyze-runtime.py --report selfhost/build/phase186/release-full45-runtime01/report.json --historical selfhost/build/phase185/release-full45-runtime02/report.json --historical-pair qbe qbe --historical-pair x86 x86 --out implementation/phase186/release-full45-runtime01-analysis.json
```

Reverify every sample/oracle/input; flag dispersion without excluding rows. Repeat only unstable cases under a separately named fresh guard, preserving original full45.
