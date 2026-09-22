# P5-002: one checked development entry

Hypothesis: composing the maintained bootstrap and paired harness into a small
entry reduces setup drift and makes artifact reuse explicit, without weakening
checking or creating another worker protocol. This is a workflow change, not a
compiler speed claim.

Owner: direct_calls. Design:
[Phase 5](../../design/phase5/conformance_and_development.md), track C.
Implementation: `selfhost/tools/development/workflow.mjs` and `process.mjs`.

The entry freezes a project-shaped source/host/runtime snapshot, invokes the
unchanged checked bootstrap, primes that API's validated Base cache and runs
the existing selected paired harness. A completed build can validate another
selection into a new directory. An incomplete build cannot resume as checked;
its retained logs remain evidence and a new build directory is required.

Correctness gates: input/canonical-path drift, missing bootstrap provenance,
cache identity, output collision, retained failed verdicts, child failure,
deadline and fast-output overflow; then one actual checked build and focused
paired run. Optional broad frontend validation remains a separate escalation,
with known strict failures retained. Equality is an explicit derivative with
its own independently verified provenance, never a copied bootstrap report.

Correctness: eleven workflow groups pass; genuine checked and explicit equality
workflows each pass the 21 declared paired oracles. Reused API validation and an
isolated JS compile-and-execute pair also pass. Twelve default-selection exact
diagnostic differences stay visible. Independent review corrected the selected
API/derivation association guard.

Measurement: not run; concurrent short correctness work establishes no timing
claim. Decision: promote the maintained thin entry for the documented focused
scope; no default compiler distribution change. Optional broad orchestration
has not itself been exercised by this focused gate.
Evidence: [report](../../implementation/phase5/development-workflow.md) and
[verified archive](../../implementation/phase5/development-evidence/README.md).
