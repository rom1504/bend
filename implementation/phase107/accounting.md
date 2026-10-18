# Phase107 execution and source accounting

Final target cutoff: **2026-10-18T09:08:13.961640+00:00** (`constant-final-guard01`), following the coordinator’s closure at **09:08:13 UTC**. Offline consolidation snapshot: **2026-10-18T09:12:14.233259+00:00**.

The inventory includes every closed `process.json` beneath Phase107 and its eight Phase98 source-law guard jobs. It preserves failed attempts and intended negative checks. It does not infer token usage, Codex quota or agent effort from elapsed time.

## Recorded occupancy

The receipt envelope runs from **2026-10-18T06:42:49.234613+00:00** to **2026-10-18T09:08:13.961640+00:00**: **145.41 minutes**. The **148** guard intervals sum to **2010.129s**; their union is **2010.129s** (**23.04%** of that envelope). Overlap wall time is **0.000000s**, with at most **1** recorded guard job active. The remaining **6714.598s** is outside those receipts, not a measure of wasted time.

Method: use each half-open epoch interval `[started, finished)`, sweep sorted endpoints, remove ending jobs before adding starting jobs, and accumulate union/overlap segments. The JSON retains every interval, command, hash and original monotonic `wallSeconds`. Parent guard time and inner job durations are never added together. These guards cover process trees: a serial guard schedule does not prove that a tool such as `make` used only one internal process.

| Activity group | Guard receipts | Sum of guarded epoch intervals, s | Nonzero exits |
| --- | ---: | ---: | ---: |
| Full native frontend acquisition | 5 | 858.279 | 0 |
| Independent source-law checks | 8 | 4.473 | 2 |
| QBE tool construction | 2 | 2.747 | 1 |
| Runtime and latency campaigns, including their checks | 21 | 466.356 | 2 |
| Semantic, cache and composition qualification | 28 | 293.601 | 5 |
| Small IR kernel acquisition | 16 | 224.274 | 1 |
| Source preparation, admission and emission | 68 | 160.400 | 16 |

These path-based groups partition observations, not compiler execution phases. Build and benchmark batches also contain orchestration, checks, serialization and waiting. Target subprocess clocks remain in their original reports; their scopes differ and are not combined into a fabricated exact target/method split. Offline agent work consisted of source changes/review, receipt analysis and documentation. The interval evidence supports the coordinator’s serial guarded-target schedule; it does not measure all offline activity or internal tool parallelism.

## Resource envelope and retained failures

Maximum sampled process-tree RSS was **1.630 GiB** (`native-link04-guard`). Minimum reported available memory was **23.119 GiB**. The lowest recorded prelaunch disk space was **649.6 MiB**; this is not continuous disk sampling. There were **0** recorded guard resource stops. No OOM is indicated by these receipts.

There are **27** nonzero exits, including **2** deliberate false-kernel-proof rejections. The others retain source-admission errors, transport/runtime controls that exposed bugs, stale output/input paths, and failed tool launches. A nonzero harness exit is not automatically a compiler semantic failure. Exact codes and diagnostic excerpts are preserved in `accounting.json`. No failed receipt is omitted from the occupancy total. The separately retained [unguarded inline-check invocation](../../selfhost/build/phase107/constant-prefilter01/inline-check-attempt.md) passed the wrong argument count to a zero-argument effect witness; its unknown duration is excluded from guard counts and timings. The final guarded standalone check passed.

## Current tracked source size

Current working-tree bytes of git-tracked Phase107 files. Counts include comments/blank lines. Fixtures, laws and experimental control mains are separate; generated images, inherited Phase106 IR, Base and existing compiler frontend are not counted as new Phase107 algorithms.

New Phase107 Bend algorithms/entry integration total **2737 lines**, **20 files**, and **394 named definitions**. A definition count is a mechanical inventory, not a count of distinct concepts or a correctness claim.

| Group | Files | Lines including comments/blanks | Nonblank lines |
| --- | ---: | ---: | ---: |
| Bend QBE emission and units | 3 | 392 | 329 |
| Bend experimental control entrypoints | 2 | 100 | 89 |
| Bend fixtures and source cases | 25 | 912 | 780 |
| Bend local laws | 2 | 61 | 47 |
| Bend optimization algorithms and shared IR helpers | 15 | 1992 | 1710 |
| Bend source lowering and native entry | 2 | 353 | 303 |
| Non-Bend methods and support | 66 | 4769 | 4555 |

These are additions to an experimental subsystem. They do not imply that the installed compiler shrank. The inherited Phase106 model/verifier/consumers, Base and existing frontend are dependencies rather than new Phase107 lines. Per-file hashes and the tracked-file snapshot are retained. Untracked Bend source, if present, is listed separately and excluded.

## Kernel03 acquisition

The successful native acquisition used **7.891498s** for Bend-to-C emission and **38.017117s** for Clang: **45.908615s** summed guard time. The elapsed emission-to-build-completion envelope was **85.529466s**, including intervening coordination and the failed launch. The separate JS API acquisition is retained but excluded from the native acquisition sum.

The first link command referenced a nonexistent Clang path and returned 127; `kernel-link03b` succeeded. The [acquisition receipt](kernel03-acquisition.json) explicitly sets `retrospectiveFlag: true`. Its source identity matches the manifest and pre-emission input pin; source, native binary and JS API match the subsequent successful same-kernel measurement. Generated C is hashed during consolidation: the successful Clang command named it through a macro, but its guard did not separately hash that included C at launch. We preserve that provenance limitation instead of claiming a contemporaneous binding that was never recorded.

- Source SHA256: `0ebbb384c408f9f49c707f9f86d4f4484897d4691539a25b93702033e38b7d69`
- Native binary SHA256: `7d3558164527349eafc764a2e306bb04d06cac4a5de377299ef388238910c1d3`
- Generated C SHA256 (retrospective): `608c8af07b73cafd07df4ce582574034e67f2954741b5d17ceb2cefc879c8186`

This image uses the installed native C route for acquisition. It is not an independently qualified selected release or a QBE B1/B2 fixed point.

[Machine accounting and interval inventory](accounting.json) · [Measured metrics](metrics.md)
