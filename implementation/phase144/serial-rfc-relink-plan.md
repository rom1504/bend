# Serial RFC: relink-only qualification and timing plan

The prepared plan reuses authenticated program objects and changes only the
runtime supplied to the linker. It never emits new QBE, assembles a program
object, or treats a historical output as a fresh result. Production selection
and the qualified original runtime remain unchanged. Execution is root-owned.

## Semantic gate

`selfhost/build/phase144/relink-plan01/plan.json` binds Phase143 qualification,
the selected N2 emitter, each original Bend source/QBE/object/build receipt,
independent complete-output oracle, original runtime and new runtime build.
Its 61 executable cases comprise all 45 ordinary programs and 16 focused
programs. The three focused compiler-stage refusals produced no object; their
historical results are retained separately and are not newly passed by relinking.

The first stage links and runs six focused ownership/readback cases with each
runtime: non-tail reverse, held-out string reverse, captured higher-order calls,
non-tail list operations, arrays with IO, and aggregate readback. It also checks
three actual candidate CLI refusals (`--threads 2`, GPU on, and a GPU memory size).
The second stage requires that exact successful receipt, retains its six cases,
and links/runs the other 55 objects with both runtimes. Every complete stdout,
stderr and exit code must match. This yields 122 fresh ordinary executions and
three fresh runtime CLI refusals; source/backend refusal coverage stays distinct.

Past costs support running the whole semantic set: ordinary45 executions totaled
0.1973s (largest 0.0644s), and focused16 executions totaled 0.0334s. Their original
93.35s and 19.51s acquisition times included emission/build work which this plan
does not repeat. The old short execution observations are cost estimates only.

These cases exercise ownership and printing, including `arrays-io`; they do not
alone establish every detached file/native-host worker cleanup path. Actual
compiler-request IO, the separate word/overflow/pool controls, and the
[source safety review](serial-rfc-safety-review.md) remain separate evidence.

## Runtime timing

Timing the ordinary programs' common 2–4ms process lifetimes would obscure the
runtime work. Instead `batch-relink-plan01/plan.json` selects four preserved
Phase131 batch program objects with original warmup/repetition counts:

| Case | Repetitions | Warmups | Runtime arguments | Prior candidate intervals, ms |
| --- | ---: | ---: | --- | --- |
| Map churn | 544 | 4 | 128, 123 | 550, 553, 560 |
| Record aggregation | 392 | 4 | 256, 123 | 552, 555, 552 |
| Binary search tree | 27,184 | 4 | 64, 17 | 623, 631, 621 |
| Unicode text | 2,024 | 4 | 64, 123 | 297, 291, 291 |

The Phase131 native-program equality receipt binds these batch sources and
measured objects to byte-identical QBE emitted by the qualified Phase131 N2.
The original atomic runtime is the same qualified Phase128 object used by
Phase143. Each object is freshly linked once with each runtime. Six pairs per
case alternate the runtime order; case order rotates. Every observation must
pass the unchanged complete result, warmup count, repetition count and elapsed
suffix oracle. Raw child wall time and the program's elapsed-millisecond interval
are both recorded. A result below 20ms is ineligible for the reported ratio.

This is a runtime-only comparison on **Phase131-generated code**. It measures
neither Phase143 code-generation quality nor compiler throughput, and four
ownership-heavy workloads are not the full 45-program speed distribution.
The plan requires the completed 61-case semantic gate before starting timings.

The compact root execution recipe is
`selfhost/build/phase144/relink-jobs01.json`: safety, full semantics, then batches,
serially under CPU3 and the existing process-tree guard. Its `command` arrays
are **inner commands only**: the root must wrap each with that guard, applying
the recorded CPU, RSS and deadline requirements. Executing the inner command on
another CPU refuses before output-directory creation or child execution.
The runner records a
fixed environment without inherited loader injection, exact realpaths, all
commands and outputs, timeouts, and input revalidation. This document describes
the prepared protocol; the closed execution results follow.

## Closed observations

The root executed all three guarded jobs. Six safety cases and the three CLI
refusals passed in 0.961s; the remaining semantic cases passed in 7.292s. Together
these establish all 61 selected programs under both runtimes: 122 complete-output
executions, plus three runtime refusals. The three historical compiler refusals
remain explicitly separate. A subsequent data-only audit rechecked exact link
and execution commands, object/runtime bindings, emitted binaries and every
observed stdout/stderr against the pinned expectations.

All 48 fixed-batch observations passed the unchanged full-output/count observer.
The campaign took 26.637s including its eight links and receipt work.

| Phase131 batch case | Atomic median, ms | Serial median, ms | Serial / atomic | Faster serial pairs |
| --- | ---: | ---: | ---: | ---: |
| Map churn | 550.0 | 551.0 | 1.0018 | 3 / 6 |
| Record aggregation | 491.0 | 488.5 | 0.9949 | 3 / 6 |
| Binary search tree | 618.5 | 605.0 | 0.9782 | 5 / 6 |
| Unicode text | 291.5 | 280.5 | 0.9623 | 6 / 6 |

Map and record aggregation were essentially flat. BST and Unicode had modest
reductions of 2.2% and 3.8% in their median intervals. Later rounds slowed in both
roles, and the six pairs do not establish a general speedup distribution. These
results support the finite semantic gates and a small benefit in two selected
workloads; they do not demonstrate a large general generated-program gain.

The compact [results receipt](serial-rfc-relink-results.json) binds all three
closed reports and both exact plans and retains every sample. The source/metadata
review of both execution harnesses found no material provenance or oracle issue.
No source, emitted program object or production selection was changed by this
relink experiment.


2026-10-26 empirical boundary update: the integrated compiler linked with this serial runtime completed the full fixed compiler request with exact QBE. The [full comparison capsule](serial-rfc-full-evidence/summary.json) records one atomic/serial pair (266.8624s / 249.6785s, 6.44% less request time). This is a single pair and does not transfer qualification to a new N2 image. It exercises NativeHost.read on this compiler path; dedicated path/publish and batch/session smokes remain separate obligations for the selected final chain.
