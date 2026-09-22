# P5-012 — Measure the maintained equality derivative on a new checked build

- Owner: direct_calls; independent review pending.
- Correctness: wrapper prepared; no measurement run yet.
- Measurement: pending an isolated root-scheduled CPU slot.
- Decision: investigate; no default compiler/runtime change.

## Claim and invariants

The maintained equality helper should preserve the large exact-image Phase4
benefit on a genuinely new checked compiler build. It must verify the original
bootstrap and replay its own derivation; the derivative is never described as a
new checked bootstrap. Original checking provenance stays separately recorded.

Compare `checked` and `derived` on the fixed312-declaration core-library capsule
and the pinned `base/list_sort` program. Include pinned TypeScript for list_sort
only; equivalent TypeScript core-library export roots are outside this bounded
comparison. Original/derived code must be byte-identical. All program variants
must execute and print exactly `6\n`; libraries must pass JS syntax checking.
Failures remain failed rows, and an incomplete/mismatched cell has no median.

## Controlled setup

Root supplies the completed `integration/attempt-02` maintained checked attempt.
One frozen shared Bend host and output runtime; exact canonical pinned Base;
standard unmodified JavaScript builtins; Node4MiBstack/4GiBheap. Separate validated
API-specific Base caches are prepared in untimed fresh processes. TS has no
corresponding serialized Base cache and rereads/checks Base in each sample.
OS caches are not flushed.

Run two repetitions, forward then reverse: two variants for core, three for list.
All samples run serially on one root-assigned CPU, with no competing compiler
jobs. Request time includes driver input/cache reads and the compiler pipeline;
imports, provenance hashing and file publication are outside it. Process wall
and maxRSS include the complete measurement wrapper, not merely D.inspect.
Per-API timing is nested diagnostic instrumentation and is not additive.

Tools: `selfhost/tools/performance/phase5/equality-{compare,worker}.mjs`.
The wrapper verifies actual input/tool/Node identities before/after children,
retains bounded file-backed logs, deadlines and failures, then independently
re-verifies the original attempt and maintained derivation after the matrix.

```sh
node tools/performance/phase5/equality-compare.mjs CONFIG.json NEW_DIRECTORY
```

Configuration: `attempt`, `coreLibrary` paths relative to CONFIG; `cpu`, even
`repetitions` (default2), `timeoutMs` (default180000). Measurement is not authorized
until the root schedules the isolated slot. First review/test the wrapper's
failure retention and missing-row rules; no full compiler run is needed for that.

## Result

Completed the reserved CPU3 comparison on2026-09-22 22:49:25–22:51:16UTC.
All10 timed rows pass their exact output gates. Median request reductions are
36.4% for the fixed core library and25.0% for list_sort, in both relative orders.
No full-derived-frontend or generated-program speed claim follows.
See [all samples and scope](../../implementation/phase5/equality-performance.md)
and [verified durable evidence](../../implementation/phase5/equality-performance-evidence/manifest.json).
Next test: a separately preregistered full frontend workflow comparison with
known failures retained and exact checked/derived observations required.
