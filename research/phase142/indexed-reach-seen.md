# Indexed reachability membership while retaining the exact visit list

Source-only candidate; no target execution or selected-source change.
The audited Phase141 source still has linear `has_name(seen,name)` in
`kr_visit`7543. Phase128's `p128rf_filter` optimized only the final filter.
`reach_book`7530 therefore still discovers reachability with a list-membership
walk before rebuilding an index for that filter.

[`reach-seen/core-v01.bend`](../../selfhost/tools/performance/phase142/reach-seen/core-v01.bend)
is32lines with six private functions. It reuses the layout experiment's exact
name-index helpers; it introduces no new cache, state schema or index algorithm.

- `p142r_kr_visit(book,todo,seen,stops)` accepts the original list-shaped API and
  builds its shadow membership index once.
- `p142r_visit` carries **both** the exact old seen list and its membership index.
- `p142r_reach(book,roots,stops)` retains the unchanged `kr_filter`.
- `kr_resolve`, `kr_parent`, `kr_dependencies`, term reference collection and
  stop behavior remain the originals.

## Subtle behavior preserved

The original walk records a queried name before resolving it. On a successful
resolution, `kr_visit_def` also records `dn(d)`, even if that name is already in
seen, and still expands the resolved definition's dependencies.

For example, querying two constructors C and D of parent P can produce the
ordered list `[P,D,P,C]`. Replacing seen with a set and reconstructing its keys
would lose both ordering and duplicates. Skipping parent expansion merely
because P was seen would also change the original transition.

The candidate preserves each original cons operation exactly. It adds/updates
corresponding membership markers, but never deduplicates the output list. Even
an initially duplicated seen list remains byte-for-byte structurally ordered.
A missing queried name remains recorded; it does not acquire a resolved-name
entry. Direct top-level lookup still precedes parent resolution.

Stops differ from the layout traversal: `kr_visit` does **not** skip a stopped
name outright. `kr_dependencies` omits only its body references while preserving
its type and constructor-type dependencies. No new stop check was added here.

## Simulation argument and costs

Maintain identical book, todo, seen list and stops, with the shadow index's
membership equal to `has_name(seen,x)` for every string x. At each step:

1. A seen query skips the same todo head in both walks.
2. A new query performs the same `Con{query,seen}` and `kr_resolve`.
3. Missing resolution continues unchanged. Successful resolution performs the
   same `Con{dn(d),seen}` and original `kr_dependencies`, regardless of whether
   that resolved name already belonged to the set.
4. Marker insertion is idempotent for membership and never replaces the list.

Induction gives the same complete returned list; the unchanged filter then gives
the same ordered KDefs. This relies on the existing exact-name index insert/find
laws, including collision buckets. Independent controls are being prepared by the
review agent; this note is not a mechanically checked proof or execution result.

The potential saving is repeated linear visited-name searches. Persistent index
allocation and hashing are added, and the final filter still constructs its own
index. Parent resolution, dependency traversals, list appends and stop membership
remain real costs. A stopped body or an already-seen parent is not a license to
remove those original operations in this experiment.

The native profile's large active `has_name` share does not identify its caller;
both this reachability walk and other analyses remain candidates. Measure exact
old/new `reach_book` outputs on actual held frontend context before attributing
that profile share. Use the same already-indexed book context as the real caller;
a raw synthetic book can add linear `lookup`/parent scans and obscure the effect.

The initial comparison needs `reach_book`, `kr_visit`, `p142r_reach` and
`p142r_kr_visit` exports plus actual frontend products. Preserve ordered full-list
comparison, not just set/count equality. No final gate changes are proposed.

## Prepared combined component observer

The review agent's `reach-seen/controls-v01.bend` now supplies28finite rows through
`p142rt_controls`. It checks exact ordered lists, including `[P,D,P,C]`, stops on
query versus parent names, type/constructor dependencies, collisions, shadowing,
missing names, cached books and duplicate final-filter results. These remain
source-prepared checks until a coordinator receipt establishes execution.

`layout-seen/component-screen-v02.mjs` preserves the earlier observer and adds
same-API reachability comparisons. It prepares `book_context` once outside timed
synthetic traversals, compares complete old/new KDef lists and complete old/new
seen lists with order/duplicates, and reports observed output cardinalities.
Normalized visit time uses actual distinct returned names; it is not a count of
popped queries. Both layout and reach finite-control rows are saved before their
`PASS ` assertions, preserving failed observations. No target execution was
performed by this investigator.
