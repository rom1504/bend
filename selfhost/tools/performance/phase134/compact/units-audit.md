# Exact private-function reuse across source revisions

Status: isolated source prototype, not selected or native-qualified. It depends
on `range-reuse-v01.bend` and the audited `p134v_*` exact structural equality and
verification helpers. No production declaration is overridden.

## Reusable unit and invalidation

`p134u_request(request, error, cache)` returns an emitted result, a successor
cache, and five counts:

1. Inline hits from the prior revision.
2. Inline misses and fresh transformations.
3. Outer-range hits from the prior revision.
4. Outer-range hits from the existing inner pass in this request.
5. Outer-range misses and fresh transformations.

Start with `P134UCache{[],[]}`. Pass only a cache actually returned by the same
fixed producer into the subsequent call. The representation is not a persistent
format or an untrusted proof/certificate interface. The host only retains and
returns immutable Bend data; it does not decide transformation legality.

Each inline slot records:

- The complete original `P113DFunction`.
- Each original-body direct-call target and the complete result of looking it
  up in the current ordered inline table, including `None`.
- The resulting `P134RKUnit`, containing the transformed function and any exact
  inner range input/output pair.

The lookup census recursively visits both branches of `P113DIf`. It collects
all original direct calls, including calls beyond the eventual site/budget
limit. This is conservative: an irrelevant changed lookup may force a miss,
but a queried changed lookup cannot be omitted. Scalar `N111Call` statements
are external/runtime calls; the existing inline scanner does not query their
symbols in `P113ITable`.

A hit requires exact original function equality and equal complete/absent
lookup results in the **current** table. Comparing signatures alone would be
unsound: unchanged call signatures can have changed bodies. A previously
absent callee becoming available must also invalidate the result.

## Why these are the actual dependencies

In the frozen selected source, all `P113ITable` parameters in the `p113i_*` and
`p113j_*` inline path occur in table helpers or original-body scan orchestration.
`p113i_scan_stmt` queries the table only for an original `P113DCall`.
`p113j_scan_cost` appends the expanded callee and then scans the original rest;
it does not rescan inserted callee bodies. Expansion, scratch analysis, fresh
local spelling, cost and budget accounting consume the exact function/callee
values already included in the key. Nested original branches are scanned and
are included in the dependency census.

Prior callees may themselves contain earlier inlining or range optimization.
Recording their complete transformed functions captures that transitive
information without hashing the entire table or original source book.

Every hit still performs the original table publication step:
`p113i_original_clean(original)` followed by the unchanged
`p113i_table_function(transformed, table)`. The table is rebuilt in current
function order. There is no stale-table reuse. Position-aligned slots are only
hints; insertion, removal or reordering can reduce hits but cannot bypass exact
function/dependency checks.

## Range and verification boundaries

The outer range cache records its own exact input and `p113k_function(input)`
output. A prior pair is used only on exact input equality. If that misses, the
same request's inner range pair may be used under the same condition. Otherwise
the ordinary pass runs. No range idempotence is assumed.

Both the inline and range results still pass through `p134v_commit`. Original
static program, IDs, genuine verified-boundary requirements and independent
final verification remain unchanged. A rejected intermediate candidate can
leave a reusable mathematical pair, but each future use still has exact input
and context checks followed by the existing verification commits. Cached
entries contain no verification result or reusable success flag.

## Falsifiers and measurement

`units-controls-v01.bend` has 20 source controls. The high-value mutation cases
are same-signature changed callee body, absent/present lookup transitions,
nested branch calls, original-body changes, table publication on a hit,
transitively affected callers, added/deleted/reordered slots, and invalid old or
new boundaries. They compare to original fresh transforms and original full
verification commits, not to a second memo path.

The important experiment is a real source edit with separately generated fresh
reference QBE, not a no-op alone. Charge cold acquisition, dependency scans,
exact equality, retained IR, misses, final validation, and whole request time.
The within-request range prototype already had mixed hosted results, so it is
not a default optimization. Across-edit reuse must demonstrate enough avoided
inline work to pay for recording this state; high hit counts are insufficient.

No frontend parsing/checking, common preparation, private-candidate lowering,
static preparation, final QBE rendering, QBE machine generation, or native
linking is cached here. This experiment cannot claim savings in those stages.
