# Exact-entry bookkeeping before host guards

Status: isolated worker23 proposal over frozen worker22. No target execution or
promotion is claimed. The maintained runtime is unchanged by this patch artifact.

Worker21 added guarded zero-argument entries while retaining their ordinary
public descriptor and function metadata. Review found a preceding observation:
`invokeExact` consulted mutable `WeakSet.prototype.has`, Object reflection and
`Reflect.apply` before the guarded body could reject a host mutation. An ordinary
nullary function need not perform those observations. A host hook can therefore
see the new entry bookkeeping even when the body later chooses ordinary code.

## Intended boundary

Private exact-entry bookkeeping must use standard intrinsics captured during
module initialization. This is the existing initialization contract, already
documented in `selfhost/docs/ARCHITECTURE.md`; it adds no support for arbitrary
hostile replacements installed before import. Actual public operations remain
observable: read `f.code`; resolve `code.call` before `f.env`; use the ordinary
call path when code identity, prototype or its own call property does not qualify.
Install the one-use permission token only after the environment read completes,
and restore the preceding token in `finally` after success, error or reentry.

## Isolated change

Capture `Reflect.apply`, `WeakSet.prototype.has`, `Object.getPrototypeOf`,
`Object.getOwnPropertyDescriptor` and `Object.hasOwn` beside the existing captured
Function prototype and call method. Bind the captured native WeakSet membership
method once to the private set, then invoke that bound function directly; this
avoids an argument-vector allocation on every ordinary call. Use captured apply
for the final exact invocation. Call the captured Object methods directly;
they require no receiver and do not consult a mutable `.call` property.

The live `code.call` property lookup and environment read retain their order.
The nullary wrapper still has zero formal parameters, checks argument count
before reading an omitted vector and receives no permission from raw invocation.
No admission, dependency list, host guard, constructor representation, error
protocol or source lowering changes. The fragment and concatenated runtime are
updated together; the latter is checked against the standard fragment order.

The patch is `selfhost/build/phase45/exact-preflight23-v2/exact-preflight.patch`,
SHA-256 `e9c00519aa510eca1988b3a65f0617f76fbd0646a83c629dbfe58db4fe46f9ca`.
Its before/after files and identities remain in that directory's `receipt.json`.
The candidate runtime SHA-256 is
`4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.

## Qualification

Use separate modules acquired with their selected runtime. Exercise post-import
replacements and accessors for every captured intrinsic, with hooks that record,
throw and reenter. Compare values, errors, event ordering and selected-path
activation with the ordinary predecessor. Retain nullary metadata, missing-vector
prototype getters, raw unforced messages, constructor calls, partial application,
oversaturation, own/inherited `.call`, environment getters and genuine Error
reentry controls. An environment getter must finish before permission is granted;
an inherited or own `.call` hook must still take the observable ordinary path.

There is a separate scope question: predecessor modules already containing exact
entries can expose these internal reflection hooks too. Capturing them removes
that accidental bookkeeping observation as well as preventing newly introduced
nullary observations. Qualification must record the actual predecessor behavior,
not silently describe every removed internal hook as previously absent. This is
not permission to suppress source-level host operations or public call hooks.

Run syntax and runtime/backend semantic checks before representative timing.
The preserved v1 patch used captured apply with a fresh membership argument
vector. V2 binds native membership once during initialization, avoiding that
hot-path allocation. Performance still requires measurement. A broad
release decision remains separate from this correctness repair.
