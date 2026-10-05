# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md),
[Phase52 report](../implementation/phase52/README.md), and
[direct JavaScript guide](docs/direct-javascript.md).
**Direct06 is installed; integrity verification and all 42 legacy plus 18 direct
ordinary/relocated CLI checks pass.** The [release manifest](dist/release.json) identifies the checked B1
compiler. Ordinary compilation runs Bend code without a TypeScript fallback.

The new `--direct-js` mode emits lexical functions, native closures and native
data layouts. It includes self/mutual tail loops, erased/partial calls, program
output, IO and foreign JavaScript. The original mutable-descriptor backend stays
the default compatibility mode; its [IR guide](docs/JAVASCRIPT_IR.md) and
[Phase51 runtime guide](../docs/self_hosted/v8-guided-runtime.md) remain applicable.

The [full 45-point / 23-source comparison](../implementation/phase52/results.md)
passes all 669 fresh samples and improves **2.631× → 1.124× TypeScript time**,
a **2.34× speedup**. Equal-source weighting gives 1.129× TypeScript. Twenty-nine
points are within 10%; seven regress against Phase51. The
[all-point chart](../implementation/phase52/ratios.svg) includes every point.
Historical ratios from other runs are not the denominator.

[Conformance](CONFORMANCE.md) keeps distinct scopes: the direct 26-row JS census
and all eight maintained compatibility suites pass; independent direct semantics
pass **95/96** scenarios across 29 checked fixtures. One NaN-payload fixture fails
its source oracle in both pinned TypeScript and direct output, differently.
Direct mode has explicit analysis bounds, including 512 selected definitions in
call analysis. Full language/host-hook conformance, a new self-emitted fixed point
and compiler-throughput parity are not established. The pin remains
`018751270e800bc222a93dad7f257083ee53a5f7`, after Bend 2.0.34.

The source now has **25,790 physical / 21,235 code Bend lines, 2,957 definitions,
95 types and 101 modules**. The new backend adds 1,746 code lines in nine modules;
all 92 original modules are byte-identical. See
[accounting](../implementation/phase52/accounting.md) for runtimes, host tools and
generated artifacts separately. Retaining compatibility grows source by 9.0%.

```sh
# From selfhost/, with Node.js 24 or newer:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --direct-js --run
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
```

The [benchmark guide](tools/performance/phase52/README.md) documents fresh checked
acquisition, fast screens and three serial full batches. CPU/allocation/V8
[diagnostics](tools/performance/programs/DIAGNOSTICS.md) remain separate from clean
timing. A checked build is about 59 seconds; an eight-point build/emission/timing
iteration used about three minutes of target work. Full45 takes about 22 minutes
including acquisition. Compiler throughput was not newly measured.

The [remaining work](../implementation/phase52/remaining-work.md),
[architecture survey](../docs/self_hosted/README.md),
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
