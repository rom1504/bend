# Compiler23 native parity investigation

These tools inspect **B1-generated C program execution**, against pinned
upstream `059266225b77c8ca256ac6b25ee5c21449bab151`. They do not measure B1/B2
compiler latency. Saved-C ablations investigate mechanisms; they are not
compiler implementations or release qualification.

Read the [report](../../../../../implementation/phase68/c23-parity-survey.md),
[code-shape analysis](../../../../../research/phase68/c23-code-shapes.md) and
[machine-code analysis](../../../../../research/phase68/c23-machine-code.md).
Run commands from the repository root. Each target campaign needs a **new**
output directory under `selfhost/build/phase68`; never reopen closed evidence.
Keep one root-owned guarded CPU3 target tree, with source/data work on CPU0.
The runners acquire the existing execution lock and apply the2GiB tree-RSS /
4GiB available-memory guard. Do not wrap them in a second guard.

## Choose the smallest useful loop

| Question | Tool | What it establishes |
|---|---|---|
| What C shapes differ? | `code-shapes.py` | Static generated-code counts, exact input hashes, global BANGS and local fixture reachability; no target execution |
| What survives Clang? | `machine-code.py` or direct `objdump` | Actual optimized instructions from verified identical `.text`; no target execution |
| Which operations occur more often? | `run.py --mode counts` | Instrumented allocation sites, retains, wrappers, scheduler entries; counts only |
| Where does CPU time go? | `sample-run-v3.py` | Main-thread native CPU sampling; requires CPU-coverage check |
| What if workers do the work? | `sample-run-threads-v2.py` | Main plus created-thread sampling with process-CPU coverage gate |
| Does scheduler mode cause the gap? | `bang-mode.py`, `mode-counts.py` | Isolated saved-C BANGS0 timings, then operation counts |
| Does constant-data allocation matter? | `static-template.py`, `static-study.py`, `static-counts.py` | Exact lexer-template preparation, then five-arm controlled timings |

A fast source-only pass takes seconds and runs no C:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/parity-survey/code-shapes.py \
  --output /tmp/c23-code-shapes.json

taskset -c 0 objdump -d --no-show-raw-insn --disassemble=WL_BEND_CLO_APPLY \
  selfhost/build/phase68/parity-survey23-debug01/closures-selfhost/program
```

`machine-code.py` is the frozen producer for `parity-survey23-assembly01` and
has that output path embedded. Use the direct read-only `objdump` command to
inspect more symbols; version the producer with a fresh output path before
replaying a complete extraction. Other no-argument reporting tools also use
fixed campaign inputs/output files; read their constants before rerunning.

## Counts and debug symbols

Example new target campaigns (root only, run serially):

```sh
python3 selfhost/tools/performance/phase68/parity-survey/run.py \
  --mode counts --cases closures,map \
  --out selfhost/build/phase68/parity-next-counts01

python3 selfhost/tools/performance/phase68/parity-survey/run.py \
  --mode debug --cases numeric,array,closures,tree,map,lexer \
  --out selfhost/build/phase68/parity-next-debug01
```

Counts compare17 minus1 repetitions, isolating16 dynamically varying input
points while cancelling fixed startup. Independent output checks run for every
instrumented executable. Instrumentation changes execution cost: **never use
its times as speed measurements**. `classify-allocations.py` categorizes the
completed `parity-survey23-counts01` sites into constructors, closures, tasks,
wrappers and other runtime allocations. These are allocation-call categories,
not retained bytes, peak live memory or full caller stacks.

Debug mode adds `-g` to the original recipe and verifies the whole `.text`
section against the qualified executable, retaining both extracted sections
and separate ELF copies. Sampling refuses a mismatched debug binary.

## Native sampling and its limits

For main-thread workloads:

```sh
python3 selfhost/tools/performance/phase68/parity-survey/sample-run-v3.py \
  --debug selfhost/build/phase68/parity-survey23-debug01 \
  --cases closures,map --periods 1000,1307 \
  --out selfhost/build/phase68/parity-next-main-samples01
```

This uses `sample-preload-v3.c` and `sample-analysis.py`. Each run targets
roughly2.5s using historical clocks; startup/shutdown are included, and each
role may use a different number of complete input cycles. **Profile clocks
cannot support candidate/upstream speed ratios.** Compare main-thread versus
process CPU before interpreting its samples. Compiler23 tree/lexer run most
work on a pool thread even with `--threads 1`, because of the investigated
BANGS flag; their main-only profiles do not cover the hot work.

Use all-thread sampling for those programs, or to validate uncertain coverage:

```sh
python3 selfhost/tools/performance/phase68/parity-survey/sample-run-threads-v2.py \
  --debug selfhost/build/phase68/parity-survey23-debug01 \
  --cases tree,lexer --periods 3001,7001 \
  --out selfhost/build/phase68/parity-next-thread-samples01
```

This uses `sample-preload-threads.c` and `sample-analysis-v2.py`, targets roughly
6s per run and requires at least500 samples, complete thread lifecycle metadata
and at least95% sampled-thread/process CPU coverage. Longer periods reduce
signal pressure. Timer overruns remain recorded; they are not redistributed
among sampled instruction addresses. Samples are leaf PCs, not call-stack
profiles. Older `addr2line` may report unsupported DWARF forms; ELF symbol and
instruction-address attribution remain available, but source/inlining detail
must not be invented. `profile-overhead.py <fresh-out>` measures the chosen
main-thread sampler's overhead separately.

## Saved-C discriminators

`bang-mode.py <fresh-out>` derives only `BANGS0` for the pinned tree/lexer C,
checks outputs with1/4threads, and rotates original/modified/upstream timings.
It is justified by the explicit dead-imported-main investigation, not a valid
transformation for arbitrary programs with reachable bang calls.
`mode-counts.py <fresh-out>` separately counts operations in the completed
`parity-survey23-bangs02` derivatives.

`static-template.py <fresh-prep>` performs source-only preparation of the exact
pinned lexer literal and records every replacement. It recognizes only the
observed39-character constant graph and fails closed on other statements.
`static-study.py --static <C> --combined <C> --derivation <JSON> --out <fresh-out>`
then compares original, static-only, scheduling-only, combined and upstream in
five rotated rounds, with independent outputs and a100ms minimum timing.
The producer records exact filenames in its derivation JSON. It does not build
a general static-data compiler pass. Consult the central report for completed
results; an existing partial report is not a success.
`static-counts.py <fresh-out>` separately verifies allocation/wrapper removal
for the completed static-only derivative. It gives no timing credit.

## Preserved attempts and versions

| Attempt | Status and successor |
|---|---|
| `counts01` producer | Original `run.py` preserved as `run-counts-v1.py`; [mapping](method-versions.json). Before any debug execution, successor made `objcopy` write a fresh ELF copy instead of its input. |
| `samples01` | Sampler build failed: Clang resource include path omitted (`stddef.h`). Original runner/preload retained. |
| `samples02` | Build failed under `-Werror` because the failure function lacked `_Noreturn`. The v2 files are retained; v3 records the fix and completes `samples03`. |
| `thread-samples01` | First sample/analysis completed, then runner accessed the wrong coverage key (`KeyError('usable')`). Preserved unchanged; runner v2 completes `thread-samples02`. |
| `bangs01` | Execution lock correctly rejected a concurrent campaign. Derived files and failure remain; serial `bangs02` is separate. |

These versions intentionally coexist: a later filename must not replace the
bytes identified by an earlier run. `summarize.py` joins completed evidence and
retains failed attempts; it is a campaign-specific report producer, not a
benchmark command.

## Input and archive dependencies

The scripts acquire exact saved products from Phase68 `native-facts23-rest`
and `native-facts23-lexer`, and Phase67 `native-baseline02` and
`native-heldout-baseline02`, using their reports, recipes, sources, emission
receipts, executables and compiler-image pins. They also depend on Phase46
`cases.json`, the independent oracle/fixtures, Phase68 `profiles/native-counts.py`,
`programs/support.py`, the prior `facts-native-comparison23` clocks, and pinned
Clang/linker inputs. `objdump`, `objcopy`, `readelf` and `addr2line` are required
for binary work. Resolve archived inputs before executing a runner; missing
historical receipts must not be replaced with guessed identities.

Root seals and archives the new `parity-survey23*` directories after all writers
finish, including failures, debug ELF/section copies, samples, instrumented C,
logs and derivation manifests. Keep small reports/tools tracked and link the
verified capsule and previous input capsules from the central report. Do not
archive a moving report or delete apparent duplicate evidence to save a few MB.
