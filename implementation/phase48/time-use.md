# Phase48 time use and iteration lessons

The final [interval receipt](evidence/time-use-final.json) covers
`2026-10-05T02:01:42.136579Z` through `2026-10-05T05:10:19.701505Z`: **3.144 hours**.
It finds **60.37 minutes** of disjoint, recorded process occupancy
(32.0% of elapsed time) across 1,399 distinct
`process.json` records. No mixed-category target overlap was observed.
Archive compression, final documentation and Git publication after the cutoff
are excluded.

| Recorded process category | Union minutes | Records |
| --- | ---: | ---: |
| build | 12.02 | 15 |
| acquisition | 14.11 | 120 |
| control | 1.61 | 63 |
| timing | 24.83 | 1173 |
| cost | 2.43 | 20 |
| qualification | 4.43 | 1 |
| preparation | 0.01 | 2 |
| release | 0.91 | 3 |
| other | 0.01 | 2 |

The remaining **128.26 minutes** are not classified by this
process-level instrument. They include source work, static research, multi-agent
review, fixture/controller repairs, orchestration and documentation; they may
also include idle time. They must not be called waiting or CPU consumption.
The file-count categories are process invocations, not independently authored
experiments. This scan found no temporal nesting among the available
`process.json` leaves; broader campaign reports do include controller and
between-sample time and must not be added to these leaf durations.

For example, the final full runtime campaign took **18m52s elapsed**, while
individual execution-process intervals account for less time. The overall
phase's timing row also includes earlier rejection screens. Likewise, the
18-request compiler-cost campaign took 161.249 seconds including coordination;
its 53.670 seconds of inner requests and 140.457 seconds of child time are
nested measures, not additional campaign duration.

An initial accounting receipt accidentally used a cutoff slightly in the future.
It is retained as [rejected evidence](evidence/time-use-future-cutoff-rejected.json)
and is not the phase's final time denominator. The final invocation captured its
actual UTC cutoff before running, and writer closure independently checked it
was already in the past. No timing sample was changed.

## What made the loop efficient

Independent workstreams prepared function-flow, aggregate-transport, array/value
lowering, controls, performance analysis and reviews concurrently. Root retained
ownership of target execution and integration. Small source/IR witnesses rejected
mechanisms before spending a full corpus run: the H experiment did not activate
on its intended workloads, and V's reduced tuple allocation failed to produce
useful timing gains. Those experiments remain reproducible without entering the
maintained compiler.

The final combined image was acquired once for the complete corpus, then reused
for qualification, all execution batches and publication. The 45 corpus modules
were byte-identical between RNFA03 and RNFA04, but final timing and qualification
were still independently run for the selected image. No profiles, builds or
compression shared the clean timing window. CPU 3, 1,024 MiB heap, 2,048 MiB
process-tree RSS and the 4,096 MiB available-memory floor bounded target work.
One compiler heap-limit failure was preserved and repaired; no host/session OOM
occurred. The guard polls resources and cannot guarantee every possible host OOM
is prevented.

## How to spend the next hour better

1. Require a static hot-entry witness on several real programs before compiling
   a new interprocedural mechanism. H's factory gap can be seen without timing.
2. Keep one root target queue; agents supply source, semantic adversaries and
   independent interpretation rather than competing timing jobs. Parallelize
   acquisitions only on separately resourced hosts with independent guards.
3. Use the [20/60/300-second benchmark selections](../../selfhost/tools/performance/phase48/README.md)
   and explicit activation controls to reject candidates. Repeat the full corpus
   only after mechanism and short-screen evidence justify promotion.
4. Maintain separate gain, semantic-boundary, compiler-cost and source-size
   decisions. A reduced constructor count is not sufficient evidence of speed;
   a large single-point gain is not broad parity.
