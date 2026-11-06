# Six-family generated-program quality screen

The cases were fixed before candidate acquisition: `editdist`, `tree-bitonic`,
`lexer`, `test-rle-roundtrip`, `test-map-set-ops`, and `raytrace`. They cover
dynamic programming, recursive tree reconstruction/sorting, text traversal,
compression, maps/sets and floating-point rendering. They are a deliberately
small regression screen of established slow families, not an unbiased sample,
the full45 result, or upstream parity.

The reference is the **retained Phase152 generated executable** for each exact
native45 timed wrapper. Build only the candidate with `single-native-n2`, stage
`N2-P169-single`, using the same pinned Base, native runtime and machine toolchain.
Both roles are QBE programs. The candidate remains experimental. Compilation is
outside the execution timing budget; no historical timing is used as denominator.

`program-screen-selection.json` authenticates the original manifest/acquisition,
candidate image/receipt, catalog, all56 unique selected baseline inputs, and the
chosen work/round/budget policy. The candidate-only acquisition `--plan` succeeded
without executing a target; its output is `program-screen-acquire-plan.json`.
The temporary candidate-only reference label serves acquisition bookkeeping;
the merged comparison uses Phase152 as its actual denominator.

Run from the repository root, with the sole target lane free. These commands
are prepared instructions; the setup agent did not execute them.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase169/program-screen-acquire01-guard \
  --run-root selfhost/build/phase169/program-screen-acquire01 \
  --disk-mib 256 --seconds 630 --rss-mib 2048 --available-mib 16384 \
  --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/bench/acquire.py \
    --recipe experiments/phase169/program-screen.recipe.json \
    --cases editdist,tree-bitonic,lexer,test-rle-roundtrip,test-map-set-ops,raytrace \
    --out selfhost/build/phase169/program-screen-acquire01 \
    --seconds 600 --guarded --cpu 3

python3 -B experiments/phase169/tools/program-screen-merge.py \
  --acquisition selfhost/build/phase169/program-screen-acquire01/report.json \
  --out selfhost/build/phase169/program-screen-merged01

python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/phase169/program-screen-merged01/programs.manifest.json \
  --cases editdist,tree-bitonic,lexer,test-rle-roundtrip,test-map-set-ops,raytrace \
  --budget 60 --rounds 4 --scale 1 --plan

python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase169/program-screen-timing01-guard \
  --run-root selfhost/build/phase169/program-screen-timing01 \
  --disk-mib 32 --seconds 75 --rss-mib 2048 --available-mib 16384 \
  --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/bench/bench.py run \
    --manifest selfhost/build/phase169/program-screen-merged01/programs.manifest.json \
    --cases editdist,tree-bitonic,lexer,test-rle-roundtrip,test-map-set-ops,raytrace \
    --budget 60 --rounds 4 --scale 1 --guarded --cpu 3 \
    --out selfhost/build/phase169/program-screen-timing01
```

The acquisition performs the independent complete-result/count check once for
each new executable. The metadata-only merger verifies both acquisition
receipts, every selected immutable product/dependency, and exact wrapper,
oracle and work-amount equality, then delegates freezing to maintained
`bench.py`. It neither copies executables nor compiles the reference. All named
catalog sets remain intact; use the six explicit IDs rather than claiming a
partial run is the full set.

Clean timing uses serial CPU3 with four rounds: each of two roles appears first
twice. Both sides run fresh with the same explicit catalog repetitions and four
warmups. Every invocation must reproduce the complete expected value and counts.
Keep failures, partial completion and intervals below100ms visible; the maintained
runner excludes unresolved cases from ratios and refuses an incomplete aggregate.
Report each family and the six-point geometric mean only if all six qualify.
Do not attach sampling/preload/event variables to this clean run. The outer guard
keeps its standard5GiB disk reserve; acquisition's256MiB allowance must fit above
that reserve before starting.
