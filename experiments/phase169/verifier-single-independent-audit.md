# One complete verifier on the public view

Source review supports the proposed implication: after the unchanged original
generic/static/adapter checks and original-private-flags check, success of the
unchanged `p118b_verify_functions` on the exact flag-only public view implies
success of that verifier on the original private functions. This removes a
duplicate complete traversal on success; it does not substitute cached validity,
header checks or producer assertions for actual body verification.

This review covers the composition, current verifier implementation and the
written candidate seam. Executed finite/real gates are separate. No compiler
target was run by this review.

## Why the implication holds

Let `F` be the actual ordered function list, with all original `public=False`,
and let `V = p168v_functions(F, adapters)`. The projection retains every name,
parameter, result, body and list position, changing only each public flag.

1. **Same borrowed-import projection.** `p118b_verify_functions` constructs IDs
   from the same actual original program. `p118ns_project_functions` applies
   `p118b_project_function` in the same order. The latter passes only the body
   and IDs to `p118b_project`; the public flag is copied into the result without
   being read. The statement/import projections therefore produce identical
   bodies and identical ordered projection errors in both cases.
2. **Same ready-table identity and call requirements.** `p113e_signature` places
   the public bit in `dv(record).id`. Name, kind, arity and result are identical.
   `p113e_insert` hashes only the name; the index uses name/hash for placement
   and lookup. `p113e_call` reads only signature kind, arity and result, alongside
   unchanged argument/destination/live-state checks. It never reads that public
   bit. Function identity checking asks only whether the name is already present.
3. **Public is an extra requirement.** `p113e_function` applies the same name,
   signature, schema and body-flow checks. `public=True` additionally requires
   the actual original scalar ABI. Setting it to False cannot turn a successful
   check into failure. No other checked behavior branches on that flag.
4. **Ordered induction.** Start from the same empty ready table. If the current
   viewed function passes, the corresponding private function passes with the
   same flow result. Inserting their signatures preserves equality of all fields
   used by later checks. Repeat over the unchanged ordered list. Missing, forward,
   duplicate and cyclic calls retain the same refusal conditions.

The effective statement dispatch chain was inspected through `p113e_stmt`,
`p126dp_original_stmt`, `p125p_previous_stmt` and `p113e_base_stmt`, including
divmod, concat, transport and array-pair import checks. Those import checks do
not receive the ready table. Branch recursion passes it to the same checker;
ordinary calls reach `p113e_call`. There is no transitive public-bit read that
weakens an actual direct-body check. A conservative textual dependency closure
from the frozen native source contained 546 definitions; inspection of its
public/ready uses agrees with the explicit paths above. This is source reasoning,
not a newly machine-checked theorem.

## Boundary that must stay private

`p167v_original` must run on the untouched original program. Its adapter
obligation calls `p167v_allowed`, which **does** require
`ix(dv(signature)) == 0`. It independently checks actual source permission,
generic headers/bodies, static image and adapter bodies. Moving this check to
the view would change its meaning. The unchanged `p167v_private` must also
precede view construction: otherwise a malformed already-public original could
be silently reset by `p168v_functions`.

## Error order

Success implication alone does not prove equal failure messages. For example,
the view could fail an early public ABI check before a later body failure which
the old private pass would have reported. On any view failure, rerun exact
`p167ob_final(book, bangs, adapters, originalProgram)`:

- If that fails, return the old original-final error with its original prefix.
- If it succeeds, return the original view-verification error and prefix.

This also preserves the existing projection-first priority: projection errors
across the complete list precede ordered direct-function checking. The success
path needs only one full borrowed/direct verifier; the failure path may do more
work to preserve externally observable diagnostics.

## Discriminating controls

Keep fixed controls for an early view ABI error plus a later original body error;
a later projection error plus an earlier body error; an already-public original;
private-valid/public-ABI-invalid input; and an earlier ready callee whose flag
changes while its signature stays identical. Include forward-call refusal.
These distinguish the actual implication and error policy from mere success
on ordinary products. Exact complete products and unchanged final verification
remain required before selecting an executable candidate.

## Written seam review

[`verifier-single.bend`](../../selfhost/tests/phase169/verifier-single.bend),
3,108 bytes, SHA256
`640e98df3324d9e1ea8d107d8d0d3388551ed3f7afe89aba7fbe039d01d41b0c`,
implements the reviewed composition without changing a verifier body.
`p169sv_original` preserves original error/private-flag ordering;
`p169sv_view` constructs exactly the existing view and invokes the unchanged
complete verifier; `p169sv_checked` either seeds that view with the same original
live-eligibility predicate or reruns original `p167ob_final`. `p169sv_refused`
preserves the two old error prefixes. No blocker was found in this wiring.

The initially reviewed controls were 4,989 bytes, SHA256
`2445fb3ec853e85d0f2a06c6b866fe2696cf9519fdbadd634aace678aa76223e`.
They include sixteen rows covering complete success products, ready public and
private callees, ABI rejection, undefined locals/calls, missing terminal,
already-public input, original-header priority, adapter arity, lowering failure
and error-selection helper behavior. The combined actual-body/projection
priority controls recommended above were not yet present in this snapshot;
their recommendation was sent to the implementation owner. No observed control
results are claimed by this source review.

Primary source paths:

- [`ownership.bend`](../../selfhost/src/back/qbe/ownership.bend):
  `p118b_verify_functions`, `p118b_project_function`, `p118ns_project_functions`.
- [`verify-direct.bend`](../../selfhost/src/back/qbe/verify-direct.bend):
  `p113e_signature`, `p113e_call`, `p113e_function`, `p113e_functions`.
- [`demand-verify.bend`](../../selfhost/tests/phase167/demand-verify.bend):
  original obligations and private flags.
- [`demand-observers.bend`](../../selfhost/tests/phase167/demand-observers.bend):
  exact old final gate and failure order.
- [`adapter-view.bend`](../../selfhost/tests/phase168/adapter-view.bend):
  exact flag-only transformation.
- [`streaming.bend`](../../selfhost/tests/phase169/streaming.bend):
  current original-final and view-final composition and error prefixes.
