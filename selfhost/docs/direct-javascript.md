# Direct JavaScript output

**Phase52 candidate documentation; full qualification and release installation
are pending.** The installed Phase51 compiler remains the compatibility release.
The commands below describe the candidate driver interface, not a guarantee that
an older installed compiler supports it. Check the
[Phase52 report](../../implementation/phase52/README.md) and release manifest
before relying on this mode.

## Select the interface explicitly

From `selfhost/`, with Node.js 24 or newer:

```sh
# Check and emit an executable ES module (candidate full-program interface).
node cli.mjs example.bend --direct-js -o example.mjs
node example.mjs -- argument

# Check, compile and execute main (candidate full-program interface).
node cli.mjs example.bend --direct-js --run -- argument

# Emit a library using the upstream callable interface.
node cli.mjs example.bend --direct-js --library -o example-library.mjs
```

Use `.mjs` for unambiguous ES-module loading. `.js` output also requires an ESM
host configuration. `--direct-js` selects JavaScript only; it cannot be combined
with native/GPU output or non-JavaScript output suffixes. Runtime arguments go
to a run, not an output-writing or library command. Without `--run`, `--library`
or `-o`, the normal default remains checking followed by interpretation;
`--direct-js` does not turn that default into a compiled run.

A generated library has a default object of source callable exports:

```js
import bend from './example-library.mjs';
const answer = bend['namespace.function'](input);
```

Names are the resolved source names in that loading book. Exported wrappers
accept live arguments; erased type arguments are omitted. Partial application
uses the pinned upstream `run_lib` convention. Functions returned by source
code are native callable closures. Consult the
[ABI notes](../tools/performance/phase52/ABI.md) for typed boundary details;
these are not legacy descriptor calls.

## Why this is a separate mode

The direct target is Bend's compiler implemented in TypeScript at fixed commit
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/bendlang/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7).
“Upstream-compatible” refers to that compiler's JavaScript calling and value
contract, not to Microsoft's TypeScript compiler or an unverified latest release.
Compatibility is a qualification goal; the prototype does not establish every
part of that goal.

Default JavaScript output retains the mutable `G` table and function descriptors
with `code`, `env`, `arity` and `bound`. Its guards preserve supported mutations,
getters and fallback behavior. Direct output instead uses lexical functions,
native closures and named constructor fields. It does not export `G` or the
legacy `call`, `list` and `ctor` machinery. Replacing an exported callable does
not replace its module's lexical internal callees.

This explicit choice permits different internal machinery without weakening the
existing backend. It is not permission to ignore effects: property reads,
conversions, argument evaluation, array mutations, failures and foreign callbacks
performed by the pinned interface still have observable order. Direct output
is not a drop-in replacement for clients inspecting or mutating legacy internals.
See the [parity contract](../../implementation/phase52/parity-contract.md).

## Values and supported lowering

U32/F32 use JavaScript numbers, Bool uses booleans, and String/Char use strings.
Nat uses Number internally and typed BigInt conversion at the public boundary,
following the pinned arithmetic and host-conversion rules. The immediate
arithmetic limit and host-input conversion boundary are distinct; do not infer
that all BigInts are accepted because public Nat values use BigInt.

Ordinary constructors use named fields and resolved constructor tags. Unit is
`{$: 'Unit'}`; tuples use `{$: 'Tuple', fst, snd}`. Arrays use native JavaScript
storage. Nat-containing arrays are converted in place at typed host boundaries;
recursive records and function arguments/results receive typed conversion where
required. Aliasing and mutation are part of the interface, not just final values.

A supported primitive lowers to its direct template only when the checked book
identifies the actual native definition. A same-spelled user definition does not
acquire primitive behavior. An operation without a direct template can retain
its checked source implementation. That is ordinary direct lowering, not a
fallback to TypeScript or legacy `G` execution.

Unsupported constructs, missing foreign sources and exhausted proof/emission
budgets must fail explicitly. The driver rejects emitted `JD_UNSUPPORTED`
markers rather than accepting a delayed failure as a working artifact. There
is no silent switch to the legacy backend. Some recursive shapes still use
native JavaScript stack space; tail-call support does not imply an unlimited
stack for non-tail recursion or all recursive host marshalling.

## Programs, IO and foreign JavaScript

The candidate full-program emitter checks and lowers `main`. Pure results use
typed readback and the pinned printing format. IO results use the direct CPS
scheduler. Libraries select ordinary source callable exports; native definitions,
foreign definitions and IO-result exports are not exposed as ordinary pure host
functions.

The full-stage implementation resolves foreign JavaScript source paths, rewrites
source constructor/function IDs to resolved names, registers effects in the
direct registry, and transports typed arguments and continuations in `$FFI`
messages. Missing effect registrations fail explicitly. This integration remains
subject to checked semantic qualification; including scheduler helpers in the
runtime alone does not establish working FFI.

Generated Node modules provide an ESM `createRequire` binding when needed.
System-call/polling paths retain the pinned runtime's Bun FFI assumptions or an
explicit `globalThis.BEND_SYS` provider. Successful printing or pure execution
under Node does not establish every asynchronous/system effect on Node. Foreign
sources are executable host code and must be trusted by the caller.

## Runtime integrity and evidence

Parsing, elaboration, checking and emission run the compiler written in Bend.
Ordinary user compilation does not invoke the upstream TypeScript compiler.
The [direct runtime](../src/runtime/js/direct.mjs) is a standalone, attributed
port of the pinned runtime helpers and is embedded in generated output; generated
modules do not import the TypeScript implementation or legacy runtime.

Use a checked compiler artifact with its matching Base, driver and direct runtime.
The direct runtime is an emission input and must be included in artifact/release
identity checks. A successful source check does not by itself qualify the new
emitter, and a candidate build is not an installed release or a new self-emitted
fixed point. Root release verification remains a separate gate.

The [Phase52 comparison guide](../tools/performance/phase52/README.md) preserves
the unchanged 45-point / 23-source catalog and labels the changed calling
contract explicitly. The passing direct03 eight-point screen reports 1.03522×
pinned-upstream execution time, versus 5.23997× for unchanged Phase51 in that
same screen. This is a short, selected prototype result, not full-corpus parity,
universal speed, compilation-latency improvement or complete language/IO
conformance. Follow the [current report](../../implementation/phase52/README.md)
for subsequent checked semantic, full-corpus and release outcomes.
