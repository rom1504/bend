# Phase85: direct V8 thread CPU attribution

Offline analysis of one traced request per role/case. All times below are milliseconds; these are diagnostic observations, not clean speedups.

| Case / role | Phase | Worker wall | Process CPU | Main compile CPU¹ | Background TF CPU² | Background Maglev CPU² | Total traced compile CPU² |
|---|---|---:|---:|---:|---:|---:|---:|
| functions65 / b2 | import | 166.5 | not recorded | 134.4 | 0.0 | 0.7 | 135.1 |
| functions65 / b2 | request1 | 675.7 | 676.1 | 79.5 | 168.1 | 122.5 | 370.0 |
| functions65 / typescript | import | 270.1 | not recorded | 52.9 | 2.1 | 1.2 | 56.2 |
| functions65 / typescript | request1 | 421.1 | 421.4 | 28.7 | 57.4 | 119.5 | 205.6 |
| numeric / b2 | import | 138.8 | not recorded | 116.5 | 0.0 | 0.6 | 117.0 |
| numeric / b2 | request1 | 986.3 | 986.6 | 119.6 | 299.6 | 149.7 | 568.9 |
| numeric / typescript | import | 286.1 | not recorded | 50.3 | 2.4 | 1.4 | 54.1 |
| numeric / typescript | request1 | 802.1 | 802.4 | 42.0 | 194.9 | 154.9 | 391.8 |

¹ Main compilation-category CPU union excludes observed nested GC; includes tier decisions and finalization.
² Lower/upper ranges arise from slices crossing a phase boundary. No CPU is prorated by wall overlap. Task envelopes and nested job phases are not added twice.

Each trace is bound to its report by explicit P85_CLOCK job and process ID. Clock marks use process.hrtime microseconds, the documented Node trace time source. Main OS thread IDs come from trace metadata. Detailed hashes, per-thread counters, boundary-crossing slices and largest background jobs are in timeline.json.

Limits: import process CPU was not recorded; background Sparkplug has no equivalent scope; tracing and clock logging perturb execution; JIT CPU is not automatically a removable latency gain. The residual includes execution, untraced compilation, GC and other runtime work. Named optimization jobs require additional same-run identity instrumentation; flow IDs alone do not name functions.

For functions65, the B2-minus-TypeScript process-CPU gap is 254.7 ms. The directly attributed compilation difference is 164.4 ms (64.6% of the observed process-CPU gap). This is attribution within one instrumented pair, not a forecast of achievable speedup.

For numeric, the B2-minus-TypeScript process-CPU gap is 184.2 ms. The directly attributed compilation difference is 177.1 ms (96.1% of the observed process-CPU gap). This is attribution within one instrumented pair, not a forecast of achievable speedup.

The two mechanisms to separate next are extra first-use parse/bytecode work and extra TurboFan compilation. Maglev CPU is similar between roles in these pairs. A change must still demonstrate clean request gains: avoiding compilation can make subsequent JavaScript execution slower.

The earlier timeline01 traces lack request clock markers and cannot support phase attribution. Node 24.18.0's performance.mark implementation does not emit the requested usertiming trace events. The v2 preload supplies explicit job/PID/hrtime markers; no trace-file ordering is used.
