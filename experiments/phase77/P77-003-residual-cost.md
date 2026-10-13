# P77-003: discriminate shared lowering and library reuse after compaction

First collect exact-output internal timing and V8 samples on the combined
compiler01 B2. Separate occurrence scans, annotation/erasure, worker candidates,
generic entry lowering, observer routing and rendering. Instrumented timings
are attribution only; clean paired requests remain authoritative for speed.

A library-product proposal must show reusable expensive work, not merely shared
names. Inspect the existing prepared-world/Base annotation admission: stable Base
identity, dependency context, disjoint user names and owned API are required.
Native static addresses and lowered fresh IDs cannot be cached verbatim across
requests. Prototype only the dominant remaining component; retain explicit
preparation and fresh-request versus warm-request clocks. Do not claim parity
from amortized products without also reporting the uncached metric.

## Decision

Investigation complete; large rewrite deferred. Fresh profiles distribute time among rendering, erasure, annotation, loading and GC. Existing annotation reuse gives no clear cold gain; symbolic native products are not implemented. Ordinary warm sessions provide the most useful immediate editing-loop change. See the [completed report](../../implementation/phase77/README.md).
