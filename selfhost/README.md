# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md),
[Phase45 report](../implementation/phase45/README.md) and
[JavaScript IR architecture](docs/JAVASCRIPT_IR.md).
The [source-based architecture survey](../docs/self_hosted/README.md) includes
the current optimization inventory, prior-work audit and parallelization plan;
[remaining opportunities](../docs/remaining_opportunities/README.md) compares
these with seven compiler implementations and ranks proposed next work.
**Phase45 worker23 is installed; release verification and all 42 CLI checks pass.**
The [release manifest](dist/release.json) and
[selected evidence](tools/performance/phase45/evidence/selected-qualification.json)
identify this checked B1 derivative.

The general private backend lowers proved first-order graphs to explicit calls,
cases, projections and returns. It partitions recursive components, emits direct
acyclic functions, keeps tail calls in scalar loops and uses bounded native
recursion with the same continuation machine at exhaustion. Private tagged
fields, exact Number Nats and native constructors reduce allocation. Complete
dependency, representation and host proofs preserve ordinary public fallback;
unsupported graphs retain the existing implementation.

Fresh qualification agrees on 3,026 main and 196 broader frontend observations
and all 81 retained backend observations. Eight maintained suites, independent
composition controls, seven freshly acquired mechanism families and separate
nullary, Unit and exact-entry host observations pass. Their scopes overlap;
[conformance](CONFORMANCE.md) preserves shared failures and limits.
The source graph contains **23,007 physical / 18,983 code Bend lines, 2,594
definitions, 87 types and 85 modules**: 1,194 more physical lines than Phase44.
These manifest-listed source counts exclude runtimes, generated images and tools;
declaration counts are syntactic proxies, not a measure of conceptual complexity.

The [full execution results](../implementation/phase45/results.md),
[compiler costs](../implementation/phase45/compiler-cost.md) and
[diagnostics](tools/performance/phase45/evidence/diagnostics.json) are separate evidence.
The 45-point / 23-source comparison measures **3.0787× TypeScript time**
with equal-point weighting and **4.1467×** with equal-source weighting.
Across four fresh compiler-cost probes, request medians increase 1.20–28.55% over Phase44. These finite measurements do not establish typical
program speed or universal parity; the corpus informed optimization and is not
an untouched holdout. Compiler request cost and generated execution are separate
measurements.

Ordinary compilation executes the Bend implementation without a TypeScript
fallback. The target remains upstream
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/bendlang/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7),
after Bend 2.0.34. This is a checked B1 derivative, not a new self-emitted fixed
point. Full backend/GPU execution and independent proof validity remain
unestablished; `--verdict` is unsupported.

```sh
# From selfhost/, with Node.js 24 or newer:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
npm run build
```

Use the [checked workflow](../docs/PHASE5_DEVELOPMENT.md) for compiler edits and
the [portable Phase45 suite](tools/performance/phase45/README.md) to compare
selected outputs against Phase44 and pinned TypeScript. Its
[current bundle](tools/performance/phase45/current/manifest.json) retains the
45-point / 23-source corpus, with case coverage independent of 20/60/300-second
ceilings and three serial 600-second full batches. Separate
[diagnostics](tools/performance/programs/DIAGNOSTICS.md) provide CPU/allocation
profiles and generated-JavaScript comparisons. Profiled durations are not timing
ratios. Heavy jobs run serially with explicit memory and deadline bounds.

Historical [Phase44](../implementation/phase44/README.md) and earlier reports
retain their own baselines and validation scopes. The
[ledger](../experiments/ledger.md), [strategy](../experiments/STEERING.md) and
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
