# Maintained equality derivative: complete frontend loop

The maintained derivative reduced this four-core validation loop from **301.905
to 229.753 seconds on average (23.90% less wall time)**. All four complete runs
retain exactly the same 2,756 raw observations, oracle verdicts and diagnostics.
The 374 known strict check failures remain failures in every run; all 919 positive
fixtures retain their successful parse/check observations. This is a faster
validation workflow, not successful full-language conformance.

## Controlled result

P5-015 ran from 2026-09-22 23:10:41.997 to 23:28:40.632 UTC, with all four physical
cores reserved and other intentional compiler and archive work paused. Each row
is one new finite harness process with four persistent workers sharing mask0–3.
It uses 4GiB heaps, 4MiB stacks, recycling after64requests, five-minute per-probe
deadlines and a15-minute external sweep deadline. Workers are not individually
pinned.

| Order | API | Harness wall | Highest worker-reported RSS |
| --- | --- | ---: | ---: |
| 1 | Checked | 308.051s | 472,801,280bytes |
| 2 | Derived | 229.885s | 559,009,792bytes |
| 3 | Derived | 229.621s | 472,829,952bytes |
| 4 | Checked | 295.759s | 575,336,448bytes |

The opposite-order pairs improve25.37% and22.36%. The checked controls drift
4.0%; both pairs remain positive. With two samples per variant, the mean is also
the two-value median. RSS ranges overlap: no memory reduction is claimed. These
are request-reported per-worker high-water values, not an OS process-tree peak
or simultaneous aggregate. The harness wall excludes snapshot preparation and
post-run audits; no per-probe times are added to estimate loop latency.

## What was verified

The checked image is genuine integration attempt02 API
`c3c2ac7b14566e3d50f8f8dd121068cd7a1b59f6a39f44213fd538ff03fdc7e1`.
Its source and original bootstrap remain distinct from the maintained derivative
used in [P5-012](equality-performance.md). The derivative has its own verified
manifest and no fabricated bootstrap sidecar. This comparison performed no new
bootstrap or self-reproduction.

Both APIs use the same frozen host, runtime, pinned Base, fixture inventory,
Node binary and harness. Their separate API-specific Base caches were primed
outside timing in P5-012 and copied without modification. Workers start fresh for
each sweep and retain the API only within their bounded lifetime. OS caches were
not flushed. All1,494 discovered input path/hash entries were checked against
the historical attempt02 inventory before execution, resolving the copied-host
path question without waiting for a full sweep to fail.

Each sweep matches the historical checked attempt02 report exactly, including
result objects, status, reason and evidence. All11,024 observations are accounted
for. Every worker session closed; every request/result digest and replay prefix
was independently validated against its raw row. There were no worker failures,
timeouts, changed fixture/import identities or changed consumed artifacts.
The final report rechecks all inputs, raw reports and histories. No fresh full
TypeScript sweep is timed here: the controlled comparison is checked versus
derived, with unchanged historical live-reference results inherited through
exact observation equality.

The two pure auditor test groups passed before the timing window. All attempted
sweeps completed; none was excluded from the comparison. Known failed probes,
their reproduction files and all worker histories remain in the archive.

## Reproduction and decision

From `selfhost/`, with the recorded genuine attempt and completed P5-012 report:

```sh
node tools/performance/phase5/equality-frontend.mjs prepare CONFIG NEW_SNAPSHOT
node tools/performance/phase5/equality-frontend-preflight.mjs NEW_SNAPSHOT PREFLIGHT.json
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/equality-frontend.mjs run NEW_SNAPSHOT NEW_RUN
```

CONFIG contains `attempt` and `comparison` paths relative to the configuration.
The preflight command's exact recorded invocation is retained with its report.
Use an exclusive four-core slot; changing the compiler requires a new genuine
attempt and verified derivation. For ordinary work, select `"profile":"equality"`
in the [maintained development entry](../../docs/PHASE5_DEVELOPMENT.md), rather
than invoking this measurement wrapper. The default checked profile is unchanged.

Decision: the maintained equality profile has a complete current-source frontend
gate and a material measured workflow benefit. It remains a labelled derivative;
this does not establish faster generated programs, all backend behavior or a new
complete-source compile ratio.

Evidence: [preregistration](../../experiments/phase5/P5-015-full-frontend-equality-loop.md),
[archive and recovery](equality-frontend-evidence/README.md),
[member manifest](equality-frontend-evidence/manifest.json).
