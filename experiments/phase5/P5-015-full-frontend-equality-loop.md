# P5-015 — Full frontend loop with the maintained equality derivative

- Owner: direct_calls; parent approved the frozen wrapper before launch.
- Correctness: all four2,756-observation sweeps and histories match exactly.
- Measurement: completed ABBA,23.90%less mean finite harness wall.
- Decision: retain the maintained labelled equality profile; checked default unchanged.

## Claim and stop conditions

The maintained equality derivative of genuine Phase5 integration attempt02
should shorten the actual four-worker frontend loop, retaining all2,756 raw
observations and every known failed oracle. This is a workflow measurement,
not a claim of successful conformance or faster generated programs.

The first checked→derived pair is both a timed pair and the new broad derivative
gate. Stop immediately on any changed diagnostic, phase, checked flag, output,
verdict, reason/evidence, incomplete inventory, worker failure or artifact drift.
Do not normalize all rejection errors together or compute timings only from
surviving probes. If that gate passes, continue derived→checked to bracket order.

## Frozen setup and measurement

Use the same verified checked/derived images as completed P5-012 run01, separately
recording original genuine bootstrap and maintained derivation manifests. Copy
attempt02's exact host/harness/native support and the two API-specific validated
Base caches into one frozen selfhost-shaped project. Caches were separately
primed outside timing in P5-012 and remain byte-identical through this comparison.
All runs use the same canonical pinned source/Base/runtime and fixture inventory.

Order: checked, derived, derived, checked. Four workers share CPU mask0–3; this is
not individual worker pinning. Every run starts fresh workers, reusing each API
within a worker for at most64requests. Heap4GiB, stack4MiB, probe deadline5minutes,
whole-run deadline15minutes. Root reserves all four physical cores and stops
other intentional compiler work for the interval. No TypeScript rerun is timed.

Measure the complete finite harness process wall, excluding snapshot preparation
and post-run audits. Report each worker's harness-recorded request RSS high water
and restart/request/recycle statistics; this is neither aggregate RSS nor exact
OS peak memory. Do not add per-probe timings to estimate wall.

Before/after checks cover source/API/runtime/Base/host/harness/Node/cache inputs.
Each run must match the completed attempt02 fixture hashes/import resolutions and
all raw result objects plus oracle verdict/reason/evidence. Audit closed worker
session histories, every request/result digest and replay prefix, with exactly
2,756 accounted observations. Final source/image changes remain outside this
frozen comparison. Pending or failed runs stay preserved.

```sh
node tools/performance/phase5/equality-frontend.mjs prepare CONFIG NEW_SNAPSHOT
node tools/performance/phase5/equality-frontend.mjs run SNAPSHOT NEW_RUN
```

CONFIG contains only `attempt` and `comparison`, paths relative to CONFIG;
`comparison` is the completed P5-012 report. Only the parent can release the
resource slot.

## Outcome

Completed23:10:41.997–23:28:40.632UTC on2026-09-22. Checked walls308.051/295.759s;
derived229.885/229.621s. Mean301.905→229.753s; both opposite-order pairs improve
(25.37%/22.36%). All11,024 raw observations, unchanged known verdicts, input
identities and closed session histories pass the exact gate. Each sweep retains
374strict check failures; this is not full conformance. RSS ranges overlap and no
memory gain is claimed. See the [report and retained evidence](../../implementation/phase5/equality-frontend.md).
