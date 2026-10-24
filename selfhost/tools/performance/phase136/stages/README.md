# Uncached ordinary native stage diagnostic

Parent is the qualified Phase134 core `a0001924…fa19fb57`, not the Phase135
session. This diagnostic changes only `p111_native_args` by adding a seven-argument
mode. Its existing six-argument clause is preserved verbatim; all existing
compiler, checker, proof and verifier helpers are unchanged. No unit cache or
framed object machinery is included.

The explicit mode is:

```text
program --threads 1 --gpu off -- phase136-stages ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP stderr
```

Stdout is the ordinary complete QBE stream, written by `p111_print_emission` and
the existing bounded writer. After writing finishes, stderr receives one line
per completed interval: `phase136 stage LABEL ms=N`. Existing error paths retain
their original errors; a failed run is not a completed timing sample. Only the
existing admitted `IO.now` and `IO.print_err` effects are used.

The diagnostic uses a small `P136Step` continuation record, one per stage. Pure
bridges and native IO execute the **same transitions**. `P136More` stores the
next computation as an explicit closure, so the current result finishes before
the ending clock; the closure prevents the next computation running early.
The `P136Plan`, `P128RawLowering`, `P114SLowered` and emission results are matched
at their boundaries. The diagnostic does not deep-walk IR to force it.

| Label | Original computation |
|---|---|
| `base_prepare` | Existing checked Base carrier acquisition, excluding file reads |
| `parse_import` | Exact copied `p86_plan` parse/load prefix, with continuation names changed |
| `check` | `check_program_diagnostic_world` and its result/error branch |
| `driver_report` | `driver_report_data` |
| `ownership` | `driver_emit_owned` |
| `compile_eligibility` | `j_compile_error` |
| `context` | `book_context_world` |
| `annotation` | `nc_annotation_stops`, `reach_book`, `annotate_selected` |
| `annotation_check` | `jl_checked_error` |
| `erasure` | `nr_prepare_annotated` |
| `runtime_admission` | `p111_runtime_admission` |
| `raw_lowering` | Certificate, compile admission, constructor/static preparation, generic/raw private lowering and initial closure |
| `open_verify` | `p114s_open_lowered` |
| `inline_commit` | `p114s_inline_lowered`, including its ordinary commit check |
| `ranges_commit` | `p114s_ranges_lowered`, including its ordinary commit check |
| `final_verify_borrow` | Original close/certificate/final verifier and borrowed-helper closure |
| `render` | Existing render-context construction, text, output writes/close |

These are wall intervals including reference management and small diagnostic
bookkeeping. Consecutive intervals share a clock, so formatting each accumulated
line is charged to the following interval. Metadata is printed only after the
last clock. File reads precede the first interval. Output backpressure remains
part of rendering. Milliseconds do not support precise conclusions for tiny
stages; use full-source observations to identify the large categories first.

Source-only composition:

```sh
python3 -B selfhost/tools/performance/phase136/stages/prepare-v01.py \
  --out selfhost/build/phase136/stages-source01
```

Suggested checked API exports:
`p88_cache_prepare p86_plan p111_runtime_admission p111_emit_admitted
p111_emit_plan p136s_pure_plan p136s_pure_backend p136s_pure_emit
p136s_begin p136b_admitted p134e_collect`.

`bridge-v01.mjs API_REPORT selfhost/build/phase134/reference03.json FRESH_OUT`
compares the complete staged frontend plan, request and verdict against ordinary
`p86_plan` on all three frozen requests; both ordinary and staged backend products
must match the independent complete QBE oracles. It also checks actual parser and
type errors, plus admission refusal. The bridge does not execute IO or establish
native timestamp behavior. After it passes, acquire the diagnostic source through
the unchanged ordinary mode, run a small explicit-mode output gate, then perform
one controlled full-source diagnostic. Root owns all such target execution.

Source01 checked successfully in 13.69 s. The bridge completed all three exact
plan/output comparisons and three refusal cases in 37.22 s guarded. These are
source/pure-route gates, not native timing validation. Root is acquiring the
diagnostic native image in `selfhost/build/phase134/p136-stages-native01`.

## Native runner and overhead control

`native-v01.py` freezes a plan from the completed image-acquisition receipt,
then executes one guarded request. The default input is the historical full
compiler A source with its independent full QBE oracle. It does not silently
substitute the newer diagnostic source as the benchmark input. Stdout streams
directly to a fresh file, with no host line transformation. Completed output
size and SHA256 must match the full oracle. Stderr requires exactly the 17
ordered timing labels. An ordinary-mode run requires empty stderr instead.
Process wall/CPU/RSS excludes preflight pinning and post-run output hashing.

```sh
python3 -B selfhost/tools/performance/phase136/stages/native-v01.py --prepare \
  --image-report selfhost/build/phase134/p136-stages-native01/report.json \
  --plan selfhost/build/phase136/staged-full-plan01/plan.json \
  --out selfhost/build/phase136/staged-full01

# Root runs this command inside the existing CPU/RSS/file/time guard:
python3 -B selfhost/tools/performance/phase136/stages/native-v01.py --run \
  --plan selfhost/build/phase136/staged-full-plan01/plan.json
```

For a small overhead check, prepare separate fresh plans with
`--case lexer`, `--case coverage-closures-256` or
`--case coverage-map-churn-128`, and `--mode ordinary` or `--mode stages`.
Both routes then use the **same diagnostic executable**, identical input paths,
Base, carrier, runtime and full-output oracle. Two alternating pairs per case
are a reasonable inexpensive screen; charge native process time, not only the
sum of stage milliseconds. They will detect a large perturbation but cannot
prove a tiny overhead or its scaling to the full compiler. Compare full ordinary
and diagnostic totals before interpreting detailed shares as neutral profiling.

The source-level extra live state is bounded by the current diagnostic closure
plus at most 17 small timing lines. Each closure captures only values the next
original stage needs. For example, the checking step holds `load`, `world` and
`original`; later backend steps hold request/certificate/raw candidates while
the next original transformation runs. Those same values already survive in the
original call continuations. Completed stage closures are consumed rather than
retained in a history list; no extra whole-book or IR snapshots are recorded.
This does add closure/record allocations, clock effects, label formatting and
generic continuation dispatch. It may change reference-count/last-use details
and code layout, so its runtime cost must be measured, not assumed zero. There
is no new deep scan of compiler data at a clock boundary.

The metadata parser was checked without running a target: exactly 17 labels
pass; extra lines, a wrong/duplicate label and a negative duration are refused.
