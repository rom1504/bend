# P45-023 — keep private-entry bookkeeping outside host observations

**Status:** six host-hook counterexamples confirmed on worker22 and repaired in
worker23. Fresh worker23 hook, nullary and Unit controls pass. Complete
qualification remains pending. This is a correctness repair, with no speed or
release claim.

## Failure and hypothesis

The runtime's `invokeExact` grants a one-use permission to a registered public
function. That permission allows its wrapper to attempt a guarded private worker.
Before invoking the wrapper, however, `invokeExact` consulted mutable
`WeakSet.prototype.has`, Object reflection methods and `Reflect.apply`. The full
host guard ran only inside the wrapper. A post-import hook could therefore run
before the guard refused private execution.

For example, replace `Reflect.apply` with a delegating function that records an
event when its target is `G.bench.code`. Calling the nullary `bench` from the
independent demand fixture gives the same value, 81, in workers19 and22. Worker22
adds an observable hook event before either source helper demand. The ordinary
worker19 root calls its code through `.call`, so it adds no such event.

These are supported **post-import** mutations. They require no change to the
existing premise of standard intrinsics during module initialization. See the
contract in [the architecture guide](../../selfhost/docs/ARCHITECTURE.md) and the
[detailed repair design](../../design/phase45/exact-entry-preflight.md).

## Independent observation

The maintained controller is
[exact-entry-host-hooks-controls-v1.mjs](../../selfhost/tools/performance/phase45/exact-entry-host-hooks-controls-v1.mjs).
It consumes checked emissions of the same
[nullary source](../../selfhost/tools/performance/phase45/fixtures/nullary-demand21-v2.bend)
and exact catalog, compiler API, runtime, module and Node identities.

For each hook it records three lanes: direct invocation of the ordinary source
root followed by demand of its tail message; normal worker19 invocation; and
normal candidate invocation. A temporary getter for the source helper marks the
start of source-body execution and independently forces private-graph refusal.
Only events before that first source demand count as entry-bookkeeping events.
The ordinary lane must have exactly two source demands and return81. All hook
properties and the helper descriptor are restored in `finally`.

Root executed this controller on worker22. The preserved report is
`selfhost/build/phase45/exact-entry-hooks22/report.json`, with `complete:true` and
`pass:false`. Every lane returned81; all six candidate traces disagreed with the
ordinary source-entry trace:

| Post-import mutation | Ordinary root prefix | Worker19 prefix | Worker22 prefix |
| --- | --- | --- | --- |
| Delegating `Reflect.apply` | none | none | one hook event |
| Delegating `Object.getPrototypeOf` | none | none | one hook event |
| Delegating `Object.getOwnPropertyDescriptor` | none | none | one hook event |
| Delegating `Object.hasOwn` | none | none | one hook event |
| Delegating `WeakSet.prototype.has` | none | one hook event | one hook event |
| Getter for `Reflect.apply` | none | none | one getter event |

The WeakSet observation already existed in worker19 because a module containing
any exact-entry function used the dynamic membership method even for ordinary
functions. It is an older runtime defect exposed by the same audit. The other
five cases demonstrate new observations on the newly optimized root. The report
keeps both facts: repair success means agreement with ordinary source invocation,
not preservation of every accidental historical preflight hook.

This controller tests six recording/delegating hooks. It does not independently
claim coverage of every throwing or reentrant host-hook implementation. Existing
public descriptor, `.call`, environment, reentry and permission controls remain
required for the repaired runtime.

## Isolated repair

At standard module initialization, capture `Reflect.apply`, the three Object
reflection operations used by entry checking, and a bound native WeakSet
membership function. Entry bookkeeping then invokes those private captures
directly. The bound membership function keeps the original WeakSet receiver and
avoids creating an extra `[code]` array on every ordinary runtime call.

The repair retains the observable public operations: descriptor `.code` access,
the live `.call` lookup before `.env`, and fallback through the actual public
`.call` when its protocol has changed. Permission is still installed after the
environment read, consumed before argument reads and restored in `finally`.
Private admission, source guards, worker IR and public representations do not
change. The runtime source fragment and generated runtime receive the same edit.

The isolated patch is
`selfhost/build/phase45/exact-preflight23-v2/exact-preflight.patch`. Version1 is
preserved; version2 replaces captured-apply WeakSet membership with bound native
membership, removing its unnecessary per-call vector. Both changes received
independent static review. Syntax, runtime-fragment concatenation and patch
applicability were checked without executing generated programs during authoring.

## Fresh worker23 outcome and remaining qualification

Root ran the unchanged six-hook controller against fresh worker23 emissions.
`exact-entry-hooks23/report.json` is complete and passing: all six candidate
traces match the ordinary source-entry lane, with only the two required source
demands and value81. The historical worker19 WeakSet event remains visible in its
own report lane; it was not rewritten or asserted to be the desired behavior.

Fresh controls on that same runtime also pass:

| Selected-image control | Recorded observations |
| --- | --- |
| `nullary23-controls-v3` | 6 value oracles, 39 boundaries, 6 activation observations, 9 metadata comparisons |
| `unit23-controls-v1` | 27 value oracles, 10 mutation boundaries, 4 activation observations, 2 public ABI bundles |

Worker23 shares worker22's compiler API, but its runtime hash is
`4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
These are fresh acquisitions and executions on that runtime; worker22's earlier
passes were not reused as worker23 evidence. Complete mechanism controls,
representative performance and full selected-image qualification remain required.
The short hook controls do not establish a speed improvement or release readiness.

| Preserved artifact | SHA-256 |
| --- | --- |
| Failed worker22 observation report | `ef49e42e378f342250a3493037633ef066d677b50da7a865cd330f5908f4e208` |
| Consumed diagnostic controller | `3daf374714bca03319676ddda1dd9dda199fdc0ffaea893a88516d049a7f985e` |
| Isolated worker23 version2 patch | `e9c00519aa510eca1988b3a65f0617f76fbd0646a83c629dbfe58db4fe46f9ca` |
| Passing worker23 hook report | `42211089b84898b62c0e100a49a0c464e5982e54f19d626e59917d303da5f5b2` |
| Passing worker23 nullary report | `ac9efa972dcd3b089ab72faa5bac526c37e3756e544464ee6ef6cec585b3bfd5` |
| Passing worker23 Unit report | `c00a28bb02989bfd0d88ccfcd61b6a59dfefbf8fb1b9f999c5dabba06bf48290` |

All report paths in this note are under `selfhost/build/phase45`. The raw failed
report remains unchanged. The final evidence archive will retain its checked
module identities, all observations and the passing successor reports separately.
