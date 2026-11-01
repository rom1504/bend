# Explicit selected-graph transport

`selected-graph.mjs` is maintained host transport for a native compiler image
that implements `BEND_GRAPH_1`. It emits the JavaScript program or library lane;
it does not discover imports, invoke TypeScript or fall back to another compiler.
The public API exports `loadNativeGraphManifest` and `runNativeGraph`.

The version1 JSON manifest explicitly names `main`, `base`, `modules` and
`assets`. Paths are relative to the manifest; modules/assets may use explicit
`{name,path}` entries. Source/runtime snapshots and bounded NUL-delimited graph
records are passed to the native compiler. Only assets reported as consumed
must exist. Duplicate identities, logical/physical collisions, unsafe output
aliases and changed protected inputs fail before publication. Successful output
uses atomic rename; failed publication preserves prior output and raw metadata.

The conformance adapter additionally requires each selected fixture and its
canonical Base/dependencies to be the pinned reference's actual paths. Equal
bytes at a different path do not authorize substitution. Missing per-fixture
manifests are unsupported. Native compilation and generated-JS execution remain
separate observations; this adapter advertises no native/GPU/check-only lane.

Transport is moved byte-for-byte from its historical implementation apart from
the executable usage label; [lineage](consolidation-lineage.json) records both
identities. The maintained [mock controls](selected-graph.test.mjs) inject the
child launcher and therefore execute no compiler.
