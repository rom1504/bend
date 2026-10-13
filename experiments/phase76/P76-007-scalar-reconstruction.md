# P76-007: eliminate scalar reconstruction after pattern matching

Generated default paths materialize a Word tail, rebuild its matched prefix and
immediately consume the result back to the same scalar. Under a row's exact bit
constraints this is a representation round trip. Beta-substitute fresh bit/tail
variables; structurally match native U32/F32 reconstruction against that prefix
and replace it by the original low32 scalar. Allocate residual Word data only
if still used. Escaping tails and unsupported reconstruction remain unchanged.

This is a general scalar pattern rule, not a Nat.read or benchmark recognizer.
It may change startup allocation and native layout. Require independent rewrite
controls, actual partial-word/captured/default/F32 execution, conformance and
balanced runtime timing. Do not assume it explains or fixes the observed runtime
regressions before measuring. Alignment probes remain separate diagnostics.

Candidate10 passes frontend36 and 20,521 independent comparisons. It removes two
word-tail reconstruction loops from Array.map output but does not recover the
Tree/Array.map runtime regressions. Rejected for default promotion; complete
source is preserved in prototypes/candidate10.patch. No full-release claim.
