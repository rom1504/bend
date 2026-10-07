# Immutable marshaller plan: conditional proposal

**Decision: deferred by root after the state06 residual profile.** The 177-line
prototype's unmeasured 0–3% Map opportunity and near-zero Numeric opportunity do
not justify its complexity and build/qualification cost now. Stop code and review
work; do not apply or run it. The isolated patch is not checked Bend source or a
measured optimization. State06 and its consumed tools remain unchanged.

## Current opportunity

The fresh state06 Map CPU summary attributes 121,454 weighted microseconds
(6.0103%; 69/1,318 samples, or 5.2352% in the count view) inclusively to
`jd_host_exports`. `jd_marshal` accounts for 112,264 weighted microseconds
(5.5555%). These are nested observations, not additive opportunities. The matching
allocation summary attributes 26,639,120 of 252,321,752 estimated bytes (10.5576%)
to the host-export subtree; marshalling is 9.6222%. Numeric's host-export CPU
share is only 0.3016%.

These single diagnostic profiles are neither clean timings nor estimates of
removable cost. Removing the entire Map host subtree would bound the possible
whole-window improvement at about 6% time reduction; a cache still pays lookup,
key creation, output concatenation, signature checks and every miss. A working
expectation for the smaller proposal is **0–3% whole-request time reduction on
Map**, with a possible regression from bookkeeping and near-zero benefit on
Numeric. There is no present basis for a large whole-compiler claim. Reprofile
the selected candidate before spending a build or widening this proposal.

The saved Map module contains 61 local `$dmN` function expressions but only five
exact expression texts. Counting only nonoverlapping outer expressions gives
31 occurrences / three texts: 15 × 760 bytes, 15 × 758 bytes, and one × 440 bytes.
That is 23,210 bytes of outer expressions and 21,252 duplicate bytes. The Numeric
module has none. This is static duplication, not runtime frequency or an estimate
of classifier calls. Equal output text does not prove equal source types: these
counts do not establish a 31-to-three cache-call reduction. Nested expressions
overlap and must not be added again.

## What TS already does

The pinned [js_marshal](../../selfhost/.bootstrap/upstream-phase23/bend2/comp.ts#L3303)
normalizes a type, tests for Nat, and handles function/Array conversion. For a
remaining datatype it interns direction plus the normalized type key in
`fl.spun` (lines 3328–3334), **before** visiting constructors. Recursion then uses
a global helper name. Each constructor field is marshalled once; the last field
whose converter is the current helper becomes the iterative spine. The completed
function is appended to `fl.spins` and emitted once (lines 3336–3357).
`js_lib` shares this state across definitions and exports (lines 3380–3402).

Our [host emitter](../../selfhost/src/back/js/direct/host.bend) only reuses
ancestor converters in `seen`. Sibling fields, export arguments, returns, input
restoration and subsequent exports rebuild complete expressions. Its tail-field
probe also builds field converters before the field printer builds non-tail
converters again. Native facts reduce the classification graph, but do not change
this repeated specialization and expression assembly.

## Option A: memoize complete expressions, preserve output bytes

The [isolated source](../../selfhost/tools/performance/phase61/host-plan/host-plan.bend)
and [patch](../../selfhost/tools/performance/phase61/host-plan/host-plan.patch)
introduce one immutable export-local plan. Its result record contains emitted
text, the persistent exact-name index, and remaining insertion capacity. The
normal export order threads that record through return conversion, live inputs,
input restoration, and then the next export. The book is fixed throughout.
Existing `jd_marshal`, recursive printers, foreign wrappers and public helpers
remain unchanged. The only production hook would replace the call from
`jd_exports` to the ordinary export-list printer; the new module also needs its
explicit manifest entry. Neither hook has been applied.

Every miss invokes **the original complete** `jd_marshal(book, ty, out)`, with
its original `seen=Nil`, depth zero and fuel 64. A hit returns its complete closed
expression. It suppresses that call's full classification, constructor
specialization, recursive classification, tail probe and converter assembly.
Repeated output text is still concatenated into the module, so this isolates
compiler work from generated program changes. Whole-signature classification,
export admission, arity and telescope traversal are deliberately not memoized.

For R complete requests and H confirmed hits, this changes R complete marshal
executions to R−H, while adding R admission/key/index operations and H structural
comparisons. A miss still does the old recursive tail/field duplication. For a
type with E visited classifier/specialization nodes and A characters assembled,
each hit avoids that request's E-node work and A-character converter construction;
it does not avoid final placement of A characters into the module. These are
algorithmic counts, not byte-allocation or time estimates. Actual R, H and miss
subtree sizes are not available from the saved generated text.

The key includes direction and the existing raw-type `term_key`. This is only
an index bucket: a hit additionally compares the exact term variant, name, ID,
quantity, literal payload, lambda quantity-presence, child sequence and removed
names. Source spans are ignored because neither marshalling decisions nor its
error strings read them. Alpha-equivalent-but-differently-numbered terms miss;
same-key raw substitutions cannot silently hit. Since `term_key` itself evaluates
`Sub`, a bounded structural admission excludes any such subtree before key
construction. Types failing admission use the original marshaller directly.
The existing string-key trie resolves hash collisions by exact name.

The plan is empty at each export entry and never inserted into `book`. It is not
shared between source requests, differently refined books, foreign IO shadows,
or direct calls to the old public helpers. A 512-insertion cap and conservative
64-step branch/list comparison bounds only disable caching; they do not change
compilation admission or the marshaller's original graph/depth limits. No new
normalization or compiler error is used to establish a cache hit. The finite
checked-term contract still excludes cyclic host objects posing as KTerm data.

The implementation cost is state threading and conservative hit checking. That
cost is substantial relative to the current residual and is why this candidate
is retained as an unapplied proposal. Raw-key creation still allocates; the cache
retains types and complete strings until export assembly ends. Bounded capacity
does not bound a single string's size or promise lower peak memory.

## Option B: a shared converter graph, closer to TS

A full plan would intern normalized specialized type plus direction into a
module-local integer ID, reserve the ID before traversing its fields, and store
immutable converter nodes: identity, Nat input/output, Array, function input and
result, or datatype arms. Each arm stores its live field converters once and the
last directly self-recursive field. Emission produces one collision-free private
helper per reachable datatype node; exports and foreign wrappers reference IDs.
The book, native proof flags and canonical type context belong to the plan.
Source-order discovery makes helper numbering deterministic.

This removes repeated constructor specialization/field assembly across sibling
occurrences as well as top-level duplicates, and shrinks output/import work.
To remove repeated classification too, the plan needs completed type facts keyed
by exact specialization. A successful independently completed no-Nat proof may
be reused; a node merely seen on the current recursive path is **not** a completed
negative proof. Nat-positive reachability can be propagated through a completed
type graph. Unknown/budget-exhausted nodes must preserve an explicit fallback;
they must never be recorded as no-Nat. No JavaScript Map or mutable host state
is needed: use the existing persistent index and an append-only node sequence.

It is unsound to cache the current recursive printer merely by type, or by
type plus depth. A fragment `$dm1` names an ancestor selected by the entire
`seen` environment; the same type and numeric depth can occur under different
ancestors. Fuel also depends on the enclosing traversal. Global plan IDs solve
lexical capture, but do not by themselves preserve the old depth-refusal set.
Either carry a separately proved resource-demand summary at each use, or obtain
explicit approval for a new bounded graph/plan admission rule and retain the old
marshaller on unsupported components. Do not quietly treat the visited-set
cycle break as an unlimited-depth permission.

Runtime obligations remain unchanged: argument conversion precedes the source
call; result conversion precedes input restoration; callbacks reverse variance;
Array conversion remains in place; getters and thrown values retain order;
each converter invocation gets its own mutable `top/at/key` state; and the last
direct self field remains an iterative spine. Hoisting a stateless converter
definition is inert, but newly shared function identities and mutual-recursion
depth still need the direct backend's stated host-contract review. This option
changes generated bytes and requires runtime/FFI qualification, unlike Option A.

## Cheapest discriminators before integration

1. On a diagnostic copy only, count complete marshal requests, exact-key hits,
   distinct types/directions, and misses due to structural/cap bounds for Map,
   Numeric and the full compiler export surface. No clean speed claim from
   counters. A low hit rate rejects Option A without another compiler build.
2. Compare every complete old/new wrapper and module byte. Include repeated
   recursive Map/List types, identical signatures, aliases, callbacks with
   contrary directions, mutable Arrays, erased Nat and whole-signature fallback.
3. Force key collisions from renamed binder IDs, raw Var/Sub representations,
   quantity-presence differences and refinements; differ only spans as a positive
   reuse case. Repeat the same types in two books with different constructors to
   prove invocation-local reset. Include empty converters and cached depth/graph
   errors. The old public classifier and every foreign wrapper remain references.
4. Exercise 63/64/65 comparison shapes and 511/512/513 insertion attempts. Limits
   must cause misses only. Record peak RSS as well as compilation time.
5. Only a reviewed survivor gets root's genuine B1/B2 and fresh clean screen.
   Require no output changes for Option A; do not credit state06 native-fact
   gains to a new memo. Option B needs a separate decision and control suite.

No compiler, generated program or benchmark was executed for this proposal.
Exact source, pinned TS, saved module and summary identities are recorded in
[proposal.json](../../selfhost/tools/performance/phase61/host-plan/proposal.json).
