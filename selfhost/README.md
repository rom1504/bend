# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md) and
[Phase37 report](../implementation/phase37/README.md). **Phase37 checked03 is
installed; release verification and all 42 ordinary/relocated CLI checks pass.**
The [gate closure](../implementation/phase37/final-conformance/gates.md) closes
15 postinstallation audit groups and verifies 227 canonical source files;
the [release record](../implementation/phase37/release-03.md) binds installation.
The [manifest](dist/release.json) identifies the installed image. Ordinary
compilation executes the Bend implementation without a TypeScript fallback.
The selected compiler is a checked B1 derivative, not a new self-emitted fixed
point; earlier releases retain their own evidence.

The expanded benchmark contains **45 points across 23 source files**, with
varied inputs, eight new application families and three held-out families.
All final outputs pass in **669 samples**, using four bounded runs totaling
**1,056.32 seconds**. Against fresh same-run Phase36 output, numeric recurrence
improves **2.674× / 5.165×** and the three tree points improve **1.165–1.270×**.
The larger active-ray and list points instead slow about **3.6% and 4.7%**.
BST 64, expression 128 and record aggregation 64 slow in all five paired rounds,
with median paired penalties of 3.85%, 3.00% and 3.44%. The
[execution table](../implementation/phase37/execution/report.md) and
[holdout findings](../implementation/phase37/holdout-findings.md) preserve these
costs, ranges and drift. Remaining TypeScript gaps include 152–209× on BST;
these workloads do not establish average application speed or broad parity.

The new finite selectors reuse the original typed match prefix, complete pure
source graph and materialized private values. Original tagged storage, sharing,
public entries and generic fallback remain. A shared exact `F32.to_u32` helper
removes generic native dispatch within existing guarded regions. Additional
DataView checks preserve host mutations and callbacks. The first ray candidate
was rejected because 1,968 extra tiny scopes cost more than their selectors
saved; new scopes now require a selector touching non-scalar data.

[Normal checked-library cost](../implementation/phase37/compiler-cost.md)
increases **2.47% local, 6.40% tree and 1.06% numeric** in request medians, with
consistent increases on the first two sources. Those measurements remain
separate from generated-program execution. Source contains **18,358 physical /
15,709 nonblank Bend lines in 70 modules**, with 2,045 definitions, 640 laws and
71 types. This adds 184 physical lines (1.01%); it is not a source-reduction
result. The [admission record](../implementation/phase37/performance-admission.md)
records the performance and complexity tradeoffs.

Fresh selected-candidate controls pass all **154 expanded correctness executions**
and the three new [optimizer owner groups](../implementation/phase37/optimizer/final-scope-owner-report.md):
exact native cast, shared DataView guard and finite selectors. All fifteen
inherited Phase35 groups and seven Phase36 groups also pass on this API, with
separate owner closures. Fresh frontend execution agrees exactly on **3,026
main + 196 broader observations**; the backend pilot retains **69 pass / 8 not
applicable / 4 shared failures** in the
[final closure](../implementation/phase37/final-conformance/gates.md).
[Conformance](CONFORMANCE.md) distinguishes their scopes and historical results.
Full backend/GPU and independent proof validity remain unestablished;
`--verdict` is unsupported.

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
The [execution suite](tools/performance/programs/README.md) offers 20/60/300/600-second
ceilings and independent case selection; the
[expanded catalog guide](tools/performance/phase37/README.md) uses the new
Phase36/TypeScript reference in bounded chunks. Separate
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
They are not alternate defaults. The installed Phase37 image passes its own
[42 ordinary/relocated CLI checks](../implementation/phase37/release-03.md),
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
