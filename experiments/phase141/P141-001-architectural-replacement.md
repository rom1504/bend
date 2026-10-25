# P141-001: retire duplicated semantic machinery

Status: preregistered bounded investigation,2026-10-25 21:49UTC.
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
