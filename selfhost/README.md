# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md) and the
[Phase43 release report](../implementation/phase43/README.md).
**[Phase43 checked14 is installed](../implementation/phase43/README.md).**
Release verification, all 42 ordinary/relocated CLI checks, the 15-group postinstall
audit and 227 canonical source bindings pass. All 34 selected mechanism owners and
the 41-group composite postinstall closure pass. The [release manifest](dist/release.json)
identifies API `222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb`.
Phase42 checked16 is the retained comparison baseline. The
[portable current bundle](tools/performance/phase43/current/manifest.json) is complete:
all 45 points were frozen and reopened byte-exact. Portable smoke replays and evidence
archive closure pass.

The release's [final results](../implementation/phase43/results.md) pass all
45 points and 669 fresh role samples over 23 sources. The point-weighted geometric
slowdown falls from 8.875959× to 6.161075× pinned TypeScript time, a 1.44065× gain
over a fresh Phase42 baseline. Medians improve on 25 points and regress on 20;
two beat TypeScript. This maintained regression corpus informed optimization;
it does not establish universal parity or independent untouched holdout coverage.

The maintained compiler graph grows by 1,384 lines and 164 definitions to
21,440 lines, 2,413 definitions and 70 modules. Normal checked-library request
medians increase about 21.1% for tree, 14.0% for list and 8.7% for local-pair;
numeric changes about 0.8%. Separate full-source acquisition shows Map compilation
rising 4.105× (2.302s→9.450s), its module growing 2.216×, and lexer compilation
costing 1.715×. These request/acquisition measures do not establish universal
compiler throughput or isolate emission cost. The
[report](../implementation/phase43/README.md) retains source and compiler-cost
tradeoffs alongside generated execution gains.

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

```sh
# From selfhost/, with Node.js 24 or newer:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
npm run build
```

Use the [checked workflow](../docs/PHASE5_DEVELOPMENT.md) for compiler edits and
the [portable Phase43 suite](tools/performance/phase43/README.md) for generated
execution comparisons against retained Phase42 and pinned TypeScript. Its 45-point
catalog supports 20/60/300-second selections and three serial 600-second batches;
a ceiling does not promise coverage. The current bundle contains all 45 verified
points; compact20, full-fast60 and targeted60 smoke replays pass.
Separate [diagnostics](tools/performance/programs/DIAGNOSTICS.md) provide CPU and
sampled allocation profiles plus JavaScript analysis. Heavy jobs run serially with
explicit memory and deadline bounds. Compiler-request cost and generated execution
remain separate evidence.

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
