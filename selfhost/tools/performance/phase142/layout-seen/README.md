# Indexed layout and reachability traversal

This experiment replaces the visited-name membership list in two existing
compiler graph walks with the existing collision-checked Patricia index. It
does not cache a validation result or skip a term/type traversal. The compiler's
independent final verifiers remain unchanged.

## Production-only composition

Append these helper modules, then replace only the two named declarations:

1. `layout-seen/core-v01.bend`: seven `p142j_*` helpers, including the shared
   full-name membership/marker operations.
2. `reach-seen/core-v01.bend`: six `p142r_*` helpers, depending on those operations.
3. `layout-seen/override-v01.bend`: replace `jl_checked_error` only.
4. `reach-seen/override-v02.bend`: replace `kr_visit` only.

Paths above are relative to `selfhost/tools/performance/phase142/`.
Do not append control or synthetic-fixture modules to the production candidate.
The reach override keeps the original inferred declaration syntax because an
existing law is attached to `kr_visit`. Its typed `override-v01.bend` failed
source checking and is retained as negative evidence.

The new layout entry calls `p142j_visit`, which calls the unchanged `jl_term`.
The new reach entry calls `p142r_kr_visit` and private recursive workers; none
calls `kr_visit` or `kr_visit_def`. Therefore replacing the entry does not
redirect the private worker back into its wrapper. Original `reach_book`,
`kr_resolve`, `kr_dependencies` and the already indexed `kr_filter` remain.

The layout walk preserves the open-array sentinel check before seen/stops,
first-match definition lookup, missing/template behavior and the error string.
The reach walk retains its original ordered seen list **including duplicate
resolved parent names** while maintaining a shadow membership index. It still
expands constructor-parent dependencies even when the resolved parent was
previously visited. Stops retain their original body-only meaning. Hashes choose
buckets; exact names decide membership, including hash collisions and empty or
`Absent` names. No native-stack or ownership annotation is forced by the adapter;
ordinary checked lowering and stack-safe fallbacks still apply.

## Evidence and limits

The pre-override layout API passed 26 finite controls. The independent reach
module has 28 controls covering exact ordered lists and complete reached books.
Keep their actual execution receipts separate from source review. In particular,
after entry replacement, a control that calls the old public name no longer has
an independent implementation oracle. Differential evidence must use the frozen
pre-override API/source; explicit expected results remain useful after wiring.

`selfhost/build/phase142/layout-component02/report.json` retains a bounded,
partially completed hosted screen. Its 26 controls and all retained pairs passed
their result oracle, but `complete` is false because the 2048-node diagnostic
reached the run budget after two pairs. Median **paired indexed/original** times:

| Held input | Pairs | Ratio |
| --- | ---: | ---: |
| Actual Lexer annotation products | 5 | 1.376 |
| Actual Map annotation products | 5 | 1.015 |
| Synthetic 128-definition graph | 5 | 0.235 |
| Synthetic 512-definition graph | 5 | 0.111 |
| Synthetic 2048-definition graph | 2 | 0.022 |

These are descriptive same-API component measurements, affected by JIT/GC.
They neither establish a native speedup nor predict a whole-request gain.
The actual small inputs show why asymptotic improvement alone is insufficient.
The synthetic fixture constructs annotated AST nodes directly; it is a scaling
diagnostic rather than a source-checked representative program. Nested direct
walk measurements exclude preparation and must not be added to complete gate
intervals. The bounded combined observer is `component-screen-v03.mjs`.

For R popped references and V previously seen names, the original membership
work can grow as O(RV) string comparisons. The index instead hashes each name
and follows at most 32 Patricia bits plus exact collision-bucket comparisons.
It creates persistent index nodes and performs hashing, so short graphs may lose.
The reach variant also retains the exact output list and initializes membership
once from any supplied initial seen list. No claim is made about total compiler
time until the integrated native candidate is measured.

## Next source-backed candidate, not implemented

`p140dr_report_data` in the frozen Phase141 source still calls
`dr_cached_names` → `dr_walk`, whose local visited list uses `has_name`.
The separate shared `safe` index already memoizes successfully established
closures, but the first large closure still performs linear local membership.
The newer `p140dr_names` already replaces `dr_own_names`' duplicate collection;
rewriting the old collector again would miss the active entry.

The smallest falsifier is a same-API original/indexed `dr_walk` comparison on
actual held report books, checking the complete `DR_Closure` including visited
order and partial results. An unsafe early exit must not publish partially
visited names as safe. This is a plausible remaining source of membership cost,
not a profile attribution: the current active `has_name` samples do not identify
their caller. `kr_push` also deduplicates per-definition references linearly,
but those lists may be short and its profitability is unmeasured.

Source basis: `selfhost/build/phase141/integrated-source02/compiler.bend`, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`:
`kr_visit` line 7543, `kr_push` 7596, `dr_walk` 37226, and
`p140dr_report_data` 62026. See also
[`indexed-visitors-integration-audit.md`](../../../../../research/phase142/indexed-visitors-integration-audit.md)
for the independent integration review.
