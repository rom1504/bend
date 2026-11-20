# Checked Phase197 measurement

This screen starts from commit `c07b44a1e13916a7f96b7d31925a4e156e987fc1`.
Fresh maintained x86 assembly has SHA256
`ee95d489522b4fdbdf253137319417f3eb09abe12f192db493d840c542adb8c5`, exactly
the qualified Phase195 source02. The six frozen Phase195 N1 objects therefore
provide the baseline; the retained Phase195 generation comparison establishes
their equality with qualified N2 objects. No new native compiler was built.

Fresh independently checked hosted APIs cover baseline preparation, minimum
alone, decrement alone and both together. Their exact 4,081-declaration
preparation closures match, allowing the existing request-local shared emitter
to prepare each workload once. All compiler decisions remain in checked Bend.
The three candidate roles each emit six complete ELF objects plus diagnostic
assembly. The unchanged machine builder skips the assembler for these products,
links the pinned runtime and checks the original complete value/count oracle.

The selected cases are `editdist`, `local-pair`, `coverage-bst-64`,
`coverage-bst-32`, `variation-editdist-3-123` and `mandelbrot`. The first three
are development targets, the next two are held out for this screen, and
Mandelbrot is an unrelated workload. These partitions were frozen before the
candidate emission and timing; they do not redefine the native45 historical
partition. The whole-object comparison finds all three Mandelbrot objects
unchanged and minimum-only BST32/BST64 unchanged. Retain their measured noise
without attributing it to optimization.

Minimum controls pass both alone and in the combination: 68 existing predicate
checks, eight new structural checks, and 7,260 plus 38,720 independent C
observations per emitted-object/rendered-assembly route. Combined decrement
controls pass 28 structural checks and 2,120 C observations per route. Both
routes share typed selection; they are not independent compiler algorithms.
The first decrement acquisition failed the affine checker on a consumed-twice
budget. Original source and failed receipt remain. V2 adds exactly three
required ownership annotations and passes checking; its selection is unchanged.

The frozen measurement plan and all argv are in `selfhost/build/phase197`.
Two fresh runtime sessions each rotate four roles through four rounds, with
independent per-role 250 ms calibration and the retained 20-attempt pilot cap.
Every timed/pilot invocation validates complete output; pilots do not enter
ratios. Six-case geometric aggregates and all per-case regressions remain
separate from the qualified full45 result. No confidence interval, compiler
speed, native reproduction or installed-image claim follows from this screen.

Replay order:

1. Reconstruct the exact baseline source/API using `baseline-*-argv01.json`.
   Reuse the protected Phase195 products, or execute the explicitly unexecuted
   `baseline-rebuild-recipe01.json` in fresh paths and require original object
   equality. This recipe uses the pinned qualified N1 image, not a new self-build.
2. Run `minimum-source-argv01.json`, `decrement-source-argv02.json` and
   `combined-source-argv02.json`, then their corresponding API argv.
3. Run minimum standalone controls and `controls-emission-argv01.json` in order.
   Prepare shared emission first with `shared-emission-prepare-argv01.json`.
4. Execute `machine-build-steps01.json`; each role writes
   `<role>-build01/programs.manifest.json`, with the same role name.
5. Run `compare-products.py`, `runtime-prepare-argv01.json`, and the two
   `runtime01-argv.json` / `runtime02-argv.json` jobs, then `summarize.py`.

All target steps use `job.py`, one CPU3/shared execution lane, explicit whole-run
disk budgets and the standard 5 GiB reserve. Each job retains its close receipt.
Use fresh output names on replay and regenerate the dependent metadata for those
names; never edit pinned historical receipts. The source modules, hooks,
control fixtures, oracles and drivers are versioned experiment inputs outside
the live compiler tree. Root owns additional direct-C input checks, full-source
acceptance and final campaign reporting.
