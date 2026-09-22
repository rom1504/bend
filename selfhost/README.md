# Bend2 compiler port in Bend2

See the [repository compiler guide](../docs/BEND-IN-BEND.md) for building, running
and validating this port. The [fast conformance guide](../docs/PHASE2_DEVELOPMENT.md)
and [phase 2 implementation report](../implementation/phase2/report.md) describe
the current development workflow, measured performance and validation. Historical
results below apply to their recorded artifacts; phase 2 does not replace the
default distributed compiler.

The [phase 3 efficiency guide](../docs/PHASE3_DEVELOPMENT.md) covers persistent
parse/check workers, reusable native builds and generated-program runtime probes;
the [phase 3 report](../implementation/phase3/report.md) records their evidence.
The [phase 4 development guide](../docs/PHASE4_DEVELOPMENT.md) documents checked
source overlays, bounded profiling and the current structural optimization work;
the [phase 4 report](../implementation/phase4/report.md) separates results from
experimental artifacts.

This project targets Bend2 2.0.21 at upstream revision
[`6018e28ecc67cf1fffc0c20c64b11023474c2df8`](https://github.com/bendlang/bend/tree/6018e28ecc67cf1fffc0c20c64b11023474c2df8).
It contains a modular typed compiler written in Bend2, plus the earlier
self-hosting surface compiler used as a regression baseline.

**The typed port is under compatibility validation. Do not treat its presence
as a claim of full upstream equivalence or use its checker as a trusted proof
verifier.** The reports distinguish implemented components, measured passes,
incorrect behavior, and targets that have not been tested on hardware.

The recorded full run covers all 1,378 upstream fixtures. All 919 positive
programs parse and check; every eligible positive interpreter, JavaScript and
native CPU probe either matches its expected result or its exact upstream
output exemption. Negative compatibility still includes diagnostic rendering,
different rejection phases/rules, and unproven intended-rule coverage. See the
[compatibility matrix](docs/COMPATIBILITY-MATRIX.md) and
[negative-test audit](docs/NEGATIVE-COMPATIBILITY.md).
The typed compiler also passed a complete checked, byte-identical self-rebuild;
see [the self-hosting report](dist/selfhost/seed-verification/report.json).

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

Set `BEND_UPSTREAM` to a checkout at the exact pinned revision. Bootstrap uses
the upstream compiler once to type-check and build the port's API:

```sh
git clone https://github.com/bendlang/bend.git /absolute/path/to/bend
git -C /absolute/path/to/bend checkout 6018e28ecc67cf1fffc0c20c64b11023474c2df8
BEND_UPSTREAM=/absolute/path/to/bend node tools/typed-driver.mjs --bootstrap
BEND_UPSTREAM=/absolute/path/to/bend node tools/verify.mjs
```

The supplied API can be exercised without that checkout:

```sh
npm test
node tools/smoke.mjs --native
npm run test:runtime
npm run test:harness
npm run test:abi
```

Component verification checks the complete assembled source and exercises the
kernel, normalization, specialization, annotation, readback, runtime ABI and
conformance harness. It is a separate gate from self-hosting and full-suite
compatibility. The generated report is `dist/component-report.json`.

Verify the included self-emitted compiler directly against its own source:

```sh
BEND_TYPED_RUNTIME=dist/selfhost/seed-verification/runtime.mjs \
BEND_SELFHOST_SEED_REPORT=dist/selfhost/seed-verification/seed-provenance.json \
BEND_SELFHOST_HEAP_MB=12288 BEND_SELFHOST_TIMEOUT=10800000 \
  node tools/conformance/verify-seed.mjs \
  dist/selfhost/seed-verification/compiler.bend \
  dist/selfhost/seed-verification/seed.mjs build/selfhost-recheck
```

This runs the generated compiler's parser, checker, annotation and emitter on
the complete source and requires its output to equal the seed byte for byte.
The condition is `B = H(B, S)`; the seed's original host and the current host are
recorded separately. [The direct verification report](dist/selfhost/seed-verification/report.json)
records a **successful byte-identical self-rebuild**, completed in 49 minutes
on 2026-09-21. The seed and rebuilt compiler both have SHA-256
`68585dc2852d8364b3ead69ea26b1e6c5a05809eeab7325206d18e06e8124418`.
[Earlier failed attempts](dist/selfhost/release/report.json) remain available.
This establishes self-reproduction of the typed compiler; full upstream
compatibility is a separate question covered by the conformance reports.
Generated foreign-function metadata includes canonical source paths, so direct
comparison with an archived seed requires the original path layout. After moving
the checkout, generate a local seed and compare its self-emission instead:

```sh
BEND_TYPED_API=dist/typed-api.mjs BEND_SELFHOST_HEAP_MB=12288 \
BEND_SELFHOST_TIMEOUT=10800000 node tools/conformance/selfhost.mjs \
  dist/selfhost/seed-verification/compiler.bend build/local-selfhost-recheck
```
The self-hosting runner uses an explicit 4 MB JavaScript stack for the large
compiler book; the host must provide a larger native stack (8 MB in the recorded
Linux run). The command also allows a 12 GB Node heap. Earlier eager ABI copies
exhausted both the default heap and a 12 GB heap; the current host uses a
[tested lazy ABI adapter](docs/COMPILER-ABI.md) to pass compiler graphs between
phases without copying them. These resource settings do not skip any
parsing, checking, annotation or emission phase. See the
[resource measurements and reproduction test](docs/SELFHOST-RESOURCES.md).

The self-emitted compiler is also included and can run ordinary programs:

```sh
BEND_TYPED_API=dist/selfhost/seed-verification/seed.mjs node --stack-size=4096 \
  cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
```

Its separate [end-to-end smoke report](dist/selfhost-smoke.json) covers checking,
interpretation, JavaScript, native C and invalid-type rejection. Full-corpus
reports identify which compiler artifact they exercised.
The [relocated lazy-adapter smoke](dist/lazy-selfhost-distribution-smoke.json)
also exercises all five routes with upstream and original-project filesystem
access blocked, using a fresh Base cache.

The conformance runner inventories every pinned upstream test and isolates each
probe with a timeout. It does not count a syntax rejection as a correct type
rejection, and GPU execution needs explicit hardware evidence.

```sh
node tools/conformance/run.mjs --upstream /absolute/path/to/bend \
  --adapter tools/conformance/adapters/typed.mjs \
  --output tests/conformance/typed-current.json
```

See [the conformance protocol](tools/conformance/README.md) and the JSON reports
under `tests/conformance/`. Reports identify the exact API/runtime hashes they
tested; an older snapshot's result does not establish coverage of a newer one.

To create a distribution with the generated compiler, sources, licenses and
completed validation reports, run `python3 tools/package.py`. Its archive manifest
records the SHA-256 of each file; build caches and partial progress logs are excluded.

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
