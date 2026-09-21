# The Bend compiler written in Bend

The compiler port lives in [`selfhost/`](../selfhost/README.md) on the
`selfhost/bootstrap` branch. Its frontend, dependent checker, specializer,
normalizer, interpreter and JavaScript/native emitters are Bend modules.
JavaScript supplies filesystem/process orchestration, a primitive runtime, and
an adapter for the compiler's public data representation. Ordinary compilation
does not invoke the TypeScript compiler.

The language and Base library are pinned to upstream
`6018e28ecc67cf1fffc0c20c64b11023474c2df8` (Bend 2.0.21). This is an experimental
compiler under compatibility validation. Successful positive fixtures and
self-hosting do not establish full diagnostic or proof-checker equivalence.
Read the [validation boundaries](../selfhost/CONFORMANCE.md) and
[negative audit](../selfhost/docs/NEGATIVE-COMPATIBILITY.md) before relying on it.

## Run a compiler artifact

Use Node.js 24 or newer. From `selfhost/`:

```sh
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --check-only
node cli.mjs tests/conformance/typed-smoke/base-u32.bend -o program.mjs
node program.mjs
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --cpu --run
```

The native CPU lane requires Clang 14 or newer; `CC` can select it. GPU execution
requires the appropriate SDK and hardware and has separate validation gates.
The JavaScript backend requires neither Clang nor GPU tools.

`BEND_TYPED_API=/absolute/compiler.mjs` selects an explicit compiler artifact.
`BEND_BASE=/absolute/base.bend` selects Base. `BEND_TYPED_RUNTIME` supplies runtime
text for generated JavaScript; it does **not** replace the runtime embedded in an
already generated compiler. Change a compiler by rebuilding it, not by pointing
an old API at newly edited Bend source.

## Phase 1 candidate

The phase 1 compiler artifacts are published separately under
[`selfhost/dist/phase1/`](../selfhost/dist/phase1/). The default
`dist/typed-api.mjs` retains the supplied baseline compiler while the candidate's
remaining performance and conformance gates are open. The host supports both
artifact generations; ordinary commands never silently rebuild an API.

From `selfhost/`, select the new bootstrap API explicitly:

```sh
BEND_TYPED_API="$PWD/dist/phase1/bootstrap-api.mjs" \
  node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
```

Or exercise the compiler emitted by the Bend implementation's own JS backend:

```sh
BEND_TYPED_API="$PWD/dist/phase1/selfhost-api.mjs" \
  node --stack-size=4096 cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
```

Both artifacts execute the Bend compiler algorithms. Their difference is which
backend emitted that compiler's JavaScript: pinned upstream for the bootstrap
API, or this port for the self-emitted API. Their timings and validation evidence
must be kept separate. See the [phase 1 report](../implementation/phase1/report.md)
for exact hashes, native timeout limitations, and targets that remain unmet.

## Build and verify

`src/compiler.json` gives the ordered module list and upstream pin.
`tools/assemble.mjs` links those modules into one source file, ordering types,
laws and definitions. It does not parse user programs or implement compilation.
The pinned upstream compiler is used explicitly as the initial bootstrap tool:

```sh
BEND_UPSTREAM=/absolute/pinned/upstream \
BEND_TYPED_API="$PWD/build/candidate-api.mjs" \
  node tools/typed-driver.mjs --bootstrap
```

This writes a checked API plus the assembled source and provenance in
`build/typed/`. Keep source, API, runtime and host snapshots immutable during
validation. Generate a local self-hosting chain with:

```sh
BEND_TYPED_API="$PWD/build/candidate-api.mjs" \
BEND_SELFHOST_HEAP_MB=12288 BEND_SELFHOST_TIMEOUT=10800000 \
  node tools/conformance/selfhost.mjs \
  "$PWD/build/typed/compiler.bend" "$PWD/build/candidate-fixedpoint"
```

The runner performs two complete checked compilations. Stage 2 is emitted by the
bootstrap API; stage 3 is emitted by stage 2. Their bytes must match. The default
4 MiB JavaScript stack needs an OS stack limit of at least 8 MiB. The 12 GiB heap
ceiling is a resource limit, not a claim that every compilation needs that much
memory. Canonical paths affect foreign metadata and emitted bytes; regenerate a
local chain after relocating the checkout. A successful upstream bootstrap alone
is not evidence of self-hosting.

Run component checks with `BEND_UPSTREAM=... node tools/verify.mjs`.
`BEND_COMPONENT_REPORT=/absolute/report.json` preserves the historical report by
writing new results elsewhere. Backend and runtime tests are documented in
[`src/back/js/README.md`](../selfhost/src/back/js/README.md). Complete fixture
runs, frozen hosts, artifact identity and GPU gates are described in the
[conformance protocol](../selfhost/tools/conformance/README.md). For a self-emitted
API, pass `--stack-kb 4096 --heap-mb 4096` to the conformance runner so its isolated
workers receive the same large-book resource settings; parent Node flags alone
do not propagate to them.

## Internal boundaries and performance

The [architecture](../selfhost/docs/ARCHITECTURE.md) describes the first-order
`KTerm`/`KDef` core and component responsibilities. The phase 1 changes retain
those boundaries:

- The host hands parsed source back to the Bend loader within one invocation.
  `FSource` remains supported; `FParsedSource` carries an already parsed result.
  This is an internal trusted handoff, not a persistent unchecked AST cache.
- After specialization, `book_context` prepares one immutable exact-name index
  and binder bound. Annotation, layout validation and emission reuse that full
  context while independently selecting live definitions. Native compilation
  retains its backend-specific flow.
- The emitter preserves audited native Base string operations using the same
  classification used for reachability. Names alone never grant Base provenance.
- Proven single-constructor field accessors use a direct worker while retaining
  the generic ABI and field-vector copy. Erased fields, computed arms and
  eta-short arms retain ordinary matcher behavior.
- Pure top-level matcher wrappers are cached; arm bodies and global references
  remain delayed until application. Computed matcher-producing initializers still
  run on every reference. This does not increase application-spine arity.
- Transparent Boolean-choice calls with literal lambda thunks become JavaScript
  conditionals. Structural validation, currying, evaluation order, erased slots
  and the tail-call trampoline remain part of the contract.

The [phase 1 plan](../design/phase1/faster_bootstrap.md) records the original
hypotheses. The [implementation report](../implementation/phase1/report.md)
records actual changes, measured improvements, remaining costs and validation.
Use the [explicit-artifact harness](../selfhost/tools/performance/README.md) for
new comparisons. Benchmark a rebuilt self-emitted compiler against a frozen
control with the same input, Base, cache policy, Node flags and CPU affinity.

The `selfhost-baseline-2026-09-21` tag and original archive reports preserve the
supplied implementation. Historical conformance or fixed-point evidence applies
to its recorded artifact hashes; it is never evidence for a later compiler merely
because the source files have the same names.
