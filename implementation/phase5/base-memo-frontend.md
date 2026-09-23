# P5-021: full frontend private Base-decoding memo

The reviewed host memo reduced full frontend harness wall time by **17.09%** in a controlled control–memo–memo–control run. All **11,024 observations**, including the known failures, matched exactly apart from each host's separately verified provenance tuple. No compiler source, compiler API, oracle or fixture changed between variants.

| Order | Host | Harness wall | Highest reported worker RSS |
| --- | --- | ---: | ---: |
| 1 | Control | 290.084 s | 738,603,008 bytes |
| 2 | Private memo | 240.355 s | 513,421,312 bytes |
| 3 | Private memo | 244.838 s | 469,049,344 bytes |
| 4 | Control | 295.119 s | 492,802,048 bytes |

Mean wall fell from **292.602 to 242.597 seconds**. The two opposite-order reductions were **17.143% and 17.038%**. RSS is a request-reported worker high-water observation, not an aggregate process-tree or OS peak; the ranges overlap, so this result makes no general memory-saving claim.

Each run covered 1,378 fixtures and 2,756 parse/check probes. All 919 positive fixtures passed both lanes. Every run retained **365 strict check failures**, 459 negative parse observations, and the same complete results/verdicts. Comparison completion is not a whole-suite conformance pass. Both memo runs also included first misses and freezing after each worker restart. The four runs used 45, 46, 45 and 45 worker lifetimes respectively; every closed history and request/result digest was verified, with no timeout or infrastructure failure.

## Scope and provenance

The genuine checked compiler is integration attempt-03, API SHA `8cfa124d7567f8840941fcfdcce79a5b9a18caac406c9a3db89c31720e7d6e06`. Both hosts used this exact API, the same runtime, canonical pinned Base and fixtures. The candidate was reviewed `base-memo/project-02`. The only host differences were `typed-driver.mjs` and `conformance/adapters/typed.mjs`. The snapshot and raw reports record their exact hashes. This is a host-only workflow result for that frozen compiler, not a newly checked or derived compiler image and not a measurement of later integrated source.

Each host received identical, separately copied, prevalidated API-specific Base cache bytes. Four fresh persistent workers shared the CPU mask 0–3, with 4 GiB heap, 4 MiB stack, a five-minute probe deadline and recycling after at most 64 requests. The memo preserves full cache-byte reading/hashing and compiler/Base identity checks for every request; only a private frozen decoded book is reused. Public inspection remains outside this memo path.

The slot ran **2026-09-23 00:12:03.524–00:30:04.668 UTC**. Other intentional compiler and heavy archive jobs were held; lightweight static reads/docs continued. This does not claim control over unrelated OS activity. Finite harness process wall includes startup and worker recycling, excludes snapshot preparation and post-run audits, and is measured directly rather than summing probe times. The whole comparison, including audits, had a 20-minute internal budget and a 1,260-second external deadline. All inputs were reverified after completion. Exit code 1 from each conformance child denotes retained known test failures; the comparison process itself exited 0.

Before the full run, two comparator test groups confirmed that diagnostic/phase/checked/output/oracle changes remain failures, and a routed smoke compared 12 observations through both actual adapters. The first healthy control established the raw baseline; this experiment did not substitute historical attempt-02 diagnostics or run a new TypeScript comparison.

## Reproduction and retained evidence

From `selfhost/`, with the recorded Node and pinned checkout, use fresh output directories:

```sh
node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/base-memo-frontend.mjs prepare \
  build/phase5/base-memo-frontend/config.json NEW_SNAPSHOT

timeout --kill-after=5s 1260s taskset -c 0,1,2,3 \
  node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/base-memo-frontend.mjs run NEW_SNAPSHOT NEW_RUN \
  > NEW_RUN.stdout 2> NEW_RUN.stderr
```

The config identifies the genuine attempt, reviewed candidate project and its completed focused gate report. Do not relabel a different API or host with these reports. The metadata-only preparation checks inventory and input paths before any long run.

[Evidence manifest](base-memo-frontend-evidence/manifest.json) and [recovery notes](base-memo-frontend-evidence/README.md) retain the four raw reports, all worker histories, failed-case repros, logs, exact copied hosts/tools, source/bootstrap inputs and cache bytes. The compressed archive was read back member by member. Its 9,510,480 bytes hash to `711ab45b928b709de1db6efd1bd7c0869ed4f8259c3974819ab3bb4f9e56b6fc`.

This full-workflow measurement supports the bounded private persistent-session memo. It does not turn the earlier cost-attribution percentage into an end-to-end speed claim, nor establish behavior for public arbitrary-API calls or execution lanes.

The [supporting manifest](base-memo-frontend-evidence/supporting-manifest.json) additionally preserves the initial attribution probe, focused ABBA and both reviewed candidate gate sets. Its 2,271,964-byte archive has SHA `e97275d4483f04247a9873d26b5d09cb6c247c0043492e699cdf35b3f4677ee9`. The old gates-01 tool was recovered byte-exact from the retained history directory; replay must restore that version rather than use the newer tool under the same original pathname.
