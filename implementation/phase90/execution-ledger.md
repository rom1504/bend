# Phase90 execution ledger

237 unique finished guarded jobs: 193 successful exits, 10 resource stops and 34 other nonzero exits. Other guard stops/errors: 0.

Summed guarded wall time: **1.51 hours** (5446.21 seconds). Guarded interval union: 1.51 hours; overlapping interval time: 0.00 seconds. Maximum sampled process-tree RSS: **10.01 GiB**.

| Category | Jobs | Guarded minutes | Peak tree RSS (GiB) |
| --- | ---: | ---: | ---: |
| Compiler emission or self-hosting | 43 | 39.36 | 1.65 |
| Clang/LLVM build or probe | 44 | 24.59 | 10.01 |
| Qualification, controls or release | 57 | 11.54 | 1.04 |
| Other guarded work | 40 | 7.60 | 1.54 |
| Profiling/diagnostic capture | 5 | 3.63 | 1.36 |
| Checked B1 build and focused validation | 7 | 3.28 | 1.62 |
| Compilation timing or screen | 37 | 0.57 | 0.36 |
| Public native CLI controls | 4 | 0.20 | 0.07 |

The public CLI capsule contributes 4 compiler guards from six controls; two refusals occurred before compiler execution. Its expected parse rejection remains a finished nonzero exit.

Excluded 0 duplicate records, 0 child/other process records and 0 unfinished records. Resource-stop reasons: {"deadline": 6, "tree-rss-limit": 4}.

These are recorded process durations, not a complete account of session or agent time. Expected rejection tests and failed experiments remain included; nonzero exits do not imply conformance regressions. No exact token/quota telemetry is available, and these timings cannot reconstruct quota consumption.

[Full ledger, commands and receipt hashes](execution-ledger.json). No targets were run to prepare this ledger.
