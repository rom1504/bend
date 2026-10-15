# Universal laws for the compiler's term representation

All 17 public laws pass source checking, safe elaboration and the independent
BendTT kernel in [representation-check03](../../../build/phase96/representation-check03/report.json).
Every theorem body is present and nonopaque. The same run also rejects the
retained false-equality kernel control. There are no extra supporting lemmas
included in the public count.

| Contract | Laws |
| --- | --- |
| Child updates | `children_put_back`, `children_last_write`, `children_preserve_metadata`, `node_reads_new_children`, `lambda_reads_new_children`, `literal_ignores_children` |
| Source spans | `span_put_back`, `span_last_write`, `span_preserves_semantics`, `span_reads_new_begin`, `span_reads_new_end` |
| Update composition | `span_children_commute`, `children_update_is_rebuild`, `rebuild_put_back` |
| Complete variant observations | `literal_observation`, `lambda_observation`, `node_observation` |

[laws.bend](laws.bend) states equations over arbitrary finite `KTerm`, `KLambda`
and `KLiteral` values, including arbitrary child lists, removed names, payloads
and source positions. Literal leaves intentionally ignore child replacement.
Lambda quantity-presence metadata survives rebuilding. The read-after-write
and variant-observation laws anchor meaning: an updater that ignores its new
argument cannot pass merely by satisfying idempotence or commutation.

[prepare.py](prepare.py) extracts the actual `KTerm` declaration and 15 helpers
from `selfhost/src/core/term.bend`: projections, child/span updates, literal
observations, quantity presence and rebuilding. It removes only each selected
definition's leading `@unsafe` annotation; the function bodies and datatype are
unchanged. Production source is not edited. The extraction's full before/after
text and hashes are retained in the
[source03 manifest](../../../build/phase96/representation-source03/manifest.json),
and the accepted checker snapshot preserves the exact proof dependency closure.

The new `Metadata` and `Semantics` records are specifications grouping correlated
observations, not replacement compiler representations. They expose all relevant
payloads together; span preservation intentionally excludes span fields from
`Semantics`, while child-update metadata excludes children. The separate complete
constructor observations anchor these projections to literal field values.

All eight semantic helper mutants were first accepted as standalone safe source,
then rejected by unchanged laws in
[representation-negative-check01](../../../build/phase96/representation-negative-check01/report.json).
They ignore new children, erase removed names, ignore a new span start, swap
literal endpoints, lose lambda quantity presence, mislabel a literal, zero a
literal payload or return the wrong node name. These are frontend proof
rejections with explicit failed laws, not parser failures or additional
independent kernel verdicts. [mutations.py](mutations.py) prepares isolated
snapshots; it does not alter production or weaken the frozen laws.

The proofs establish these pure representation operations' equations under
BendTT. They do not establish that every arbitrary record is a well-typed source
program, that surrounding unsafe compiler passes preserve their invariants, or
that C emission and runtime execution implement the calculus. The separate
[production controls](../production/README.md) exercise full actual values;
their 226-case, 16-family JS corpus and32 selected generated-C cases pass in
the [integrated audit](../../../build/phase96/audit01/report.json). They remain
finite execution evidence, distinct from these universal proofs.
