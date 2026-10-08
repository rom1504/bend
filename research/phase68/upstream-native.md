# Phase68 upstream native source audit

Source-only investigation; no native, compiler, Node or benchmark target executed.
Read-only CPU0 inspection of pinned upstream `059266225b77c8ca256ac6b25ee5c21449bab151`,
current Bend native backend, and sealed Phase67 emitted C. Rankings and gain
ranges below are hypotheses, not measured results. Older raw remains unchanged.

## Decisive finding: saturation stops at the first matcher

The shortest structural improvement is to reuse the existing typed arity
analysis for native saturated calls. `nd_leading` in
[`direct.bend:47`](../../selfhost/src/back/native/direct.bend#L47) walks leading
`Lam` only; `nd_arity` uses that result; `nd_extend` similarly only strips those
lambdas. A `Mat` is also a function, but is invisible to this analysis.

For the array fixture this means:

| Definition | Current native direct arity | Full source arity | Consequence |
| --- | ---: | ---: | --- |
| `fold.loop` | 0 | 3 | No direct entry; each recursive iteration curries the recurrence |
| `fold.cell` | 1 | 2 | Its nominal direct entry allocates and returns a closure |
| `fold.step` | 2 | 3 | Its nominal direct entry allocates and returns a closure |

The source is
[`local-fold.bend`](../../selfhost/tools/performance/phase37/fixtures-historical/local-fold.bend).
In selected array C, `fold.loop` starts at line6671; positive branch closure
allocations are at6689 and6712; direct `fold.cell` at7074 and direct `fold.step`
at7343 each still allocate a closure. `Array.get` allocates a Tuple at7597;
`fold.step` builds another Tuple at7425. The steady nonterminal path has **four
curry-closure allocations, two Tuple allocations, eight continuation cuts,
and five closure-apply dispatches per element**. These are manually traced
emitted-code operations, not a runtime instrumentation profile. The zero-case
boundary has fewer recurrence allocations.

Pinned upstream `fun_of`/`def_raise` in
[`comp.ts:1164`](../../selfhost/.bootstrap/upstream-phase66/bend2/comp.ts#L1164)
raises arity through matching: the hit arm consumes one scrutinee and opens
constructor fields; the fallback retains the remaining function telescope;
the minimum common raise is capped by the type telescope. Its array C
[`spin_11`:1466](../../selfhost/build/phase67/native-baseline02/array-upstream/program.c#L1466)
has four word state (Nat, U32, Array handle, U32); `spin_12` and `spin_8` perform
the get/update. These three hot functions have **zero heap allocations** per
iteration. It is misleading to attribute the entire 84.99x gap to Array storage:
a tiny update is surrounded by function and aggregate transport.

The Bend JS backend already ports exactly this analysis:
[`jd_arity`:83](../../selfhost/src/back/js/direct/model.bend#L83), `jd_raise`
through142, and `jd_live_arity`:148. Reusing these facts for ordinary native
definitions avoids adding another arity algorithm. Preserve current curried
entries for partial applications; add a full-arity private entry whose freshly
bound parameters are consumed through matches. The architecture owner is
prototyping this candidate.

## Other structural differences

1. **Ordinary C return lane.** Upstream `flat_of` (comp.ts1258) admits the
   transitive set whose bodies contain no parallel let/bang and no non-tail
   self-call (`file_book`:1393–1415). `emit_fuse`/`emit_native`:2149–2219 use an
   ordinary C `spin_N(Env, Term* out, typed parameters)` call and return; self
   recursion loops. The selfhost `$direct` prefix instead means a scheduler
   `WL_CASE`, `WL_JMP` and `WL_RETN`. Every non-atom/scalar let still goes through
   `nc_let_cut` (bridge188), spilling live values into a continuation frame
   (`ne_frame`, emit44), or a task on the parallel path. Scalar call-site
   inlining in Phase67 did not make arbitrary known calls C expressions.

2. **Products are register bundles.** Upstream `lay_of`/`lay_pack`:922–990
   represent eligible nonrecursive ADTs as word arrays, with a tag only when
   needed. `arr_op`:1756–1781 returns `[array, element]` as a `Tuple` layout;
   the array itself stays a box. `val_to`/`val_box`/`val_unbox`:1668–1727 bridge
   general boxed boundaries. Selfhost `NC_Binding` stores a single word;
   `nc_array_pair` (array28) calls `ne_constructor`, and all general constructors
   allocate (emit19). `nc_destructure` (bridge303) immediately takes/frees the
   box when the pair is subsequently matched. Local constructor-to-match
   elimination is a smaller first step than a universal multiword ABI.

3. **Typed arrays and words.** Upstream `lay_arr`:988 selects 32-bit element
   storage when every layout word is W32; selected array C uses `blk_new(e,0,...)`
   and `blk_read/write(...,0,...)`. Selfhost array1 explicitly chooses a uniform
   64-bit slot and all operations use boxed-word ownership helpers. The latter
   is general and correct but larger and prevents Clang seeing a simple U32
   loop. This alone is unlikely to explain an 85x gap.

4. **Borrow and ownership facts.** Upstream `brw_of`:1189 and
   `val_own`:1621–1665 propagate a borrowed parameter root, deciding whether a
   call lends, owns or retains it. `bind_uses`:1812 unboxes a shared flat product
   before duplication. The emission repeats to a fixed point as ownership,
   lending and hot-layout facts stabilize (comment1299 and compile2790).
   Selfhost `nc_share_env` (bridge135) emits `term_keep` whenever a variable is
   needed in both pieces and `nc_drop_dead` emits `term_sink` for all words.
   Clang may remove trivial scalar operations, but not general box traffic.
   This is especially relevant to recursive trees, Map and lexer, after the
   missed saturation and cuts are removed.

5. **Allocation reuse and static structure.** Upstream `node_fields`:1584
   retains constructor storage as a spare in tail position, and `ctr_build`
   can reuse it; selfhost `nc_destructure` immediately frees and
   `ne_constructor` unconditionally allocates. Upstream additionally emits
   const tables/folding, which explain part of the whole-file size difference;
   whole-file counts must not be interpreted as hot-path counts.

## Static emitted-code census

Inputs are selected selfhost `native-scalars01` / `native-heldout-scalars01`
and upstream `native-baseline02` / `native-heldout-baseline02`. Counts below are
whole-file syntax counts: actual `  WL_CASE(FID_...)` definitions, emitted
`INLINE|FAR Term spin_` functions, and indented `WL_ROOM(` frame reservation
sites. They include cold formatting/IO dependencies, and do not count dynamic
executions or establish a speedup.

| Family | C bytes selfhost / upstream | Scheduler segments | C spin functions | Frame sites |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 1,645,611 / 117,622 | 1,834 / 51 | 0 / 14 | 1,476 / 16 |
| Array | 1,676,027 / 118,820 | 1,863 / 51 | 0 / 17 | 1,497 / 16 |
| Closures | 1,639,805 / 125,109 | 1,821 / 65 | 0 / 10 | 1,478 / 23 |
| Tree | 1,870,349 / 153,342 | 2,034 / 80 | 0 / 18 | 1,603 / 33 |
| Map | 2,886,281 / 320,345 | 2,975 / 169 | 0 / 23 | 2,297 / 109 |
| Lexer | 1,977,087 / 144,943 | 2,195 / 69 | 0 / 25 | 1,699 / 26 |

The baseline-to-selected Phase67 changes reduced these costs without changing
their essential shape. Held-out evidence also shows missing full entries for
`Map.put`, `Map.put.go`, lexer `batch`, `lex`, `flush`, and `gen`; saturation
is a general opportunity, not a recognizer for the array benchmark.

## Ranked prototypes and falsification

Engineering hours are approximate implementation/review scope, excluding a
full release. Gain ranges are deliberately broad hypotheses for the affected
family, not predictions for the six-family geometric mean; benefits overlap.

| Rank | Prototype | Hypothesized affected-family gain | Hours | First discriminating observation |
| --- | --- | --- | ---: | --- |
| 1 | Reuse typed arity raising; full exact-saturated private native entry | Array 2–8x; broad families potentially 1.2–3x | 1–3 | Four per-element curry allocations disappear; existing partial-call behavior and independent digest pass |
| 2 | Flat ordinary-C return lane, initially retaining one-word boxes | Scalar/array loops additional 2–5x | 4–12 | Hot known-call chain has no continuation frame; self-tail recurrence uses loop; error/parallel controls pass |
| 3 | Local pair scalar replacement, then small nonrecursive product arguments/results | Array additional 1.5–4x | 3–8 local; 8–20 typed ABI | Get/state pair no longer allocates; escaped pair still boxes and shares correctly |
| 4 | Typed U32 array access/storage | Memory-heavy array work 1.1–2x after transport removal | 4–10 | 32-bit buffers, no scalar retain/sink, shared/nested/atomic controls exact |
| 5 | Borrowing and reusable constructor storage | Tree/Map/lexer additional 1.2–3x | 8–24 | Profile shows box keep/take/allocation decline; alias and final-use destruction controls exact |

Minimal first flat-lane eligibility can be more conservative than upstream:
exclude bang, foreign, dynamic calls and parallel lets; require exact saturated
known calls; allow only tail self-recursion and an acyclic closure of admitted
callees (reject mutual recursion initially). Keep ordinary/partial entries as
adapters. One-word results already remove scheduler traffic; add multiword
products only at a later independently measured step. Do not rewrite emitted
C by textual replacement of return macros: a structured destination/return
mode must carry the ownership and error path.

## Correctness edges sent to architecture and review owners

- Reuse the checked typed `jd_arity` facts before erasure; erased matcher `ix`
  encodes live fields plus one and must not be confused with raw constructor
  arity or source parameter count.
- A Mat with extra arguments must apply constructor fields before those extra
  arguments in the hit; fallback receives its scrutinee before extra arguments.
  Optimized Nat chain lowering must forward extras or use the generic path.
- A trailing argument can repeat the scrutinee variable. Current match lowering
  unconditionally removes the scrutinee binding. Use a fresh alias with the
  existing share protocol, or explicit ownership accounting; otherwise the
  extension can introduce an unbound use or consume it twice.
- Preserve partial/over-applied/foreign/bang entry behavior. Restricting an
  internal matcher extension to already-bound trailing Vars prevents one local
  reordering, but does not preserve the old call-site order: raising arity
  causes `nc_sequence` to evaluate all supplied arguments before the prefix
  matcher. Upstream does this too: `emit_args`:2091–2105 evaluates non-Var
  arguments before entering the matched body, and `def_raise` does not exclude
  IO.OP. A request-valued IO.OP prefix plus a later Nat overflow can therefore
  change the first diagnostic from old selfhost tags to upstream Nat overflow.
  Qualify this against upstream using runtime-dependent factors; distinguish
  inherited baseline divergence from a new regression. Partial applications
  retain the old selfhost demand in arity-v1 only. Upstream `call_eta`:707–715
  instead eta-expands named partial calls and may defer the prefix match until
  remaining arguments arrive; eta-adapter-v2 separately addresses that inherited
  partial-call discrepancy. An explicit source match is the reliable staged
  first-diagnostic control.
- Full layouts must box recursion, Array, IO.OP, hidden dependent-family cycles,
  unknown types and excessive width. Escaping products/callbacks, duplicated
  fields, zero-field constructors and erased fields require explicit bridges.
- Normal-C recursion cannot silently acquire unbounded host stack usage. Start
  with verified tail self-recursion and retain scheduler fallback elsewhere.
- No runtime gain has been measured in this audit. Source census and manually
  traced allocation counts guide the next guarded CPU3 experiment only.


## Independent review of arity-v1 proposal

Reviewed `selfhost/tools/performance/phase68/architecture/arity-v1.patch`,
SHA256 `d8ff121003a169e46af4d4d22d1b49ccd4015ac7d38e2c2ddb5a670977f9af25`,
and independently verified its two before/after source hashes against the
proposal receipt and source copies. No source-level semantic blocker found
for a checked full-compiler prototype. No target was run in this review.

The query uses the annotated, pre-erasure KDef and then converts its full typed
arity to live arity; the maximum with old leading-lambda arity retains existing
raw-core leading-lambda controls with approximate types. Fresh entry IDs begin
after `nc_fresh(base)` and advance the counter by arity. Matcher argument aliases
correctly expose repetitions/captures to the existing retain operation. Hit arms
apply constructor fields before residual arguments; miss arms apply the original
scrutinee before residual arguments. Nat chain specialization runs only when
there are exactly two NMatch children, so it cannot silently discard extras.
Exact saturation, primitive/foreign branches and bang exclusion remain.

One integration boundary remains: `native/tests.mjs` assembles core and native
modules alone, whereas this prototype refers directly to JS arity helpers. A
shared extraction or explicit manifest dependency is required before final
standalone native qualification. The full compiler already contains these
helpers, so this does not block the bounded B1 screen. First-diagnostic order
still requires the upstream comparison described above.

## Narrow follow-on: forwarding pair results

A local `let pair = Array.get(...); match pair` rule alone does **not** remove
this fixture's hot get Tuple: the getter is the final argument to `fold.step`,
whose immediate match executes in another private worker. Likewise, the state
Tuple crosses `fold.step` → `fold.cell` → `fold.loop`. Eliminating these boxes
requires either bounded inlining that exposes each producer/consumer pair, or
private worker specialization of product arguments and results.

The existing scheduler supports multiple return words already: `N_Segment.result`,
`ne_ret`'s word list, `nb_returns`, `nb_frame_results`, and frame-result tables.
The missing piece is semantic lowering: `NC_Binding` and constructor/match/call
lowering uniformly use one word per value. A two-word ABI must propagate both
ownership and result count through intermediate tail-forwarding workers, and
retain boxing adapters at ordinary closure/unknown-call boundaries. Treat this
as a representation change, not a two-line array optimization.

The cheaper independent candidate is allocating-value binding: extend the
immediate-let path to an `N_Emitted` prefix plus word for constructors and known
Array primitives. Bind/evaluate arguments once in order, emit the allocation or
array operation prefix, and lower the let body with its resulting word directly.
This removes their continuation frames while retaining the existing box ABI.
Factor expression emission structurally rather than replacing `WL_RETN` strings.
It should remove Array.get/set frame boundaries in the recurrence immediately;
measure it separately and do not describe it as pair scalar replacement.
