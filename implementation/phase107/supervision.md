# P107-007: subprocess supervision and complete-path latency

The pidfd wait helper passed its host controls and integrated pipeline checks.
With it, the experimental native QBE path builds the three measured programs in
34.6–37.5% less time than the installed native Bend CLI followed by Clang O2.
This meets the 25% goal for these finite source-to-executable comparisons; no
Bend code, selected compiler image, or installed release changed for this work.

The unchanged [source04 image](../../selfhost/build/phase107/native-source04/image.json)
binds compiler source `004467575e7144d7…` and executable `23bec3d748781668b…`.
The preceding/new timing reports have identical image pins; the JS API pins and
incumbent package pins also match within their respective comparisons.

## Controlled wait-method probe

Python 3.9's file-output timeout path polls `waitpid(WNOHANG)` with sleeps capped
at 50ms. The new helper waits for Linux pidfd readiness, then reaps without a
polling timeout. It retains one deadline across interruptions, kills/reaps on
timeout or failure, and closes descriptors. Unsupported environments fall back
to the prior polling wait. Output stays in files; no signal handler or output
buffer was added. The outer guard still owns descendant resource limits.

The [host-only probe](../../selfhost/build/phase107/process-controls01/report.json)
passed 56 alternating samples and 13 controls: normal/nonzero exits, checked
failures, timeout kill/reap, fallback, interruption, error cleanup, descriptor
balance and pipe rejection. Each table cell is the median of seven fresh Python
children, including their startup/shutdown; the requested sleep is not their
total work.

| Requested sleep | Polling wall, ms | Pidfd wall, ms |
| --- | ---: | ---: |
| 0ms | 32.520 | 20.737 |
| 10ms | 32.473 | 30.250 |
| 40ms | 64.597 | 62.784 |
| 100ms | 164.985 | 123.478 |

Commit `658ce45` integrated the helper into the native request/build drivers and
both timing harnesses, symmetrically for each comparison's outer waits. Helper
pins/snapshots and actual wait methods are retained. All waits recorded by the
new latency harnesses, and all native compiler jobs in the cache campaign, used
pidfd. Existing image acquisition and historical receipts were retained.

## Current complete-path results

The [incumbent comparison](../../selfhost/build/phase107/legacy-latency02/report.json)
uses the same zero-argument `main()` on both paths, prepared Base, fresh object
builds, and three paired rounds with reversed order. The baseline is the installed
native Bend CLI → C → pinned Clang22 O2; the candidate is native Bend → QBE →
assembler/linker/common runner. Independent masked-U32 answers require exact
decimal stdout plus one LF and empty stderr for all 18 executions.
Each fixture's `main` calls `bench(19,23)`; program execution validates the output
of these compilation-latency cases.

| Source | Installed C/O2, s | Native QBE, s | QBE / C | Shorter |
| --- | ---: | ---: | ---: | ---: |
| Arithmetic | 0.594848 | 0.376388 | 0.633 | 36.7% |
| Recurrence | 0.583751 | 0.381523 | 0.654 | 34.6% |
| Compiler classifier | 0.624124 | 0.389832 | 0.625 | 37.5% |

These are medians of complete compiler subprocess-wall sums. Adding executable
startup/execution yields native medians 0.377980/0.383168/0.391496s versus
0.596684/0.585599/0.626087s. The geometric mean of the three median ratios is
0.637 for source-to-executable and 0.638 for source-to-result. Supervisor intervals,
authentication, frontend and backend clocks are separate in the receipt; initial
tool/package auditing and one-time image acquisition are outside these pairs.

The [native versus JS comparison](../../selfhost/build/phase107/native-latency02/report.json)
also uses three reversed rounds, the same three sources and the matched fast
pipeline. Native uses prepared Base; JS retains its normal frontend. Thus this is
a source-to-executable interface comparison, not an isolated host-language test.

| Source | Cold native / JS, s | Cold ratio | Warm native / JS, s | Warm ratio |
| --- | ---: | ---: | ---: | ---: |
| Arithmetic | 0.383414 / 0.888830 | 0.431 | 0.317037 / 0.726019 | 0.437 |
| Recurrence | 0.379588 / 0.872221 | 0.435 | 0.318156 / 0.727262 | 0.437 |
| Compiler classifier | 0.397548 / 0.990483 | 0.401 | 0.334726 / 0.826075 | 0.405 |

Cold means a fresh object-cache directory, not cold OS pages. Warm reruns checking,
lowering and emission while reusing verified objects. All 36 builds, 18 QBE
comparisons and 132 independent runtime checks pass. The QBE comparison calls
`rstrip(b'\n')` on both byte streams: it removes **all trailing LF bytes**, not
exactly one, and normalizes no other byte. Executable stdout is compared exactly,
with one expected final LF and empty stderr.

[Actual cache controls](../../selfhost/build/phase107/native-real-cache02/report.json)
pass 12 compilations and 120 independent outputs across raw units and optimized
whole-object modes. They cover cold/warm reuse, a same-path arithmetic edit,
warm-edited reuse, ABI salt invalidation and rejected/rebuilt corrupted objects.
The cache harness's outer waits remain its original implementation; its native
compiler subprocesses exercise the integrated helper.

External guard walls were [28.345s](../../selfhost/build/phase107/native-latency02-guard/process.json),
[12.530s](../../selfhost/build/phase107/legacy-latency02-guard/process.json), and
[7.817s](../../selfhost/build/phase107/native-real-cache02-guard/process.json),
respectively. These campaign totals include validation and are not request medians.

## Before/after interpretation

The preceding [native/JS batch](../../selfhost/build/phase107/native-latency01/report.json)
had native cold medians 0.423/0.422/0.517s and warm medians 0.366/0.372/0.416s;
the new values are 0.383/0.380/0.398s and 0.317/0.318/0.335s. The preceding
[incumbent batch](../../selfhost/build/phase107/legacy-latency01/report.json)
had native source-to-executable medians 0.465/0.423/0.474s and baseline medians
0.681/0.680/0.731s. Both arms are lower in the new batch.

Those complete batches ran separately, so the differences are descriptive and
do not isolate the helper's causal contribution. The alternating host probe
isolates the wait-method change under controlled child workloads. The current
paired pipeline batches establish the finite results above. There is no new
compiler-kernel speedup claim, full-language qualification, or universal gain.

Methods and replay rationale: [P107-007](../../experiments/phase107/P107-007-supervision.md),
[pidfd helper](../../selfhost/tools/performance/phase107/frontend/native/process.py),
[native/JS harness](../../selfhost/tools/performance/phase107/latency.py), and
[incumbent harness](../../selfhost/tools/performance/phase107/legacy-latency.py).
