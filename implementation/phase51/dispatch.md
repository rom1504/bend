# Phase51: make the generic application path small enough to inline

Status: isolated saved-output prototypes; not integrated into the compiler or
runtime. All three variants passed 27 focused controls. The IO-only extraction
also showed a 1.0477× Evening improvement after a much longer fixed-work
warmup, supporting integrated qualification of its three-line change. The
full split and split-plus-entry variants remain unselected. These focused
results alone do not establish release-wide improvement. Root owns all target
execution.

## Evidence and hypothesis

[Phase50's generic-dispatch investigation](../phase50/generic-dispatch.md)
found that `apply`, `force`, and `invokeExact` together account for about
39–42% of sampled self time in Morning, Evening, and MapSet. Morning and Evening
have no sampled private-entry guard cost. Their estimated allocation per call
is about 30× and 28× the upstream output respectively. These are diagnostic
measurements, not an allocation-by-allocation ownership proof.

V8 already optimizes `apply`; the issue is not simply failure to reach an
optimizing tier. In Evening and MapSet traces it refuses to inline `apply`
with reason 5. The pinned Node v24.18.0 V8 source identifies that reason as
`kExceedsBytecodeLimit`. `invokeExact` can inline into `apply`, and `force` can
inline into `callOwned`, but the larger dispatch body prevents the next
composition. No deoptimizations occurred in those measurement windows.

The hypothesis is that moving infrequent branch bodies out of `apply` permits
ordinary call sites to inline its common path. This may expose argument-vector
and descriptor operations to V8 in a more useful context. Neither reduced
source length nor successful inlining alone establishes a speedup.

## Small, reversible change

The prototype changes exactly one function in each saved generated module:

| Existing branch | New helper | Common path retained |
| --- | --- | --- |
| IO application | `applyIO(f,args)` | Both separate `io` property reads and the empty-argument check |
| Type application | `applyType(f,args)` | Initial `typeName` check |
| Nonfunction/empty application | `applyNonfunction(f,args)` | Initial `code` check |
| Overapplication | `applyOverflow(f,all)` | Bound-vector assembly, exact and partial saturation |

Each helper receives existing local values. Its body is copied intact from
the original branch. The common path still uses the original bound/owned/copy
choice, exact call through `invokeExact`, and partial `fn` construction.
There is no new ownership assumption, cached public descriptor, vector reuse,
type guard, or function-name selector.

The authoritative original is
[`src/runtime/js/core.mjs`](../../selfhost/src/runtime/js/core.mjs), SHA-256
`d427d2433cee7585d002ea178a694e552deb7cbf8e21ce4caaf9804a1463e971`.
The exact old and new text is retained in
[`dispatch-prepare.py`](../../selfhost/tools/performance/phase51/dispatch-prepare.py).

In particular, the transformation preserves:

- Repeated `io`, `typeName`, `code`, `bound`, and `arity` reads, including a
  different receiver returned by the second `bound` getter.
- Resolution of `code.call` before `env`; the original argument evaluation
  order; and fresh `arity` reads after the function body and after forcing an
  overapplication result.
- Deferred IO `pureValue` observation, source receiver identity, iterator and
  array-species behavior, and error identity and reentry.
- Exact-entry token consumption, public copies, owned private argument
  vectors, delayed constructor forcing, and trampoline stack safety.

Diagnostic JavaScript stack traces may contain the new helper names. This
experiment does not claim identical engine-specific stack strings.

## Reproduction and isolation

Root runs the following commands with fresh output paths, using the exact
module hash supplied by the acquisition receipt:

```sh
python3 selfhost/tools/performance/phase51/dispatch-prepare.py MODULE EXPECTED_SHA NEW_OUT
node selfhost/tools/performance/phase51/dispatch-controls.mjs NEW_OUT/receipt.json NEW_CONTROL_OUT
```

The producer pins itself, the authoritative runtime fragment, and the input
module. It requires exactly one original body, refuses helper-name collisions,
and verifies that reversing the replacement recovers the complete original.
It emits separate clean modules and diagnostic copies containing one explicit
runtime export. Timing uses the clean copies only. Inputs and outputs are
hashed; consumed inputs are rehashed before completion.

The focused controller preserves 27 observations across the two diagnostic
modules. It covers ordinary partial/exact/overapplication with both ownership
modes; changing getter values and exceptions; bound-vector receiver and copy
behavior; sparse-array species; IO and type branches; delayed-field errors;
20,000 trampoline steps; raw/overapplied/exact entry and reentry; and the full
public source program. It pins the receipt and every recorded input/output,
verifies clean-versus-diagnostic equality, and rehashes all inputs at the end.

Frozen producer SHA-256:
`9ed8479a81a551f5b5155946cce5274ee983285b1d90d3e5570d701bac63a49b`.
Frozen controller SHA-256:
`842375a03abd00334dd6cb969dee96cdd4b35bb1ace66ad5df64674dae789c47`.
See the independent [semantic review](review.md).

## Decision gates

First run the focused controller and existing runtime application controls.
Then compare clean Morning, Evening, and MapSet outputs with identical inputs,
warmup, and alternating execution order. A separate Evening V8 trace must show
whether the new `apply` actually becomes an inlining candidate and whether
callers inline it. Traces, counters, and instrumented modules are not speed
samples. Any gain must survive a longer paired confirmation and the unchanged
representative corpus before production integration.

The common path may remain too large, or V8 may choose to inline cold helpers
and lose the intended benefit. Additional calls can also hurt workloads that
frequently use overapplication or IO. Preserve such negative results rather
than widening the transformation without evidence.

If retained, integration must edit the authoritative fragment and regenerate
the concatenated runtime through `src/runtime/js/build.mjs`; it must not patch
only the generated bundle. Production source and installed RNFA04 remain
unchanged while the saved-output experiment runs.

## First executed checkpoint

`selfhost/build/phase51/dispatch-controls01/report.json` passes all 27
observations (SHA-256
`40e9f04bd80c0f505566dd0b1567f86c12e683d38a0fad4273aee003bb324fe1`).
The existing runtime application test also passed against candidate Evening.

The clean three-round screen uses 350 ms warmup and 150 ms target samples;
all outputs agree. This is a screening result, with substantial within-sample
drift, not a stable release comparison:

| Program | RNFA04 median | Four-branch split median | Baseline/candidate |
| --- | ---: | ---: | ---: |
| Morning | 261.329 µs | 239.966 µs | 1.0890× |
| Evening | 172.343 µs | 174.256 µs | 0.9890× |
| MapSet | 1.69999 ms | 1.74829 ms | 0.9724× |

Receipt: `selfhost/build/phase51/dispatch-screen01/report.json`, SHA-256
`7d25464fa1190d5babe9953b26538002dd830240f34d9d733f309e1d13208e8b`.
For example, candidate MapSet half drift is +38% to +63%; a small median
difference here does not establish a steady-state regression or gain.

The separate Evening trace confirms the intended mechanism **and a tradeoff**:

| Trace event | RNFA04 | Four-branch split |
| --- | ---: | ---: |
| `apply` reason-5 refusals | 70 | 0 |
| `apply` successful inlining events | 0 | 37 |
| `invokeExact` successful inlining events | 1 | 38 |
| `force` successful inlining events | 17 | 0 |
| Measured-window deoptimizations | 0 | 0 |

Candidate `apply` has 248 bytecodes. It inlines into `force`, `callOwned`,
`call`, and 34 anonymous compilation units. However, the trace's existing
inlined-bytecode-size field for `force` grows from 319 to 807. Candidate
`callOwned` first inlines `apply`, then its 240-byte `invokeExact`, while the
considered `force` is left uninlined. The traces prove this changed selection;
they do not alone prove it causes the small timing differences.

Trace logs are under `selfhost/build/phase51/dispatch-trace01`:
baseline `00-baseline/process/stdout.log` SHA-256
`efba5bb1586bda484a867d00b6e7ee82aa6e0b88eae4e8f42a4e34fa29a36619`;
candidate `01-candidate/process/stdout.log` SHA-256
`379550c6ebccb1cca13fbcc9c84abd0acb2778bd45ad7e56b8a8e35dbe08f9b8`.
Candidate lines 141–164 show the `callOwned` selection directly. Both traces
use 8,192 warmup and 8,192 measured calls. Counts include all compilation
events and are not dynamic call frequencies.

## Two bounded followups

1. [`dispatch-prepare-io.py`](../../selfhost/tools/performance/phase51/dispatch-prepare-io.py)
   moves only the IO branch into `applyIO`. This removes the captured `f` from
   `apply`'s source scope while retaining its other branches. The experiment
   tests whether avoiding broad inlining displacement is preferable. There is
   currently no graph or heap evidence proving an eliminated physical context
   allocation; the capture requirement is a source fact only.
2. [`dispatch-prepare-exact.py`](../../selfhost/tools/performance/phase51/dispatch-prepare-exact.py)
   retains the four-branch split and moves registered-entry bookkeeping behind
   `invokeRegistered(f,all,code)`. `invokeExact` still reads `f.code` once, then
   takes the unchanged `code.call(f.env,all)` path when no exact functions have
   been registered. Its registered helper preserves the original checks and
   token protocol. This directly tests the extra inlining budget consumed by
   bookkeeping that Morning and Evening do not use.

Both producers preserve and pin the first producer and use the same CLI.
The latter records two ordered text replacements in `receipt.edits`.
[`dispatch-controls-v2.mjs`](../../selfhost/tools/performance/phase51/dispatch-controls-v2.mjs)
accepts that explicit recipe, verifies its inverse, and retains every original
semantic test. It also pins the first controller. No further variants are
planned without a correctness counterexample.

Both successors passed independent static review and all 27 executed focused
controls. Fresh short screens retained the same three-round protocol:

| Variant | Program | Baseline median | Candidate median | Baseline/candidate |
| --- | --- | ---: | ---: | ---: |
| IO only | Morning | 260.702 µs | 219.156 µs | 1.1896× |
| IO only | Evening | 174.550 µs | 163.695 µs | 1.0663× |
| IO only | MapSet | 1.69328 ms | 1.69612 ms | 0.9983× |
| Four branches + small entry | Morning | 263.157 µs | 228.496 µs | 1.1517× |
| Four branches + small entry | Evening | 172.512 µs | 170.397 µs | 1.0124× |
| Four branches + small entry | MapSet | 1.68991 ms | 1.73379 ms | 0.9747× |

Receipts: `selfhost/build/phase51/dispatch-io-screen01/report.json`, SHA-256
`244c3f03e70df79f62a2bd4986b59d7be487c3ab552e9f5df1380834dcd4f498`;
`dispatch-exact-screen01/report.json`, SHA-256
`d632cc549ab65bcb9503c250c5bfcaddead8299ebf71604ce5c9ea48acb3d837`.
These are separate fresh comparisons; cross-screen medians are not a paired
ranking of the two candidates. The evidence justifies a longer IO-only
confirmation, not promotion of any variant or a corpus-wide speed claim.

The [IO-only source proposal](../../selfhost/tools/performance/phase51/proposals/dispatch-io-runtime.patch)
contains the exact fragment change and corresponding assembled-runtime change.
Its [identity manifest](../../selfhost/tools/performance/phase51/proposals/dispatch-io-runtime.json)
pins both original sources and the consumed prototype recipe. The logical
change adds three lines and 54 bytes; its appearance in both fragment and
bundle must not be counted as two independent runtime additions. It remains
a proposal, and production integration must verify regenerated assembly.

## Longer IO screen: stationarity is still unresolved

The five-round followup used 1,000 ms warmup, 50 ms calibration, and a 300 ms
measurement target. All 45 samples across the three roles and three cases
passed their value checks. Baseline/candidate medians were:

| Program | Baseline | IO-only candidate | Observed ratio |
| --- | ---: | ---: | ---: |
| Morning | 227.957 µs | 215.783 µs | 1.0564× |
| Evening | 220.876 µs | 142.057 µs | 1.5548× |
| MapSet | 1.35183 ms | 1.32916 ms | 1.0171× |

The large Evening ratio is **not an established steady-state gain**. Its
baseline samples range from 197.652 to 249.853 µs and improve by 37.6–57.9%
between their halves. Candidate samples are much tighter at 140.797–142.208 µs,
with 3.2–4.3% improvement between halves. Morning also has substantial drift,
and MapSet generally continues getting faster within each sample. A fixed
warmup duration and several rounds do not prove stationarity. Tier transitions,
feedback evolution, and compilation timing remain possible explanations;
the experiment has not established eliminated context allocation as the cause.

Receipt: `selfhost/build/phase51/dispatch-io-confirm01/report.json`, SHA-256
`6be41d8b0a8f977dfdfd9e7f865691ea0bda0b2b7e9ed817a29a4280eb6d0e79`;
wall time 76.062 s. This triggered the fixed-work Evening check below. The
earlier screens remain preserved, including their drift.

The prepared [IO trace queue](../../selfhost/tools/performance/phase51/dispatch-io-trace-jobs.json)
pins the exact baseline and IO-only Evening modules, with 32,768 warmup calls
and 16,384 measured calls for each. It uses only the existing optimization,
deoptimization, and inlining trace flags. Inspect `apply` refusals/inlines,
`force` inlining and its accumulated size, and tier/deoptimization events on
either side of the explicit warmup/measurement markers. These diagnostics can
explain compiler decisions but cannot serve as clean timing or prove physical
allocation removal. No forced optimization or tier restriction is used.

## Fixed-work Evening checkpoint

The completed `selfhost/build/phase51/io-steady01` queue uses three fresh
processes per role in rotated order, each with **32,768 warmup calls followed
by 16,384 measured calls**. The six clean runs validate all public results and
digests. A seventh, separate process supplies the IO-only trace. Root used its
own pinned queue configuration; the prepared trace queue above was not run a
second time.

| Role | Clean measurements, µs/call | Median |
| --- | --- | ---: |
| RNFA04 | 143.936, 134.006, 135.230 | 135.230 µs |
| IO-only | 129.660, 128.175, 129.076 | 129.076 µs |

The observed median ratio is **1.04768×**, substantially smaller than the
earlier 1.5548×. All three candidate runs are faster than their paired baseline.
Between-process max/min spans are 7.41% and 1.16% respectively. This driver
does **not** record sample halves, so these are repeatability statistics, not
within-window drift measurements. It would be incorrect to infer zero drift
from the missing field.

The IO-only trace reports a 429-bytecode `apply`, eight successful `apply`
inlining events, nine `invokeExact` inlining events, and no reason-5 `apply`
refusals. Thus even extracting just IO crosses the inlining threshold; the
initial idea that it might preserve the original inlining shape was not
confirmed. `force` is considered but not inlined, with an existing inlined
bytecode-size field of 669. Its standalone optimized code and `apply` finish
before the measurement marker. There are no measured-window deoptimizations
or optimization completions in this candidate trace.

The earlier original trace had 70 refusals and no `apply` inlining, while the
larger split generated 37 `apply` inlining events and a `force` accumulated
size of 807. Those traces used fewer warmup/measured calls, so event totals
should not be treated as normalized frequencies. The reliable mechanism
finding is changed inlining eligibility and composition. Physical context
allocation removal still has not been demonstrated.

Queue receipt SHA-256:
`b33f1749f7295ce8c9aa2df7a7d85eb6a8a29d5b3ee682a31fcd526e0672d8b3`.
Candidate trace `06-candidate-trace/process/stdout.log` SHA-256:
`399f207d0004b5acfc4a7a8573ad54593c83752d7f1fbb3c0060c801f807f25d`.
The complete seven-process queue took 56.995 s; profiled timing is excluded
from the clean comparison.

Recommendation: qualify the IO-only change in the integrated compiler and
unchanged representative corpus. Its three-line cost and repeatable focused
benefit justify that next gate. Keep both larger variants as unselected
experiments. Do not describe this as a 55% steady-state improvement, a proved
allocation optimization, or a substitute for full semantic qualification.
