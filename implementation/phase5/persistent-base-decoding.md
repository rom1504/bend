# P5-021 — reuse verified Base decoding inside a worker session

Status at 2026-09-23 00:38 UTC: the reviewed host is promoted after the focused
contract gates and complete frontend ABBA comparison passed. Compiler source,
generated code and the public single-request compiler interface are unchanged
by this experiment. The final combined checked build is running.

## Measured cause

Each persistent parse/check request previously decoded the same Base JSON cache,
serialized its complete book again and verified that serialization's digest.
These operations occurred even when the compiler API and cache bytes were
unchanged. The first instrumented probe used the verified equality derivative of
integration-02. In 84 measured requests, decoding took 2,617 ms and book digest
verification took 3,297 ms out of 13,397 ms total: 44.14%. Cache reads and API/Base
identity hashing remain necessary. The instrumented and control hosts produced
168 exactly matching observations. This was cost attribution, not a speedup.

## Candidate and its boundary

`createPersistentInspector` owns one compiler API and at most one decoded Base
entry. The persistent adapter uses it only for parse/check. Every request still
reads and hashes the complete cache bytes and verifies the expected compiler,
Base, format version and canonical Base source identity. A hit avoids decoding
and reserializing the same verified book. Every source graph and checked suffix
is constructed for the request.

Only successfully verified entries are retained. A miss, missing file, malformed
JSON or invalid identity clears prior state before following the existing
validation/fallback path. The exact buffer hashed is the buffer parsed. The
private decoded book is frozen iteratively once, avoiding both caller mutation
and recursion depth limits. Public `inspect` and `prepareBase` do not receive
this memo; a supplied API cannot enter its private state.

The inspector binds the API's canonical path and digest at creation, imports a
content-identified URL and verifies that identity again after loading and on
each request. The canonical URL matters: identical API bytes in two directories
can import different relative dependencies. Ordinary worker provenance still
checks the complete consumed host/runtime inputs; a URL query alone is not a
dependency proof.

## Focused gates

The final isolated host (`base-memo/project-02`) runs against genuine checked
integration-03 API `8cfa124d7567…`. Eighty-four mixed accepted/rejected parse/check
observations, in both case orders, are exactly equal to the original host.
Fifteen adversarial contract groups cover immutable hits, malformed/missing
caches, invalid metadata, book corruption with restored timestamps, valid changed
bytes, expected-identity drift, recycling, supplied APIs, lane restrictions, API
replacement and canonical-path changes with relative imports. The earlier host
and its 14-group gate remain preserved before the canonical-URL hardening.

The existing seed-equivalence test also passes its six cases, including changed
Base bytes/path, unused Base, import order and nested imports. The persistent
worker regression file exits successfully, including its replay/failure controls.
Its raw Node reporter gives one file-level passing test; no invented subtest
count is substituted.

With other intentional compiler/archive jobs paused, a one-process focused ABBA
pilot produced 168 exact results. Control blocks took 8.382 and 8.247 seconds;
memo blocks took 5.372 and 4.772 seconds. Total request time fell from 16.629 to
10.144 seconds, **39.00% less**. Opposite-order reductions were 35.92% and 42.13%.
Preparation and warmup are excluded, and separate API module instances share the
host process. The variation and that limitation remain visible; this is not a
complete compiler or production CLI timing.

## Full frontend gate and promotion

The frozen comparison uses the same genuine integration-03 API, identical
prevalidated cache bytes, runtime, fixtures and harness in fresh four-worker
processes. Order is control, memo, memo, control. First misses, freezing, worker
recycling and process startup are included in harness wall time. All result
fields and oracle verdicts must agree; the changed driver/adapter provenance
tuples are separately verified rather than silently normalized. Each of 11,024
observations must also belong to an intact closed worker history. Known
conformance failures remain failures.

The full comparison completed at 00:30:04 UTC within its 20-minute budget.
Mean harness wall fell from **292.602 to 242.597 seconds**, **17.09% less**; the
two opposite-order reductions were 17.14% and 17.04%. All 11,024 observations,
oracle verdicts and closed worker histories matched. Every run preserved all
919 positive fixtures and the same 365 strict check failures. This comparison
uses an intermediate compiler source and isolates the host change; it does not
measure a combined equality-plus-memo improvement.

The [full report and verified archives](base-memo-frontend.md) retain the raw
timing rows, observations, frozen inputs, focused gates and prior candidates.
[Promotion](persistent-base-decoding-promotion.json) verifies both production
host files against their reviewed original hashes before copying the exact
measured candidate. The final integration will rebuild and validate the combined
source with this host; the default distribution is unchanged.
