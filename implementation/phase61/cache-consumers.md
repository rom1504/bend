# Cache-format consumer audit

Read-only audit, before framed-cache performance qualification. Maintained driver
application is owned by root; historical tools/receipts are unchanged.

| Consumer | Assumption | Minimal successor |
| --- | --- | --- |
| `tools/typed-driver.mjs:readBaseCache/prepareBase` | One JSON object, canonical tree digest, old filename | Proposed inline frame codec; public object validators stay exact |
| `tools/development/workflow.mjs:validatedCache` | Hard-coded old filename; parses whole file; canonical digest | Select the explicitly supported namespace and use reviewed decoder for framed bytes; preserve identities, span metadata and digest obligations |
| `tools/private-compiler/tests/batch-compare.mjs:39` | Parses every cache file as one JSON object | Preserve protected/historical source; use a narrow private successor if needed |
| Frozen Phase61 `latency-method02/setup.mjs:verifyFinal` | Parses every staged cache file as JSON and canonical rehashes the book | New method03 setup uses decoder for framed namespace, unchanged metadata/oracle/input checks; method02 immutable |

The Phase61 latency worker binds and rehashes raw cache files but does not decode
books, so its timing/observation path needs no cache parsing change. Old historical
performance tools also contain fixed names/readers; they stay reproducible with
copied old drivers and old formats and must not be silently rebound to this draft.

A minimal exported `decodeBaseCacheFrame(bytes)` in the driver is sufficient for
new async setup consumers. Importing the whole driver into synchronous workflow
validation has initialization/dependency implications and deserves a separate
review; do not solve it by broadly accepting unverified JSON or dropping digests.
No consumer updates are claimed complete. Establish a controlled useful win first.

Existing persistent memo deep-freezes only `cached.book`, then shallow-freezes its
metadata wrapper. Any optional checked-publication state needs its own recursive
freeze before memo permission is stored. A source cache `validatedBy` field is not
proof of a checked state; the state owner must provide explicit generation/binding
and fail-closed admission, with normal checker fallback when absent.

## Canonical workflow successor (prepared, not applied)

`selfhost/tools/performance/phase61/cache/workflow-sync01/workflow.patch`
keeps `validatedCache` synchronous, including the existing literal preflight and
development-test callers. It imports the maintained driver's synchronous
`decodeBaseCacheFrame`, avoiding a second frame implementation or a new snapshot
helper. Import initializes driver paths and reads its compiler manifest, but does
not load an API, prepare a cache, or run the CLI. The decoder itself ignores those
configured paths. Existing snapshots already contain its transitive imports.

The new namespace is checked first; a present malformed frame refuses rather than
falling through to an older artifact. Framed bytes require exact payload digest
before parsing plus the existing API/Base/path/span/check_book metadata gates;
legacy bytes retain their canonical book digest and version policy. The function
still returns the cache file identity. Optional states remain the driver's concern;
workflow validation does not grant checkpoint permission.

Root must wait until all attempts pinning the old global workflow finish before
applying this patch. Then re-snapshot/rebind the selected driver and workflow,
exercise synchronous preflight/development checks and a genuine checked build,
and verify actual bootstrap81 exports plus cache state admission. Consumed private
workflow-frame01, latency methods and prior receipts remain immutable. Protected
batch-compare readers require a private successor rather than edits. No application
or execution of this canonical proposal is claimed here.

## Current exact consumer readiness (after host controls09)

[Inventory pins](../../selfhost/tools/performance/phase61/cache/workflow-sync02/consumer-inventory01.json)
bind the current maintained callers and tests. The complete proposed canonical
change is only `tools/development/workflow.mjs`; its synchronous return shape and
internal `validateAttempt` call remain intact. `tests/conformance/development.test.mjs`
lines63–65 exercise legacy version2 success and API/path/book/producer refusal;
those expectations remain valid. `tests/phase9-literals/full-source-preflight.mjs`
line10 synchronously consumes `.file`, so it needs no caller change.

The prepared `workflow-sync02` patch additionally handles frame2 and frame1 via
one exact driver decoder and keeps the legacy namespace/object digest path.
Its driver import's manifest read is the sole added initialization IO; configured
BEND_BASE/API constants are not used by the decoder. It performs no compiler/API
request or preparation. Snapshot dependency lists already include all imports.
The patch remains unapplied while root's measured methods pin the old workflow.

`tools/private-compiler/tests/batch-compare.mjs` line39 is the other actual disk
JSON parser/canonical-digest reader. It is protected historical source: unchanged.
A regenerated current-format private image needs a separately pinned successor
that imports its own copied driver decoder for explicit frame suffixes and keeps
all API/Base/path/check_book/identity obligations. Historical images keep their
old copied driver/JSON format; do not reinterpret their receipts.

Private session/worker audit cache reads as filesystem events without decoding;
CLI validation inventories cache file identities only. `tests/diagnostic-reuse.mjs`
uses `prepareBase`'s returned object and records metadata, not disk JSON, so these
consumers need no wire-format change. Private workflow/frame and latency setup
successors already cover selected frame namespaces; consumed predecessors remain
immutable.

After winner selection, root can apply the exact workflow patch, run the existing
`node --test selfhost/tests/conformance/development.test.mjs` suite under its guard,
then generate a genuine new snapshot/build and run the literal preflight against
that attempt. Actual decoder corruption/state/refusal coverage is the57 passing
host groups in controls09. No test execution is claimed by this readiness audit.
