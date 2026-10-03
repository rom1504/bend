# Phase42 private Tree/Stat layout ablation

Hypothesis: retained payload arrays account for a material part of the tree
execution gap after Phase41 direct workers. Flattening each private `Leaf`,
`Node`, and `St` into one object should reduce allocation while preserving the
same tree sorting network, stack machines, generic dispatch and BigInt Nat.
This is a representation experiment, independent of counter removal, Nat
unboxing, recursion rewriting and cross-function fusion.

The pinned upstream `bend2/comp.ts` (`0187512`, lines 3115–3153 and 3216–3253)
emits user ADTs directly as tagged objects with named fields, and reads named
fields after the constructor tag check. Its `js_marshal` separately handles
Nat host conversion and recursive constructor output. Phase41's actual tree
module instead constructs `{$:k,a:[...]}` and directly reads `.a[index]` in
workers. Both Tree and Stat therefore offer an allocation opportunity.

The exact saved-output prototype at
`selfhost/tools/performance/phase42/layout/derive.mjs` pins the complete
109624-byte checked Phase41 tree output SHA256
`64bfc698048c2ebf92c123111a5ce3fd8ccdb47b2fd8a7488243adbd1c2f6e9d`.
It replaces 37 construction sites and 101 fixed-slot read sites. Constructors
produce named slots only under the preexisting private scalar region proof;
otherwise they call the original public constructor. Public `ctor` itself is
unchanged. The generic matcher/project path builds a temporary argument array
when consuming a private object, so residual generic dispatch remains measured.
Every Leaf/Node/St construction remains fresh; sharing child objects and
constructor evaluation order are retained. No in-place updates or sorting
algorithm changes are made.

Three roles distinguish proof overhead: `original` is byte-identical to the
checked Phase41 output; `flat` uses module-private bound WeakSet membership to
select public or private slot reads; `direct` assumes every worker Tree/Stat is
owned, and reads slots directly. Both packed roles still register each private
constructor in the WeakSet for generic project/fields. Direct is an unsupported
ownership ceiling, not a proved compiler admission. Neither role is checked
compiler output. Time their `.clean.mjs` modules, never diagnostic adapters.

A production implementation would need typed constructor/field plans and a
representation identity per component, with a closed scalar root proving all
live ADT producers and consumers, and no host input or output. Any edge to an
unproved worker/native/foreign call needs a proved adapter or rejection. Generic
residual calls are consumers too; this prototype teaches its generic matcher
about private ownership rather than demonstrating an existing compiler contract.
Mutable G bindings, getter replacement and native host invalidation must refuse
private entry through existing guards. Reentry must preserve and restore the
previous proof; private objects must not reach an observer during reentry.
Deferred build fields must retain demand order and fail-stop behavior. Deep
stack behavior is preserved by keeping emitted frame machines unchanged.

Cheap falsifiers are complete sorted trees and Stat summaries, public tagged
construction, hostile field/private-marker getters, binding/getter/throw/reentry
observations, followed by a serial root-run same-module timing. A checksum alone
is insufficient. A timing null rejects the current mechanism; a survivor still
requires wider ownership/demand validation before any Bend source patch.

## Whole private graph successor

Root's first screen decisively rejects the WeakSet layout mechanism: packed
roles are 3.16–5.69 times slower on the selected tree points. That does not
establish the cost of a graph without representation checks or generic bridges.
`layout/complete-v1.mjs` therefore supplies a diagnostic architecture ceiling:
the entire Tree/Stat graph uses direct private functions and named objects,
BigInt countdown, and bounded native recursion. It follows the Bend flow/warp
algorithm, including its fresh zero-depth constructors and mixed-shape Leaf0
branches, rather than importing the TypeScript twin's different flow driver.

The original module remains the public fallback. The bench exact entry keeps
its full 15-name guards and proof open/close; for a guarded depth at most12 its
body calls the private graph and returns only the scalar checksum. A refused
entry or a greater depth runs the original generic public body. Tree/Stat values
never need an ABI bridge in this graph. Only diagnostic exports expose private
values; their bounds and unsupported ownership are explicit.

This successor intentionally combines complete dispatch removal, named layout,
and native recursion. Its timing cannot assign gains to one of those mechanisms.
If it reaches the TS denominator, subsequent ablations must separate recursion
from explicit-frame work and generic dispatch from layout before a compiler
rewrite. The native stack ceiling is not a replacement for production deep
stack semantics; any promotion needs the existing stack-safe continuations or
an independently justified bounded-depth admission. Range-unboxed Nat is absent.

The reviewed implementation is `complete-v2.mjs`. V1's depth cap preceded
canonical scalar admission and could demand host coercion; retain it rejected.
V2 adds the comparison only after the original complete entry guard. Host count
coercion, throw, reentry, Symbol and raw entry controls cover that distinction.

## Orthogonal whole-graph ablations

Root's whole-graph screen reaches a measured diagnostic ceiling close to TS:
for depth8/9 the complete BigInt/named-object medians are about1.078/1.053 times
TS, versus about1.54 at depth6. This is a bounded saved-output ceiling, not a
source compiler result. Original baseline warming/noise remains visible.

`complete-ablate-v1.mjs` derives three exact roles from that saved graph:
`flat-bigint` retains identical clean bytes; `array-bigint` emits fresh
`{$:tag,a:[fields]}` directly and reads direct fixed slots; `flat-number` changes
only private Nat zero/decrement and scalar-count conversion, admitted by the
same canonical U32/depth12 root guard. No generic projection, runtime constructor,
WeakSet, or native stack change accompanies the array role. Number countdown
is safe within its stated domain, but it is still a separate research ceiling.
Diagnostic-only named-to-array adapters preserve aliases for fixture APIs and
are absent from clean timing modules. Existing V4 complete controls apply to
each variant's subdirectory.

## General source implementation proposal

Start with public-compatible tagged objects and arrays, BigInt Nat, and the
existing stack-safe structural worker machines. No arbitrary native recursion
or benchmark-specific depth limit belongs in that first source implementation.
The general unit is a closed pure scalar root and its complete typed dependency
graph. This is broader than an individual worker's local direct edge.

1. Reuse `j_pure_graph`/`j_component_plan` to derive the complete graph, with
   exact definition identities, constructor layouts, primitive/native owners,
   and no-backedge obligations. Root parameters/results must remain canonical
   scalar host values; intermediate ADTs are all created within the graph.
   Exhausted fuel, an unsupported call, a host/native observer, or an unproved
   recursion shape rejects the entire new route and keeps existing emission.
2. Plan a private declaration for every graph member, including acyclic scalar
   `key`/`prng` and finite selectors. Calls within this closed emission context
   use those exact declarations unconditionally. Full-graph guards stay at root
   entry; no per-call `regionProofCovers`, generic apply, capture closure, or
   temporary currying object belongs inside the successfully planned route.
3. Preserve constructor family/native classification. For known nonnative
   JPure ADTs, emit fresh inline tagged objects with payload arrays directly.
   Their current private worker field reads already use fixed `.a` slots.
   Primitive Bool/Nat/List handling must retain its established contracts;
   do not infer that an ADT name alone selects a native representation.
4. Use the current self-recursion frames for admitted binary/tail components
   and direct acyclic helpers otherwise. A dependency DAG after excluding
   proved self-recursion bounds host call depth by definition graph size,
   rather than by runtime tree depth. Mutual recursion or a returning dependency
   backedge needs an explicit whole-graph continuation plan or rejection.
5. Keep the complete generic public body and root guard/error/demand order.
   Bind all mutable G dependencies/native hooks before route selection without
   evaluating user getters. Once selected, the graph must have no observer that
   can mutate dependencies or reenter before its scalar return. Existing proof
   open/close restores outer context even on errors. Public ADT entry, foreign
   calls, unsupported native hooks and noncanonical scalars keep generic demand.

This proposal changes emission context and routing, not the language's algorithm
or public ADT ABI. A full graph plan must be emitted all-or-nothing: a single
residual generic call invalidates the zero-dispatch contract and can introduce
an observation boundary. Actual source work should first produce one checked
B1 tree emission with static zero-dispatch evidence and complete values, then
screen stack-safe performance. Named-field layout or range-unboxed Nat follows
only if its separate ablation justifies a separate representation proof.

## Actual checked graph layout clone

The orthogonal root screen shows a useful representation discriminator: depth8
flat BigInt0.3113ms versus array BigInt0.5282ms; depth9 flat0.7465ms versus
array1.3625ms. Number Nat is inconclusive/null. This supports a real emitted
control experiment rather than immediate source promotion.

`actual-flat-v1.mjs` consumes the checked Phase42 checked01 tree module and its
checked emission receipt. It requires exactly five private worker declarations
with zero generic dispatch, G reads or proof checks internally. The fourteen
acyclic helper IIFEs remain inside those exact workers. It clones those five
workers plus the local scalar Stat output helper, leaving every original public
G function and shared worker intact. The existing admitted scalar bench true
branch selects a private cloned root; the original entry checks, proof lifetime,
refused body and BigInt remain. There is no native recursion rewrite or depthcap.

Clone-array constructs fresh tagged objects and payload arrays directly;
clone-flat constructs fresh tagged objects with `_0`... slots and reads them
directly. Both retain identical continuation stacks, frame arrays, helper IIFEs,
case order, primitive arithmetic and call routing. No private ADT is passed to
an original generic matcher. The scalar output helper is also cloned and reads
flat Stat slots directly, so conversion/repacking is absent from clean modules.
Full-value/alias adapters are diagnostic-only and never compiled into timings.

Production feasibility: extend the existing covered private emission with an
explicit closed layout context, rather than changing global constructor/runtime
behavior or rewriting emitted JS strings. The plan must prove the whole scalar
root graph closed and select a private declaration suffix for each exact KDef.
That suffix and layout context propagate through component calls, acyclic helper
inlining, private finite matches, field bindings and constructors. Known JPure
nonnative constructor layouts select slot properties; their current arity/type
proof supplies field order. The existing original worker declarations stay
available for public/tagged-array paths. Native Bool/Nat/Tuple/List lowering
keeps its existing classification and contracts. Reject any missing observer,
unsupported helper or escaping ADT rather than bridging mid-graph.

The flat context needs to reach both `j_component_emit` and finite/acyclic helper
prefix emission, plus `j_region` scalar output unpacking; changing only ctor
emission is invalid. A source patch is therefore wider than a constructor tweak
but needs no runtime membership protocol or new public ABI. Reuse stack machines
and full checked01 helper planning. Source promotion depends on actual clone
controls/timing, a checked B1 context implementation, full values/aliases/host
counterexamples, and broad semantics after freezing a survivor.

Use `actual-flat-v2.mjs`: V1's property labels were inserted at AST expression
starts rather than complete grouped element starts and failed parsing. V2 uses
outer array token boundaries; the semantic transformation is unchanged. Failed
V1 and partial output remain preserved.

The concrete readonly source feasibility review is
[`source-proposal.md`](../../selfhost/tools/performance/phase42/layout/source-proposal.md).
It names the existing owners, a cache-preserving third-child scoped context,
five lowering hooks, and a negative normalized-emission audit. Lexical clones
belong inside the admitted try block; outside fallback cannot resolve them.
This avoids global worker ABI changes and reuses exact component/direct facts.
The initial route rejects vector/read/producer/fusion plans rather than mixing
those boundaries into layout admission. Estimated160–230 source lines plus
wiring; no runnable patch is claimed before the all-or-nothing audit exists.

The runnable conservative source proposal now exists as
[`source-v4.patch`](../../selfhost/tools/performance/phase42/layout/source-v4.patch)
(208 added lines, 9 removed). It preserves both original BookCache children,
audits the exact normalized private closure before creating the third scoped
context, and emits lexical flat clones only inside the existing fully guarded
scalar proof. V3 bypasses post-audit local inlining; V4 falls back to the original
normal body when an uncached Book cannot carry the context. No new runtime
protocol or public representation is introduced. Checked acquisition remains
root-owned and is required before calling this a source optimization.

The handwritten native-recursion graph is a ceiling: depth8–9 is approximately
1.05–1.08 times pinned TypeScript. The exact emitted frame-machine ablation is
slower: flat depth8 .5297ms versus TypeScript .2862ms; depth9 1.3718ms versus
.6792ms. Its controlled array-clone counterparts are .7496ms and 1.7356ms.
Thus layout alone yields 1.22–1.42 times improvement with real frames, and does
not establish parity. The separate Number Nat ablation showed no repeatable
benefit. Keep BigInt Nat and the existing structural frames in the source route.

The checked source successor has now emitted the private flat region in
checked09, and root reports complete actual controls pass20/98/68/2 with depth
30000. Independent renamed ReviewTree/ReviewStat controls pass40 scalar oracles
and every positive/negative admission flag. The V5 source correction keeps the
full normalized audit and guard graph, while recording the canonical source
root in identity metadata after selected-root annotation. No exact helper or
context comparison is weakened. This is checked semantic evidence; fresh
paired source timing and the stale-context diagnostic still remain required.
