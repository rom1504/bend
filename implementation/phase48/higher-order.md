# Phase48 function-flow implementation status

Owned new module: `selfhost/src/back/js/ir/function-flow.bend`. Shared emitter,
region, runtime and compiler manifests are untouched. Root owns integration and
all checked compilation/target jobs. This is an unqualified prototype.

The candidate normalizes typed source KTerm syntax before JPure: known function
aliases, exact leading-lambda helper applications, live-argument administrative
bindings, capture-preserving alpha-renaming and singleton factory-prefix Lets.
It preserves existing KTerm metadata on copied source nodes. Administrative
nodes carry exact type annotations so the ordinary context builder can infer
RHS types. No source-program name selects eligibility.

Integration must compute a request-wide fresh ID bound, retain the original
proof/provenance view, add every returned dependency to the exact public source
fence and run complete normalized graph admission. Do not replace the original
primitive/source scan with the normalized body. Invalid candidate means use the
entire original planning path, not a partially rewritten graph. A marker and
counter must distinguish normalization success, successful graph proof and
ordinary private entry. Ordinary/public escaped function values remain generic.

Root should first compile the new module in isolation through the normal checked
manifest workflow, then acquire renamed fixtures with installed baseline,
candidate and pinned TS; semantic/mutation controls precede timing. First screen
should be bounded and include an actual private-entry witness. The factory
branch/recursive Morning graph is deliberately not a first-slice success gate.

Pending independent review and checked compilation. No measured speed claim.

First slice static-review checkpoint:248 lines, SHA256
`96bc30eb8504bc69f90d2831eda55f80e956261e669bc22da661d91c0a7ba263`
(11542 bytes). Static delimiter checks pass; independent source review passes
under the stated integration obligations, with metadata tightening rechecked.
The independent catalog pins source bytes and arithmetic outputs, without
claiming checked emission or private activation. A dedicated all-children budget
counts type/annotation metadata, unlike the existing runtime-only U32 size check.

The follow-on finite matcher-family design is in the design document. It keeps
factory prefix execution as a first-order private record producer, specializes
helper callback parameters on family identities and lowers application through
existing private matcher/direct calls. Recursive cycles stay graph cycles rather
than compiler inlining. Extraction of exact typed capture environments precedes
construction of generated private types/definitions; no matcher-family code or
Morning qualification exists in this first module.

Root integration checklist (not an applied patch):

1. Build the module through the compiler manifest, without calling the pass yet.
2. Produce the fresh-ID bound from the whole original book plus root context,
   using an all-children budget; overflow/exhaustion means no candidate.
3. Normalize a selected root value into a request-local planning view. Keep the
   original root value for the public generic fallback and original identity
   snapshots. Do not emit normalized source directly as ordinary public code.
4. Prove the entire rewritten graph in that view. Add returned dependencies to
   the original source guard graph even when no normalized call remains. Preserve
   every original reachable primitive dependency, including untaken branches.
5. Emit through existing private worker entry only after complete proof. Record
   normalized candidates, graph refusals, dependency count and real private
   activation separately. No changed original body participates in snapshot
   equality checks. An integration unable to keep these views separate must
   refuse the experiment rather than broaden mutable-public assumptions.
