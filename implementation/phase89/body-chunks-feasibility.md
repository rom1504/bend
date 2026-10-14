# Deferred native body composition: bounded source audit

Status: proposed, not implemented or measured. This audit made no compiler,
upstream, image, or target changes. It preserves the separately frozen owned
match candidate and its source identities.

The root investigator reports 26,639,166 String-append characters and roughly
72 million allocations per Map request for roughly 895 KB of final C. Those
whole-request counts motivate this change; they do **not** establish how much
of either count belongs to `NC_Code.body`. Characters and output bytes are
different units. The diagnostic below must measure the attributable part.

## Smallest coherent representation change

Replace only `NC_Code.body: String` with an ordered, shareable Data tree:
`Empty | Leaf(String) | Join(left, right)`. Keep `N_Segment.body`, `N_Emitted.code`,
and the public C output as String. A join preserves the exact left-to-right
order; it does not evaluate or reorder compiler operations. Existing short
String-producing helpers become leaves. Child bodies remain trees throughout
match, let, pattern, observer, and parallel composition.

Use a body/tree accessor in composers and a visibly separate render operation
at final boundaries. Keeping the old String-valued accessor in composers would
silently reproduce the original copying. Do not use function-valued difference
lists: the native closure-sharing failure from Phase87 is directly relevant.

Flatten iteratively with an explicit Data stack, visiting right children before
left children and prepending each leaf to the accumulated suffix. Thus every
leaf is on the left of String append once per materialization. Do not append
the growing accumulator to each leaf, recursively flatten child trees before
joining them, or build chunk lists by repeatedly appending whole child lists.
The final segment renderer still indents and joins strings as today; that is
bounded linear work outside this first change.

## Exact scope

A static source inventory of the active modules, before the isolated owned
match patch, finds 29 `nc_body` call sites, 35 `NC_Code` construction sites and
9 direct patterns, spread over 43 definitions in 10 modules. These are source
inventory counts, not runtime frequencies. Most constructors merely wrap a
String leaf; unchanged-body patterns carry the tree through.

| Module | Definitions mentioning those interfaces |
| --- | ---: |
| bridge | 14 |
| direct | 4 |
| flat | 5 |
| product | 5 |
| pattern | 2 |
| word-pattern | 2 |
| parallel | 2 |
| book | 3 |
| observer-emitter | 4 |
| observer-adapter | 2 |

The eight String boundaries are `nc_let_cut`, `nc_lambda`, `nd_join`,
`nc_children`, `nc_parallel_finish`, `nc_append_book`, `nf_bodies`, and
`nq_wrap_segment`. Several functions both finalize one child into a segment and
carry another child onward: render **only** the finalized child. In particular,
`nd_join` must carry the base body unchanged. `nc_append_book` must not render an
omitted factory, and `nf_bodies` must not render an unadmitted worker.

Only two body inspections require special treatment:

- `nf_inline` checks `String.length(body) <= 4096`, from both prototype and body
  emission. Use a bounded tree/leaf traversal that stops after 4097 Bend
  characters. Preserve code-point semantics, not UTF-8 bytes or UTF-16 units.
  No full rendering or unbounded Nat length is necessary. An eager cached
  length on every leaf adds work and is not needed for the first prototype.
- `nc_compile_kept` checks whether the body equals `""`. Normalize empty leaves
  and joins, so Empty is an exact constant-time predicate. If joins are left
  unnormalized, an Empty-tag-only test is incorrect.

The existing native text helper `nt_text_finish` already follows the safe
right-suffix accumulation principle. A tree stack extends this principle to
nested bodies; it is not a new output language or optimization IR.

## Invariants and ownership hazards

Keep lowering calls in their current order, including miss lowering after an
errored hit, and retain exact fresh values, first-error priority, segment order,
call lists, guards, whitespace and newlines. Changing the body representation
must not become a shortcut that suppresses work or changes diagnostics.

Carry forward the owned match candidate's consume-once destructuring. Repeated
whole-code projections can retain and later destroy the tree just as they did
strings. Avoid expanding this into an unrelated all-composer ownership rewrite
before the representation discriminator. Ordinary Data sharing is supported;
function-valued closure nodes are not an acceptable substitute. Trees also add
node allocations and destruction, and rejected workers still build bodies.
Deep skewed trees need an explicit traversal stack, including for length checks.

## Fast discriminator and bounds

First check pure rendering controls for ordered joins, empty normalization,
shared subtrees, deeply skewed trees, and Unicode at lengths 4095, 4096, 4097.
Then adapt the existing 19 composition and nine full-lowering controls to
compare the **rendered complete NC_Code product** against baseline, including
segments, fresh, error and calls; the raw internal tree is intentionally not
the same product representation. Run checked JS and native controls.

Next use Map, a nested-match/let case and a shallow case in the same native
request harness. Require exact C and record append characters, allocation
count, request time and peak memory, including final flattening inside the
same timing boundary. Compare to the owned-only derivative so the two changes
remain separable. The compelling discriminator is reduced dynamic append
work on nested bodies without replacing it with similar tree-allocation work.

This is approximately 40–45 definitions to review plus a small tree helper
API, not a two-function patch. A reasonable planning allowance is 2–4 hours
for a coherent prototype and focused controls; full-image builds and release
qualification are additional. No measured speed forecast exists yet. Even
perfect removal of internal-body copying leaves leaf construction, discarded
candidates, semantic lowering, final output scans and allocator behavior.
