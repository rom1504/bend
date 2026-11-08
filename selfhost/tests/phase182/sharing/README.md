# Phase182 equality sharing correctness port

This ports the behavior of upstream commits `88a7dfd` and `7442eee6`, as present
in `9a4223d577ba56a0cb53d1fd952d2b481c38930f`. Equal share cells join a separate
equivalence class; their evaluation values never move. A proven EQ class may
discharge an EQ or LE comparison, while a successful directional LE comparison
never creates an EQ fact.

Implementation is in maintained `src/core/graph.bend` and
`src/core/normalize.bend`. This subtask launched no compiler, test, profiler or
benchmark. Source checking, execution, proof replay and qualification remain
separate root-owned gates. No verifier or checker condition was removed.

## Representation and invariants

The existing `GState{heap,next}` constructor stays valid and denotes an empty
class relation. New `GCompared{heap,next,classes}` carries the relation separately
from the immutable value heap. The two original exhaustive GState observers
handle both variants. `g_share` and `g_cache` use `g_with_heap` to preserve the
relation while allocating or reducing values. Fresh states at the rigid and
full-book comparison boundaries still have independent empty relations.

`GClasses` is a persistent radix map from a cell's full U32 identity to an
optional parent/rank record. Absence denotes a singleton root, including id zero;
no sentinel id overlaps an actual key. A stored root names itself. Union first
finds both roots and does nothing if they already agree. Otherwise the lower
rank root links to the higher rank root; equal ranks raise the surviving root.
Rank strictly increases along links. Thus generated class maps cannot cycle,
and parent walks have logarithmic depth without mutable path compression.

Only `KNormShare` creates a class join. It remains queued after all obligations
of an EQ cell comparison, so failed comparisons and directional LE successes
cannot publish an equality fact. `norm_cmp_shared` is admitted before graph
forcing in both modes. Proven facts may survive an alternative within the same
comparison heap, as before; no facts transfer from failed rigid evaluation to
the independent full-book pass.

The join changes neither heap bytes nor the next-cell identity. In particular,
a left cell's value may contain a path to the right cell: joining their classes
does not copy that path into the right cell or create a self-referential value.
Evaluation never follows class links and comparison never redirects value
ownership through a representative. This distinction is the cycle fix.

Our existing graph state is scoped to one `norm_convert`; upstream's mutable
cells can survive separate comparisons. The port preserves the current scope.
It does not claim upstream's across-comparison cache lifetime or an identical
speedup on the LE scaling case. It retains the current worklist/alternative
algorithm and fresh-heap policy.

## Source inventory

- Two new types: `GClassEntry`, `GClasses`; one new `GState` variant, `GCompared`.
- Twelve graph helpers: `g_with_heap`, `g_classes`, `g_class_get`, `g_class_put`,
  `g_class_root_entry`, `g_class_root`, `g_class_rank_entry`, `g_class_raise`,
  `g_class_link`, `g_class_join_roots`, `g_class_join`, `g_class_same`.
- One forward type signature: `law g_class_root`; this is not a proof.
- One normalization helper: `norm_cmp_shared`.
- Five existing definitions change: `g_heap`, `g_next`, `g_share`, `g_cache`,
  `norm_cmp_loop`; the public comparator signatures and KNorm work items remain.
- No declaration is removed. `compiler.json` is intentionally left for root's
  coordinated refresh.

## Focused finite controls

`controls.bend` builds four equal cells whose metadata differs. It joins three
pairs including nonroot IDs, then exposes complete old/new heaps. The host gate
checks every field rather than `norm_exact`, which omits source spans. It also
checks preserved aliases, same-class idempotence, transitive/symmetric class
membership, independent fresh state, next-cell identity, and preservation of
the relation through cache and share updates.

The comparator controls require these literal outcomes:

| Worklist | Expected |
|---|---|
| Data LE Type | true |
| Data LE Type, then the same cells EQ | false |
| Failed EQ followed by the same EQ in an alternative | false |
| Equal cells EQ, then LE | true |

Prepare a checked API with `controls.bend` and these exports:

```
p182s_state
p182s_joined
p182s_heap_observations
p182s_checks
p182s_relations
p182s_relations_expected
g_class_join
g_class_same
g_heap
```

Then run `values.mjs --candidate REPORT --out FRESH` under the maintained guard.
It proposes 22 observations. No pass is claimed in this source-only note.

## Upstream regression fixtures

`upstream/` contains byte-for-byte copies from the migrated upstream working
tree, with the original expected-output trailers:

- `tests/check/conversion_shared_cells_once.bend`
- `tests/check/conversion_shared_cells_no_cycle.bend`
- `tests/check/conversion_shared_cells_no_cycle_check.bend`
- `tests/check/conversion_shared_cells_self_value.bend`
- `tests/check/conversion_shared_cells_three_way.bend`
- `tests/check/conversion_shared_cells_le.bend`
- `tests/proof/share_cell_cycle.bend`

They cover repeated shared graphs, cyclic-value creation, subsequent checker
forcing, three-way classes, LE reuse and the original list head/tail proof.
Run them against the migrated compiler with the appropriate Base and independent
proof path where supported. An accepted unsafe source, a checker result and a
BendTT proof are distinct evidence; unsupported lanes must remain explicit.
