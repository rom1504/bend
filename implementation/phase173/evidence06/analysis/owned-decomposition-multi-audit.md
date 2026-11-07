# Multi-argument owned decomposition: independent audit

Source-only review by `ambitious_challenge`. No target execution, production
change, or performance measurement. The reviewed extension recognizes one
computed setter argument plus already evaluated values and structurally checked
projections of the same root. It specializes the actual setter body into the
existing `P173ODSummary`/`P173ODRow` interface.

## Findings sent before acquisition

**Correctness blocker in the first draft:** a getter argument unused by a selected
setter branch was never authenticated. `p173om_row_schema` only resolved variables
appearing in the output constructor. Call-site collection accepts an ordinary
arity-one `getter(root)` before its semantics are established. Consequently:

```
setter(root, F(good_getter(root)), ignored_bad_getter(root))
```

could previously become a selected branch that dropped the original eager
`ignored_bad_getter` computation. That function might fail or diverge. Refusing
only an ignored *computed worker* did not address ignored other arguments.

Required correction: authenticate every projection descriptor for each emitted
constructor row, even if its formal parameter is unused. If any cannot be proved
a bounded structural projection or closed constant on that constructor, omit the
row and retain the entire original call through fallback. Already evaluated
unused atom arguments are different: removing their variable occurrence does
not remove its earlier evaluation, though ordinary ownership/drop rules remain.

**Coverage refusal in the first draft:** the common field parser accepts only
quantity-2 lambdas. Reusing it for setter formal parameters also rejected ordinary
quantity-1 parameters, including the unrelated packet rebuild fixture. Real
`k_rebuild` declares reusable parameters and was unaffected. A dedicated formal
parser can accept quantities 1 and 2 while preserving disjoint IDs and keeping
the actual constructor field-binder requirement at quantity 2. This is a
conservative coverage issue, not evidence of a semantic miscompile.

Both findings were delivered to root and the summary author before any target
execution by this reviewer. The author's corrections and final source identities
are recorded below when reviewed; this document does not claim passing controls.

## Other boundaries reviewed

- Setter formals are interpreted through their ordered descriptor vector. Each
  output field is resolved exactly once from an actual constructor field or
  formal argument. This preserves the original setter's field order rather than
  guessing a layout from argument positions.
- Caller atoms whose variable IDs equal the helper field basis or common
  replacement ID are refused. Those are precisely the IDs subsequently renamed.
  An atom sharing an unrelated formal ID is not recursively substituted again:
  one-pass origin resolution prevents capture by another parameter mapping.
- A per-branch computed formal is normalized to one common symbolic replacement.
  Its original use count and resolved use count must both equal one. Fields must
  be distinct from that symbolic replacement. The existing whole-book/candidate
  fresh-ID checks then guard final field and result-binder allocation.
- `k_rebuild` preserves the physical KTerm/KLambda distinction. KLambda's
  `present` field comes from the actual old constructor field and is included in
  the resolved output, even though it is not a call argument. KLiteral ignores
  the computed replacement; its row is omitted and its complete original call
  remains fallback. Arbitrary literal kinds and metadata are not reconstructed
  by name-based assumptions.
- Same-root additional arguments are refused. Distinct aliases remain legal and
  are governed by ordinary ownership/liveness after the rewrite. A getter field
  reused elsewhere in the result remains shared when required.
- The interface now admits one computed call, not necessarily exactly one changed
  field: other supplied atoms or projections can alter or permute fields according
  to the real setter body. The existing term-based emitter can represent this;
  no positional-only in-place-update assumption is used here.
- A selected branch retains the worker exactly once in a strict let. Other
  eliminated projections must be total structural computations; after that proof,
  moving their reads/reclamation across the worker has the same fixed-runtime
  ownership obligations as the original early-decomposition experiment. Unknown
  rows retain exact eager fallback.
- The original two-argument route is unchanged apart from the explicit
  multi-argument fallback entry. Module assembly requires original summary,
  multi summary, multi transform, multi call, then controls. The transform hoists
  the forward `p173om_application` contract. No additional obvious affine binder
  or forward-law issue was found by source inspection; source checking remains
  authoritative.

## Small decisive controls

1. A selected row with a valid computed getter and an unused, unproved getter,
   both before and after the computed argument. Inspect admission only; do not
   run a deliberately diverging fixture.
2. Quantity-1 and quantity-2 setter parameters; reject erased/parallel quantities,
   duplicated parameter IDs, and field/parameter collisions.
3. Full KTerm/KLambda values including both `present` states, spans, removed names,
   Var-hit/miss behavior, and arbitrary KLiteral variants using unchanged fallback.
4. Complete packet values with outer-root retention and child aliasing, followed
   by actual source-backed admission. A successful synthetic summary is not
   proof that the independently written workload was rewritten.
5. At least one exact expected transformed graph that covers field/parameter ID
   collisions and the single computed result. Final verifier success alone does
   not prove that the source rewrite preserves eager evaluation.

No full compiler acquisition is justified by this audit alone. First establish
real admissions, complete-value equality, ownership-work removal, and compilation
cost on the existing bounded experiments.

## Corrected implementation review

The author added `p173om_all_args` before output origin resolution. It walks every
descriptor and authenticates both ordinary getter projections and the computed
argument's input getter for the selected constructor. An unproved unused getter
now refuses that row; the original call remains fallback. `p173om_parameters`
separately accepts formal quantities 1 or 2 while retaining duplicate/forbidden
ID checks. Constructor field binders still use the quantity-2 parser. These
changes address the two substantive findings above.

The synthetic projection control initially supplied an unprepared raw getter
book, which `nc_definition` erases and constructor-encodes, but requested a raw
`Record` constructor name. Review caught this before acquisition. The corrected
control uses encoded identities consistently in the requested projection, Mat
and output Ctr; the raw source getter stays raw for ordinary erasure. This also
prevents ignored-getter negative controls from passing merely because of a
constructor-name mismatch. A paired positive row uses the same schema with a
certified unused getter, isolating the negative case's actual reason for refusal.
The revised module has 30 prepared finite controls;
their execution outcome is not asserted here.

Reviewed identities after those fixes:

| File under `selfhost/tests/phase173/` | SHA-256 |
| --- | --- |
| `owned-decomposition-multi-summary.bend` | `df79286050915e7522371594b76f28a30c57baee5fa6f1c6567e31e835021c9e` |
| `owned-decomposition-multi-transform.bend` | `6832021102a83a583aaca327802972c77962fb8201c657db2057525982a86a8c` |
| `owned-decomposition-multi-call.bend` | `aa954e5b46a7d75a0f8e955879563ffeacf73179e1060055f14ea2979046e732` |
| `owned-decomposition-multi-controls.bend` | `ea3f46ecf95df04a6f4c70693ab4d16fd121d1611920add396f06e4439860737` |

No remaining concrete semantic blocker was found in this bounded source review.
Source checking and real native admission/value controls remain required; a
structural audit cannot certify the selected compiler's downstream implementation.
