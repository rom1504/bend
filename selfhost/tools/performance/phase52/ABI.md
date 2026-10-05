# Direct JavaScript candidate ABI

Status: candidate 05 implements the full direct library/program contract below;
its qualification and release selection remain pending. The installed Phase51
backend remains separate. Select this backend explicitly with `--direct-js` or
`inspect(input, { backend: 'direct', mode: 'library' })`.

The driver prepends only `src/runtime/js/direct.mjs` and Bend-owned direct
emission. Program output and libraries with foreign sources also receive an ESM
`createRequire` binding for the pinned Node IO helpers. There is no TypeScript
compilation delegation, legacy G registry, or descriptor guard ABI.

Reference: pinned `selfhost/.bootstrap/upstream-phase23/bend2/comp.ts` at
`018751270e800bc222a93dad7f257083ee53a5f7`: `js_marshal`, `js_host`, `js_lib`,
`js_book`, `show_main`, `js_def`, `run_lib`, `run_loop`, and `nat_host`. These upstream sources are unchanged.

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
type scans distinguish exhaustion from a proven absence. Unknown datatype
parameters are not guessed from runtime objects.

## Exports, programs, and foreign effects

Library roots and default exports follow pinned `js_lib`: ordinary filled,
nonnative, nontemplate definitions, excluding Foreign definitions and definitions
whose **original whole type** is `IO<A>`. A function with type `U32 -> IO<Unit>`
remains a callable export. Filtering the post-arity result instead would silently
omit such exports and is not this contract.

`src/back/js/direct/program.bend` provides `jd_roots(book,library)` and
`jd_program_selected(contextBook,defs)`. Program mode roots `main`; library mode
roots the callable exports. Selected annotated definitions overlay the context
before call analysis and SCC emission. The CLI calls
`cli(process.argv.slice(1))`, then `io_exit` on the direct main function. IO main
uses the pinned scheduler. Pure main uses a Bend-built packed `[D,N]` readback
schema and pinned `show_val`. Native primitives, named ADTs, Bool, Tuple/List,
Array, and equality proofs use that display protocol. Symbolic cell offsets
support recursive type schemas; the type graph has a 4096-node bound. Unprintable
functions, types, erased/dependent fields, and exhausted analyses emit an explicit
compile-refusal marker. A build needs Base; foreign main cannot anchor IO.

`jd_foreign_paths/error` collect selected reachable Foreign definitions, including
Base effects; there is no legacy built-in IO exemption. `jd_modules(selectedDefs,
sources)` consumes shared namespace-resolved `Source/Text/CID/FID` rows. Both CID
and FID expand to quoted resolved names, as in pinned JS source substitution.
Sources run in isolated IIFEs, register `$0eff` effects, and undergo missing
registration checks. Missing `.js` sources and invalid source identifiers fail
explicitly.

`jd_foreign_def` uses the full normalized IO telescope, including its erased
result type and final live continuation. The continuation occupies the final
live argument exactly once. Foreign operations have the pinned shape
`{ $: '$FFI', run, need, args, kont }`. Registry `run` and `need` reads occur before
typed OUT conversion of arguments and continuation. The continuation conversion
preserves function variance and converts foreign Nat results back to internal
Number values. IO.OP matching throws incoming `$FFI` operations to the scheduler,
which dispatches the registered effect. Direct output never delegates to legacy
`j_modules`, `foreignModules`, or G. Metadata currently says
`prototype: true, foreign: 'upstream-cps'`; that label is not a release claim.

The pinned runtime supplies the complete scheduler and IO helpers. Its
Bun-dependent syscall/parking path retains upstream platform requirements;
including those helpers does not establish independent Node syscall coverage.

## Qualification checkpoint

Candidate 04 completed 63 of 64 independent differential observations; the
remaining failure was the NaN-table bit witness. This was an actual qualification
failure, not a passing full gate. Its maintained 26-row JS census agreed on all
26 observations: 22 fixture passes and four unchanged not-applicable rows. A
separate 40-source gate recorded 39 candidate successes and one source failure
shared with the reference. These scopes are distinct and do not constitute the
81-row native/interpreter census or full frontend conformance.

Candidate 05 qualification is pending here. Root owns all builds, acquisition,
and execution. Complete default-export values, partial application, erased
quantities, Number/BigInt Nat errors, Unicode, constructor fields/tags, aliasing,
mutable Array restoration, function variance, deep marshalling, CLI, and live
foreign effects require actual checked-module comparisons. Compilation latency,
emitted size, and execution speed remain separate measurements. See the
[user guide](../../../docs/direct-javascript.md) and
[current Phase52 report](../../../../implementation/phase52/README.md) for the
selected status and eventual final counts.

## Historical pure-library prototype

The first host slice intentionally emitted named unreachable Foreign stubs with
`JD_FOREIGN_UNSUPPORTED` and metadata `foreign: 'unsupported'`. It had no qualified
program/FFI path. Those limitations describe that preserved prototype only; they
do not describe candidate 05's CPS/module/program implementation above. Historical
prototype measurements do not qualify the expanded effectful interface.

## Installed-release smoke controller

`direct-release-smoke.mjs` is prepared for root-scheduled execution after final
installation and the existing 42-check CLI smoke. It is not an executed result.
Run it under the existing bounded job supervisor, with a fresh output directory:

```sh
NODE tools/performance/phase52/direct-release-smoke.mjs SELFHOST NEW_OUT \
  FINAL_API_SHA256 FINAL_SOURCE_SHA256 FINAL_DIRECT_RUNTIME_SHA256
```

All three expected hashes must be exact 64-character SHA256 values from the
selected release. Its 18 checks cover ordinary and relocated release verification,
pure direct execution, emitted ESM execution, callable/partial library exports
without G, Node IO print/FFI, deliberate copied-runtime tamper rejection, and
restored release verification. Relocation reuses the release inventory and copies
no upstream checkout. BEND and Node option overrides are removed. Inputs, inline
fixture sources, generated modules, logs, controller, and Node executable are
hash-bound in the receipt. Root owns execution and final publication status.
