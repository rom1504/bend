# Direct JavaScript prototype ABI

Status: source prototype, not an accepted release or a conformance claim.
The checked driver must explicitly request `backend: 'direct'`. It prepends only
`src/runtime/js/direct.mjs`, then the Bend-owned direct library source. There is
no TypeScript compilation delegation, legacy G registry or descriptor guard ABI.
The installed backend and previous evidence remain separate.

Reference: pinned `selfhost/.bootstrap/upstream-phase23/bend2/comp.ts` at
`018751270e800bc222a93dad7f257083ee53a5f7`: `js_marshal`, `js_host`, `js_lib`,
`run_lib`, `run_loop`, and `nat_host`. These upstream sources are unchanged.

## Module and calls

Core emits named saturated functions using `jd_name(name)` with **live arguments
only**. `jd_arity(book,d)` supplies the source formal count, including erased
positions and any core-owned arity raising; `jd_live_arity` counts runtime slots.
Host generation uses the same count for inputs, result telescope and exports.
Default exports are callable JavaScript functions, wrapped by upstream-style
`run_lib` for rest-argument partial application. Erased inputs do not occupy host
slots. Extra arguments follow the pinned rest-wrapper behavior. Zero-arity roots
recompute their body on each call; exported values are not memoized.

The host wrapper evaluates typed input conversions left-to-right, invokes the
named function, runs its tail messages through `run_loop`, converts the result,
then converts mutable input arrays back to host values before returning. It does
not restore inputs in a new finally block on error; that would change upstream
behavior. Function-valued conversions preserve curried application and variance.

| Value | Direct internal representation | Host boundary |
| --- | --- | --- |
| Nat | Number, bounded by pinned Nat runtime rules | `nat_host` on input; `BigInt` on output |
| U32/F32 | Number | Identity unless inside a Nat-containing aggregate |
| Bool | boolean | Identity |
| String/Char | JS string | Identity |
| Unit | `{ $: 'Unit' }` | Identity; Unit is not null |
| Named ADT | `{ $: resolvedConstructor, namedField: value, ... }` | Identity when no known Nat; typed copy/conversion when Nat-containing |
| Tuple/Sigma | `{ $: 'Tuple', fst, snd }` | Same typed named-field rule |
| Array | Native JavaScript array | Nat cells converted in place, matching pinned `js_marshal` |
| Function | Native callable, with direct runtime closure/tail helpers | Curried typed Nat conversion when required |

Null is used only where the selected core/runtime representation explicitly
uses it; it is not a blanket replacement for Unit or empty constructors.
Native ownership is established by checked declarations, not arbitrary field
shapes. This backend targets the upstream native ABI, not the stronger mutable
legacy descriptor contract. Malformed named tags use the pinned thrown-string
message, including constructor identities and loading-book caveat.

## Typed marshalling implementation

`src/back/js/direct/host.bend` provides `jd_exports(book,defs)`, `jd_host(book,d)`,
`jd_marshal(book,ty,out)`, and `jd_foreign_def(book,d)`.

Known Nat occurrence uses a shared worklist with 1024 visits and exact specialized
`term_key` identities. Erased/abstract types have no known conversion, following
the pinned type-directed policy. Telescope advancement substitutes an opaque
`Absent` DUMMY via `j_app_type`, rather than assuming a runtime argument is known
at compiler time. The core must use the same opaque-erasure policy.

Named recursive types use nested typed converter functions. The last directly
self-recursive field forms an iterative spine, like upstream `js_marshal`;
other converted fields retain order. Nat-free arms retain their original object.
Conversions preserve other enumerable object fields through spread. This is
not a universal stack bound for arbitrary branching recursive data.

Marshaller construction/field telescopes are capped at 64 levels. Budget or
formal failures emit an exact newline `/*JD_UNSUPPORTED:` marker and an explicit
throwing expression. The direct driver must reject such generated source before
accepting an artifact; a delayed throw is not qualification. Nat occurrence and
IO-result checks distinguish exhaustion from a proven absence. Unknown datatype
parameters are not guessed from runtime objects.

## Effects and foreign scope

The runtime owner supplies pinned IO scheduler helpers, `$0eff`, `io_eff` and
`io_run`; their presence does not qualify direct FFI emission. This first host
slice exports pure ordinary, nonnative, nontemplate definitions. Foreign and
IO-result definitions are excluded from the default host interface, like pinned
library export selection.

Unreachable foreign definitions may have explicit named stubs which throw
`direct-js prototype unsupported: foreign definition NAME` on invocation.
They carry a separate `JD_FOREIGN_UNSUPPORTED` marker, and backend metadata says
`prototype: true, foreign: 'unsupported'`. They never delegate to `j_modules`,
foreignModules or G. Effectful entry must be refused explicitly until the direct
CPS/IO.OP matcher and source registration contracts are implemented and tested.

Full FFI needs its own direct module producer: constructor/function source IDs
must resolve to direct names, sources register exact `$0eff` entries, arguments
and continuation are marshalled at their typed boundaries, and operations use
`{ $: '$FFI', run, need, args, kont }`. The IO.OP matcher must propagate that
message to the scheduler. Missing `.js` imports/registrations must fail clearly.
Node `require` binding is needed only when actually enabling the corresponding
foreign sources. A dormant scheduler is not silently treated as working FFI.

## Qualification still required

Root owns checked build, acquisition and execution. Before calling this backend
compatible, verify complete default-export values against pinned TypeScript,
partial application, erased quantities, Number/BigInt Nat errors, Unicode,
constructor fields/tags, aliasing and mutable Array restoration, function
variance, deep recursive marshalling, and explicit unsupported/effect controls.
Pure benchmark success cannot grant effects or renew historical conformance.
Compilation latency, emitted size and execution speed remain separate metrics.
