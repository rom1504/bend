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

## Priority

First correlate emitted-reach and final-emission profiles with section 4's
census. Quantity merge width and substitution/reflexivity work are the next
strong structural candidates. Book/host counters can cheaply prevent false
attribution. No representation replacement, cache or pass removal is justified
by this source inspection alone; source-order errors, dependent types, quantities,
original provenance and the qualified fixed-point checks remain acceptance gates.
