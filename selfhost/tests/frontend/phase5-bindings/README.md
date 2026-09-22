# Phase5 binding and decorator witnesses

`cases.json` contains22 fresh live-reference acceptance/rejection-phase controls.
`additional-cases.json` adds two intended-rule probes: a grouped unbound value
behind a bad constructor binder, and an imported Base constructor used bare.
The ordinary/parallel distinction matters: single-local constructor destructuring
is legal, while parallel bindings allow names only. Constructor names declared
later remain legal binders at the earlier declaration.

These acceptance/phase oracles do not assert exact upstream diagnostic wording.
In particular, `parallel-first-bad-value.bend` deliberately retains a known
same-phase but different-rule discrepancy: Bend's raw parser reads the following
brace differently. `parallel-first-unbound-value.bend` removes that ambiguity
and is the intended binder-first-error control. Do not count the former as
proof of the latter rule.

Use `tools/conformance/target.mjs` with this selection and an explicitly checked
API, canonical Base and a fresh output directory. Normal checked APIs use their
genuine bootstrap report. Overlay APIs use `phase5-overlay-adapter.mjs`, which
verifies their separate checked-overlay report and frozen host artifacts; it
never manufactures a normal-bootstrap sidecar. Check lanes may use persistent
workers. Interpreter/JS lanes require `workerMode: isolated` and explicit output
oracles. Exact commands, frozen configurations, outcomes and failed setup
attempts are retained by the Phase5 implementation report.
