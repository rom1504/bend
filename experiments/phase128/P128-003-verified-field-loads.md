# P128-003: expose borrowed field access to QBE

Hypothesis: after verified borrowing removes ownership traffic, opaque helper
calls and scratch transport still hide important optimization opportunities.
Expand only the already-verified exact import into guarded readonly loads.

Selected template retains constructor arity in previously unused emitter
metadata. It preserves IDs, tag/CID checks, low 40/RFC header decoding, widths 2–8,
scratch/status and the original helper fallback. The generic verifier and runtime
are unchanged; the capability is limited to the pinned sequential CPU ABI.

Five paired clean kernel rounds improve 0.531184 → 0.368798s (30.57%). Parent
1.490729s and upstream 0.102037s delimit the full composition and remaining gap.
Whole-reader machine instructions increase 130 → 220; textual call sites stay 10
because fallback calls remain. Those static counts do not estimate hot work.

Evidence: 21 finite predicates, 545 independent ABI checks, 27 ordinary output
lines, actual renamed spine/list readers, final 100-predicate source and native
N1/N2 qualification. The ABI spy tests dispatch and memory equivalence, not the
production helper's fail-stop error behavior. Two checker failures in controls
are preserved; source04 uses corrected controls-v3/oracle-wrappers-v2.

Receipts: `selfhost/build/phase128/field-timing01/report.json`,
`field-machine01/report.json`, `native-admission03.json`, and
`selfhost/build/phase113/p128-field-oracle02/report.json`.
See the [audit](../../implementation/phase128/borrow-field-template-audit.md)
and [final report](../../implementation/phase128/README.md).
