# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md),
[Phase61 results](../implementation/phase61/state08-results.md),
[backend boundaries](../docs/self_hosted/backend-boundaries.md) and
[direct JavaScript guide](docs/direct-javascript.md).
**Phase61 state08 is installed and verified.** Direct JavaScript is the default;
`--legacy-js` and native targets retain their contracts. Ordinary compilation
runs Bend code without a TypeScript fallback.

The genuine direct B2 freshly type-checks its complete source in **11.397 seconds
of check-request time** (**17.248 internal / 17.385 supervised seconds**) and emits a
byte-identical B3 in **34.386 internal / 34.568 supervised seconds**. All 3,192
definitions remain `@unsafe`; proof trust is refused. These correctness durations
are not controlled compiler-speed comparisons, and type acceptance and
reproducibility do not establish kernel proof validity. The installed package
remains checked B1. B2/B3 are **3,978,248 bytes**, with **86 explicit roots**.
B2 passes eight exact driver observations and the final semantic controls; all
23 raw benchmark modules and their 45-point observer mapping equal selected B1.
See the [image workflow](../docs/self_hosted/compiler-image-generation.md).

[Source accounting](../implementation/phase61/source-footprint.md) records
**27,753 physical / 22,799 code lines**, 3,192 definitions, 112 types and 114
modules: +1,193 physical / +976 code lines relative to Phase58. All 17 native
modules and both runtimes retain exact bytes; the typed driver and maintained
workflow changed. The [compiler-request guide](../docs/self_hosted/compiler-request-pipeline.md)
describes the current mechanisms. The six changes in the
[allocation guide](../docs/self_hosted/compiler-allocation.md) remain Phase58 history.

The [Phase61 results](../implementation/phase61/state08-results.md) separate
compiler measurements, generated-program behavior and release qualification.
The balanced compiler campaign passes **207 workers: 23 sources × three roles ×
three rounds**. Equal-source geometric means of per-source medians improve from
**2.476542× to 1.433877× B2/TS** for API import/load plus first compilation and
**3.816429× to 2.071828×** for compilation alone. These use genuine B2 in fresh
processes with prepared persistent Base caches, without a cold OS-cache or
installed-B1 CLI-latency claim. The [Phase58 runtime campaign](../implementation/phase58/program-performance.md)
remains dated evidence, transferable only to byte-identical artifacts; no new
669-sample runtime campaign or generated-program speed gain is claimed.
Phase56's 44/45 byte retention and map/set timing remain
[historical results](../implementation/phase56/performance.md).

```sh
# From selfhost/, with Node.js 24+:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --legacy-js --run
```

The [benchmark recipes](tools/performance/phase53/PLAN.md) cover checked acquisition,
fast screens and serial full-corpus validation. Use fresh attempts and the
[Phase61 results matrix](../implementation/phase61/state08-results.md) for the
selected image. Historical [Phase56 recipes](tools/performance/phase56/README.md)
require fresh identity bindings before replay. CPU/allocation/V8
[diagnostics](tools/performance/programs/DIAGNOSTICS.md) remain separate from clean
timing. The pin remains `018751270e800bc222a93dad7f257083ee53a5f7`, after Bend 2.0.34.

The [architecture survey](../docs/self_hosted/README.md),
[compiler research](../research/compilers_architecture_and_techniques/README.md),
[ledger](../experiments/ledger.md), [strategy](../experiments/STEERING.md) and
[checked workflow](../docs/PHASE5_DEVELOPMENT.md) retain the development context.

## Use the typed compiler

Node.js 24 or newer runs the supplied generated API. The host shell handles
files, arguments and processes; parsing, elaboration, checking, specialization,
normalization and emission execute code generated from the Bend2 modules.
There is no fallback to upstream TypeScript in ordinary compilation.

```sh
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --check-only
node cli.mjs tests/conformance/typed-smoke/base-u32.bend
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
node cli.mjs tests/conformance/typed-smoke/base-u32.bend -o program.mjs
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --native --run
```

Native execution requires Clang 14 or newer. `--native` selects a GPU build
for bang calls when the host has the supported SDK; `--cpu` forces CPU execution.
`--metal` and `--cuda` explicitly select those platforms and fail when their
toolchain is unavailable. GPU builds need Clang 19 or Apple Clang 17, plus the
platform SDK. The native build shell links the platform libraries requested by
foreign effects. Actual GPU execution has not been verified in this workspace.

The default checks the file, then interprets `main` (or reports declarations when
there is no `main`). `--interpret` selects this explicitly; `--run` executes the
JavaScript backend. Runtime arguments can follow the input or `--`.

Use `-o program.c` to write C, `-o program.js` or `-o program.mjs` for JavaScript,
and another output suffix to build a native executable. Multiple `-o` outputs are
supported. `--library -o library.mjs` emits a JavaScript library. `--checkup`
checks and runs each directly imported module independently.

The parser reports source errors separately from type errors. A rejected check
stops executable generation. Host effect implementations necessarily use
JavaScript or native platform code; that runtime is separate from the compiler.

## Source organization

| Directory | Responsibility |
|---|---|
| `src/core/` | First-order terms, substitution, weak/strong evaluation, conversion, term readback |
| `src/front/` | Lexer, declarations, expressions, desugaring, nested patterns, validation, fresh binder IDs |
| `src/load/` | Module graph, namespaces, aliases and foreign-source paths |
| `src/check/` | Dependent checking, quantity accounting, recursion, template instances and typed annotations |
| `src/diagnostic/` | Structured checker errors, context rendering and source provenance |
| `src/back/js/` | JavaScript generation, literal lowering, typed readback and foreign linkage |
| `src/back/native/` | Runtime layouts, segments, continuations, closures, erasure and C generation |
| `src/runtime/js/` | JavaScript primitive and effect runtime, including foreign marshalling |
| `src/runtime/native/` | Pinned upstream native execution runtime and effects |
| `src/driver/` | Compiler queries shared by the host shell |
| `tools/` | Bootstrap, source assembly, command shell and validation tools |
| `tests/` | Component regressions and upstream conformance reports |

`src/compiler.json` is the canonical module manifest. `tools/assemble.mjs`
orders type declarations, forward laws and function bodies into one bootstrap
input, with a source map back to editable modules. It does not parse or compile
user programs. See [the architecture notes](docs/ARCHITECTURE.md).

## Rebuild and validate

Prepare the exact upstream checkout once as described in the
[compiler guide](../docs/BEND-IN-BEND.md#rebuild-the-default), then run:

```sh
npm run build
npm run verify:release
```

For a custom upstream location or focused selection, pass a development JSON
configuration and a fresh attempt path to `npm run build -- CONFIG NEW_ATTEMPT`.
For experiments that should leave the default intact, use the
[maintained development workflow](../docs/PHASE5_DEVELOPMENT.md).

Direct self-reproduction is a separate integration gate using a genuine checked
parent. Follow the [image workflow](../docs/self_hosted/compiler-image-generation.md)
and [Phase61 results matrix](../implementation/phase61/state08-results.md). The
[legacy reproduction instructions](../docs/BEND-IN-BEND.md#full-self-reproduction-and-component-checks)
and [Phase 5 record](../implementation/phase5/final-selfhost.md) describe the older
pipeline. A derived API must not acquire a bootstrap sidecar. Low-level bootstrap commands need an
explicit fresh `BEND_TYPED_API` path; running them against the default replaces
its artifact kind and invalidates release verification.

Runtime, ABI and harness checks remain available:

```sh
npm run test:runtime
npm run test:abi
npm run test:harness
```

The [conformance protocol](tools/conformance/README.md) documents full inventory,
exact selections, resource limits and retained failures. Negative syntax
rejection is not automatically correct type rejection, and GPU execution needs
actual hardware evidence. Use a fresh report path and preserve the artifact
identities; historical reports do not validate later source just because paths
have the same names.

Historical self-emitted distributions and their original reproduction reports
remain in `dist/selfhost/`; the [preservation index](../experiments/PRESERVATION.md)
and [experiment ledger](../experiments/ledger.md) identify their exact scope.
They are not alternate defaults. The historical Phase39 image passes its own
[42 ordinary/relocated CLI checks](../implementation/phase39/release-05.md),
including relocation without an upstream checkout. The earlier
[Phase36 release](../implementation/phase36/release-03.md) retains its separate evidence.
The earlier [Phase5 clean-package evidence](../implementation/phase5/relocated-cli-evidence/README.md)
applies to that historical artifact.

## Earlier prototype

`src/compiler.bend`, `dist/bend2c.mjs` and `legacy-cli.mjs` retain the earlier unchecked
single-file JavaScript path. Its stage-2/3/4 fixed point applies to that
prototype, **not automatically to the new typed compiler**. Use the typed driver
above for the new work. The original behavior and bootstrap are documented in
[the legacy notes](docs/LEGACY-PROTOTYPE.md).

## Provenance

The new compiler modules follow the pinned upstream semantics. The standard
library and native runtime/effects retain upstream source and licenses. The
native runtime is not claimed to have been rewritten in Bend. See `NOTICE`,
`UPSTREAM-LICENSE`, and `src/runtime/native/ORIGIN.md`.
