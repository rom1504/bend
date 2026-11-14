# V3 correction: match scrutinee staging

Preserved failure: `selfhost/build/phase195/owned-diagnostic-api01/stderr` and
its frozen source at `owned-diagnostic-api-source01/compiler.bend:52145`.
The bootstrap parser rejected `+first = ...; match first` in
p195od_shape_fields. This is a source-language staging error, not a failed
ownership proof or runtime observation.

V3 changes two compiler definitions:

- p195od_shape_fields now passes the computed shape to
  p195od_shape_fields_next, which matches its final parameter immediately.
- p195od_rows now passes the computed schema to p195od_rows_prepared, which
  matches its final parameter before evaluating the plan or constructing rows.

The copied evaluator has no computed/local scrutinee and is byte-identical to
v2. No semantic admission conditions were weakened.

The independent ordinary BST source also required staging repairs: numeric
comparisons now pass Bool results to od_leaf/od_branch; main passes the result
to od_observe; the negative discarded-recursion case passes its computed pair
to od_discard_result. Matching those parameters/fields preserves the intended
positive and negative semantics. The search key's reusable demand is explicit.

Read-only audit of pinned bootstrap `bend.ts:2737-2871` confirms both explicit
matches and tuple-pattern local syntax are subject to the parameter/field rule.
The lexical inventory in match-audit.json records all88 match sites, including
two tuple-pattern parameter destructurings. Manual review confirmed that every
scrutinee is a function parameter or an immediate constructor field, all matches
precede local statements within their branch, and multi-scrutinee matches follow
parameter order. The lexical script is only an inventory aid; it does not claim
parser/source acceptance. No compiler, generated target or timing ran here.
