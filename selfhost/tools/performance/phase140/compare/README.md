# Exact structural comparison without index adapters

Source-only candidate; no API, native test or performance result yet. The
current compiler/session is unchanged. `core-v01.bend` adds only
`p140eq_def` and `p140eq_list`; it does not override existing comparators.
`controls-v01.bend` depends on the existing render comparator as an independent
reference and exports `p140eqc_controls` with40 expected rows.

The old `p140r_def` wraps both values in singleton lists and traverses generic
KDef views. For physical index nodes, `dc` materializes a two-child list; the
head comparator counts it and the traversal obtains it again, before joining
it onto a worklist. `dt` and `dv` expose synthetic absent terms. The candidate
matches physical constructors directly and compares actual hash/mask/children
or collision buckets. Ordinary declarations compare all nine fields and still
use the existing exact term comparator, including source ranges, literal
identity and explicit lambda quantity presence.

This removes source-level representation work. It is not evidence of dynamic
allocation savings: the existing compiler may already eliminate some
constructions. The new branch recursion also needs actual native code/stack
inspection. Do not assume that a scalar source result or `+` annotation creates
a borrowed worker, or that a generated reader is actually called.

## Next checks, in order

1. Append `render/reuse-v02.bend`, `compare/core-v01.bend` and
   `compare/controls-v01.bend` to qualified Phase137; source-check the API and
   run all40 finite controls. Do not change current integration sources.
2. Through that checked API, compare both functions on actual immutable
   Patricia maps from the existing Lexer/Map render contexts: function IDs,
   constructor IDs, direct/ready/view maps and registry ready/symbol views.
   Include independently rebuilt equal maps, edited maps, aliases and misses;
   record sizes, complete equality results and observer costs.
3. If native warm profiling points here, emit one small retained-map comparator
   workload using ordinary Bend construction and the original exact comparator
   as oracle. Include more than one map size and a declaration/term-tree
   transfer case. Compare identical source workloads under the two comparators,
   inspect actual called workers, take/sink operations and constructor calls,
   and retain unique/shared/alias correctness controls.
4. Only after a measurable native benefit, substitute `p140r_def` through a
   separate overlay and require exact context/registry/output equality on the
   complete edited requests. Charge acquisition, old/new IR retention,
   destruction and full warm request time. A standalone comparator improvement
   is not a complete compiler speed claim.

The structural predicate is exact equality, not logical map equality: order in
collision buckets, duplicate records, constructor-child order, variants and
metadata remain significant. No hashing shortcut or collision assumption is
introduced. This predicate must not replace the different `declared`-header
relation in the owner/checker caches without a separate equivalence argument.
