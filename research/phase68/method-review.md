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

The consumed V1 stays frozen. The subsequent
[V2 comparator](../../selfhost/tools/performance/phase68/benchmark/saved-native-v2.py)
(`83c586f2…10cd2`) admits only the explicitly registered, candidate-added
Phase67 `fast-plan.py`, SHA256 `a94c2853…e7082`, 2,919 bytes. This calibration
producer is outside acquisition and runtime commands; their exact unchanged
controller pins and absence of an import/reference are recorded. Both timing
receipts still consume the same frozen plan. No arbitrary extra input is
ignored. The correctness lane replayed all five exact source edits and accepted
this admission. A CPU0 comparison of the saved baseline-fast02 and eta-fast02
receipts passed; it executed no target.

## Selected-image qualification successors

The [Phase68 qualification methods](../../selfhost/tools/performance/phase68/qualification/README.md)
preserve the Phase67 methods and raw evidence. The source-only non-native
admission (`faddc52c…ade60`) uses the original complete generated-function
dependency scanner. All 98 non-`nc_compile` roots, runtime and export wrappers
must remain exact. A module path does not exempt changed code from that actual
closure check. Every source declaration moving modules must retain its exact
annotation, signature and body; other host/runtime/provider files remain exact.
Assembler and native fixture module lists are structurally checked and all
changed source identities are recorded.

The existing eta02 snapshot passed this CPU0 source/data check against selected
Phase67 scalars: 1,403 frontend functions and 3,066 non-native functions remain
exact (`qualification-eta-source-review01.json`, `247ab5c6…a026`). The
correctness lane independently replayed the derivation and accepted the method.
This transfers finite non-native semantic observations only, not native output,
B2 behavior or timing.

The final-method factory requires an actual checked selected attempt. It emits
five exact output-boundary relocations of the consumed Phase67 gate files and
seven ordered commands for closure, genuine B2 construction, fresh own-source
checking, reproduction and JS23/45 emission equality. The eta02 data-only
preflight wrote `qualification-method-preflight01/methods.json`
(`4ae01795…c833`); none of its targets ran in this lane. The final receipt join
binds the actual selected B1/B2 identities and separate native-request summary;
native runtime/control selection and installation remain separate gates.

The compilation lane's parameterized `prepare-selected-v1.py` also passed an
independent nine-edit replay, AST review and all preflight input pins. It keeps
the actual acquisition producer attached to each C oracle. Reusing an older
producer after a byte-preserving compiler change needs a separate explicit
oracle-producer join and fresh complete-C equality; it must never relabel old
acquisitions.

Templates05 demonstrates why the historical 98-root transfer is stronger than
a JS/frontend-route transfer: native public `nc_annotation_stops` reaches the
changed intrinsic selector. The strong gate fails and remains preserved.
The versioned route gate (`b96bb043…e03fa`) derives roots from the entire exact
unchanged driver after excluding only its two source-hash-pinned native-guarded
arms. An independent source review verified both guards and that the native
emission arm returns before the JavaScript path; all remaining API references
and function-value aliases stay roots, and all five dynamic references are
presence checks. This is a narrower, explicit claim, not an exception to exact
reachable-function equality.

The Templates05 route report (`1867c189…1eec7`) passes all 85 actual driver roots,
2,988 generated functions and the 1,403-function frontend closure. It records
the six native-only references and eight unused public roots excluded from
transfer, and reports the stronger 98-root gate as false. The V2 factory and
collector have exact two-/four-edit derivations selecting and binding this
scope; both also passed peer source review. Native/raw controls, actual B2 and
timing remain independent gates.

## Flat06 split-campaign comparison

The data-only `compare-union.py` records the original two Flat06 timing receipts
as a disjoint union and runs unchanged, pinned `saved-native-v2.py` against each
member separately. It never synthesizes a measurement receipt or substitutes a
producer identity. Identical compiler/recipe/method/fixed-plan inputs and the
complete six-case, selfhost, two-round matrix are required. The consumed methods
and acquisitions remain unchanged.

`native-flat06-comparison-union01/report.json` (`9477fc58…1dfd7`) joins twelve
exact, qualifying intervals. Candidate/baseline geometric ratios are runtime
0.303410618, original Clang build time 0.362138187 and C size 0.606548009. The
runtime case ratios are Numeric 0.140924, Array 0.247475, Closures 0.819473,
Tree 0.439830, Map 0.268217 and Lexer 0.231399. These compare separate sequential
campaigns; the original one-build Clang clocks remain distinct from saved-binary
runtime timing. No target ran in the comparison lane.
