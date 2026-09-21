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
Logical module names become absolute lexical paths. Physical paths are resolved
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
Timeouts, rejection and failed writes preserve an existing destination. The direct
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
Its source/program/export hashes accompany differential evidence.

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
