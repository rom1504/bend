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
