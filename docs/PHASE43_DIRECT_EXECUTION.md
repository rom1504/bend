# Complete-operation JavaScript execution

Phase43 extends the compiler written in Bend. Its
[design](../design/phase43/README.md),
[experiments](../experiments/phase43/) and
[implementation report](../implementation/phase43/README.md) distinguish saved
JavaScript experiments, checked compiler output and installed releases. The
release manifest remains authoritative; development checkpoints are not releases.

## Why complete operations matter

Optimizing one helper can leave most time in generic function application,
trampolines, descriptor checks and temporary values between helpers. The compiler
instead proves an enclosing operation and emits private fixed-arity workers for
its reachable graph. Public arguments still enter through the normal descriptor
and guards. Unsupported shapes and changed dependencies use the original body.

The public runtime remains observable: function identity, partial application,
mutable bindings, host hooks, errors and reentry all matter. A source purity proof
alone does not authorize caching mutable facts across invocations. Each entry
establishes its own permission, and `finally` restores the previous proof scope.

## Shared source and type facts

The existing `KTerm`/`KDef` representation and bounded purity/direct-call plans are
extended rather than introducing another general intermediate representation.
Every recursive proof has a budget and refuses unsupported or exhausted inputs.
Conditional recursion uses explicit branches: Bend's eager Boolean operators
cannot provide a recursion guard.

Closed String/Char, Map, Maybe, comparison and tuple representations require their
native owner and constructor signatures. Tuple equality retains both quantities;
it must not conflate distinct closed types. These rules do not replace the older
vector-specific equality policy.

Contextual instances specialize erased arguments while preserving the original
source definition, full public arity and generic fallback. The private worker has
only live slots. Instance facts are separate from ordinary source definitions;
their graph metadata has reserved kinds and positions. Source-emitted library
functions are eligible even when marked native, provided the backend does not
replace them with a runtime intrinsic. A native flag alone proves neither case.

## String operations

Exact String/Char admission lets generation, parsing and supporting functions
share a complete private graph. Typed dependency traversal records whether an
operation needs String host checks, including dependencies hidden in data fields.
Literal definitions retain dependency identity. Lowered direct calls preserve
the original source proof when validating a pure scalar prefix.

Strings and intermediate results remain materialized. Unicode projections,
constructor layouts and complete intermediate values are checked independently
of the final checksum. A mutated dependency invalidates the root that depends on
it; independently safe nested roots may still run.

## Captured functions and temporary pairs

Eligible known callbacks use private environments instead of repeatedly invoking
generic closure descriptors. Admission checks the authoritative erased formal,
the raw source binder and its absence from runtime use. Captured values and
noncommutative composition order remain explicit. Unknown or escaping functions
retain the existing behavior.

An exact closed-U32 callback proof permits the smaller shared integer host guard
and a private capability that avoids unrelated String checks. It does not change
the public dependency metadata or the default guard. Integer conversion,
arithmetic, function/protocol and dependency checks remain active.

Eligible Nat-driven pair loops keep two private state slots. Zero iterations
return the original value; positive iterations create fresh state. Right-hand
sides are evaluated before either field is replaced. Escaping trees, path lists
and their alias relationships retain their layouts. Existing stronger scalar
workers keep selection precedence.

## Reproducing and qualifying changes

Use the [checked development workflow](PHASE5_DEVELOPMENT.md) and
[Phase43 validation commands](../selfhost/tools/performance/phase43/validation/README.md).
Regenerate `selfhost/src/runtime.mjs` from `runtime/js` fragments before building;
qualification verifies exact fragment/bundle agreement in the selected snapshot.

The inner loop starts with a small falsifier, actual entry counters and complete
value/boundary controls. Only surviving changes proceed to clean timing with
fresh previous-release and pinned-TypeScript samples. Profiles and instrumentation
are separate from runtime measurements. Source acquisition and checking are
reported separately from execution time.

Final qualification includes the inherited frontend/backend/application/release
checks, new mechanism controls, scalar selection precedence, compiler request
costs and the complete maintained 45-point performance corpus. All measurements
use one CPU and memory-bounded serial processes. The report records source growth,
failed experiments and remaining gaps alongside gains.
