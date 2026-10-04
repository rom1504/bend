# P44-001: ordinary runtime IR and composable emission

Correctness: checked04 passes strict build, 3,026 main and 196 broader frontend
agreements, 81 backend agreements, eight maintained suites and independent
composition controls. Shared failures remain explicit.
Measurement: all 45 points / 669 samples pass; 6.1214× → 6.0832× TypeScript is
effectively flat. Decision: retain the composable architecture and its general
passes without claiming a broad execution gain. Checked04 is installed and
release verification passes; CLI smoke closure is recorded in the final report.

Claim: ordinary calls, bindings, functions and delayed matches can share a typed
runtime IR without changing program behavior, while replacing the old mixed
source-analysis/text traversal. Once explicit, bounded local passes and statement
emission can apply across unrelated programs with shared legality conditions.

First falsifiers: emitted byte differences on the unchanged corpus; changed
erasure, saturation order, parallel scope, delayed matching or constructor demand;
an IR whose ordinary expressions all remain opaque; unacceptable compiler costs.

Root starts from Phase43 checked14 at69d8c70; exact identities are recorded in
`selfhost/build/phase44/baseline.json`. The closed Phase43 bundle supplies old
programs. New source composition fixtures are independent feature controls, not
evidence of performance on an unseen application population.

See the [design](../../design/phase44/README.md). The [report](../../implementation/phase44/README.md) records outcomes, timed
samples and remaining architectural boundaries.

## Observations

- The first migration, checked01, emits byte-identical modules for all 45 points
  across 23 maintained sources. It also preserves the independent composition
  fixture's output and existing backend observations.
- The next candidate introduces copy propagation, exact identity-binding
  elimination, nine literal U32 folds, and statement emission. These are rules
  over runtime operations and lexical scopes, with no benchmark-name selectors.
  Output changes at 41 points across 21 sources. Changed output is not evidence
  that a transformed operation executes on the measured hot path.
- Checked04 removes five more obsolete helpers and is byte-identical to
  checked03 across all 45 prepared modules. Its API is a different, freshly
  checked artifact, so final qualification binds checked04 explicitly.
- The first six-point screen has baseline/candidate geometric ratio 0.98978:
  essentially flat, with no demonstrated broad benefit. V8 may already remove
  much of the IIFE/binding overhead; this is an inference, not an isolated causal
  finding. The separate [known-call experiment](P44-002-known-call-dispatch.md)
  rejects the tested helper-based stable-target intervention after another flat
  screen; the unchecked prototype is excluded from the installed compiler.
- The IR is a partial migration. Private layouts, deep factories and guarded
  call selection retain explicit Legacy/CallPlan boundaries. Those nodes do not
  confer effect or ownership facts on their source subtrees.

- Full timing is effectively flat under point, source and family weighting.
  Twenty medians improve and 25 regress; two beat TypeScript. The source graph
  grows 373 lines to 21,813. This is an architectural refactor, not a line-count
  reduction or a demonstrated general runtime speedup.
- All 36 controlled compiler requests agree exactly. Map request time improves
  15.61%; the other three medians regress 2.81–3.57%. Those combined changes do
  not isolate planner reuse causally.
