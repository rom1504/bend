# P68-022 — Native profiles distinguish structural parity opportunities

- Owner: root; independent source/research/method lanes.
- Started: 2026-10-11; source checkpoint `4e0d8c6`, compiler23 at `b2ec0a2`.
- User objective: investigate paths to 1x or 0.5x upstream C generated-program
  runtime; no production optimization or release promotion in this experiment.
- Correctness status: prospective diagnostic oracle checks; unchanged compiler.
- Measurement status: prospective; prior 1.724x result remains historical.
- Decision at registration: investigate.

## Hypothesis and disproof

Excess allocation/ownership transport and call boundaries account for a large
part of the four slow families' gap. Fresh native samples, dynamic operation
counts and exact emitted-code comparisons can identify general upstream
mechanisms absent from our current lowering. This is disproved or narrowed if
the excess operations are cold, upstream performs equivalent work, or removing
them would violate ownership/evaluation order or only help one artificial input.

The alternative explanations include runtime-revision differences, memory
layout, register pressure, dispatch/branch behavior and benchmark composition.
Retain these alternatives until evidence discriminates them. More counters do
not by themselves prove speed potential.

## Method and invariants

Follow the [design](../../design/phase68/c23-parity-investigation.md). Preserve
all old source, acquisitions and receipts. Fresh artifacts and independent
oracle checks bind actual compiler23 and pinned upstream. Native targets are
serial and guarded on CPU3; source/research lanes use CPU0. Clean clocks and
instrumented counts/profiles remain separate. Profiling changes are diagnostic
derivatives only; the compiler remains implemented in Bend and unchanged.

Results, attempts, limitations and decisions will be recorded in the linked
[report](../../implementation/phase68/c23-parity-survey.md), without rewriting
this prospective registration into a retrospective success claim.
