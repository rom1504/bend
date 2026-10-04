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
checks its dependency and host assumptions. Routes that open a proof scope restore
the previous scope in `finally`; lexical contextual routes do not open that scope.

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

Eligible known callbacks fuse construction with application. Instead of allocating
an unescaped closure/environment graph and traversing it afterward, the worker
computes each captured scalar and applies its leaf operation in the proved
application order. Noncommutative composition stays ordered. This requires an exact
total-U32 grammar that excludes capture escape, foreign calls, observable errors
and retained callbacks; purity alone does not justify interleaving the two stages.
Public or escaping functions retain their descriptors and generic behavior.

The fused countdown evaluates its count and seed once. Counts that are JavaScript
Number integers in 0..4,294,967,295 use exact Number decrement and the proven U32
image of the predecessor. Other counts keep the original BigInt countdown and
capture expressions. This removes BigInt work only within the proved bound;
it introduces no closed-form sum or unchecked Nat conversion. Number, BigInt,
Number.isInteger and required arithmetic host identities remain guarded.

An exact closed-U32 callback proof permits the smaller shared integer host guard
and a private capability that avoids unrelated String checks. It does not change
the public dependency metadata or the default guard. Integer conversion,
arithmetic, function/protocol and dependency checks remain active.

Eligible Nat-driven pair loops keep two private state slots. Zero iterations
return the original value; positive iterations create fresh state. Right-hand
sides are evaluated before either field is replaced. Escaping trees, path lists
and their alias relationships retain their layouts. Existing stronger scalar
workers keep selection precedence.

## Map source calls

A scalar enclosing request can construct a fresh Map and use exact contextual
instances of source-defined Map helpers. Erased type and quantity arguments are
proved closed, substituted into the source, and removed only from private live
parameter slots. The emitted workers and recursive continuations refer to lexical
clones; they never look up private instance names through public G. Unsupported
combiner shapes refuse the complete plan. Public Map methods retain their original
erasure/null-prefix ABI, and public data arguments do not acquire ownership merely
because their type is closed.

Ordinary entry must execute the selected contextual branch and actual Map workers.
This route does not open regionProof. Complete native Map, Maybe and Sigma values,
sharing, fresh shells, externally retained inputs and deep source operations are
checked separately from final checksums. Some helpers remain generic residuals;
contextual lowering does not imply that every application in the request vanished.

Numeric intrinsic lowering bypasses ordinary G calls, so the enclosing guard also
records conservative identity dependencies for the whole known U32/F32 primitive
family. Even a changed primitive that this request does not use can force fallback.
Source binding/code identities, native String hosts, errors and reentry remain
observable and guarded. The conservative fence trades some entry-check cost for
the original generic behavior under mutation.

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
costs and the complete maintained 45-point regression corpus. These workloads
informed optimization, including historically named holdout partitions; qualification does
not establish universal TypeScript parity or independent unseen-workload coverage.
All measurements use one CPU and memory-bounded serial processes. The report records source growth,
failed experiments and remaining gaps alongside gains.
