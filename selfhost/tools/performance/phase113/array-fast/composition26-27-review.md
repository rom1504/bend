# Exact source26/source27 composition boundary

Both fixed compositions include the reviewed guarded uniform-array templates,
pre-inlining array identity transfer, and stable heap-base entry load. They use
the exact runtime-products01 source and runtime-products-build01 object. No
raw/dynamic/scalar guard or owning helper effect is removed by these additions.
The source17/21/22 receipts and rejected source23/25 attempts stay preserved.

The branch overlay is exactly branch-facts manifest-v2. Nonexact low/high words
are mandatory-one masks, not exact values: OR unions them, joins intersect them,
and the unsigned width bound remains. A mandatory-one word is nonzero. Signed
comparisons remain unknown through the original unsigned comparison helper.
Boolean branch refinement requires an operation-derived 0..1 subject and a
relation whose condition and subject write versions still match. Every fact
replacement advances its version; joins discard relations and no relation
crosses a self-loop backedge. This neither derives a numeric representation from
an ownership kind nor establishes a raw-array invariant. The version counter's
no-wrap premise is the finite admitted worker/body bounds, not arbitrary
unbounded reflected fact-map histories.

The width overlay is exactly width/modules-v2.json, including cases-v2. It only
combines an adjacent same-destination U64 ring operation and exact low32 mask,
or renders a standalone exact low32 mask. Low32 projection commutes with
add/sub/mul/and/or/xor; a fresh word temporary followed by extuw preserves the
original full-width result. Inputs are read before assigning the original
destination, so input/destination aliases remain safe. It crosses no effect,
observation or branch and does not narrow shifts, division or comparisons.
The fresh namespace and shared renderer counter are unchanged; counter overflow
falls back. Original verifier, transfer/error handling and other renderers stay
exact. This is a finite backend rule, not an ownership proof.

Source26 retains the192-node inline eligibility and512-node expansion budget.
Source27 changes those two bounds to384/1024 through the separately frozen
policy-wide module. Arity32, results1..8, input body2048, candidate stack8192,
final stack16384,16-site hygiene, exact return/alias checks and rollback remain.
Both use the same bottom-up range simplifier and final pre/post-verification
pipeline. Larger budgets do not add a new semantic transformation.

The admission checks exact approved source hashes, ordered recipe/snapshot
replay, all prior array/runtime requirements, these exact overlays, and completed
checked-API receipts containing the same source. It does not accept a caller's
arbitrary profile. Native arithmetic, ownership, branch-refusal and complete
output receipts remain separate evidence; a completed admission alone makes no
performance or general compiler-correctness claim.
