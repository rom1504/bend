# Field-quantity reuse: the annotation boundary is local

Read-only source audit of the Phase175 field-reuse experiment. No target was
executed for this audit, and no compiler source was changed.

## Finding

Freshly annotating a definition does **not** imply that every constructor
subtree visited later by erasure has marked fields. Removing all marker checks
on that assumption is unjustified.

- `selfhost/src/check/annotate.bend:285` rebuilds an ordinary constructor with
  `ka_args_cached`; its fields receive `ka_field` markers carrying the telescope
  quantity. This is the useful producer/consumer contract.
- `annotate.bend:370` deliberately retains the rewrite motive, `kid(t,1)`, raw.
  Only the proof and resulting value are recursively annotated.
- `annotate.bend:289` returns other node kinds unchanged; raw type/ADT children
  therefore do not acquire a blanket annotation guarantee.
- `selfhost/tests/phase175/semantic-field-erasure.bend:92` recursively visits
  retained children. An explicit annotation around a constructor inside a raw
  motive/type subtree can reach `p175sf_ctor` with unmarked fields.

For example, an unmarked live literal field commonly has `qt == 0`; treating
that value as its telescope quantity would discard the field. This is a
source-derived failure mechanism, **not an executed new source counterexample**.
The existing rewrite fixture exercises its annotated live result, rather than
establishing coverage of every raw motive subtree.

## Scope of the existing guarded implementation

The private entry receives the same freshly produced `annotate_selected` list
as the unchanged layout check and context merge. Native, foreign, template and
unselected definitions retain ordinary erasure. Within selected definitions,
the complete marker predicate retains telescope reconstruction for unmarked or
malformed fields. Public/raw erasure entry points are unchanged.

Membership in the private selected list is a calling precondition, not an
authentication mechanism for arbitrary supplied compiler data. Existing controls
explicitly demonstrate that forged field quantities can alter private erasure.

## Decision

The reported native frontend screen was 60.509s versus 61.085s, a nonpaired
neutral/slower observation; the entire targeted stage was below six seconds.
Do not expand or promote the duplicated eraser based on the current result.

If revisited, a small **future ceiling experiment** could retain the per-field
`Ann` plus marker-ID check while testing removal of redundant metadata checks,
but only after establishing that every admitted marker came from `ka_field` in
this exact request. Raw/template fallbacks and complete `NR_Request` comparisons
must remain. Do not infer that one marked field authenticates all siblings, or
that a freshly annotated definition authenticates every descendant. A measured
gain must justify any additional provenance machinery.
