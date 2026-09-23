# P5-021 — avoid repeated decoding of an unchanged validated Base cache

Preregistered 2026-09-22 during P5-015. Root owns the experiment. No timing or
implementation result exists yet. First budget: 20 minutes after the timing hold;
escalate only for a material measured cost.

Static inspection of `typed-driver.mjs::readBaseCache` shows that each persistent
parse/check request reads the serialized Base cache, parses its complete JSON,
serializes its book again, and hashes that serialization. API and Base source
hashes are independently recomputed by `baseCacheInfo`. The persistent adapter
currently retains only the compiler API. Repeated decoding may be material for
small regression cases; this is a hypothesis, not an inferred speedup.

The cheapest falsifier measures actual cache size and separates reading, decoding,
book serialization/verification, and total request time on a frozen current
compiler. Retain all samples. If the avoidable share is under 5% of a representative
persistent parse/check batch, defer rather than adding state for a negligible gain.
Instrumentation and microbenchmarks do not establish an end-to-end speedup.

A candidate, if justified, uses one bounded private memo per persistent session.
Always read and cryptographically hash the complete cache bytes on each request;
reuse a previously verified decoded book only when those bytes and all expected
compiler/Base/version/canonical-source identities agree exactly. API and Base
verification remain unchanged. No mtime-only validation, unchecked cached verdict,
source-graph reuse or memo shared between compiler APIs. Isolated/CLI requests and
public `prepareBase` retain their current behavior. The decoded memo is private to
inspection and has no caller-accessible mutation API.

Bend books are immutable inputs; verify this assumption against the actual cached
book before/after mixed accepted/rejected requests and alias/seed fallbacks.
Every request still constructs a fresh source graph and checks its suffix. A
changed, missing, malformed, wrong-version or tampered cache must take the same
current validation/fallback path, including when changed after a warm hit and
when file size/mtime are restored. Limit retained state to one entry per session,
and preserve replay independence after recycling or a failed request.

Gate order: cost falsifier; bounded candidate in an isolated frozen host; existing
seed/persistent replay controls plus new hot-cache mutation counterexamples;
exact baseline/candidate results for a mixed request sequence; controlled opposite-
order batch measurements with other compiler jobs paused. Broaden only after a
consistent material improvement, then compare the full frontend inventory and
worker histories. Host provenance hashes are expected to differ and remain
recorded; compare the complete semantic result plus explicit host identities,
never silently normalize diagnostic text or classify existing failures as passes.

No compiler source algorithm or generated-program runtime change is implied.
Keep this candidate separate from P5-011's two diagnostic-prefix guards and from
the active P5-015 benchmark's frozen host. Do not run profiling or compilation
during the P5-015 timing hold.

## Checkpoint — 2026-09-23 00:15 UTC

The falsifier measured44.14% decoding/book-verification share on84 instrumented
requests, with168 exact control observations. It justifies the isolated memo
candidate, without predicting its end-to-end gain. The final candidate passes84
mixed request comparisons and15 adversarial contract groups. The focused ABBA
pilot reduces total request time16.629→10.144s (39.00%), with168 exact results.
Both source variants and all raw observations are retained. Canonical API URL
binding was strengthened after independent review and verified with identical
API bytes importing different relative dependencies in different directories.

The full four-worker1378-fixture ABBA gate is now running under an explicit
20-minute total budget. No promotion yet. See the
[implementation record](../../implementation/phase5/persistent-base-decoding.md)
for the policy boundary and pending checks.

## Completed full gate and promotion — 2026-09-23 00:38 UTC

The full ABBA comparison passed all 11,024 result/history comparisons; mean
wall is 292.602→242.597 seconds (17.09% less), with consistent opposite-order
pairs. All 919 positives and 365 known strict check failures are unchanged.
The exact candidate host files were promoted with guarded original/after hashes.
See [full evidence](../../implementation/phase5/base-memo-frontend.md) and
[promotion](../../implementation/phase5/persistent-base-decoding-promotion.json).
Final combined-source validation remains a separate gate.
