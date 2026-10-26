# Indexed layout-traversal membership audit

2026-10-26. Source-only review of `layout-seen/core-v01.bend` against Phase141
integrated-source02 (`f5bfca6d...`). No execution or speed claim. Independent
controls: `selfhost/tools/performance/phase142/layout-seen/controls-v01.bend`,
export `p142jt_controls`, 26 rows. The full selected source plus the candidate
core provides all dependencies; no compiler overrides are needed to test it.

## Verdict and invariant

No source-semantic blocker found for the private traversal starting with an
empty index. The representation invariant is:

```text
p142j_member(index, name, index_hash(name,2166136261))
  == has_name(originalSeenList, name)
```

The index contains only records made by `p142j_mark`, each with the complete
queried `name` and kind `P142JSeen`. It starts from `missing()`. The existing
`index_set`/`p131i_insert` preserve canonical Patricia structure; `index_leaf`
replaces only records with the same complete name. `index_find` routes by hash
but its final `index_bucket` compares full names with `p88_string_eq`, the same
equality used by `has_name`. Thus actual hash collisions remain distinct. A miss
returns kind `Absent`, not `P142JSeen`; querying the empty string or the literal
name `Absent` cannot confuse presence with the missing-record payload.

This invariant is for indexes constructed by the candidate. Arbitrary malformed
KDef trees or caller-supplied mismatched hashes are not admitted authority. The
public-shaped experimental entry `p142j_checked_error` constructs its own empty
index and computes each name's actual hash internally.

## Traversal and error obligations

The candidate preserves the original worklist, `lookup(defs,name)`, dynamic
`dk==Def && dx==0` guard and complete `jl_term` traversal. It changes only seen
membership/storage:

- `$layout.open-array` is checked before both seen and stops. Even if included
  in either set, it still returns the original rejection.
- Every new queried name is marked before visiting its looked-up definition,
  including missing, non-Def and templated definitions. Marking `dn(lookup(...))`
  instead would be incorrect for missing or unusual names; the candidate uses
  the original queried name.
- Existing stops retain exact list membership. No alias normalization, namespace
  stripping or delimiter splitting is introduced.
- Duplicate definitions retain the original cached-book lookup/first-match
  semantics. Seen-set replacement does not select a different definition.
- Self/mutual recursion and shared callees terminate through the same membership
  event. The same `jl_term` result is prepended to the same remaining worklist;
  no DFS/BFS or branch ordering changes.
- Native Array checks, erased/live field handling, unchecked-shape fallbacks and
  the returned `"an open Array element type"` text remain original.

Original anchors: `has_name`5817, `index_hash`6177, `index_find`6227,
`index_bucket`6285, `index_leaf`6343, `index_set`6412,
`jl_checked_error`17137, `jl_visit`17142, `jl_def`17152 and
`p131i_insert`56734 in the selected source.

## Independent controls and limits

The controls compare candidate results against the unchanged original entry or
visitor, while also asserting explicit expected accept/reject results. They
cover missing references, duplicate roots, first-match duplicate definitions,
self/mutual cycles, a cycle followed by rejection, sentinel priority, stops,
pre-seen names, skipped non-Def/template bodies, two-branch traversal, native
Array rejection and exact qualified-name handling. Membership controls include
empty/Absent names, duplicates, non-BMP/BMP names and the real FNV collision
`costarring`/`liquid`. The collision graph puts the rejection only behind the
second distinct colliding name, so hash-only membership would fail it.

These are constructed traversal graphs, not a claim that every graph is accepted
by source checking. Full real-request QBE equality and measured native/hosted
cost still need the root's existing harness. Index allocation and hashing are
new costs; the asymptotic membership improvement alone is not evidence of an
end-to-end gain. The static audit does not establish a new theorem about the
index implementation or remove any existing independent compiler gate.
