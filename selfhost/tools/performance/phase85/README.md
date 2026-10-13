# Investigating V8 execution of the compiler

[Design](../../../../design/phase85/v8-compiler-execution.md) ·
[Results](../../../../implementation/phase85/README.md) ·
[Thread attribution](../../../../implementation/phase85/timeline.md).

These tools investigate the frozen Phase82 JS-hosted B2 compiler generating C.
They do not measure Clang or generated native-program execution. Restore the
Phase83 input plans/images/caches before replaying historical commands; parent
inputs are exact-hash-bound and their existing evidence capsules remain required.

## Fast clean and diagnostic lanes

From the repository root, use a new output directory for every attempt:

```sh
python3 -B selfhost/tools/performance/phase85/plan.py \
  --out selfhost/build/phase85/new-clean --mode clean --rounds 3
python3 -B selfhost/tools/performance/phase85/run.py \
  --plan selfhost/build/phase85/new-clean/plan.json
```

Default cases are Numeric, Map, Functions65 and Lexer; roles are genuine B2 and
pinned TypeScript. `--cases`, `--roles`, `--rounds`, `--calls` select a smaller
loop. Five ordinary requests in one process are explicitly repeated-process
observations, not hidden warmup or persistent semantic memoization. Full output
hashes and ordinary checked/report observations are verified after each request.
One full C file per process is saved; any mismatch saves the failing output too.

`--mode trace` enables opt/deopt/inlining/GC logging. `--mode cpu` samples calls
one and five (or the chosen last call), with inspector protocol outside the
request stopwatch. `--mode tier --flags='--max-opt=2'` is a labelled altered-tier
diagnostic. `--mode bytecode` plus exact filter flags inspects generated code.
Never mix those clocks into clean results. `--no-opt` is not optimizer-free.

Every target runs serially through the existing ExecutionGuard: CPU3, heap1GiB,
stack4MiB, tree RSS2GiB, available-memory floor4GiB,90s timeout and64MiB per-file
limit. An explicitly frozen hardware plan may instead set `cpu` to `"2,3"`.
Run matched upstream controls under the same affinity; retain one-CPU results
as a separate contract. Never run other target jobs or compression concurrently.

`run-paired.py LEFT_PLAN RIGHT_PLAN` interleaves matching job lists with
alternating pair order. Both plans must be frozen before running, with fresh
directories. Use it for hardware or generated-image comparisons. Failed output
directories are retained; retries require new plans.

## Direct thread CPU

Inspector profiles miss background JIT threads. Use the exact-pinned
`timeline-preload-v2.mjs` with these Node flags in a fresh diagnostic plan:

```text
--import=/absolute/path/to/timeline-preload-v2.mjs
--trace-event-categories=v8,disabled-by-default-v8.compile,node.perf.usertiming
--trace-event-file-pattern=/absolute/new/output/timeline-${pid}.json
```

Pass each as an argv string, preserving literal `${pid}` for Node. Pin the
preload in the plan input inventory before execution. It bridges existing P85
stdout markers to job/PID/process.hrtime microseconds and request CPU deltas;
ordinary dispatch stays unchanged. See archived timeline02/plan.json for the
complete recipe. Original `performance.mark` did not enter Node24's trace;
timeline01/preload-v1 remain preserved as an unsuccessful boundary method.

`timeline-summary.py RUN_DIRECTORY OUTPUT_JSON NOTES_MD`
unions per-thread CPU intervals, excludes nested GC from main compilation,
reports boundary-straddling ranges without prorating, and binds each trace by
PID/job. Consult `--help` for exact options if replaying a different revision.
Do not add inclusive phases or interpret elapsed background-job durations as
CPU/removable request time. Sparkplug coverage remains incomplete.

## Generated-code experiment and offline analysis

`code-shape.py --out NEW_JSON` reads frozen source and prior profiles without
executing the compiler. Source size is not bytecode size. V8 filters are exact
names or trailing prefix wildcards: leading`*` matches everything, not a suffix.
Shell-single-quote names containing`$`.

`lexer-choice.py --output NEW_IMAGE --report NEW_JSON` is a restricted exact-source
diagnostic transformer, not an optimizer release. It rewrites only recognized
if/return immediate arrows within the pinned lexer. `prepare-choice.py --api
NEW_IMAGE --out NEW_DIRECTORY` owns a copied project and new Base cache. Execute
its preparation plan with the preserved Phase84 prepare worker under the same
guard/file limits; do not relabel an old Base cache as valid for a new API hash.
The actual experiment is rejected; do not install its generated image.

`summarize.py --root-data selfhost/build/phase85 --lanes LANE_NAMES --out NEW_JSON`
verifies all successful receipts and produces a full offline summary. Derive a
small report with `--compact-from FULL_JSON --out COMPACT_JSON`; derive matched
comparisons by adding `--comparisons-out COMPARISONS_JSON` to that compacting
command. Early summary-method
source is preserved in commit a906937; the final method adds hardware/candidate
classification. CPU samples with negative deltas stay flagged; positive-only
hotspot weights are diagnostic estimates. Inspector self time remains explicit.

`plot.py` creates PNG/SVG from the thread-attribution JSON, without target runs.
`seal.py` archives every Phase85 raw file, reopens and hashes every archive member,
and checks unchanged originals. The archive includes failed diagnostic methods,
plans, complete C, profiles, traces, bytecode/assembly and rejected image/cache.
It does not duplicate historical Phase82/83 inputs; their existing capsules are
dependencies, not missing new results.
