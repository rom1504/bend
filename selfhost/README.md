# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md),
[Phase44 report](../implementation/phase44/README.md) and
[JavaScript IR architecture](docs/JAVASCRIPT_IR.md).
**Phase44 checked04 is installed; release verification and all 42 CLI checks pass.** The
[release manifest](dist/release.json) identifies the installed artifact.

The selected compiler introduces a runtime IR with separate lowering, lexical
facts, general transformations and emission. Its ordinary code uses copy
propagation, exact identity-binding elimination, literal U32 folding and lexical
statement emission. Fifteen replaced helpers were removed; private layouts and
source-dependent guarded call selection remain explicit migration boundaries.

Fresh qualification agrees on 3,026 main and 196 broader frontend observations
and all 81 retained backend observations. Eight maintained semantic suites and
independent feature-composition controls pass. The
[conformance record](CONFORMANCE.md) retains the shared failures and scope limits.
The source graph contains 21,813 physical Bend lines, 2,452 definitions and
78 modules, a net increase of 373 lines for this architectural change.

The [full execution results](../implementation/phase44/results.md) and
[compiler costs](../implementation/phase44/compiler-cost.md) are separate evidence.
Map compiler request time improves 15.61%; the other three measured request
medians regress 2.81–3.57%. The full 45-point runtime comparison is effectively flat: 6.1214× → 6.0832×
TypeScript time. The known-call prototype is rejected. These are finite
measurements, not universal performance or independent untouched holdout coverage.

Ordinary compilation executes the Bend implementation without a TypeScript
fallback. The target remains upstream
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/bendlang/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7),
after Bend 2.0.34. This is a checked B1 derivative, not a new self-emitted fixed
point. Full backend/GPU execution and independent proof validity remain
unestablished; `--verdict` is unsupported. See [conformance](CONFORMANCE.md) for
retained shared failures and unavailable platforms.

The [complete-operation architecture](../docs/PHASE43_DIRECT_EXECUTION.md) explains
lexical contextual Map calls, callback construction/application fusion, bounded
Number counters with original BigInt fallback, private pair state and exact source
proofs. The [Phase42 architecture](../docs/PHASE42_GENERATED_JS.md) retains earlier
owned layouts, List fusion, structural fallback and request-local facts. Public data, host mutation, evaluation order,
sharing and generic fallback remain explicit proof boundaries.

The [JavaScript IR architecture](docs/JAVASCRIPT_IR.md) documents the modular
runtime representation, composable passes, semantic contracts and remaining
compatibility boundaries introduced during Phase44 development.

```sh
# From selfhost/, with Node.js 24 or newer:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
npm run build
```

Use the [checked workflow](../docs/PHASE5_DEVELOPMENT.md) for compiler edits and
the [portable Phase44 suite](tools/performance/phase44/README.md) for generated
execution comparisons against retained Phase43 and pinned TypeScript. Its
45-point catalog supports 20/60/300-second selections and three serial 600-second
batches; a ceiling does not promise coverage. The
[current bundle](tools/performance/phase44/current/manifest.json) contains all
45 verified points. Separate [diagnostics](tools/performance/programs/DIAGNOSTICS.md)
provide CPU and sampled allocation profiles plus JavaScript analysis. Heavy jobs
run serially with explicit memory and deadline bounds. Compiler request costs and
generated execution remain separate evidence.

Historical [Phase40](../implementation/phase40/README.md) and
[Phase39](../implementation/phase39/README.md) results retain their original
baselines and validation scopes. The [ledger](../experiments/ledger.md),
[strategy](../experiments/STEERING.md) and
[preservation index](../experiments/PRESERVATION.md) retain failures and decisions.

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

Full self-reproduction is a separate integration gate using a genuine checked
parent. Follow [the current reproduction instructions](../docs/BEND-IN-BEND.md#full-self-reproduction-and-component-checks)
and [final Phase 5 proof](../implementation/phase5/final-selfhost.md). A derived
API must not acquire a bootstrap sidecar. Low-level bootstrap commands need an
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
