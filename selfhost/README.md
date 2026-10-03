# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md) and
[Phase40 report](../implementation/phase40/README.md). **Phase40 checked06 is
installed; release verification and all 42 ordinary/relocated CLI checks pass.**
The [release record](../implementation/phase40/release-06.md) and
[final integration](../implementation/phase40/integration.md) retain the evidence:
all **15 postinstallation audit groups and 227 canonical/frozen source pairs**
pass. The [manifest](dist/release.json) identifies API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`.
Ordinary compilation executes Bend code without a TypeScript fallback. This is
a checked B1 derivative, not a new self-emitted fixed point.

[Execution evidence](../implementation/phase40/execution/report.md) covers
**45 points / 23 sources**, selecting **42 complete checked05 measurements by
exact checked06 module identity and three fresh checked06 ray measurements**.
The reused measurements retain their original same-run baseline and TypeScript
rotations. Relative to starting Phase39, list points improve **9.97–13.11×** and
tree points **1.83–2.18×**; they remain **4.51–6.52×** and **17.15–21.54×** slower
than TypeScript respectively. Protocols, ranges, paired outcomes and drift remain
per point. This is selected evidence, not a fresh full checked06 timing run or
an average program-speed claim.

[Compiler-request cost](../implementation/phase40/compiler-cost.md) rises
**24.45% for tree** and **19.09% for list**, with requests **4.66–8.37× TypeScript**
on four measured sources. The [admission decision](../implementation/phase40/performance-admission.md)
and [profiles](../implementation/phase40/profile-findings.md) retain these tradeoffs
and separate compilation from generated-program execution.

Phase40 adds guarded list workers and broader structural traversal. Exact entry,
complete graph proofs, host/dependency guards, proof cleanup, evaluation order,
sharing and public fallback remain covered by actual compiler-output controls.
Lexer speedups remain manual experiments. Source contains **18,863 physical /
16,156 nonblank Bend lines in 70 modules**, 2,104 definitions, 640 laws and
71 types: **141 physical lines and 17 definitions more than Phase39**. Runtime,
modules, types and laws remain unchanged. This is a performance tradeoff, not
simplification.

Frontend observations agree exactly on **3,026 main + 196 broader results**;
the backend pilot retains **69 pass / 8 not applicable / 4 shared failures**.
[Integration](../implementation/phase40/integration.md) and
[conformance](CONFORMANCE.md) distinguish their overlapping scopes. Full
backend/GPU and independent proof validity remain unestablished; `--verdict`
is unsupported. Earlier [Phase39 results](../implementation/phase39/README.md)
retain their original baseline and validation scope.

The target remains upstream
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/bendlang/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7),
after Bend 2.0.34.

```sh
# From selfhost/, with Node.js 24 or newer:
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
npm run build
```

Use the [checked workflow](../docs/PHASE5_DEVELOPMENT.md) for compiler edits.
The portable [Phase40 execution suite](tools/performance/phase40/README.md) offers
20/60/300/600-second ceilings and independent case selection. Its current bundle
preserves **45 points in 1,336,751 bytes**, alongside the starting Phase39 and
pinned TypeScript reference. The five-point smoke passes all **45 samples** with
**20.36 seconds** reported wall using the 20-second preset. Complete coverage
uses bounded chunks; a ceiling is
not a promise that all 45 points finish in one run. Separate
[diagnostics](tools/performance/programs/DIAGNOSTICS.md) add profiles and JavaScript
analysis. Heavy jobs run serially with explicit heaps, RSS/deadline bounds and a
free-memory floor.

The [ledger](../experiments/ledger.md), [strategy](../experiments/STEERING.md) and
[preservation index](../experiments/PRESERVATION.md) retain failures and decisions.
The [performance guide](../docs/BEND-IN-BEND-PERFORMANCE.md) explains the admitted
representations and fallback boundaries.

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
They are not alternate defaults. The installed Phase39 image passes its own
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
