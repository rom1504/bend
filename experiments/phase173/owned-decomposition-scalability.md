# Frozen automatic08: source-level cost and coverage audit

This is a bounded audit of the code actually linked into native08, not a new
compiler run or a timing claim. No production source, admission condition or
verifier was changed. The parent owns the native qualification measurements.

## Exact subject

- `selfhost/build/phase173/owned-native-modules08/pass.bend`: 54,350 bytes,
  SHA-256 `c9484880708a6b5f85441e8b6d42f151f2d4786066e607b0f35c586773068f56`.
  The extracted runtime closure has 104 function definitions, 103 forward laws,
  and nine data types. Diagnostic exports and finite controls are excluded.
- `selfhost/build/phase173/owned-native-source08/compiler.bend`: 3,205,249 bytes,
  SHA-256 `8536e598ee618e401fafed82e9e75f0d32e13c697a13ddbd5f2de23639e6c3c6`.
- `owned-native-modules08/report.json` records the exact declaration closure.
  Line references below refer to that complete frozen compiler source.

The selected hook is `p168_catalogued` (67157): prepare the original book once,
then apply `p173op_prepared` before the unchanged downstream pipeline. Summary
analysis reads the original checked/erased book; publication updates only the
prepared static-body index. An earlier rewritten body cannot change the
meaning of the helpers used to justify a later rewrite.

## Findings

**There is no evident new whole-book quadratic scan on the intended request
path. There is definite whole-program extra work, and some avoidable work
before a candidate can possibly qualify.** Neither observation establishes
that this overhead dominates native08. Full-request measurements remain the
decision gate.

### Existing indexed facts are reused

`lookup` (5773) enters the `BookCache` index. `index_find` (6228) follows stored
32-bit hash masks, with string collision buckets; it does not scan all 8,414
definitions for every query. Hashing and collision-bucket costs remain, so this
is not a claim of unconditional constant-time arbitrary-name lookup.

`nd_arity` (32583) uses the cached `NativeErasedBody`/`NativeStaticBody` arity.
`nc_definition` (35260) returns the cached erased body and does not repeatedly
run erasure for those facts. `nr_prepared` (35969) attaches the collected facts;
`ns_attach_book` (35858) attaches the constructor index as well.
`p173od_ctor` (68325) therefore reaches `nc_find_ctor`'s indexed path (32174).
The helpers still have plain fallbacks for uncached books; those should not be
mistaken for the qualified request path.

`norm_book_bound` (6944) reads `BookCache.da` immediately. Its two uses in
`p173op_prepared` are redundant small reads, **not two traversals of all compiler
bodies**. Optimizing them is not a high-value response to a slowdown.

### Two additional body traversals are real

1. `p118ns_effect_definitions` (51927) looks up each requested definition and
   `no_effect_terms` (34745) traverses its original body to exclude `Rwt`, with
   separate native/allowed-foreign checks. This extra certificate is retained
   even though the fixed-runtime gate already ran. The two establish different
   conditions. Removing it because another gate mentions effects would weaken
   the current admission argument.
2. `p173oa_definitions` (69754) walks every available `NativeStaticBody`, not
   just bodies containing the seven source candidates discussed below.
   `p173oa_walk` tries admission at each visited term and recursively processes
   children after a refusal. The 4,096 fuel is a **depth bound**, not a total
   node/definition budget. Large shallow bodies still receive a complete walk.

For an unchanged subtree, `p173oa_terms`/`p173oa_cons` (69730–69745) build a new
child list and result wrappers, then `p173oa_rebuild` (69722) discards that list
and returns the original term when `hits == 0`. Thus unchanged AST nodes are
not reconstructed, but their traversal/list-result scaffolding is. Counting
these source constructors is not a measured allocation count: existing product
lowering can erase some wrappers. Actual generated ownership/drop behavior
must be measured before assigning seconds to it.

### Syntax recognition has a small avoidable-work opportunity

At every App, `p173oa_try` (69688) computes its complete `nd_head` and `nd_args`.
When the pass descends a curried application spine, it repeats this for each
prefix. A spine of length `a` therefore has O(a²) head/argument-list work in the
worst case. Ordinary bounded-arity compiler calls limit this factor; no evidence
here shows unusually long spines dominating the workload.

More immediately, the original two-argument path (69696) performs a setter
lookup and arity check as soon as the first argument is a variable. Only later
does it check that the second argument is `F(getter(root), ...)` with the
required atomic extras. Most ordinary two-argument calls need no such lookup.
Likewise `p173oa_call_args` (69677) and the multi collector can authenticate an
ordinary worker before discovering that its first argument is not a getter.

The multi-argument setter lookup has already been moved after successful
collection (`p173om_collected`, 69928). All-atom calls avoid it. All-getter calls
with no computed F can still authenticate getters before the final refusal;
this is bounded but guaranteed fruitless candidate work.

**Smallest safe cost fix if the new pass is expensive:** first prove the purely
syntactic nested-call/root-variable/atomic-extra shape, then perform the exact
same getter, worker and setter semantic checks. Reorder their evaluation; do
not remove any. Preserve original fallback on every refusal. This needs no
cross-request cache, new representation, changed effect gate or final-verifier
policy. A paired exact-QBE comparison is appropriate for such a cost-only
change. It should not interrupt the current qualification without measured
reason.

### Summary rebuilding is bounded but repeated

There is no recursive traversal of the worker F's definition to prove it. The
pass authenticates its source identity and saturated arity; F's evaluation
remains in the generated computation. Getter/setter summaries are bounded to
eight constructors, sixteen fields and closed getter constants of 32 nodes.
The multi interface has at most seven non-root arguments. Freshness checks and
field renaming run only after a structural summary exists.

Within each accepted multi row, getter analysis is repeated:

- `p173om_all_args` (69132) authenticates every descriptor, including ignored
  getters. This is necessary for strict evaluation correctness.
- `p173om_values` resolves constructor output fields; a used getter invokes
  `p173om_project` again. Multiple output occurrences can repeat it again.
- `p173om_row_built` (69019) extracts the computed argument's getter again.

For the ordinary `k_rebuild` eight-field row, this means seven projection
checks during all-arguments authentication, six used-metadata projections, and
one projection for F: fourteen bounded getter inspections for seven logical
arguments. Each inspection reuses cached erased bodies but repeats lookups,
variant traversal and field-binder checks. The second constructor repeats the
work. The ignored computed KLiteral row deliberately retains the original
fallback and is not rewritten.

Returning a vector of already-authenticated projected values from the
all-arguments phase would remove this local duplication without a global
cache. It must still authenticate **every** descriptor, even one omitted by
the setter. This is the next bounded cleanup if profiling places material cost
inside summary construction. It is less urgent than avoiding analysis of
syntactically impossible calls across the entire compiler.

The fixed local bounds prevent unbounded interprocedural summary exploration;
they do not make processing every AST node free. An honest cost model is:

`effect-body walk + prepared-body walk + sum(application-spine work) +`
`candidate lookup/summary work + changed-body publication`.

No duration estimate is justified by source inspection alone.

## Coverage beyond the two measured compiler kernels

`consuming-frontier-census.json` is a lexical screen: 36 functions, 19 outside
JS modules, and eleven manually identified recursive-parent rebuild
candidates. **Eleven does not mean eleven admitted by automatic08.** Inspection
of the frozen compiler source gives the following narrower picture.

| Function | Current source shape | Expected current admission |
| --- | --- | --- |
| `env_subst_term` | `k_with_children(t, env_subst_terms(ks(t), bindings))` | Compatible two-argument shape |
| `f_sub` | `k_with_children(t, f_subs(ks(t), id, v))` | Compatible two-argument shape |
| `f_pattern_sub` | Same form with pattern traversal | Native transfer measured |
| `nw_restore_children` | `k_rebuild`, metadata getters, one `F(ks(t), ...)` | Compatible multi-argument shape |
| `nq_layout_subst` | Same form with layout substitution | Native transfer measured by parent |
| `nc_compact_ctor` | `k_rebuild`, metadata getters, `F(ks(t))`, Nil/zero metadata | Compatible after prepared Nil is an atomic static value |
| `nc_compact_plain` | Same rebuild form in fallback | Compatible after the same preparation |
| `sp_shift` | Computes both changed ID and child list | Refused: two computed arguments |
| `f_path_term` | Computes both name/path and child list | Refused: two computed arguments |
| `nc_erase_app` | `F(book, ks(t))` rather than `F(ks(t), ...)` | Refused: observed getter is not worker argument one |
| `nc_erase` | Both computed constructor identity and `F(book, ks(t))` | Refused for both reasons |

This identifies **five plausible additional function bodies**, not five proven
native speedups, beyond pattern/layout. Actual erased syntax, static
preparation, reachability and emitted-worker evidence can still restrict them.
The source census alone does not measure frequency or hotness. Existing
Phase171 physical samples are sparse and are not inclusive owner attribution.

The cheapest further expressiveness improvement, after cost qualification, is
allowing the **one** authenticated getter argument at an arbitrary fixed
position of F while requiring every other argument already evaluated/atomic
and root-free. This potentially reaches `nc_erase_app` without allowing a
second computed expression or changing evaluation order. It still needs exact
erased-body admission and native transfer evidence. Generalizing to multiple
computed arguments is a larger legality/effect-order problem and should not
be conflated with that small extension.

## Recommendation for the current campaign

Finish the already-running native request comparison. The source audit finds
no reason to abandon the pass on an assumed catalogue O(N²) problem. It also
provides no basis to promise a whole-compiler win from the kernel gains.

If request time regresses, isolate the extra certificate, unchanged-body walk,
candidate recognizer and actual summary work before expanding admission. Start
with syntax-first recognition if it explains meaningful cost; retain the
current qualified fallback compiler throughout. A change that only speeds the
two measured kernels while adding more full-body work everywhere would not
meet the research-throughput objective.

If request time improves and exact/native gates pass, keep the frozen result
and defer generic caching. The existing seven-function source screen and the
two precise refusal classes are more informative next leads than broadening
the lexical census or redesigning the IR.
