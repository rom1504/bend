# P98-006: avoid repeated work exposed by observer admission

Status: value/proof experiments complete; no native image built or promoted. The observed resource failure was instead fixed by P98-007. These candidates remain unmeasured performance hypotheses.

The combined59b36a1c candidate enables checked observer planning for the native
compiler's authenticated IO entry. Its six-source B1 screen improves to0.808856×
request time with48 exact C/diagnostic matches. However, full self-compilation
hits the2GiB RSS guard after83.00 seconds and the bounded4GiB retry after101.09
seconds. Both guards stop cleanly with more than21GiB available; neither emits a
complete C product. Do not reinterpret those attempts as timings or correctness
passes. The unchanged B1 compiles the same source in140.061 request seconds,
with1.526GiB peak RSS; unchanged B2 takes155.703 seconds.

Source inspection identifies two repeated-work mechanisms newly exposed by
observer admission:

1. `no_scalar_redirect` constructs redirect text for every worker, even when the
   name differs and the text is discarded. Move construction into the matching
   branch and retain the complete original worker on misses. Keep traversal of
   all duplicate names. The candidate adds3 physical lines and removes26 bytes.
2. Successful schema finishing repeatedly computes `nol_scalar_specs(book,book)`.
   Compute that immutable value once inside the permitted observer route and
   thread it through a private cached schema path. Existing public helpers stay
   unchanged. This candidate adds56 lines; its eager-once placement can have a
   cost on books with no successful schema, so measure that boundary too.

Recipes: `selfhost/build/phase98/observer-cost-sources01/manifest.json` contains
independent redirect, scalar-specs and combined candidates. All replay forward
from D04 through59b36a1c and reverse exactly. No canonical modules are changed.
The combined source is a0254c279cab150aeb5c5e9084e1520ae2c1f8ec4ef9bdd96189eb3364e7d5a5.

An actual-helper proof establishes complete ordered worker-list equality for
arbitrary names, roots, fields, errors, dependencies and duplicate matches.
`redirect-proof-check01` passes the source checker and unchanged independent
BendTT kernel: one public law and two support lemmas, no opaque helper assumptions.
This establishes a value contract, not a runtime allocation bound.

Next gates: complete-value worker/schema comparisons through narrow APIs;
identical complete C and diagnostics on fixed inputs; bounded full self-emission;
then the ordinary two-stage conformance, behavior and performance qualification.
The repeated-work explanation is a hypothesis until a measured intervention or
usable profile attributes the large-input resource failure.

The later90s prefix profile identified a different concrete cause: unbounded
`noa_below` recursion after a failed field-tag guard. See [P98-007](P98-007-observer-ancestry-termination.md).
The cache/redirect candidate passes105 full-worker and60 full-schema observations
and three exact C/diagnostic comparisons, but is not being built/promoted as a fix
for that failure. Its accepted whole-list law also rejects a separately labeled
late fault that stops after the first duplicate hit, after admitting that mutant
as safe code. These are useful independent results, not measured compiler gains.
