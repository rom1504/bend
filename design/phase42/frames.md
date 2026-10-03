# Phase42 frames: prospective saved-output ablation

Hypothesis: binary structural components spend avoidable time restoring original
argument arrays and repeating an already decided typed match prefix on both
continuations. Phase41 transfer tuple scalarization had a null result; this
experiment deliberately retains every `$next` vector and child transfer.

The immutable checked input is
`selfhost/build/phase41/integration01/full-preparation/modules/tree-bitonic.mjs`.
`selfhost/tools/performance/phase42/frames/derive.mjs` verifies its saved receipt
and SHA256, parses its AST with Node's bundled Acorn, identifies the existing
binary leaf in each worker, and extracts the exact right-child and combine
expressions. Each frame saves only lexical variables used by those expressions,
plus a continuation site. Resume dispatches by site, without restoring original
arguments or repeating tag tests/field reads. Initial traversal, `$next` tuple
allocation, generic calls, region proof checks, constructors and fallback stay
byte-identical outside the four workers. Reusing a frame clears left and resets
phase before entering a child.

Priority alternatives: live continuations first; saved argument scalar fields
alone as an allocation-only ablation if the combined mechanism wins; bounded
direct recursion only to estimate the control-stack ceiling. Direct recursion
cannot be promoted: its native depth limit violates existing deep guarantees.

Controls reuse the Phase41 independent nested-array oracle and hostile boundary
owner, recording their exact hashes. They compare complete flow trees across
scalar domains, shared/uneven trees, fresh root/child alias identities, mutation
and getter event traces, exception/proof close order, ordinary bench entry, and
an iterative depth30000 oracle. Root owns every timing and heavy control run.

This first derivation is fixture-specific, unchecked saved JS. It asserts exactly
four binary workers and does not admit unary continuation phase3. Source promotion
must preserve the existing structural descendant, closed full typed graph,
independent RHS, binder freshness, purity and host/dependency guard proof. A
source implementation needs exact binder identity and lexical live-use analysis,
not textual names or a runtime assumption that typed tags cannot vary. Unary
workers must retain their previous lowering until a separate reconstruction
proof covers operand ordering and before-slot retention.

Falsifiers: complete-value/alias/order mismatch; a resumed read of a variable
not saved from the original prefix; a host-owned accessor reaching the private
worker; native-stack growth in the live role; or corrected paired timing too
small to distinguish from drift. Saved-output speed alone is not source promotion.

## Revised source investigation after the small frame result

A graph proof alone does not justify native recursive calls: JPure validates
complete typed pure bodies and signatures, and stops visited graph backedges;
it does not prove every recursion structurally decreasing or bound native stack
height. Existing structural workers therefore retain their descendants/closed
backedge/independent-RHS proof and frames. General non-tail contification would
need continuation sites for call arguments, parallel Let RHSs and constructor
fields, not just a new recursive worker name. Arbitrary helper DAGs may instead
be compiled or inlined directly with a checked bounded acyclic call graph, adding
no native recursive cycle and no frame cases.

For current tree graph, warp_leaf.go and warp_leaf construct tagged Tree data;
key/prng are scalar helpers. Despite the `.go` spelling, warp_leaf.go is finite
Bool selection, not a recursive worker. These helpers do not require new frame
forms. Existing warp/flow/bsort/scan structural calls already have stack-safe
workers; inherited complete-graph context can remove their redundant proof
membership tests only inside dominated private bodies. It cannot be applied to
ordinary generic/global emission or to calls whose transitive graph is missing.

## Whole private graph: smallest tagged-data source step

The complete manual graph's near-TS ceiling justifies a separate constructor
step; it does not justify native recursive promotion. The concrete supplemental
patch is `frames/owned-constructor-source.patch`, reproducible with
`frames/make-owned-patch.py`, applied after the inherited-context patch. It marks
constructors only in admitted component bodies; `calls/owned-helper.patch` marks
only independently admitted acyclic helper bodies. Existing typed expression,
field argument and linear continuation emission remain the semantic owners.

Runtime `ctor(k,a)` for a nonnative constructor returns exactly `{$:k,a}` and
performs no registration. For a marked constructor whose original type is a
closed JPure nonnative ADT and whose resolved constructor has exact name/arity,
source emits `({$:tag,a:[original typed fields]})`. Every field remains in source
order; the object and array remain fresh and children retain their original
references. Recursive results come from the existing explicit frame loops.
Linear reconstruction uses the same literal after its existing before/resume
operand sequencing. Constructor identity collisions with native names are
resolved by original owner and constructor metadata, not spelling.

Private structural/finite prefixes already emit direct tag tests and positional
field reads on inert owned data. No additional field plan or runtime check is
needed. Ordinary scalar arithmetic already uses the common primitive emitter.
This step does not change Nat representation, List/native construction, generic
ADTs, deferred tail `build`, or structural admission. The generic constructor
mode remains byte-identical; only existing eager private emission bypasses ctor.

Full original typed graph and exact descriptor/host guards must dominate every
private call. Function-valued or unsaturated escapes, host-owned ADT input,
foreign/native representation, mixed recursion requiring an unproved worker,
and missing transitive callees remain refused by the existing owners. An acyclic
helper graph can add only bounded source depth; it cannot create input-dependent
native recursive depth. No runtime depth cap substitutes for source proof.

## Stretch BST native product/List proposal

Representation and control ownership moved to `frames/bst/representation.md` and
`controls.json`. Native Sigma is a dense pair array; List is tagged nodes. The
prospective `emitter-proposal.bend` contains isolated owned Tuple field/match
helpers and optional direct-pair construction; it is uninstalled and unchecked.
Facts owner controls exact closed native type identity/equality. The initial
explicit owned-mode proposal is superseded by the globally logically closed
JPure domain under existing scalar-root guard ownership; no new mode/cache
hierarchy is added. Ordinary grounded-U32 List selectors are not widened. No
saved-JS BST ablation or execution was performed by this owner.
