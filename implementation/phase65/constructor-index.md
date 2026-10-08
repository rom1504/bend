# H5: exact Base constructor membership

**Status: rejected after the checked-B1 screen; not promoted.** The repeated work is
concrete, but the measured complete-request gain was below noise. The experiment is
[P65-005](../../experiments/phase65/P65-005-base-constructor-membership.md).

## What repeats

`base_prefix_world_admitted` calls
`base_prefix_ctor_disjoint(suffix, finalBase)`. That predicate visits every suffix
definition and nested child, and each `constructor_exists` walks all Base outer
definitions and performs a child lookup. Both successful checking and the later
owned-context admission repeat this test. This can create allocation proportional
to suffix names times Base declarations, despite Base being immutable.

The fresh allocation ancestry evidence is
[baseline-state09-constructor-ancestry.json](evidence/baseline-state09-constructor-ancestry.json).
Clearly attributed `base_prefix_ctor_disjoint` allocation is approximately
6.04 MB Lexer, 6.96 MB Map and 5.51 MB Ray. Constructor-inclusive totals are much
larger but cannot all be assigned to this path. The patch does not claim to
remove those totals or to save an equal percentage of time. The exact constructor
CPU union has only 13/14/14 samples on these three requests.

## Exact semantics

The original predicate examines **immediate children of every non-BookCache
outer definition**, and treats any non-`Absent` child as present. It does not
require child kind `Ctr`, does not include an outer definition's own name, and
does not recursively search grandchildren. The frontend constructor index has
different semantics and is intentionally not reused.

The admitted Base producer has already established `base_prefix_names` for the
original prefix: every definition recursively has kind Def/ADT/Ctr, never
Absent/BookCache. Finalization selects those declarations without inventing new
child kinds. Therefore, for this private domain, lookup succeeds exactly when
an immediate child's exact name belongs to the saved union. Duplicate same-name
entries cannot turn a non-Absent membership into absence. Trie hash collisions
retain full string comparison through existing buckets.

`base_prefix_constructor_index` constructs this union once in Bend. It skips an
outer BookCache for consistency, although admitted prefix declarations exclude
it. `base_prefix_ctor_index_disjoint` retains the original recursive suffix walk
and substitutes one exact-name index lookup for each complete Base scan.
`base_prefix_world_admitted_indexed` keeps all original readiness, name,
namespace, bounds and disjointness guards. The original admission predicate is
retained for public/compatibility controls and fallback.

## Isolated patch

[`constructor-index-v1.json`](../../selfhost/tools/performance/phase65/cache-contract/constructor-index-v1.json)
pins the complete three-file patch and its source copies:

| File | Delta | Change |
| --- | ---: | --- |
| `src/check/prefix-state.bend` | +27 lines | Add builder/predicate, append immutable field, switch three private admission sites. |
| `tools/base-cache-graph.mjs` | +2 lines | Decode new exact typed field while retaining old world layouts. |
| `tools/typed-driver.mjs` | +2 lines | Extend positional ABI, require world version4 and an index-shaped field. |

The new last field is `constructorIndex: KDef`. Ready preparation fills it from
the exact final Base; refused preparation uses `missing()` with an unready state.
Frame4's arena format and root layout do not change. Its fixed constructor decoder
accepts world records with six, seven, eight or nine fields; only nine-field,
version4 admitted worlds grant this private fact. Raw JSON compatibility is
retained. Missing or invalid optional state retains ordinary checking.

Schema/type checks do not prove the index's semantic contents. As with TODO and
checked-bound facts, that comes from the exact bound local Bend producer. There
is no new public permission, mutable global cache or JavaScript implementation
of constructor semantics. Host metadata still binds API/Base bytes, canonical
path, interval and the exact world/prefix/state roots.

## Review and executed validation

The correctness reviewer independently confirmed the membership proof under
ready-prefix invariants. The source-reviewed
[`prefix-world-constructor-v1.mjs`](../../selfhost/tools/performance/phase65/controls/prefix-world-constructor-v1.mjs)
adds fifteen immediate-kind, depth, duplicate and full-hash-collision membership
cases, and checks that the actual prepared index equals its Bend producer over
the saved final Base. Its focused mode runs these plus the inherited maximum
controls; the default also retains the complete prior result/context matrix.
Focused success alone does not establish the latter claim. Root ran the focused
controller on checked State03: all fifteen membership cases and eight inherited
maximum cases passed. The receipt is
[`state03-ctor-focused01/report.json`](../../selfhost/build/phase65/state03-ctor-focused01/report.json)
(SHA `7089b2703802ac88b5ae75fd4e28f8397bceed17607c13d9ec4d70de52557f89`).

The host-only
[`constructor-host-v1.mjs`](../../selfhost/tools/performance/phase65/cache-contract/constructor-host-v1.mjs)
retains all 79 previous admission and frame controls and adds thirteen index
boundary controls: old version/layout refusal, malformed or wrong-subtype
references, arena forward references and frozen-index mutation. It exercises
the actual private driver admission through an export-only copy, without loading
a compiler image. Its expected count is 92; **these host controls were not run**
because the latency screen rejected advancement. Arbitrary well-shaped index contents remain outside the
semantic proof of these host checks. An independent source review confirmed
the retained assertions and the new JSON/arena field offsets before execution.

## Latency screen and decision

The [State03 balanced screen](evidence/state03-b1-screen.json) used eight fresh
workers: two cases, two roles and two rounds with balanced role order. All eight
complete emitted modules matched their pinned raw-output oracles.

| First request, prepared persistent cache | Baseline median | H5 median | Change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 298.52 ms | 300.73 ms | +0.74% |
| Map set operations | 1,310.69 ms | 1,295.93 ms | −1.13% |
| Equal-case geometric mean ratio | | 0.99803× | −0.20% |

Including host/API imports gives a geometric mean ratio of 0.99792× (−0.21%).
These small, mixed changes are below the established A/A noise and do not justify
another prepared-world field, version or host admission path. Root rejected the
standalone candidate. The original Phase64 baseline remains selected; world
version4 is not promoted.

The full inherited result/context matrix, 92 host controls, genuine B2 image,
and broad benchmark were deliberately not run. Passing focused membership and
eight output checks does not imply those unrun gates passed. Preserve the patch
and receipts as a negative result; do not add its schema complexity merely to
eliminate a visible allocation hotspot. No live source was edited or target
executed by this agent.
