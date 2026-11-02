# Phase155 query composition: ideas 08–10

These additive Bend witnesses target the qualified Phase152 source. No production
module, independent verifier, runtime or selected image is changed. Root owns
checking, native execution, profiling and any promotion decision. The source is
[`queries.bend`](../../../selfhost/tests/phase155/queries.bend).

## Why these boundaries

- [Phase136 query audit](../../../implementation/phase136/profiling/query-mechanics.md)
  established that ordinary read-like queries can own and destructure all nine
  KDef fields. Its query census also showed that prepared lookup **already uses
  an index**. These experiments preserve that index; they do not benchmark a new
  hash map against a deliberately linear prepared lookup.
- [Phase144 compact/parallel analysis](../../../research/phase144/compact-and-parallel.md)
  requires complete conversion, cleanup and consumer costs and explicitly says
  source `+` is not a guaranteed borrowed ABI.
- [Phase153](../../../implementation/phase153/README.md) attributes significant
  actual ownership/reclamation work to lookup and fact queries. Counts are not
  removable-time percentages. [Phase154](../../../implementation/phase154/README.md)
  found that a dedicated numeric cell still returns through owned scheduled
  transport. A scalar-result observer is the next bounded discriminator.

## 08 — Observe a fact width inside the existing index traversal

Original: `da(p111v_get(tree,name))`. Candidate: the same full-hash Patricia and
collision-bucket decision tree returns width directly. It preserves legacy KDef
trees, zero-mask nodes, wrong-hash misses, absent results, first-match buckets and
empty-name behavior. It does not return a complete owned fact row to its caller.

Both entries construct the same 32-row fact index through actual `p111v_put`,
then consume n scalar query results. Queries cycle through 32 present and three
absent keys. Name construction and hashing are paid by both. No source-specific
cache or preconverted candidate input is used. Construction and final release
remain in the complete call. This uses the actual generic fact representation,
not the Phase154 private model, so there are no additive module dependencies.

## 09 — Keep a descendant observation under its held root

Original: `ix(kid(dt(root),slot))`. Candidate: match the held root, type and child
list, observing the scalar ID inside the scope that exposes each descendant.
The type root remains live through all n iterations. Eight present and two absent
slots alternate; supplementary controls include literal/lambda/index variants
and ID 4294967295. Root construction and destruction are common and charged.

This composes several projections, unlike another isolated owned-versus-borrowed
single-field helper. The source interface exposes a borrowing opportunity; only
actual native instruction/runtime inspection can establish whether the selected
backend uses it. If both paths already select identical borrowed access, a neutral
result is meaningful and no new lifetime mechanism should be inferred necessary.

## 10 — Carry a located constructor to all metadata consumers

Three consumers independently request arity, template count and telescope binder
ID via the unchanged `j_layout_ctor`. The candidate locates the constructor once,
then consumes its three fields together. Both use identical outer and nested
BookCache indexes, an ADT domain, 16 constructors, two missing names, existing
fallback semantics and a checksum covering all three fields. No direct owner
assumption or new constructor identity rule is introduced.

This is a **composition ceiling**, not evidence that one current production
function makes precisely these three duplicate calls. Actual consumers are
spread through `common/arity.bend`, `common/queries.bend`, direct pattern/call
lowering and layout validation; `back/qbe/lower.bend:p111_show_arm` also
repeats constructor identity for the same already located child. A positive
micro result needs a measured real consumer chain before implementation. Reusing
the exact `j_layout_ctor` avoids conflating this with a new index or first-match
rule. The earlier Phase94/97 narrowly improved helper results do not establish
whole-compiler benefit here.

## Observation and controls

All six entries have `(+n: U32) -> String`. The string is decimal U32 checksum:
start at 2166136261, then `acc = (acc * 16777619 mod 2^32) xor result` for every
iteration. This consumes the complete scalar result of 08/09 and all three
metadata fields of 10. It is not a full returned-KDef comparison, because neither
experimental API promises such a result. Exact expected small values are in
`spec.json`, derived independently from the stated fixture/schedule, not from
candidate execution. Every timed result must also match the old role.

`p155q_controls(0)` must return `"ok"`; its thirteen structural comparisons cover
representations not all visited by the timed fixtures. These are finite tests,
not a semantic theorem. No target has been run by the author. Root's combined
source/native gate must establish legality before any timing claim.

Useful rejection conditions: candidate is slower; backend already fuses the old
path; scalar query still performs equivalent owning traversal; real consumers
cannot share immutable identity without changing evaluation/order; or a synthetic
win does not transfer to captured compiler owners. Do not remove checking,
final verification, missing-result semantics or required ownership credits.
