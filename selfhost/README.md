# Bend2 compiler port in Bend2

Use the [compiler guide](../docs/BEND-IN-BEND.md) and
[Phase39 report](../implementation/phase39/README.md). **Phase39 checked05 is
installed; release verification and all 42 ordinary/relocated CLI checks pass.**
The [release record](../implementation/phase39/release-05.md) preserves the
successful same-tool retry and its earlier sandbox failure. The
[final closure](../implementation/phase39/final-conformance/gates.md) accepts
all 15 postinstallation audit groups and verifies all 227 canonical/frozen source
pairs. The [manifest](dist/release.json) identifies the image:
API `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
Ordinary compilation executes Bend code without a TypeScript fallback. This is
a checked B1 derivative, not a new self-emitted fixed point.

Phase39 keeps the **45-point / 23-source** catalog and measures fresh Phase37
checked03 and pinned TypeScript baselines. All points pass in **669 primary
samples**, with **60 separate confirmation samples**. Expression points improve
**4.461× / 8.052×**, tree points **1.761–2.252×**, active-ray points **2.617–2.867×**,
and numeric recurrence **1.068× / 1.221×**. The
[execution table](../implementation/phase39/execution/report.md) preserves exact
per-point ratios, ranges, paired outcomes and internal drift. These are scoped
results, not average program speed or TypeScript parity.

**23/45 points execute identical baseline/candidate module bytes**; their timing
changes are controls, not compiler effects. The changed generic-row module is
slower in every primary and confirmation pairing (+0.966% / +1.656% median time).
Tree compilation costs **3.50%** more by request medians; normal checked requests
remain **5.05–5.98× TypeScript** on three selected sources. The
[admission](../implementation/phase39/performance-admission.md),
[compiler-cost study](../implementation/phase39/compiler-cost.md) and
[42 diagnostic captures](../implementation/phase39/profile-findings.md) keep
these costs and measurement boundaries separate.

The compiler carries an unobservable private Nat countdown in a Number, shares
a proved scalar root's guard scope, and adds explicit frames for eligible
two-child data traversal and unary data production. It retains tagged values,
sharing, ordered argument evaluation and public fallback. Complete graph proofs,
exact entry, host/dependency guards and reentry cleanup still apply. No callback
specialization or fusion is installed. Read the
[backend rules](../implementation/phase39/backend-rules.md) and
[new-owner controls](../implementation/phase39/new-owner-gates.md) before extending
these paths. Source contains **18,722 physical / 16,031 nonblank Bend lines in
70 modules**, 2,087 definitions, 640 laws and 71 types. This adds 364 physical
lines (1.98%) and 42 definitions to Phase37; runtime, modules, types and laws stay
unchanged. It is a performance tradeoff, not simplification.

Final frontend observations agree exactly on **3,026 main + 196 broader results**;
the backend pilot retains **69 pass / 8 not applicable / 4 shared failures**.
All 154 expanded correctness observations and the separate 15 Phase35, seven
Phase36, three Phase37 and four Phase39 owner groups pass on this image.
[Integration](../implementation/phase39/integration.md) and
[conformance](CONFORMANCE.md) distinguish their overlapping scopes. Full
backend/GPU and independent proof validity remain unestablished; `--verdict`
is unsupported. Previous [Phase37 results](../implementation/phase37/README.md)
and its [release](../implementation/phase37/release-03.md) are historical evidence
with their original denominator, not validation of the current image.

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
The portable [Phase39 execution suite](tools/performance/phase39/README.md) offers
20/60/300/600-second ceilings and independent case selection. It reuses checked
modules from the current compiler and Phase37/TypeScript reference without a
compiler rebuild or historical build directories. Complete coverage uses bounded
chunks; a ceiling is not a promise that all 45 points finish in one run. Separate
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
