# Phase 44 time and size accounting

This accounting is frozen from the campaign start at **2026-10-04T07:03:08Z** through the successful final CLI smoke job at **2026-10-04T08:58:35Z**. It excludes subsequent documentation, archive construction, final data-only receipts, review, commit and publication work. Approximately ten minutes of initial consultation preceded the ledger; that estimate is separate from measured time.

## Elapsed time

| Measure | Minutes |
| --- | ---: |
| Ledger window | 115.46 |
| Union of wrapped job intervals | 61.17 |
| Outside wrapped job intervals | 54.29 |
| Approximate window including initial consultation | 125.46 |

The ledger contains **46 wrapped jobs: 43 successful and 3 failed attempts**. Intervals use each event’s `started` and `finished` timestamps. Overlapping intervals are merged; nested child receipts are not added. The raw sum is 61.21 minutes, exceeding the union by 2.768 seconds.

The unwrapped residual is mixed analysis, coding, subagent collaboration, review, documentation and orchestration. These records cannot separate those activities or identify time spent waiting. Wrapped time likewise records job occupancy, not idle human/agent time: analysis and agent work could proceed while jobs ran. Agent token cost and aggregate agent work time were not measured.

## Wrapped work

| Classification | Jobs | Interval union, minutes |
| --- | ---: | ---: |
| Checked compiler builds | 4 | 2.35 |
| Checked program acquisition | 9 | 8.64 |
| Semantic and conformance qualification | 15 | 22.66 |
| Compiler request timing | 1 | 5.20 |
| Selected program execution timing | 4 | 19.94 |
| Saved JavaScript experiment | 4 | 0.83 |
| Profiles and static diagnostics | 1 | 0.46 |
| Evidence freezing, summaries and release checks | 8 | 1.11 |
| Cross-classification overlap to subtract | — | 0.046 |
| All wrapped jobs, merged | 46 | 61.17 |

Acquisition includes three complete corpus preparations plus the small composition fixtures and the compiler-cost baseline. Qualification includes both backend 81 runs, the main 3,026-case and broader 196-case frontend runs, direct IR checks and the maintained suites. Program timing includes the short screen and three full-corpus batches; the saved-JavaScript experiment has its own screen and controls. Evidence/release work includes install, verify and the final 42-step CLI smoke.

## Failed attempts and resource limits

| Attempt | Seconds | Cause and disposition |
| --- | ---: | --- |
| `job-checked02` | 4.108 | A source binder error in the primitive lowering helper prevented a checked build. The helper was corrected and later checked builds passed. |
| `job-maintained04` | 0.462 | The launcher looked for a test helper absent from the frozen host snapshot. Its binding was corrected to the checked current helper. |
| `job-maintained04b` | 11.483 | The arm harness incorrectly required an unselected historical `prebind-arm` optimization marker. Its 72 ordinary and 22 exact behavior observations passed; the marker expectation was corrected to the selected backend’s existing behavior. No compiler behavior was changed for this failure. |

The rejected saved-JavaScript optimization experiment is an experimental outcome, not a failed job. Its control/timing jobs completed; it was not selected for release.

Target work used CPU 3, a 1,024 MiB Node heap, a 2,048 MiB process-tree RSS cap and a 2,048 MiB available-memory floor, with bounded per-job timeouts. Frontend qualification used one worker. The maximum retained supervisor observation was **1,397,559,296 bytes (1.302 GiB)** during `run-checked04`; no retained supervisor receipt records an OOM, memory-floor or timeout stop. This is sampled supervised process-tree RSS, not a claim about total machine memory or aggregate agent memory. Nested and copied receipts can repeat observations and are used only for the maximum, not summed.

## Maintained architecture size

Counts enumerate the modules listed by each frozen `compiler.json`. They exclude runtime, host code, tests, documentation and unlisted legacy sources. Physical lines use `splitlines()`; code lines exclude empty lines and lines whose first non-space character is `#`. Declaration counts are syntactic proxies, not a measurement of semantic complexity.

| Measure | Phase 43 checked14 | Phase 44 checked04 | Change |
| --- | ---: | ---: | ---: |
| Maintained Bend modules | 70 | 78 | +8 |
| Physical Bend lines | 21,440 | 21,813 | +373 |
| Nonblank/noncomment Bend lines | 17,770 | 18,025 | +255 |
| Definitions | 2,413 | 2,452 | +39 |
| Type declarations | 72 | 75 | +3 |
| Law declarations | 640 | 629 | -11 |
| JavaScript backend physical lines | 7,427 | 7,800 | +373 |
| Generated compiler API bytes | 1,460,868 | 1,487,170 | +26,302 |

The new eight-module IR is 524 physical lines, 386 code lines, 52 definitions and 16 node kinds. Changes to preexisting backend modules remove 151 physical lines in aggregate, giving a net addition of 373 lines (+1.74%) across maintained Bend modules. The generated compiler API grows by 26,302 bytes (+1.80%). This phase establishes composable lowering, analysis, simplification and emission; it does not claim an overall source-size reduction.

The final 45-point/669-observation runtime comparison remains approximately **6.0832× the execution time of pinned TypeScript output** under equal-point weighting. The architecture work and correctness results should therefore be judged separately from runtime gains; this phase did not close that performance gap.

## Evidence identity

- Campaign: `selfhost/build/phase44/campaign.jsonl`, SHA-256 `9a98eabaa97267e79da9277468cb9c59cc7883ac4883c0fd0c7a6f461a36c955`; 47 rows including the start record.
- Size receipt: `selfhost/build/phase44/architecturemetrics.json`, SHA-256 `c44e1061e03a971ffc40262fe3f14e09c9c41a39b88e4be1f83dd39bab24c2aa`.
- Final wrapped event: `job-release-smoke04`; nested release checks are not separately charged.
- Selected compiler: `selfhost/build/phase44/checked04`, API SHA-256 `0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea`.

The campaign labels determine the table’s coarse classifications; no fine-grained retrospective agent activity estimate is inferred from gaps in the ledger.
