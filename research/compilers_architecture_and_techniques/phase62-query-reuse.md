# Phase62: reuse compiler facts at the scope where they remain true

Investigation date: 2026-10-07. This is source inspection and primary-source
research, with **no compiler change, compiler execution or new speed result**.
The installed implementation is Phase61 State08. The TypeScript comparison is
the pinned Bend compiler at `018751270e800bc222a93dad7f257083ee53a5f7`, not
Microsoft's TypeScript compiler or a newly selected upstream revision.

The strongest small hypothesis is a **per-definition signature summary in one
immutable emission context**. It would replace repeated arity and telescope
walks with facts computed once. The larger hypothesis is preserving emission
artifacts from reachability into final assembly, but that still requires a
context/dependency proof. A general memoization engine is not the recommended
starting point: the historical experiment already failed its speed criteria.

## What the pinned TypeScript compiler actually reuses

The inspected [comp.ts](https://github.com/bendlang/bend/blob/018751270e800bc222a93dad7f257083ee53a5f7/bend2/comp.ts)
uses two different cache lifetimes. `file_book` clears `TELES`, `FUNS`, `LOOPS`
and other book facts; `memo_gc` clears `OPENS`, `USES`, `SPINES`, `FOLDS`,
`CONSTS` and `LITS`. `file_book` calls the latter during its queue traversal;
`js_lib` calls it before each emitted definition. These are inexpensive,
bounded-by-work-scope caches, rather than persistent structural hashes for
every query.

| Cache / source symbol | Effective key and scope | Reused result | Current selfhost difference |
|---|---|---|---|
| `OPENS` / `term_open` | Lam/Let object identity, between `memo_gc` calls | Opened probes and body | First-order `KTerm` already has explicit binder/body fields, so this is not a missing one-for-one cache. The important difference is how substitutions and opened bodies share work. |
| `USES` / `term_uses` | Term identity within that scope and implicit fixed `File` | Variable-use map, recursively reused by demand analysis | `JDText` already carries demand metadata and preserves fallback scans. Do not transplant a source-use map without proving it matches emitted demand. |
| `TELES` / `tele_unbind` | Type object identity, fixed book | Domains and return type | `jd_domains`, `jd_live_arity`, `jd_params` walk the same telescope for different projections; application-specific traversal also uses `j_app_type`. |
| `SPINES` / `term_spine` | Term identity, implicit fixed `File` | Head, all/live arguments, known saturated target | `j_call_spine` reconstructs head/arguments and later callers redo type/saturation questions. Some queries are pure syntax; others depend on book, native facts and argument types. |
| `FUNS` / `fun_of` | Definition name, fixed book | Raised arity, opened body, live domains, layouts and result layout | `jd_arity` recomputes `jd_domains` and `jd_raise`; callers separately request live arity and parameter names. A small fact bundle is a closer transfer than memoizing all normalization. |
| `LOOPS` / `loop_of` | Name in the selected graph | Tail SCC members | Selfhost already has indexed `JDCall` facts and SCC/bounce summaries. Missing work is possible reuse between two graph constructions, not lack of an SCC algorithm. |

Source anchors are `comp.ts:567` (cache declarations), `:737` (`term_spine`),
`:850` (`term_uses`), `:915` (`tele_unbind`), `:1253` (`fun_of`), `:1330`
(`loop_of`), `:1385` (`file_book`), `:1942` (`memo`/`memo_gc`) and `:3374`
(`js_lib`); line positions are aids, with symbol names and pin authoritative.

The reference also differs below these caches. Its
[term_wnf machine](https://github.com/bendlang/bend/blob/018751270e800bc222a93dad7f257083ee53a5f7/bend2/bend.ts#L2765)
places demanded arguments in sharing cells and fills them with weak-head normal
forms. Cells belong to machine frames/output rather than mutating input syntax.
That is a representation-level reduction-sharing mechanism, not a cache around
arbitrary calls to `wnf`. The separate Phase62 term-representation investigation
should evaluate it; this note does not infer that more maps provide the same
benefit.

## The concrete repeated work in State08

In [model.bend](../../selfhost/src/back/js/direct/model.bend), `jd_arity`
computes declared arity plus `jd_raise`, capped by `jd_domains`. Those helpers
walk body structure and normalize the telescope. `jd_live_arity` walks and
normalizes that telescope again to count live formals; `jd_params` does so again
to produce parameter names. Calls analysis, ordinary definition emission, SCC
width/case emission, ordered calls and host exports request these facts.

A read-only lexical census of `selfhost/src/back/js/direct/*.bend` finds 14
`jd_arity` call sites, 8 `jd_live_arity`, 4 `jd_params`, 5 `j_call_spine`, 12
`j_type`, 37 `j_app_type` and 7 `j_specialize` sites. These counts exclude each
function's definition line but include recursive call sites. They are **not
dynamic execution counts or time attribution**. The useful unknown is how many
calls repeat the same logical definition/context and how expensive their missed
computations are.

The second duplication is explicit:

1. [jd_reach_selected](../../selfhost/src/back/js/direct/reach.bend) builds an
   annotated selected context and `jd_calls_context`.
2. Each actual reach visit builds `jd_doc_definition`; its `JDText` determines
   runtime dependencies through `jd_text_refs`.
3. `JDReach` returns definitions plus an error, discarding the documents.
4. [jd_library_selected](../../selfhost/src/back/js/direct/core.bend) overlays
   retained definitions, rebuilds `jd_calls_context`, and emits documents again.

The first and final books are not equal: initial emission overlays all annotated
selected definitions, whereas final emission overlays only the retained set.
Removed aliases revert to their original book values. Complete runtime closure
does not imply the same compile-time lookups.

The existing [State06 report](../../implementation/phase61/state06-results.md)
bounds the visible opportunity. Map/Set's final definition emission accounts for
7.91% of sampled CPU and final call-fact construction another 2.16%, about 10.07%
combined **before** validity checks, lookups and retention. Numeric's final
definition emission is only 0.54%. These are earlier diagnostic samples, not
State08 clean-clock gains. Even perfect removal of a 10.07% wall-time fraction
would yield only about 1.112× speedup; the CPU share is not established to be
that wall-time fraction.

The Phase61 diagnostic found 873 equal retained texts across 23 requests, with
671 functions and 202 empty ADT entries totaling 619,101 bytes. Tail facts,
components and closure agreed. But potential changed lookup values remained:
Word in 23 cases, Pair in 13 and Set in 2. Those were context differences, not
recorded reads. Matching text on this corpus is evidence of an opportunity,
not authorization to reuse it universally.

## Candidate facts, sufficient keys, and falsifiers

The following are designs for **private immutable compiler work**, not new
assumptions about mutable public API values. Initial instrumentation may assign
object IDs using host-side identity tables on diagnostic images. That does not
authorize a production host-language implementation or turn `KTerm.ix` into a
node identity: `ix` identifies binders/other existing semantic fields.

| Candidate fact | Sufficient initial key / dependency boundary | Cheapest discriminator | Main falsifier |
|---|---|---|---|
| Definition signature: raised arity, telescope quantities, live count and parameter sequence | Exact immutable selected book generation plus definition identity; include source/native policy identity at context creation | Count `jd_arity`, `jd_domains`, `jd_raise`, `jd_live_arity`, `jd_params` by definition/context; estimate duplicate traversed nodes | Arity differs under an alias/constructor overlay, foreign declaration, common matcher prefix or erased/dependent formal; lookup/summary construction costs exceed saved walks |
| Syntactic call spine | Exact term identity and complete supplied argument-list identity, or specialize the fact to the existing empty-list entry | Count `j_call_spine(t, Nil{})` repeats within definition emission and calls scan | Newly reconstructed terms make identity hits rare; retained list/lookup overhead dominates this cheap walk |
| Typed call information | Book/context generation, lexical typing environment identity, term identity, mode and all semantic arguments | Count exact identity repeats of `j_type`, plus nodes traversed per repeated result | Same term under a different environment or IO shadow returns a different type; structural-key construction is needed to get hits |
| Normalized telescope projection | Book generation, exact telescope identity and requested prefix length; specialized telescopes additionally bind all argument/environment identities | Record raw/specialized telescope repeats and widths; distinguish unchanged tree identities from freshly substituted copies | Repeated values are mostly new trees; zero/one-domain queries dominate; delayed admission costs erase savings |
| Retained `JDCall` row | Definition body/type identity and exact compile-time dependency results within its origin context | Record only actual row reads; compare retained rows and closure to the original selected graph | Pruning changes a constructor/native/type decision, unknown-tail seed, row validity or edge occurrence budget |
| Emitted `JDText` | Definition identity, emitter policy, exact observed compile-time dependencies, and preserved SCC/bounce/ordering facts | Trace actual dependency reads during initial/final emission; compare only reads relevant to each artifact | A non-runtime alias changes normalization, scalar row pruning, chooser inlining, raised arity or host/native identity; resource refusal is skipped |

For the first candidate, a per-definition fact bundle keyed in the existing
name index may be cheaper than a nested identity-map trie. It should be scoped
to one immutable user-definition context and reused by its projections. Adding
internal call-fact tables produces a different physical book; a future design
would need an explicit proof that those tables do not change signature queries,
or simply use separate scopes. An invented numeric epoch without controlled
construction is not a proof of immutability.

Cross-context dependency capture must include successful **and missing** lookups,
their lookup container/context, and direct list scans such as `j_find_ctor`.
Recording only `(name, result)` from root `lookup` misses child-constructor books,
IO-shadow books and consumers which read fields or traverse lists directly.
For the first probe, treat any untracked whole-book traversal as a dependency on
the entire book; do not silently call the trace complete. A whole-book equality
gate is safe but Phase61's known Word differences make it too conservative to
demonstrate useful hits on those cases.

If retained call rows are unchanged and their initial edges remain inside the
retained set, the original SCC/bounce graph can potentially be restricted safely.
Preserve the original definition order so leaders, member numbering and generated
bytes remain stable. Keep original per-definition and aggregate budgets and
failure behavior; a cache hit must not convert a refused plan into an accepted
one. Retain documents only from actual successful reach visits, and account for
their live memory until final assembly.

## Focused lessons from Rust and LLVM

Rust's query model records dependency reads and reuses results when those inputs
are unchanged. Its projection-query pattern lets a small unchanged result remain
reusable after a larger collection changes. Persistent stable identities and
fingerprinting add cost; the guide explicitly notes hashing can make incremental
compilation slower. The useful transfer here is a per-definition projection and
an explicit dependency boundary within one request, before a persistent query
graph. This is an inference for Bend, not a Rust performance claim.
[Rust query guide](https://rustc-dev-guide.rust-lang.org/queries/incremental-compilation-in-detail.html).

LLVM caches analyses by their IR unit and requires transforms to state what they
preserve or invalidate. Inner passes may inspect cached immutable outer analyses
without repeatedly triggering global analysis; the documentation identifies
quadratic scanning as one reason. For Bend, selected-to-retained emission should
have an explicit preservation contract for type, call and SCC facts. Build each
global fact once per justified scope rather than hiding a whole-book rescan
behind a helper called for every definition. This does not call for importing
LLVM's pass-manager framework.
[LLVM analysis and invalidation documentation](https://llvm.org/docs/NewPassManager.html#using-analyses).

These primary pages were read on 2026-10-07. They are explanatory floating
documentation, not pinned implementation/performance experiments. The existing
[Rust source survey](rust.md) contains separately pinned implementation evidence.

## What not to repeat

- **Generic query memoization:** Phase32 already counted many exact argument
  identity repeats and tried emission-scoped 4k/16k map tries. The 16k screen was
  +5.16% for the small request, −2.19% Mandelbrot and −3.32% edit distance, failing
  its preregistered criteria. Hit rate alone did not establish value. The current
  image and backend differ, but another cache needs evidence about saved work
  and lower lookup cost, not the same argument again.
  [Preserved rejected campaign](../../implementation/phase32/compact-counts.md).
- **The same backend telescope cursor:** Phase61 State07's combined cursor/leaf
  prototype measured 1.01023× State06 elapsed time on its B1 confirmation. It was
  reverted, with no B2 result and no isolated cursor attribution. New evidence
  would need to identify missed eligible work or a materially different design.
  [State07 report](../../implementation/phase61/state07-results.md).
- **Blind cross-stage text caching:** The 23 passing text comparisons do not
  discharge annotation/alias/context dependencies. Reject name whitelists and
  unproved annotation stripping as validity conditions.
- **Broad host memoization as the parity strategy:** Phase61 reduced this
  residual substantially. The deferred 177-line converter memo had only a
  speculative 0–3% Map opportunity and negligible Numeric opportunity.
  [Deferred proposal](../../implementation/phase61/host-plan-proposal.md).
- **Structural keys everywhere:** `term_key` can traverse large terms and force
  `Sub` values. Merely adding a string key may recreate the work being removed.

## Bounded next experiment and decision

1. On the actual State08 diagnostic image, record invocation counts, exact-key
   repeats and traversed nodes for the signature family and syntactic spines.
   Partition calls analysis, emitted reach, final emission and host exports;
   preserve whether the key belongs to the initial or retained context.
2. Record actual compile-time dependency reads for the retained artifacts on
   Map/Set and one contrasting input. Include known changed aliases and a small
   deliberate overlay counterexample. The probe must compare complete outputs
   and report uncovered dependency mechanisms.
3. Rank **exclusive repeated work** after counting key/traversal overhead; do not
   add nested `wnf` and `jd_arity` times. Also record maximum live entries and
   retained result bytes. Stop if the estimated removable budget is small.
4. If signature duplication is substantial, test one explicit shared summary
   in a private immutable scope. If cross-context dependencies are cheap and
   usually unchanged, separately test carrying successful documents/facts into
   final assembly. Use separate ablations and the existing short clean loop.

The expected deliverable is a ranked work budget and a counterexample-tested
validity condition, not a claim that query caching alone closes the remaining
2.07× compilation-only gap. No speed or implementation-completion estimate is
justified for either candidate until dynamic counts and current profiles arrive.

## Inspected local source identity

| File | SHA256 |
|---|---|
| `selfhost/src/back/js/direct/model.bend` | `dc48e335d8dc1bdc58aeaca26cdadfd53e952e975f85c3a529719905deb25aaf` |
| `selfhost/src/back/js/direct/calls.bend` | `14e037349e61ecb8f0fc60cf5a50f1edfc05ae18f04a764f1da786c8d9f5f99d` |
| `selfhost/src/back/js/direct/core.bend` | `3a8d40750cde3e5ba6fa26dbaa9795d197069fb92db9098209721e0e473444fc` |
| `selfhost/src/back/js/direct/reach.bend` | `c6a7e59f7e986be68c1b1ada83612147cbc62641533142cde11e28afa8fb5071` |
| `selfhost/src/back/common/queries.bend` | `e62d1b368c8c3b4a69eb0eedca263e3ac4ac3059746c257039e16999993038a8` |
| Pinned upstream `bend2/comp.ts` | `3bd7ed49d33f1c61334d75a905e38c0345fb15a10b45d85884b77f49833dc5ee` |
