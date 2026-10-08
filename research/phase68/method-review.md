# Phase68 measurement review

Source/data review on 2026-10-08, on CPU0. No Node, Clang, Lean, native program,
or benchmark target was executed by this reviewer. No production source or
historical raw evidence was changed. Successful root receipts are required
before interpreting numerical results.

## Native compilation requests

Reviewed [preparation](../../selfhost/tools/performance/phase68/compilation/prepare.py),
[worker](../../selfhost/tools/performance/phase68/compilation/worker.mjs),
[executor](../../selfhost/tools/performance/phase68/compilation/run.py), and
[analysis](../../selfhost/tools/performance/phase68/compilation/analyze.py).
No target-execution blocker was found.

The roles are actual Phase67 B1 `c76f1113…`, genuine B2 `cbffd1f8…`, and the
pinned upstream TypeScript compiler. B1 and B2 use separate fresh Phase68
projects copied from the checked attempt's frozen driver/runtime. Their
compiler images remain the actual admitted files. The worker loads the owned
API and calls the ordinary `inspect(..., {mode:'native', withReport:true})`
route; an injected substitute API does not stand in for the compiler.

Both Bend roles explicitly prepare a fresh Base cache before measurement.
Requests require the successful preparation receipt, exact plan identity,
unchanged cache bytes, and frozen inputs. Every clean and instrumented request
must check successfully and reproduce the complete previously qualified C
source byte-for-byte. B2 is compared against the same admitted selfhost C;
this transfers finite output qualification, not B1's compiler timing.

The clocks have distinct meanings:

| Clock | Included work | Interpretation |
| --- | --- | --- |
| Imports/API loading | Fresh module imports and owned API loading | Separate startup observation |
| Base preparation | Explicit prepared-world/cache construction | Separate setup; excluded from requests |
| Checked C request | Ordinary source loading/checking/native emission | Clean compiler-request screen |
| Profile request | Public API wrappers plus V8 CPU sampling | Diagnostic only; excluded from clean medians |
| Clang/runtime | Earlier qualified native acquisition/execution | Separate provenance; not freshly timed by this request loop |

TypeScript loads/checks Base inside its request; Bend requests use mandatory
prepared Base. This is the stated prepared-request comparison, not cold-CLI
parity. One round is a screen. Three rotated rounds put each role in each
position for each source. The executor owns the existing single guard and
launches serial CPU3 children with 1 GiB Node heap, 4 MiB stack, 2 GiB tree RSS,
and a 4 GiB available-memory floor.

Public-stage profiles count driver entry calls, not all recursive compiler
calls. V8 nearest-named-frame ownership leaves unknown/host/GC samples
unattributed; inclusive stack rows overlap and cannot be summed. Neither
profile clocks nor sampled percentages belong in clean request ratios.

The frozen [15-job screen](../../selfhost/build/phase68/native-compilation01/plan.json)
has SHA256 `2991d80bd102903b2bbe716721098a3e0c0bc953dd459fdbee4b9b0434cf39f8`.
All 248 declared input hashes and byte counts were independently rechecked on
CPU0 after freeze. The final method explicitly joins old acquisition, recipe,
source, emission receipt, C and compiler identity; analysis reports missing
jobs and remains incomplete until all planned jobs close. The preparation
readiness assertion follows the actual `preparedWorld.state.ready` ABI.

## Saved native diagnostics

Reviewed the current [runner](../../selfhost/tools/performance/phase68/profiles/run.py)
and [scope](../../selfhost/tools/performance/phase68/profiles/README.md),
coordinating with the independent counter-transform reviewer to avoid repeating
the 18-record transformation audit. No additional blocker was found.

The method preserves old emitted C/acquisition receipts and creates fresh
Phase68 derivatives and executables. The compiler libraries, linker, selected
API, profiler, oracle, generated artifacts, and measured executable identities
are bound and rechecked. Counts at one and seventeen repetitions differ by
one complete sixteen-input cycle; changed digest/IO work remains included.
Both outputs must match the independent oracle.

Allocation/refcount/segment counts are operation frequencies. Requested
allocation capacity is not retained memory or RSS. The two roles also retain
different runtime revisions, so counter differences do not isolate a compiler
pass or explain a percentage of the clean runtime gap.

Optional gprof output is usable only after successful profiling/analysis and
the declared positive-sample threshold. That threshold establishes usable
localization, not precise percentages. Numeric/array `BANGS=0`, threads1 and
GPU-off select the main sequential workload path; helper threads and unresolved
shared-library work still limit process-wide attribution. Instrumented and
`-pg` clocks receive no clean-runtime speed credit. Failed probes and targets
remain in fresh output directories.

## Saved-binary continuity through a manifest extraction

The new [saved-native controller](../../selfhost/tools/performance/phase68/benchmark/saved-native.py)
and [commands](../../selfhost/tools/performance/phase68/benchmark/README.md)
keep the Phase67 tools and raw recipes unchanged. They address the mechanical
compiler-manifest extraction: a runtime request on an already built binary
does not consume live `src/compiler.json`.

The controller admits the original acquisition recipe and all product/receipt
identities. Its single exception resolves the original manifest hash and byte
count to the selected checked attempt's frozen `src/compiler.json`; the
attempt's actual API must match the recipe exactly. Other old inputs remain
strict. Multiple acquisition reports from the same recipe support the six
baseline families. The runtime command, oracle, fixed plan, role rotation,
deadline, resource guard and clock qualification match Phase67.

Data comparison accepts either Phase67 timing receipts or the new receipts.
It verifies each row's workload, oracle, executable command and qualifying
clock. Shared method/toolchain/runtime/wrapper inputs must match; only an
explicitly registered manifest difference is accepted, with both snapshot
continuities retained. Different selected API paths are intentional compiler
endpoints. Clang/build clocks remain the separate original acquisition clocks.

CPU0 admission accepted the six old baseline products from both acquisition
folders and the six completed arity-attempt products; self-comparison of the fresh Phase68 baseline returned runtime,
Clang and C-size ratios of 1.0. Supplying the arity attempt with the baseline
recipe was rejected at the exact API association check. These were data-only
checks; no target ran and no historical file changed.

The correctness review lane independently accepted the final controller,
SHA256 `8cffef36ebeb8418942aaa4d5a07a27239aa2a980ed22515060445db9963c7cd`.
Comparison summaries apply to their observed selfhost rows and reported round
counts; they do not imply a broader case set.
