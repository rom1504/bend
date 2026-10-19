# Phase112 three-hour time account

Window: **2026-10-19 00:41–03:41 UTC**. The 72 completed recorded guards occupy **92m25s**, or **51.34%** of the three-hour window. There is no measured overlap between target guards.

The remaining **87m35s** is outside recorded target guards. It includes implementation, source review, experiment preparation, disk cleanup, reporting and coordination, but the logs do not separate those activities. It is not a measurement of waiting or idle time. Agent preparation/review can overlap target execution.

| Recorded guard category | Wall time | Share of window |
|---|---:|---:|
| mixed qualification and benchmark batches | 42m11s | 23.43% |
| native self-reproduction | 15m15s | 8.48% |
| mixed full-image acquisition, self-reproduction and qualification | 14m51s | 8.25% |
| representative benchmark acquisition | 5m50s | 3.24% |
| focused source, IR and semantic loops (provisional default) | 5m24s | 3.00% |
| full compiler image acquisition | 4m50s | 2.68% |
| generated-program runtime measurement | 2m22s | 1.31% |
| compiler transport and executable-build measurement | 1m29s | 0.83% |
| profiling | 0m12s | 0.11% |
| Outside recorded guards | 87m35s | 48.66% |

The 17 nonzero guard outcomes occupy **9m00s**, already included above. These include useful falsification and harness failures; they are not automatically wasted time. The rejected immediate-helper composition is retained alongside successful candidates.

Mixed envelopes deliberately stay mixed. The facts full guard contains approximately284s hosted emission,7s machine construction,283s self-reproduction/build and44s focused qualification. The facts broad guard includes the IR witness,45 one-shot cases, broad product acquisition and runtime rounds. Adding those child clocks to their enclosing guard would double-count work. The profile/broad guard spends most of its time on runtime measurement, not profiling. Final category overrides were reviewed against these receipts.

The first implementation image, word checkpoint and final facts integration each received a full acquisition/self-reproduction gate. Development between them used checked APIs, structural/semantic fixtures and small matched screens. Independent source preparation and audits ran in parallel; benchmark targets remained serial on CPU3 to avoid mutual interference.

The original plan reserved the final20 minutes for consolidation. Final matched timing/profile work finished within that interval; it was followed by the comprehensive report,45-case plot, method review, source-boundary audit, time accounting and archive preparation. Evidence sealing and the last push occur after the03:41 cutoff and are not misreported as target-optimization time.

This account measures neither CPU-seconds nor tokens, quota, agent labor or validated improvements per compute unit. There is no billing telemetry from which to infer those quantities. Future work should record lightweight source-task boundaries if a more detailed implementation/review split is wanted. The data supports batching integration gates and one serial timing lane; it does not show that adding target CPUs would remove the remaining wall time.

[The interim account](time-use-interim.md) retains the earlier00:41–02:00 snapshot and original method identity. The final receipt is `selfhost/build/phase112/time-accounting-final01/report.json`; its method, source hashes,72 guard intervals, command lines, nested jobs and limitations are captured in the evidence capsule. The current method is [time-accounting.py](../../selfhost/tools/performance/phase112/time-accounting.py).
