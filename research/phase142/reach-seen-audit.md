# Indexed reachability membership audit

2026-10-26. Source-only audit of `reach-seen/core-v01.bend` against Phase141
integrated-source02. No target runs, theorem or performance claim. Independent
`reach-seen/controls-v01.bend` exports `p142rt_controls`, 28 rows.

No source-semantic blocker found. The candidate uses the indexed membership
invariant already reviewed in [layout-seen-audit.md](layout-seen-audit.md), while
retaining the **original ordered seen list** as a separate value. This matters:
`kr_visit`7543 first conses the queried name; `kr_visit_def`7550 then conses
`dn(resolvedDefinition)` whenever its kind is not `Absent`, even when the two
names are equal or the resolved name already appears in the list.

The implementation retains both cons operations and corresponding index updates.
It does not skip dependencies just because the resolved parent was already seen.
For an ADT `P` with children `C,D`, roots `[C,D]` must return `[P,D,P,C]`.
Replacing the list with unique keys, skipping the second parent, or returning an
index traversal would change this observable result.

The candidate also keeps these less-obvious rules unchanged:

- `kr_resolve`7555 first tries the ordinary top-level lookup; only an Absent
  result triggers `kr_parent`7565. That scan picks the first ADT whose immediate
  child lookup succeeds; it does not require that child to have kind Ctr.
- Missing queried names are still added once. Duplicate initial seen entries
  remain in the returned list, though their membership index is a set.
- `kr_dependencies`7572 tests stops against the **resolved definition's name**.
  A stop omits only its value references. Its type and constructor-type
  dependencies remain, in exactly their existing order. Stopping `C` does not
  stop resolved parent `P`.
- `kr_refs`, `kr_ctor_refs` and their local `kr_push` duplicate suppression are
  untouched. This change does not eliminate every `has_name` call in reachability.
- `$layout.open-array` is an ordinary name here. The shared set helper does not
  import the special early rejection of the separate layout visitor.
- `p142r_reach` uses unchanged `kr_filter`, already indexed by Phase128. It
  preserves the original book order, complete KDef payloads and repeated records
  having a live name; it does not filter by deduplicated index iteration.

The 28 controls compare exact ordered lists with `norm_exact_names` and complete
reached definitions with `p140p_defs`, using unchanged `kr_visit`/`reach_book`
as differential oracles and explicit expected results. They cover cycles,
duplicate initial seen, same-name query/resolution duplicates, repeated parent
resolution, type/constructor/body ordering under stops, parent and top-level
shadowing, cached books, the real `costarring`/`liquid` hash collision, Unicode,
empty/Absent names and duplicate-record filtering.

Hashing/index construction/allocation are additional costs. In particular,
`p142r_kr_visit` constructs an index for any supplied initial seen list; the
ordinary reach entry starts empty. Report that preparation consistently in
whole-operation timing. A profile attributed to `has_name` alone cannot identify
whether this visitor, layout validation, local `kr_push` or another caller
dominates. The component screen must establish the actual cost and preserved
outputs before integrating either alternative.
