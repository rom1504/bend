# Generic source patch proposal (pending clean discriminator)

This is the concrete source patch boundary proposed for root integration. It has
no benchmark names or source-name allowlist. It is not a checked compiler patch.
All four JavaScript tools pass Node24 syntax checks. Their target controls and
timings are owned by root.

## Bounded grammar

The first source feature admits a scalar-owned component with live U32 arguments
and U32 result whose internal function values have one of these proved origins:

1. Scalar lambda: one live U32 argument, U32 result, zero or more captured U32
   slots; body uses the existing total native-U32 scalar whitelist.
2. Identity lambda: returns its one live scalar argument.
3. Composition lambda: erased type slots, two owned U32->U32 values and one live
   U32 argument; body applies first value once, then second once in source order.

Factories may build these values through existing bounded structural Nat
recursion. All function-producing references must be exact, nonnative source
identities inside the component. Every function value use is a saturated
application, internal composition field, or owned transfer; no public return,
foreign field, unknown lambda set, deferred capture, non-U32 capture or partial
application crossing the private boundary. Dependent erased slots retain their
original positions and are checked against source type binders. A generic
function type alone never establishes the required provenance.

The first implementation preserves closure construction and tagged materialized
containers. It specializes only application of known private closures. Deferral
of general function-bearing ADT admission is intentional: existing j_pure_type
continues to refuse function fields everywhere except this separate audited
closed component route.

## Files and function-level diff

New `selfhost/src/back/js/callback.bend` defines:

- `JCallbackLeaf`: exact original lambda KTerm identity, ordered capture binder
  identities/types/quantities, argument binder, original scalar body.
- `JCallbackValue`: bounded set of proved leaf identities or composition of two
  owned callback values; no name-based lookup and no unknown bottom promoted.
- `JCallbackPlan`: scalar root identity, exact ordered dependency graph, lambda
  facts, application facts, remaining shared fuel, validity flag.
- `j_callback_root_select(book,d)`: select scalar entry; consume one shared fuel
  across signature, construction-flow and application-flow audits. Reject when
  any live callback has an unknown origin, escapes or crosses a generic observer.
- `j_callback_scalar_lambda(book,t,locals,fuel)`: prove binder/capture identities
  and scalar body using total-U32 proof helpers; annotations preserve original
  types. Evaluate every original capture once and retain binding order.
- `j_callback_application(plan,t)`: return a direct application fact only when
  source application is fully saturated and exact function provenance covers it.
- `j_callback_root_emit(book,d,plan)`: lexical factory and lambda clones plus
  exact guarded public root; original fallback remains byte-identifiable.

`selfhost/src/back/js/emit.bend` imports this module and tries the callback root
selector only after existing scalar-island precedence, before ordinary region
emission. Failed selection takes the current emitter unchanged. The root uses
the same exact saturation, dependency/native descriptor guards and host guard as
existing scalar regions; no new runtime exactCode domain is introduced.

`j_callback_root_emit` represents a known leaf with a fresh private descriptor
and captured scalar slots. A private worker takes captures and live argument as
separate scalar parameters, emitted from the proved source body. Composition
keeps fresh descriptors with the same logical two closure references. No closure
factory is erased, cached or hoisted. Traversal of nested composition uses an
explicit left-before-right work stack/iterative chain path; it never uses input-
dependent native recursion. Every private factory retains generic trampoline
construction until independently measured.

Public aliases cannot observe this representation because the root admits only
scalar inputs/result and proves closure construction cannot escape. Diagnostic
materialization is a separate test-only observer and is not production admission.

`selfhost/src/back/js/jpure.bend`: no unconditional change to j_pure_type or
j_pure_signature. Existing first-order proof remains its original domain. Shared
exact-source dependency and total-scalar helpers may be factored only after all
current consumers pass immediately.

Runtime `selfhost/src/runtime/js/core.mjs`: reuse regionProofOpen/Close and host
checks. If an application token is needed, it carries the exact nonnull proof
object; Error-hook suspension nulls current proof and cannot lend old token to
foreign callback reentry. Clear/restore token in finally. Root factory code may
omit application guards only when no generic/host crossing exists between root
admission and application; retaining token equality is the conservative first
implementation.

No BookCache fact is persisted initially. Later caching must include exact Book,
root/lambda binder identities, erased-slot layout, closure-flow context, all
captured types and failure/fuel validity. Cache reuse is a separate cost hypothesis.

## Why this is still conditional

This plan adds a proof domain rather than pretending function types already
belong to JPure. Its implementation cost is several hundred lines and a new
flow audit, which is unjustified after a null saved-output result. Root should
integrate only the smallest proved grammar whose actual clean callback-family
result survives. If construction dominates and direct invocation remains null,
stop; composition fusion or factory elimination is a separately named mechanism
with materialized direct emission as comparator.

## Implemented bounded source successor

`callback-candidate.bend` and `callback-source.patch` now implement the first
right-spine structural factory grammar as source code. They reuse the existing
scalar entry helpers and exactCode/fallback/proof-finally boundary, with no new
runtime/cache layer. This narrower implementation precedes general finite
lambda-set flow analysis.

Exact source facts distinguish KDef arity5 from its six-lambda composition body.
Three erased Type&1/q0 arguments are checked before U32 specialization, then
live f/g/x q1 argument types and U32 result are checked. Factory captures are
proved bounded total scalar expressions in the Nat predecessor; leaf expressions
are emitted directly from source with capture/argument bindings. Construction
materializes every fresh leaf, base identity and composition node in original
order before invocation. Function-bearing public types remain outside JPure.

The candidate is source-reviewed but unchecked. An early draft lacked complete
erasure/type proof; another used strict&& around recursive scalar checks and
would have explored absent children exponentially. Both are repaired and recorded
in the implementation report. Lazy kc admission/size/valid-call/child-success
fences precede recursive proof. Source qualification, actual-path activation and
clean timing are required before integration. The independent noncommutative
fixture tests order and same-arity live-prefix refusal.
