# P44-001: ordinary runtime IR and composable emission

Correctness: unqualified until checked build and actual emission controls.
Measurement: not run. Decision: implement the authorized architecture migration.

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

See the [design](../../design/phase44/README.md). Outcomes, timed samples and
remaining architectural boundaries will be recorded in implementation/phase44.
