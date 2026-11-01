# Phase149 exact evidence

`capsule.tar.gz` contains 1,435 members, 156,572,157 raw bytes compressed to
16,909,199 bytes. `manifest.json` lists every member's SHA-256, size and mode,
and the archive identity. Creation reread and authenticated every member.
Restore into an isolated directory, retaining the repository-relative paths;
do not extract historical snapshots over current working source.

The capsule includes the actual experimental native image, selected generated
program executables, checked and failed source snapshots, current Bend modules,
manifest snapshots, independent checking receipts, frozen benchmark recipes,
raw measurement records, canonical small QBE references and exact tool methods.
Full compiler QBE, assembly and the two large generated compiler executables
remain in verified local retention archives, whose member plans and receipts
are included. Those archives are recoverable locally, not an off-machine backup.
Repeated large benchmark stdout also has canonical product/hash bindings and
complete local archives; small program stdout is included directly.

## Important members under `selfhost/build/phase149/`

| Evidence | Path |
| --- | --- |
| Checked source and source map | `source03/` |
| Committed-source whitespace bridge | `source04/`; see `../source-equivalence.json` |
| Exact consumed manifest | `source-refresh02.json` |
| Independent whole-book source check | `check03/` |
| Experimental image and acquisition | `native01/program`, `native01/report.json`, `native01-guard/process.json` |
| Sixty Bend controls | `controls01-guard/stdout.log` |
| First seven-policy output acquisition | `requests-plan01/jobs.json`, `requests01/` |
| Independent default references | `parent01/` |
| Repeated small compiler/program experiments | `bench-plan01/`, `compiler-bench01/`, `program-bench02/` |
| Two additional transfer workloads | `transfer01-plan.json`, `transfer-bench01-manifest.json`, `transfer-bench01/` |
| Same-source full compiler requests | `full01-plan.json`, `full01/` |
| Separate full machine builds | `full-products01-plan.json`, `full-products01/` receipts |
| Execution of the two generated compilers | `compiler-products-recipe01.json`, `compiler-products-bench01/` |
| Actual timing/invalid/passthrough CLI controls | `cli-controls01-plan.json`, `cli-controls01-results.json`, matching guards |
| Failed checks/budget and lock refusal | `check01*`, `check02*`, `program-bench01-guard/`, `lock-refusal.json` |
| Resource closure | `close-plan01.json`, all guards' `retention.json`; local close receipt tree |

Job plans contain exact argv, inputs and fresh output locations. Benchmark
recipes use the maintained `bench.py freeze` / `run` interface. Compiler
behavior itself is selected by the Bend `phase149` command, not a host script.
For repetition, supply the pinned native runtime/toolchain/Base assets, choose
fresh guarded output paths and freeze a new manifest after relocating paths.
The old guards are immutable evidence, not reusable output directories.

The experimental image is SHA-256
`9ef6ff1f2095c8587f1d72dff500ff97f7c9f3f4966c12c90fc0ee6602b4fc75`.
The source it executes is the checked `9ddf4e00…` snapshot. The committed source
differs only by removal of a blank line, authenticated separately. This image
is not installed or newly native-qualified. The ordinary qualified Phase147
receipt remains the compiler-parent authority.
