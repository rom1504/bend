# P141-001: retire duplicated semantic machinery

Status: implemented and ordinary-native qualified; see the completion report.
Preregistered2026-10-25 21:49UTC.
See [design](../../design/phase141/README.md).

Hypothesis: the current compiler contains a complete subsystem whose repeated
representation/recognition responsibilities can be replaced with one smaller
semantic implementation, without imposing generic callback/ownership overhead
or weakening the supported contract. The exact subsystem is selected after the
first20-minute current-source/caller inventory.

Success requires old/new independent equivalence, an actual deletion list and
net maintained-code reduction after adapters, plus practical performance evidence.
The10k whole-compiler goal is not inferred from one successful slice. A candidate
that only adds an abstraction without retiring its predecessors fails this trial.

Keep the qualified compiler and independent verifier. First-hour decision22:49;
complete the authorized three-hour trial by00:49UTC onOctober26. Record selection,
failures and final evidence in the linked implementation report.

## Outcome

The first-hour gate selected two actual replacements: one stop-aware parser
instead of two grammar copies, and statically specialized canonical comparison
instead of runtime-generic plus handwritten copies. The latter family is62.3%
smaller with handwritten-level native proxy speed. The whole candidate saves828
physical/606 code lines, including76 control lines. This supports the local
hypothesis, not a10k whole-compiler conclusion. See the
[report](../../implementation/phase141/README.md),
[identities](../../implementation/phase141/candidate.json) and
[measurements](../../implementation/phase141/metrics.json) for qualification,
same-source costs, failed attempts and limits. No installed/default selection
was changed; incremental entry points remain experimental.
