# P126-001 — persistent private float transport

Owner: root; bounded independent analysis/review by p116_backend_audit and
p110_abi. Parent Phase125 `3c94d98`; preregistered [design](../../design/phase126/persistent-private-values.md).

Hypothesis: exact low32-only argument-use certificates permit private F32
calling conventions and loop backedges, removing integer/float transport across
complete computations. Keep the original checked graph/verifier and public word
ABI. A private adapter bridges legacy callers; unknown/full-word observations
retain integer formals. Whole-buffer-certified adjacent primitive groups retain
F32 lanes through local computations; branching loses non-dominating facts.

The alias graph accumulates all copies/overwrites/branches and backedge edges;
full-word observations refuse a formal. N_W32 alone is not a float certificate.
All private return values remain ordinary words in this first slice. Array
template functions retain the original lowering and are excluded from typed ABI.
Sqrt preserves the runtime's float→double sqrt→float arithmetic, not sqrtf or FMA.

First attempts preserved under selfhost/build/phase126/: local-source01 refuses
out-of-order pattern matching; local-source02 refuses an affine tail reused by
both branch closures; typed-source03 refuses String-valued synthetic binding IDs.
typed-source04 checks; ten pure admission/refusal controls pass. Ordinary two-file
controls pass on Phase125 independently before candidate execution. These are
scoped checks, not whole compiler correctness.

Compare original, local-only and typed-call/backedge variants on original active
ray, original raytrace and unrelated numeric recurrence; keep the frozen complete
output/count oracle. Admission and emitted-machine inspection must establish that
the intended path actually runs. The first three-case candidate emission is
`selfhost/build/phase118/p126-typed04-emit/report.json`; runtime timing is separate.

Status: experiment running; no performance/promotion claim yet. Exact source/API
receipts retain all inputs and original verifier authority. No installation or
native-image change. Subsequent outcomes belong in implementation/phase126/.
