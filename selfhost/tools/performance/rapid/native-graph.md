# Native compiler with explicit module and foreign-asset manifests

This host executes the compiler's Bend implementation as a native CPU executable
and emits JavaScript. Parsing, graph loading, checking, specialization, annotation
and emission remain Bend code. The Node wrapper supplies filesystem identities,
source snapshots and process/output management. It does not parse imports or
invoke a JavaScript or TypeScript compiler as a fallback.

A complete, explicit manifest is required. Automatic import discovery, check-only
and interpreter modes, and native target emission are not provided by this entry.
The older main-plus-Base entry remains available through `native-bundle-run.mjs`.
A native executable emitting the compiler's JavaScript is not a native self-hosting
fixed point.

## Build a checked executable

Run from `selfhost`, using the pinned upstream checkout and a supported Clang.
Set `CC` and normal compiler include/library environment variables if Clang is
not on PATH. Choose a fresh directory and an available CPU:

```sh
node tools/performance/rapid/native-bundle-prepare.mjs . build/native-graph
node --stack-size=4096 tools/performance/rapid/native-component.mjs \
  build/native-graph/compiler.bend build/native-graph/build --js --cpu=3
node tools/performance/rapid/native-compile-c.mjs \
  build/native-graph/build/program.c build/native-graph/build/program-o1 \
  --opt=O1 --cpu=3 --timeout-ms=180000
```

The first command freezes the compiler modules, both native host modules and the
runtime. The second checks the complete Bend source, including ownership, before
emitting JavaScript and C. The third compiles that preserved C. Keep preparation,
checked-emission and C-build reports together; a successful C compilation alone
is not a Bend checking result. A timed-out optimization attempt does not require
repeating checking or C emission. Use a fresh output binary name for each retry.

## Manifest and invocation

For the existing imported-module fixture, save this as `graph.json` in `selfhost`:

```json
{
  "version": 1,
  "main": "tools/performance/rapid/native-bundle-fixtures/extra-import.bend",
  "base": ".bootstrap/upstream/bend2/base.bend",
  "modules": [
    "tools/performance/rapid/native-bundle-fixtures/extra.bend"
  ],
  "assets": []
}
```

```sh
node tools/performance/rapid/native-graph-run.mjs \
  build/native-graph/build/program-o1 graph.json \
  build/native-graph/src/runtime.mjs build/native-graph/output.mjs program \
  --cpu=3 --timeout-ms=120000
node build/native-graph/output.mjs
```

This prints `42`. Use `library` for the compiler's existing library export policy.
All JSON paths resolve relative to the manifest file. `main` and `base` are added
automatically; `modules` supplies the remaining available sources. Entries may be
path strings or `{ "name": "logical/path", "path": "physical/file" }` records.
Logical module names become absolute lexical paths. Ambiguous mappings where one
module logical name collides with a different module physical identity reject. Physical paths are resolved
with `realpath`; Bend uses them for canonical identity and source-relative imports.
The reserved Base mapping is supplied only through `base`.

`assets` lists available JavaScript files, using the same string/object forms.
Normal filenames suffice even when a foreign declaration spells `./file.js`:
lookup normalizes the requested path, but emitted bindings keep the original
qualified path. An explicit logical name takes precedence over any record whose
physical path happens to match. Physical identity is only a fallback lookup.

The manifest must cover the actual dependency graph. Missing required entries
fail explicitly. Extra source records are read as bytes but are not parsed unless
reachable. Consequently an unused malformed module has no effect. JavaScript
asset contents are read only after checking and reachability select them. A
missing unused asset is harmless; a missing required asset reports a compile
failure with `checked=true`. Repeated required logical paths are read/emitted once,
in first-occurrence order. Builtin IO remains handled by the existing runtime.

## Boundaries, timing and evidence

The wrapper validates version, record shapes and path fields. There are at most
4,096 source/asset records, 8 KiB per transport field, 16 MiB per input file and
128 MiB of source/runtime snapshots. It creates a private source snapshot and a
bounded, versioned NUL-delimited path transport. The native decoder checks record
boundaries, termination, tags, version and count/field limits. Paths containing
Unicode, spaces, quotes or newlines remain data; NUL is rejected in paths.

Both lexical identities and canonical filesystem paths are retained. Graph order,
aliases, namespace conflicts, cycles and elaboration are decided by `f_load_graph`.
All check, ownership, TODO, specialization, reachability, foreign and layout gates
remain enabled. Raw compiler errors do not include optional JS-host diagnostic
replay/location formatting. Missing manifest entries are an explicit-manifest
boundary, distinct from the JS host's discovery of an absent filesystem module.

The wrapper rejects output aliases to the binary, runtime, manifest, any module
or asset, including symlinks and hardlinks. It publishes a private temporary
output by rename only after successful compilation and input-drift checks.
Timeouts, rejection and failed writes preserve an existing destination. A post-run
drift or publication failure retains native status/timing and, when available, an
explicitly unpublished output hash in its JSON report; it is not a successful
compilation publication. The direct
binary CLI is internal; use the wrapper for this publication boundary.

The JSON result records identities and hashes, selected asset IDs, error phase,
checking status and output SHA. Source/runtime bytes are frozen and rechecked.
Asset contents are hashed only when used; before/after canonical identities and
high-resolution size/mtime/ctime metadata detect asset changes around native IO.
Unused asset metadata is retained without reading contents. `compileMs` covers
native manifest/source IO, the full pipeline, selected-asset IO and consumption
of every output/error character; output writing follows. `nativeWallMs` adds
process startup/output IO. `wallMs` also includes host preparation and provenance
checks. Compare matching scopes and record shared-host/resource conditions.

## Focused validation

```sh
node tools/performance/rapid/native-graph-run.test.mjs
node tools/performance/rapid/native-graph-api.mjs \
  build/native-graph/build build/native-graph/host-api
node --stack-size=4096 tools/performance/rapid/native-graph-wire.test.mjs \
  build/native-graph/host-api/api.mjs
```

The API exposure tool replaces only the checked program's process entry with
exports wrapped by its existing `run_lib` ABI. It leaves compiler workers intact,
allowing the existing JavaScript host to exercise exactly the same Bend source.
Its source/program/export hashes accompany differential evidence. The validator
also checks the native C-build identity and hashes the consumed host tools, Node
executable and exposed workers before and after the run.

Create a validation configuration with `binary`, `api`, `base`, `runtime`, `cpu`
and optional `timeoutMs`; paths resolve relative to that configuration. `api`
can point to the just-exposed `host-api/api.mjs`. Then run:

```sh
node tools/performance/rapid/native-graph-validate.mjs \
  validation-config.json build/native-graph/validation
```

The runner creates isolated import/foreign graphs and compares native and
uncached JavaScript-host acceptance, phase/checking status, exact emitted bytes
and execution. It retains failures and explicit scope differences. These focused
results do not assert whole-language conformance. The conformance harness's
`native-graph` adapter requires per-fixture manifests and reports unsupported
lanes instead of falling back to JavaScript compiler execution.

## Compare the actual development loop

`native-graph-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY` measures alternating
fresh-process native, uncached same-source JS, and ordinary checked JS with its
validated Base cache. Supply `binary`, exposed `api`, ordinary `cachedApi`, `base`,
`runtime`, `cpu`, `repetitions` (normally 3), and
`workloads: [{id,input,manifest,stdout}]`. Paths resolve relative to the configuration.
The report separates initial cache preparation, successful native build-phase
work, compiler time and full child-process wall time. It checks output bytes and
execution for every sample. Cached JS is a separate policy and must be included
before recommending native for batches; an uncached-only speedup does not establish
that the native path improves the normal cached development loop.

`native-graph-upstream-measure.mjs LATENCY_REPORT.json PINNED_UPSTREAM NEW_OUTPUT_DIRECTORY`
adds live TypeScript samples using the same physical inputs, CPU, Node flags and
fresh-process policy. It requires the checked native build's clean upstream pin,
checks the full upstream pipeline, and compares execution with the prior samples.
These are subsequent samples rather than an interleaved four-way experiment;
the report preserves that distinction. Upstream has no persistent Base cache.

For a full compiler-source library comparison,
`native-fullsource-upstream.mjs CONFIG.json NEW_OUTPUT_DIRECTORY` accepts
`upstream`, `input`, `base`, `nativeApi`, `nativeBuild`, `cpu`, and optional
`repetitions` (1–3) and `timeoutMs`. It copies the unchanged pinned TypeScript
modules into a private directory and symlinks Base to the specified canonical
path. Roots follow `j_library_roots`, including Base foreign definitions; they
are checked against `nativeApi`, a native-produced full compiler library. Each
sample performs full checking and library emission, then separately checks
syntax, export roots and a compiler-helper execution oracle. The report records
the changed TypeScript module location and the exact Base identity. Use the same
core and repeated samples for stronger timing claims; a single later sample
must retain that limitation.

The runner retains a read-only copy of its own consumed source and executes
workers from that copy. Outside the compile timer, the actual Bend
`j_library_roots` checks the selected root set from upstream definition metadata.
Native default exports also contain runtime globals and reachable Base helpers;
their extra names are recorded rather than misrepresented as matching the
TypeScript library's narrower default export contract.

`selfhost-cache-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY` compares the
checked B1 API, the final self-emitted H API and pinned TypeScript in rotating
fresh-process order. Supply `priorReport` (the completed two-workload native/cache
report), `selfhostReport` (the completed input-verified stage2/stage3 proof),
`upstream`, `cpu`, and optional `repetitions` and `timeoutMs`. The tool validates
the actual H stage chain instead of fabricating bootstrap provenance, primes
B1/H validated Base caches separately, and uses the same host worker for both.
It records current host sources and any changes since the earlier native sample;
those earlier native timings remain a separate experiment. H/B1 emitted bytes
must match the prior port output, and all three variants must match its execution
oracle.
