# Phase128: index the immutable live set once

This experimental Bend overlay replaces only `kr_filter`. It reuses the
existing exact-name Patricia implementation rather than adding a new hash table
or changing the compiler's identifier representation. It is composed, but has
not been checked, executed, measured or native-qualified by this investigation.
The coordinating agent owns those gates.

## Measured reason to try it

Phase127's full-source attribution contains 942 `kr_filter` active-context
samples out of 36,220 (2.6008%). The separate `has_name` context has 2,651
samples (7.3192%); it is shared by many callers and is **not** all attributable
to this boundary. These are sampled execution contexts, not inclusive stacks.

The existing short-request event survey shows substantial work under only two
`kr_filter` dispatches per request:

| Phase126 diagnostic request | `kr_filter` dispatches | `ctr_take_calls` | `term_drop_calls` |
| --- | ---: | ---: | ---: |
| lexer | 2 | 521,698 | 907,822 |
| closures256 | 2 | 210,564 | 364,532 |
| Map churn128 | 2 | 704,269 | 1,204,485 |

Private helpers retain their caller's active dispatch context. These counts
include private membership operations and reclamation; they are neither the
number of book entries nor a complete attribution of all `has_name` work.
Sources are retained `selfhost/build/phase127/owner-survey01/events-*-phase126.json`
and `full-profile01-attribution/report.json`. The committed
[owner survey](../../../../../implementation/phase127/owner-survey.md) and
[full timeline](../../../../../implementation/phase127/full-timeline.md) explain
the observation limits. No new target measurements were run for this candidate.

## Transformation and obligations

The old function performs a fresh linear membership scan of the same `live`
list for every book entry. The replacement builds one name-membership index at
the function boundary, then walks the book in its original order. Recursion
calls `p128rf_filter`, so it does not rebuild the index per entry.

`p128rf_members` inserts a private `P128ReachMember` marker for each exact name.
`index_set` and `index_find` retain exact-string collision buckets. Duplicate
live names do not change membership. Empty names remain valid: membership
tests the marker kind, not a nonempty-name sentinel. All matching book entries
survive, including duplicate definitions with distinct payloads. No `KDef` is
reconstructed; native provenance, quantities, payloads and constructor children
remain attached to the original retained entry.

The finite equivalence checks retain the original linear algorithm, and fixed
expected lists independently check ordering, duplicate payloads, Unicode, empty
names, `BookCache`, index nodes and the real FNV-1a collision `costarring` /
`liquid` (both hash to 1,582,148,253 with this compiler's seed/multiplier).
Larger controls cover 128 equal-name and distinct-name entries. These checks
are preparation for qualification, not a proof of all language semantics.

This removes a product of book length and live-set length in the common
non-collision case. It adds a one-time index construction, index-node storage
and cleanup, plus hashing each queried definition name. Small lists may be
slower. Exact full-QBE equality is required on the fixed compiler requests;
complete native request timing must include index construction and disposal.
Do not count an isolated membership speedup as the complete gain.

## Reproduce composition and finite-check transport

The parent is frozen Phase127 `live-bank-source01/compiler.bend`, SHA-256
`f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d`.
Its `kr_filter` is the same linear algorithm as `selfhost/src/core/reach.bend`.
The common composer authenticates that source and preserves all non-overridden
declarations, including the verifier and transport contracts.

```sh
python3 selfhost/tools/performance/phase128/prepare.py \
  --out selfhost/build/phase128/reachability-source03 \
  --module selfhost/tools/performance/phase128/reachability/plan.bend \
  --module selfhost/tools/performance/phase128/reachability/controls.bend \
  --overrides kr_filter
```

Use a fresh output path for another composition. The composed source identity
from this investigation is
`358e00862c655f2fd87a3643e2f24ffed27d6243541ebe6ee8e2532cfa42bab3`.
The earlier sources remain retained; source02 adds the explicit `+rest`
sharing annotation required when both lazy branches capture the same tail,
in the candidate and its linear reference. The coordinating agent's first
checked-API acquisition rejected source02 because the controls' `+book` list
literal lacked an explicit type. Source03 adds `: List<&2,KDef>` to that binder.
The failed receipt and diagnostic remain at
`selfhost/build/phase111/p128-reachability-api01/`; no optimizer result is
inferred from that source-typing failure. No target was executed by this
investigation agent.
Generate an ordinary checked API exporting `p128rf_controls` and the normal
compiler-request exports. Then the existing `phase128/finite.mjs` accepts the
group specification `{"p128rf_controls":20}`. Preserve its checked receipt and
all independent request/output oracles. Native acquisition and timing remain
under the coordinating agent's resource lane.

No changes to parser indexes, `has_name`, `nb_contains`, reachability traversal,
stops, output order, installed selection or runtime are part of this candidate.
