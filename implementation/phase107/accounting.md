# Phase107 execution and source accounting

Snapshot: **2026-10-18T08:58:29.504173+00:00**. Targets may continue; this is not a declared final cutoff.

The inventory includes every closed `process.json` beneath Phase107 and its eight Phase98 source-law guard jobs. It preserves failed attempts and intended negative checks. It does not infer token usage, Codex quota or agent effort from elapsed time.

## Recorded occupancy

The receipt envelope runs from **2026-10-18T06:42:49.234613+00:00** to **2026-10-18T08:57:09.792557+00:00**: **134.34 minutes**. The **131** guard intervals sum to **1847.329s**; their union is **1847.329s** (**22.92%** of that envelope). Overlap wall time is **0.000000s**, with at most **1** recorded guard job active. The remaining **6213.229s** is outside those receipts, not a measure of wasted time.

Method: use each half-open epoch interval `[started, finished)`, sweep sorted endpoints, remove ending jobs before adding starting jobs, and accumulate union/overlap segments. The JSON retains every interval, command, hash and original monotonic `wallSeconds`. Parent guard time and inner job durations are never added together. These guards cover process trees: a serial guard schedule does not prove that a tool such as `make` used only one internal process.

| Activity group | Guard receipts | Sum of guarded epoch intervals, s | Nonzero exits |
| --- | ---: | ---: | ---: |
| Full native frontend acquisition | 5 | 858.279 | 0 |
| Independent source-law checks | 8 | 4.473 | 2 |
| QBE tool construction | 2 | 2.747 | 1 |
| Runtime and latency campaigns, including their checks | 15 | 370.233 | 2 |
| Semantic, cache and composition qualification | 27 | 293.516 | 5 |
| Small IR kernel acquisition | 10 | 127.059 | 1 |
| Source preparation, admission and emission | 64 | 191.023 | 16 |

These path-based groups partition observations, not compiler execution phases. Build and benchmark batches also contain orchestration, checks, serialization and waiting. Target subprocess clocks remain in their original reports; their scopes differ and are not combined into a fabricated exact target/method split. Offline agent work consisted of source changes/review, receipt analysis and documentation. The interval evidence supports the coordinator’s serial guarded-target schedule; it does not measure all offline activity or internal tool parallelism.

## Resource envelope and retained failures

Maximum sampled process-tree RSS was **1.630 GiB** (`native-link04-guard`). Minimum reported available memory was **23.119 GiB**. The lowest recorded prelaunch disk space was **713.1 MiB**; this is not continuous disk sampling. There were **0** recorded guard resource stops. No OOM is indicated by these receipts.

There are **27** nonzero exits, including **2** deliberate false-kernel-proof rejections. The others retain source-admission errors, transport/runtime controls that exposed bugs, stale output/input paths, and failed tool launches. A nonzero harness exit is not automatically a compiler semantic failure. Exact codes and diagnostic excerpts are preserved in `accounting.json`. No failed receipt is omitted from the occupancy total.

## Current tracked source size

Current working-tree bytes of git-tracked Phase107 files. Counts include comments/blank lines. Fixtures, laws and experimental control mains are separate; generated images, inherited Phase106 IR, Base and existing compiler frontend are not counted as new Phase107 algorithms.

New Phase107 Bend algorithms/entry integration total **2717 lines**, **20 files**, and **391 named definitions**. A definition count is a mechanical inventory, not a count of distinct concepts or a correctness claim.

| Group | Files | Lines including comments/blanks | Nonblank lines |
| --- | ---: | ---: | ---: |
| Bend QBE emission and units | 3 | 392 | 329 |
| Bend experimental control entrypoints | 2 | 99 | 88 |
| Bend fixtures and source cases | 25 | 912 | 780 |
| Bend local laws | 2 | 61 | 47 |
| Bend optimization algorithms and shared IR helpers | 15 | 1972 | 1693 |
| Bend source lowering and native entry | 2 | 353 | 303 |
| Non-Bend methods and support | 61 | 4432 | 4229 |

These are additions to an experimental subsystem. They do not imply that the installed compiler shrank. The inherited Phase106 model/verifier/consumers, Base and existing frontend are dependencies rather than new Phase107 lines. Per-file hashes and the tracked-file snapshot are retained. Untracked Bend source, if present, is listed separately and excluded.

## Kernel03 acquisition

The successful native acquisition used **7.891498s** for Bend-to-C emission and **38.017117s** for Clang: **45.908615s** summed guard time. The elapsed emission-to-build-completion envelope was **85.529466s**, including intervening coordination and the failed launch. The separate JS API acquisition is retained but excluded from the native acquisition sum.

The first link command referenced a nonexistent Clang path and returned 127; `kernel-link03b` succeeded. The [acquisition receipt](kernel03-acquisition.json) explicitly sets `retrospectiveFlag: true`. Its source identity matches the manifest and pre-emission input pin; source, native binary and JS API match the subsequent successful same-kernel measurement. Generated C is hashed during consolidation: the successful Clang command named it through a macro, but its guard did not separately hash that included C at launch. We preserve that provenance limitation instead of claiming a contemporaneous binding that was never recorded.

- Source SHA256: `0ebbb384c408f9f49c707f9f86d4f4484897d4691539a25b93702033e38b7d69`
- Native binary SHA256: `7d3558164527349eafc764a2e306bb04d06cac4a5de377299ef388238910c1d3`
- Generated C SHA256 (retrospective): `608c8af07b73cafd07df4ce582574034e67f2954741b5d17ceb2cefc879c8186`

This image uses the installed native C route for acquisition. It is not an independently qualified selected release or a QBE B1/B2 fixed point.

[Machine accounting and interval inventory](accounting.json) · [Measured metrics](metrics.md)
