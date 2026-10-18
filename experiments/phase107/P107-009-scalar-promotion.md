# P107-009 — closed-allocation scalar field promotion

2026-10-18. P107-006 passes the bounded memory controls but invariant-load
forwarding alone leaves owned-observer runtime around3.3× raw Clang. Hypothesis:
promoting fully understood private scalar fields into locals exposes ordinary
scalar arithmetic optimization, including balanced counter updates, without
recognizing reference counts or inventing a borrowed ABI.

Prototype `nx_scalar_promote(program)` performs whole-function legality analysis
before publication. Only scalar parameters/results, fresh constant nonzero-size
allocations outside loops, resolved pointer copies/constant offsets, exact disjoint
field layouts and simple loops are admitted. Unknown accesses, calls/indirect calls,
pointer returns/loads, branches/nested loops, escaping pointers, use after free and
partial/mixed-width overlaps refuse the entire function unchanged. Apply existing
load forwarding first to expose known pointer copies.

Promote U32/U64 fields to fresh, typed-zero locals. Keep every allocation/free and
pointer-field store physically present; retain pointer identities, byte layout and
allocation-failure behavior. No ownership policy, call ABI or runtime changes.
Loop pointer provenance must hold for every iteration; values of scalar locals
naturally follow actual load/store control flow, including zero iterations.

Before speed claims: independent whole-result checks, exact refusal controls for
unknown aliases/mixed widths/escapes, scalar and pointer dependency changes,
loop-carried payload updates, zero-trip and allocation/free controls, fresh-name
collisions and admitted mutants that conflate aliased or overlapping fields.
Check that physical effects other than promoted scalar accesses are unchanged.
Validate both original and transformed graphs, retaining every failed attempt.

Measure optimizer time, scalar memory-access reduction, backend object cost and
runtime on the same frozen memory workloads. The experiment concerns bounded
sequential well-defined IR, not a proof of the compiler or automatic promotion of
arbitrary escaping/concurrent allocations. Defaults remain unchanged.
