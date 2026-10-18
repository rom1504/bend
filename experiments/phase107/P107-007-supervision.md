# P107-007: remove polling delay from file-output subprocess supervision

Status: implemented and measured. The host probe and three integrated campaigns
passed; no Bend code or installed compiler selection changed. See the
[measurement report](../../implementation/phase107/supervision.md).

The completed [native latency campaign](../../selfhost/build/phase107/native-latency01/report.json)
contains native frontend samples near 0.12/0.17 seconds and outer samples near
0.365/0.415 seconds. These observations motivate a host-supervision hypothesis;
they do not establish how much of either interval is compiler work.

Local Python 3.9 `subprocess.py` provides a concrete mechanism. File-output
`subprocess.run(..., timeout=...)` reaches POSIX `Popen._wait`, which polls
`waitpid(WNOHANG)` and sleeps with increasing delays capped at 50 milliseconds
(`/usr/lib/python3.9/subprocess.py:1887`). Nested supervised invocations can incur
this delay more than once. This is sleeping/polling overhead, not active CPU work.

The [process.py](../../selfhost/tools/performance/phase107/frontend/native/process.py)
waits for Linux pidfd readiness using the default selector and then reaps with
blocking `Popen.wait()`. It maintains one monotonic deadline across interruptions,
closes descriptors, and kills/reaps the direct child on timeout or other failures.
Unsupported pidfd environments explicitly fall back to the existing timeout wait.
It neither installs signal handlers nor buffers child output; pipe capture is
rejected. The outer resource guard continues to supervise descendants. This
assumes normal child ownership without an independent SIGCHLD reaper.

The host-only probe ran under the serial guard:

```sh
python3 -B selfhost/tools/performance/phase107/frontend/native/process-controls.py \
  --out selfhost/build/phase107/process-controls01 --rounds 7
```

The [probe receipt](../../selfhost/build/phase107/process-controls01/report.json)
records 56 alternating samples and 13 passing controls. It alternates the two wait
methods for identical Python children sleeping
0, 10, 40, and 100 milliseconds, with complete stdout/stderr, exit status, child
timestamps, parent wall time, descriptor balance, and reaping checks. Separate
controls cover nonzero exits, checked failures, timeout kill/reap, unsupported
fallback, interrupted selection, unexpected selector failure, blocking wait, and
pipe rejection. Child startup/shutdown remains in both arms; the child-final to
parent-return interval helps distinguish polling from requested sleep.

Median subprocess wall milliseconds for the 0/10/40/100ms child sleeps changed
from 32.520/32.473/64.597/164.985 to 20.737/30.250/62.784/123.478. Both arms include
Python child startup and shutdown; the effect varies with the requested duration.

After approval, commit `658ce45` integrated the unchanged helper into native
`compile.py`/`run.py` and both paired timing harnesses. Both comparison arms use
the same outer wait; native compiler subprocesses also use the helper. New
receipts pin/snapshot it and record the actual wait method. All recorded waits in
the two new latency batches used pidfd.

[Native versus JS](../../selfhost/build/phase107/native-latency02/report.json)
passes 18 QBE comparisons and 132 program checks across 36 builds; native/JS
median wall ratios are 0.401–0.437. QBE comparison removes all trailing LF bytes
from both files, with no other normalization; program stdout is exact.
[Native versus installed C/O2](../../selfhost/build/phase107/legacy-latency02/report.json)
passes nine pairs and 18 complete outputs. Source-to-executable medians are
0.376/0.382/0.390s versus 0.595/0.584/0.624s for arithmetic/recurrence/classifier:
34.6–37.5% shorter on these three sources, meeting the finite 25% goal.
[Cache controls](../../selfhost/build/phase107/native-real-cache02/report.json)
pass 12 builds and 120 outputs, including ABI invalidation and corruption repair.

The native source/image, API and incumbent package pins match their preceding
timing batches. Before/after complete batches ran separately, so their lower
medians are descriptive observations, not a causal estimate of this helper
alone. The controlled host probe isolates the wait-method change; the complete
comparisons establish the current finite pipeline results. Neither establishes
a Bend compiler-kernel improvement, full-language backend coverage, or a universal
speedup. Earlier receipts remain intact.
