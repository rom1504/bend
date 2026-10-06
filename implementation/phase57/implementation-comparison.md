# Phase57: compiler representation and algorithm comparison

This is a read-only source comparison, not a performance attribution or proposed
semantic change. No compiler, generated program, benchmark or profile was run.
The current baseline is Phase56 string01; the reference is the retained upstream
commit `018751270e800bc222a93dad7f257083ee53a5f7`, under
`selfhost/.bootstrap/upstream-phase23/bend2/`. All locations below refer to those
local source files, inspected on 2026-10-06.

The [Phase56 report](../phase56/README.md) measures B1 at 2.84–3.11× handwritten TS
and direct B2 at 5.08–5.55× on two cache-primed import+request inputs. Those are
request timings, not isolated kernel timings or universal ratios. B2 reproduction
has 89.03 s emitted reachability and 111.68 s unsplit emission. These stage costs
justify inspecting printing first; they do not establish the causes below.

## 1. Quantity accounting uses different persistent structures

**Fact.** Current `selfhost/src/check/quantity.bend:73–104`, `uses_get`,
`uses_del`, `uses_merge`, represents usage as `List<KTerm>`. For each entry in the
left list, merge searches the right list for its quantity and traverses it again
to delete that identifier. Disjoint lists of lengths m and n therefore admit
O(mn) list visits; deletion also reconstructs retained list nodes. Saturated
quantity addition and branch join are distinct operations and must remain so.

Upstream `bend.ts:511–562`, `pmap_get`, `pmap_set`, `pmap_union`, uses a persistent
integer-keyed binary trie. `uses_add` at 629 delegates to a structural trie union;
empty subtrees are returned directly. This is not a JS hash-map-versus-list
comparison: the upstream usage structure is also persistent, but aligns keys
structurally instead of repeatedly searching a flat list.

**Possible cost.** Wide scopes and branches with many independent live binders
can amplify checker work independently of normalization. Whether the measured
Evening/Lexer requests contain enough wide merges is unmeasured.

**Discriminator.** Count merge input cardinalities, `uses_get` visits and
`uses_del` visits, aggregated once per checking request. A renamed source family
varying live binder count at fixed expression depth separates width cost from
beta cost. Any replacement must retain erased/affine/unrestricted violations,
branch joins and diagnostic attribution; passing only positive fixtures is weak.

## 2. First-order substitution versus HOAS opening

**Fact.** Current `core/term.bend:16–24` gives globally unique binder IDs and
first-order `KTerm`/`KLambda` children in linked lists. `subst`, `subst_node`,
`subst_terms` at 332–355 recursively rebuild nonliteral nodes, including children
that contain no occurrence of the substituted identifier. `core_apply_span` at
374 substitutes a lambda body. `core/normalize.bend:397`, `norm_rebind`, also
renames opened binders using substitution.

Upstream `bend.ts:285–308` distinguishes first-order `LTerm` from `HTerm` whose
binder bodies are native functions. `term_higher` at 693 installs closures over
the original syntax and environment; `term_apply` at 653 opens a lambda by
`f.f(tm)`. `term_wnf` at 2784 opens lambda/Let bodies similarly while running an
explicit frame loop. HOAS opening can still traverse syntax through
`term_higher`; it is not a proof of constant-time beta reduction. `term_lower`
at 782 remains a full explicit conversion when needed.

**Possible cost.** Repeated substitutions and freshening can allocate/copy large
subtrees where an upstream closure opening follows only demanded structure.
Generic tag dispatch and linked-child access are additional representation costs,
not independently measured causes. Both B1 and B2 execute the same first-order
compiler algorithm, so this alone does not explain B2 being slower than B1.

**Discriminator.** Census substitutions by subtree node count, replacement
occurrences, and reconstructed nodes; distinguish binder freshening from beta
application. Measure retained versus rebuilt nodes, rather than only call counts.
A future delayed substitution/environment design would need to preserve spans,
erased quantities, globally fresh IDs, dependent scopes and error demand.

## 3. Conversion has a structural fast path instead of native pointer identity

**Fact.** Upstream `bend.ts:3053–3074`, `term_compare`/`compare_go`, tries rigid
then unfolding comparison, with `lhs === rhs` before normalization and `a === b`
afterward. Proven equality between share cells can redirect `rhs.v` to `lhs.v`.
Current `core/normalize.bend:250–262` invokes `norm_exact` before conversion;
`norm_exact_lists`/`norm_exact_head` at 426–443 walk names, IDs, quantities,
children and removed-name lists. They compare contents of stored cells too.
Current `norm_convert` at 467 likewise runs rigid then full-book policies and
uses `GState`/`KNormShare` to retain proven sharing. Thus neither rigidity nor
sharing is absent from the current checker.

**Possible cost.** Same-object reflexive comparisons can be cheap in upstream
but require a tree/content walk here. First-order copying may make this effect
larger. Structural equality can also avoid evaluation for separate equal trees,
so replacing it wholesale is not automatically an improvement.

**Discriminator.** Aggregate `norm_exact` node visits, success rate and compared
root size alongside heap/share hits and actual normalization steps. Separate
reflexivity-heavy inputs from unequal/dependent comparisons. An identity fast
path would require a trusted internal identity representation, not public JS
object identity or equality of a reused numeric ID across contexts.

## 4. Direct reachability renders and parses output before final rendering

**Fact.** `back/js/direct/reach.bend:20`, `jd_reach_selected`, constructs the
call context. `jd_reach_definition` at 82 renders `jd_definition(book,d)` and
`jd_reach_refs` at 39 scans its emitted String one character at a time for
physical-line `JD_REF` metadata. This deliberately follows actual emission,
including erased arguments, native folding and unused Let demand. The scanner
has fail-closed character/edge/definition budgets.

Final `back/js/direct/core.bend:317–337`, `jd_definitions` and
`jd_library_selected`, constructs the selected call context and renders
remaining definitions again. SCC emission uses `jd_component_case` at 312;
shared cases may be rendered for multiple entry wrappers. Output concatenation
alone does not prove quadratic copying: native JS strings may use ropes.

Upstream `comp.ts:3374–3403`, `js_lib`, prepares a `File`, emits definitions into
segment line arrays, then joins segments and patches tail markers. `js_def` at
3257 emits component cases into that representation. Its retained reference and
segment machinery is not a textual `JD_REF` scan. It still has graph preparation,
component emission and output processing; this is not a claim that upstream has
only one pass.

**Possible cost.** Repeated rendering plus full output scanning is directly
consistent with the two dominant B2 reproduction stages. Attribution to scanner,
SCC duplication, normalization during printing or string assembly awaits profiles.

**Discriminator.** Census per-stage `jd_definition` calls, characters rendered
and scanned, component-case renders and final bytes. Compare counts per unique
source definition and SCC member, without logging every character. A candidate
structured emission result `(text, refs)` must retain exactly the current
emitter demand rules. Memoizing across initial and pruned contexts is unsafe:
SCC membership, transfer width, wrappers and tail decisions can change.

## 5. Book lookup and validation already have important reuse

**Fact.** Current `core/term.bend:251–279`, `lookup`/`lookup_cached`, uses a
`BookCache` when available, otherwise a linear list. `core/index.bend:1–23`
defines a compressed persistent binary trie with exact-name collision buckets;
`index_hash` at 26 traverses the name. Upstream `bend.ts:319` stores definitions
in `Book.tlds: Record<Name,TLD>`. Repeated name hashing/trie traversal and record
property lookup have different constant costs; calling current lookup uniformly
linear is incorrect.

`core/normalize.bend:353`, `norm_book_bound`, reads the immutable book stamp;
only unstamped callers scan the book for maximum IDs. `tools/typed-driver.mjs:
489–526` uses ABI2 checked-result books and skips separate specialization.
The driver still performs owned-emission checks, source reach, annotation and
emitted reach at 541–577. Those passes have different contracts; their existence
is not evidence of redundant full validation.

**Discriminator.** Count indexed versus unstamped/linear lookup calls, total
name characters hashed, and whole-book bound fallbacks. Census stage/query
counts with complete immutable context keys before proposing reuse. Do not add
a global name-only cache across books, substitutions or annotation contexts.

## 6. Host ABI and generated runtime remain separate measurement axes

**Fact.** `tools/typed-driver.mjs:200–214` wraps modules exposing legacy `G` with
`createCompilerAbi`; modules without `G` return their default API directly.
`tools/compiler-abi.mjs:16–35` encodes host-owned graphs with a fresh memo per
call, but decoded compiler views unwrap to their original graphs.
`decode` at 37 creates memoized read-only Proxy views lazily; `wrap` at 78 exposes
encode/invoke/decode phase hooks and counts. There is no unconditional full
output-tree copy. The actual Phase57 prepared raw/source/direct APIs all export named callable
APIs and no `G`: raw is upstream checked emission `1498f675…`, source is
derived checked B1 `12861977…`, and direct is self-emitted B2 `3f652f7d…`.
Their export blocks and setup assertion `api === raw.default` establish that
all three ordinary driver routes bypass this adapter. These measured roles do
not differ by positional-ABI adaptation. The generic legacy branch above is a
supported compatibility path, not evidence of cost in these requests.

Upstream `bend.ts:319` checker APIs use their native `Book`/`HTerm` structures.
Upstream generated libraries also marshal public Nat/function/aggregate values
(`comp.ts:3303`, `js_marshal`; 3360, `js_host`). Current direct output follows
that typed callable contract. The prepared projects also copy the legacy runtime
for the ordinary driver’s legacy output backend; this does not imply that source
B1 executes through legacy `G`. Algorithmic differences, generated
trampoline/layout quality and host loading must be measured separately.

**Discriminator.** Split fresh module import, Base preparation, ABI encoding,
compiler invocation and output observation. For these no-G B1/B2 roles, compare the same named-API request stages
against TS; use ABI hooks only in a separately verified G-bearing experiment. Compare emitted hot helper code only after
profiles identify it; do not infer a runtime cause from the source language.

## 7. `sk_char` is canonical-key escaping, with a separate numeric-lowering cost

Root's lexer allocation screen attributes about 206 MB in B1 and 219 MB in B2
to the shared `sk_char` frame (approximately 22%/10% of their respective totals).
These supplied sampled totals are not retained heap or exact allocation counts.
The source trace localizes this to key serialization, not the parser's generic
character constructor.

**Exact path.** `check/specialize.bend:132`, `term_key`, starts
`sk_term(t,Nil,0)`. `sk_quote` at 104 calls `sk_escape` at 108; each character
calls `sk_char` at 114, reverses its escaped fragment, and prepends it to a
reversed accumulator. `sk_quote` reverses the completed accumulator again.
`sk_char` implements JSON quoting: quotes/backslashes/control escapes, surrogate
escapes, otherwise `Char.show`. Keys preserve names, erased quantities and
constructor-removal lists, alpha-renumber bound IDs by lexical depth, follow
stored Var values, and substitute `Sub` nodes. They are not merely type names or
hashes; changing their equivalence changes specialization identity.

**Callers and existing reuse.**

- `check/specialize.bend:136`, `sp_keys`, serializes template arguments, joined
  by newlines. `sp_live_args`/`sp_live_key` at 383/349 build this key before
  `sp_find` looks in `KSpecMemo`. That memo reuses completed or active template
  instances and enforces recursion rules; it does not cache serialization of
  arguments before lookup. Key growth is capped at 32,768 UTF-16 units.
- `back/js/direct/host.bend:18–27`, `jd_host_nat_status_on`, keys each non-Nat ADT
  for a per-scan visited set. An unseen type is serialized once for membership
  and again when inserted. Each `jd_marshal` starts a new type scan; nested
  marshalling can scan again. The signature-wide completed no-Nat gate at
  160–173 already skips component scans for signatures proved Nat-free.
- `direct/host.bend:74–96`, `jd_host_marshal_key`/`named`, retains recursion keys
  in the current marshaller's `seen` stack, with input/output direction included.
  This prevents recursive expansion. There is no module-wide completed
  marshaller cache in this source; identical public signatures can emit their
  marshalling independently. Do not duplicate the existing recursion guard.
- `direct/pattern.bend:203–211`, `jd_word_cover_diff`/`key`, serializes composed,
  unannotated Word covers to prove cover equality. This is not template checking
  and may run repeatedly during emitted reachability and final rendering.
- `direct/program.bend:27–39`, `jd_show_find`/`ref_on`, serializes prior type
  entries on each linear search. This path is for program readback, so it is not
  an explanation for the lexer **library** request's printing stage.

Upstream `bend.ts:1192`, `term_key`, is `JSON.stringify` with a replacer omitting
source spans. `def_inst` at 3730–3758 still lowers and serializes each argument
before looking in `book.tmps`; upstream does not universally memoize term keys.
In emission, `comp.ts:1021` computes a key before the `LAYS` memo; `js_marshal`
at 3328 uses `fl.spun` for completed named marshaller generation. Its separate
`OPENS`/`USES`/`FOLDS` maps and `memo_gc` at 1950 are body-analysis caches, not an
implicit memo for this `JSON.stringify` call. Current and upstream both pay some
key construction even when downstream result memoization hits.

**Additional concrete generated-code fact.** In the exact prepared source B1
API, `$sk_char$` is 6,626 bytes; direct B2 `$jd$sk_95_char` is 8,219 bytes. Each
contains eight textual `u32_to_word` sites and 24 `word_to_u32` sites across
alternative matcher branches, not all executed on every character. For example,
the residual `(n & 3)==2` branch converts the same scalar twice to read successive
Word fields, then reconstructs WCon prefixes to recover `n` in range checks and
closures. Both compiler images show this expansion. Runtime
`runtime/js/direct.mjs:19–24`, `u32_to_word`, allocates WNil plus 32 WCon objects
per invocation. Thus JSON escaping's U32 residual-pattern lowering can create
substantial temporary Word graphs even for ordinary nonescaped characters.
Actual optimized allocations may differ through V8 elimination; the source
allocation totals alone do not separate those graphs from closure/string costs.

**Why existing numeric lowering does not remove it.** This is already the
native numeric-row path, not failure to recognize U32. `direct/pattern.bend:
155–185`, `jd_word_start`/`rows`, turns literal paths into scalar equality/mask
tests; fully known depth-32 rows have `fields=0`. Residual/default rows retain
`fields=1` or `2`. `jd_word_row_body` at 258–264 supplies those demanded fields
using `jd_word_view` at 267: a boxed Word suffix or head/tail from
`u32_to_word(bits)`. The source's named default `other` is reconstructed from
known constructor prefixes plus these fields, so range checks see a newly
rebuilt U32. This is the familiar native-row fallback from upstream
`comp.ts:3232–3238`; actual type facts survived, but scalar provenance through
**partial** Word views/reconstruction is not represented.

The current inverse-view optimization (`direct/constructors.bend:47–97`) only
cancels a native constructor whose direct Var field names a compiler-created
whole native `$JD.View`. It cannot cancel the nested WCon reconstruction from
two residual fields. The Phase53 [table investigation](../phase53/table-opportunity.md)
is separate and still a proposal: current direct emission has no table emitter.
Even upstream's table filter cannot cover this case: `comp.ts:1230–1236` needs
more than half the literal range populated (seven explicit keys through 92 give
7*2 < 93), while `emit_tab` at 2757 requires constant-emittable rows. The named
default's range tests and dependence on captured `c` are not constant table cells.
A general opportunity is retaining exact scalar origin/bit-prefix provenance
through owned residual views and constructor recomposition, with demand/alias
proofs. Adding a dense constant table alone cannot repair this `sk_char` path.

**Smallest discriminator, no implementation here.** First count `term_key`
entries by caller/stage, serialized bytes and repeated resulting-key frequencies;
count `sk_char` calls and `u32_to_word` calls beneath that frame. Aggregate once
per request rather than logging strings or traversing arguments for every counter.
This separates repeated serialization from the numeric matcher expansion.
A saved-image diagnostic can replace only `sk_char`'s residual matcher with
scalar switch/range tests, retaining existing `Char.show`/hex helpers and exact
returned escaping bytes. Compare every key/output/unsafe diagnostic and all
UTF-16 edge cases before timing; this is an ablation, not permission for a
compiler-name intrinsic or native-template promotion. Alternatively a single
local `jd_host_nat_status_on` key binding removes its demonstrated double
serialization without changing the memo structure. That narrow change cannot
address checker keys or the Word allocation path, so its possible gain is bounded
by those caller counts. A global identity/key cache needs immutable terms and
complete binder-environment/depth keys; caching `sk_term` by term alone is unsafe.

## 8. Whole-source completion includes parsing; law-fill hits retain linear scans

The [own-source profile report](profiles.md) attributes B2 51.86% inclusive to
`discoverSources` and 44.96% to nested `f_complete_aliases`; `kt` has 9.32% self
weight. These do not add. `load/modules.bend:234`, `f_complete_aliases`, is a
wrapper around `f_source_body` and `f_complete_parsed`; it does not itself run
an alias-rewrite loop. Its descendants include the whole contextual parser and
module completion. Calling its inclusive share “alias processing” is misleading.

**One concrete width-sensitive loop.** `front/declarations.bend:736`,
`f_decl_local`, checks the persistent scope index first. A miss calls `f_find`
on an empty list, deliberately avoiding an O(n) search for new names. A **hit**
still calls `f_find(name,book)`, preserving original first-event semantics.
`f_find`/`f_find_next` at 245–258 scan the newest-first local declaration list
until a matching event; the index is not a replacement for this event lookup.
`f_decl_find` at 693 invokes it during a definition's header (`f_def` dispatch
at 289–293). Existing law names therefore trigger linear searches through the
growing local event list, even though their scope-index lookup succeeds.

The exact own-source assembly has 629 laws and 3,012 definitions; **all 629 laws
precede the first def at line 5125**, and all have a matching definition later.
Thus those successful law-fill lookups must cross preceding newer declarations.
A source family of N early laws followed by N definitions admits O(N²) aggregate
local-event visits. This is a demonstrated algorithmic shape, not a measured
claim that it dominates the 44.96% frame. The profile's `f_find` self share
(2.96% B2) supports counting it, but does not establish the full removable cost.
Upstream's `Book.tlds` lookup is direct by name; its checker/loader need not
scan a declaration-event list to retrieve a prior law.

**Other loops and existing protections.**

- `modules.bend:211`, `f_source_body`, builds exact-name and constructor indices
  once for its prior scope. `front/contextual.bend:262`, `f_context_declared`,
  incrementally updates them for every published header. Constructor lookup
  uses `front/validate.bend:54–65`, `f_ctor_index`/`find`.
- `front/contextual.bend:4–12`, `f_context_resolve`, can use recursive linear
  `f_declared` membership for namespace/alias ambiguity. In this own-source
  request the compiler assembly is the root namespace and imports only Base;
  unchanged near names bypass that membership condition. It is not evidence
  of an all-reference global scan in this particular request.
- `load/graph.bend:194–213`, completion resolves imported fills, checks fresh
  names with an index, qualifies only the new fragment, then appends it to
  prior definitions. `f_graph_fill_defs` at 437 rebuilds definition shells,
  not all term bodies. `front/contextual.bend:468–481` lowers new types and
  rebuilds module shells; `load/paths.bend:64–73` rewrites Foreign bodies only.
  `norm_defs_join` at `core/term.bend:478` copies the prior list spine. Across
  many tiny modules those cumulative prior copies/index builds can be quadratic,
  but this assembled compiler has one root body plus seeded Base, so that
  many-module mechanism is not the immediate explanation.
- `typed-driver.mjs:253–310`, `discoverSources`, retains physical-file parse
  results, finishes dependencies before siblings and uses `f_complete_seed`
  for the verified Base. `FCompletedSource` bypasses body parsing. Root
  `f_context_result` explicitly avoids a second full scope walk; a proposed
  blanket parse cache or global qualification deletion would duplicate
  existing reuse or alter source-order/error semantics.

**Cheapest discriminator.** Count `f_decl_local` index misses/hits, actual
`f_find_next` visits for hits, and successful law-fill distances; separately
count parsed tokens/created KTerm nodes and completion shell/Foreign-body visits.
Aggregate per source, with no dump of every event. This determines whether
wide event scans or ordinary parser construction explain the nested share.
A possible replacement is a separate exact-name **local first-event index**,
updated under the current reversed event-list order and kept distinct from the
mapped/header scope index. It must reproduce law/def fill, imported aliases,
constructor collisions and first-error order. Reusing the existing scope index
as though it returned the same event is not justified by these source facts.
No instrumentation or replacement has been implemented here.

## Priority

First correlate emitted-reach and final-emission profiles with section 4's
census. Quantity merge width and substitution/reflexivity work are the next
strong structural candidates. Book/host counters can cheaply prevent false
attribution. No representation replacement, cache or pass removal is justified
by this source inspection alone; source-order errors, dependent types, quantities,
original provenance and the qualified fixed-point checks remain acceptance gates.
