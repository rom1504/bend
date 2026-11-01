# Compact-function fast loop

These methods prepare and compare a private additive experiment. They do not
replace the compiler or select a new image. All target commands run under one
outer disk guard, serially on CPU3. Preserve failed jobs and use fresh output
directories after changing a consumed method or module.

The baseline is the exact Phase147 canonical source and its explicitly qualified
N2 in `implementation/phase147/candidate.json`. The installed default is not the
baseline. Source extraction and ADT literal transport reuse the exact read-only
Phase147 helpers; compiler algorithms remain checked Bend declarations.

## Closed campaign and exact versions

This experiment is closed without integration. The current modules and methods
prepare the affine ownership version checked by
[API10](../../../selfhost/build/phase148/unit-api10/api/report.json): source
`d7b0bef4…`, API `cb8f5c3e…`.
[Controls02](../../../selfhost/build/phase148/unit-controls02/report.json) passes
81 rows; [supplement01](../../../selfhost/build/phase148/supplement01/report.json)
passes ten optimizer comparisons and two separately counted refusals.

The original full-pipeline measurements use
[compiler-native03](../../../selfhost/build/phase148/compiler-native03/timing/report.json)
and [map-native01](../../../selfhost/build/phase148/map-native01/timing/report.json):
new/old median ratios are 0.993625 and 1.027905. Their harness and preparation method
are retained in [analysis-v01](../../../selfhost/build/phase148/method-history/analysis-v01/inventory.json).
The current harness is the later
[compiler-native04](../../../selfhost/build/phase148/compiler-native04/manifest.json)
ablation successor. Its [separate ablation result](../../../selfhost/build/phase148/compiler-ablation01/report.json)
is 0.990699 full, 0.990519 without rendering, and 1.162295 transport/old. Fresh runs
of the commands below use this successor; they do not recreate native03's exact
source. No native Lexer timing was run; Lexer has checked structured controls.

[ownership-v01](../../../selfhost/build/phase148/method-history/ownership-v01/tools/inventory.json)
retains the earlier shared-wrapper methods associated with the native02 runtime
failure. Its sibling core/scalar/verifier files are historical evidence, not the
current runnable candidate. Source snapshots, preparation manifests and generated
`compiler.bend` files remain distinct; never relabel an earlier failed source as
the affine successor.

Historical receipts deliberately retain their original absolute paths and hashes.
Rerunning a historical timing reader against changed live methods fails closed.
Recover the matching method versions at their original relative locations in a
controlled replay environment, or rebuild the exact retained `compiler.bend`
with fresh receipts. Snapshot Python files are not standalone commands from their
archive directory: their repository root and sibling imports depend on location.

## Checked source and independent controls

Prepare after the three module owners freeze their files:

```sh
python3 -B experiments/phase148/tools/prepare.py \
  --core selfhost/tests/phase148/core.bend \
  --scalar selfhost/tests/phase148/scalar.bend \
  --verify selfhost/tests/phase148/verify.bend \
  --out selfhost/build/phase148/unit-apiNN
```

Execute the single command in the resulting `jobs.json`. It checks the small
dependency closure with pinned upstream0592662 and acquires a private API.
Then use the successful acquisition path in this separate guarded control job:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase148/unit-controlsNN-guard \
  --run-root selfhost/build/phase148/unit-controlsNN \
  --seconds 90 --disk-mib 128 --rss-mib 3072 --available-mib 16384 \
  --file-mib 128 --cpu 3 -- \
  selfhost/.assets/bin/bun experiments/phase148/tools/controls.mjs \
  --api selfhost/build/phase148/unit-apiNN/api/report.json \
  --fixtures selfhost/tests/phase148/control-fixtures.json \
  --capture selfhost/build/phase147/verifier-capture01/report.json \
  --out selfhost/build/phase148/unit-controlsNN
```

The fixed controls retain37 independently specified admission diagnostics and
eight literal full optimizer results. Eighteen captured direct functions add
roundtrip equality, complete old/new optimized structures, original and compact
admission, independent final verification, and exact rendered QBE text. Rejected
inputs are never executed as native programs. Passing these finite controls is
not a proof of general correctness.

## One native image, two complete pipelines

After successful controls, prepare the compiler family first:

```sh
python3 -B experiments/phase148/tools/native.py \
  --preparation selfhost/build/phase148/unit-apiNN/manifest.json \
  --controls selfhost/build/phase148/unit-controlsNN/report.json \
  --capture selfhost/build/phase147/verifier-capture01/report.json \
  --family compiler-verifier-slice \
  --out selfhost/build/phase148/compiler-nativeNN
```

Execute both `jobs.json` commands in order, stopping on any failure: independent
complete harness source checking, then native build with retained QBE IR.
After both succeed, execute its `timing-job.json` command.
Both files contain complete outer guards; do not nest another guard. Repeat with
`--family coverage-map-churn-128` for transfer, then `--family lexer` as the
held-out family. Their six selected direct functions contain respectively
856/33,291/13 and922/35 statements/branches. The larger Map raw scheduler packet
is a different representation and is deliberately excluded.

The binary selects `old` or `new` at runtime. Both modes build the actual global
headers, IDs and ordered ready-prefix contexts once per child. Each repetition
then runs all six functions: old scalar optimization and admission, or fresh
packing, compact scalar optimization, compact admission and decoding. Both
perform the same independent final verification, complete rendering, File.write
and cleanup. No compact unit or optimization result survives between iterations.
An unavailable unit fails the child instead of silently falling back.

`P148Unit` and its tape are affine `Type` values. `p148o_function` consumes and
mutates its freshly packed tape. Admission consumes it through `p148v_check`,
which returns `P148Checked{unit,error}`; decoding consumes that returned unit.
Neither controls nor timings reuse any consumed unit or share it between
iterations. Independent checks repack from the immutable original P113 function.
Control rows record actual used instruction/value/name counts before and after
optimization, plus the16-cell/name fact allocation and its power-of-two capacity.
At the current eight-byte native array slot size, a complete fact-array clone
costs128 bytes/name before capacity rounding; branch count alone does not measure
which clones execute after simplification.

Before and after timing, both modes must emit the entire checked API reference
text exactly. Timing writes to `/dev/null`, calibrates a common repetition count,
then runs four alternating pairs of the same executable. Zero-repeat costs are
reported separately and never subtracted. Headline whole-child wall time includes
context preparation and final cleanup; user/system CPU and peak RSS are retained.
The default timing soft budget is45s inside a60s guard. Calibration may fail this
budget instead of producing an under-resolved speed claim.

These measurements cover the complete selected function pipeline. They do not
establish full compiler speed, upstream parity, native self-hosting, kernel proof
or a release promotion. Source, API, capture, oracle, runtime and executable
identities remain separate in the receipts.

## Supplementary mutation-order controls

`selfhost/tests/phase148/supplement-scalar.json` independently specifies12 whole
original-optimizer results: ten ordinary optimizer comparisons and two explicit
reserved-metadata refusals. `supplement.mjs --api REPORT --fixtures FILE --out DIR`
runs them in a separate30s guard after the first timing. It leaves the consumed81
controls unchanged. Calls whose destination also appears as an argument, stale
predicate/relation epochs, terminal edges, scalar returns, and branch joins are
covered. Some inputs deliberately violate admission rules; their only claim is
exact optimizer transformation. Neither those inputs nor refused compact units
are executed, and the two refusals never increase the parity count.
If an authoring-reference source has changed, explicitly supply `--source-history
selfhost/build/phase148/method-history/ownership-v01`; the checker requires the
retained file to match the original declared hash exactly and records both paths.
The new candidate remains independently bound to its fresh checked acquisition.

## Diagnostic ablations

The successor harness also accepts `old-analysis`, `new-analysis` and `transport`.
An explicit Boolean at the final rendering stage disables only rendering for the
two analysis modes. Scalar optimization, admission, independent final checking,
temporary cleanup and an empty File.write still run. Oracle requests accept
only full `old`, `new` and `transport` modes, each requiring the entire original
output. Transport packs and unpacks fresh input, then runs the full old pipeline.
Its difference includes ownership of the newly decoded tree; it is not an
isolated additive conversion stopwatch.

`time-ablation.py` uses one executable and a common calibrated repetition count
for all five modes. It runs four alternating pairs for full, analysis and
transport comparisons, rotating category order. Complete old/new/transport
oracles run before and afterward. Use a fresh75s outer guard with the default60s
soft budget. These separate diagnostic results do not replace the frozen full
pipeline timing or justify attributing a subtraction to a single compiler stage.

The compiler ablation retains about 85% of full time when rendering is disabled.
This compares whole-child medians with common repetition count and includes the
same fixed context work; it is not an inclusive render-stage profile. Neither
the near-equal analysis result nor the positive transport overhead supports a
10× complete-pipeline speedup from changing only rendering. Broader native qualification, a whole compiler image change,
and larger-input/native Lexer measurements were deliberately not attempted.
