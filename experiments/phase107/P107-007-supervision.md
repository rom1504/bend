# P107-007: remove polling delay from file-output subprocess supervision

Status: prepared, unrun. Existing compiler and timing drivers are unchanged.

The completed [native latency campaign](../../selfhost/build/phase107/native-latency01/report.json)
contains native frontend samples near 0.12/0.17 seconds and outer samples near
0.365/0.415 seconds. These observations motivate a host-supervision hypothesis;
they do not establish how much of either interval is compiler work.

Local Python 3.9 `subprocess.py` provides a concrete mechanism. File-output
`subprocess.run(..., timeout=...)` reaches POSIX `Popen._wait`, which polls
`waitpid(WNOHANG)` and sleeps with increasing delays capped at 50 milliseconds
(`/usr/lib/python3.9/subprocess.py:1887`). Nested supervised invocations can incur
this delay more than once. This is sleeping/polling overhead, not active CPU work.

The optional [process.py](../../selfhost/tools/performance/phase107/frontend/native/process.py)
waits for Linux pidfd readiness using the default selector and then reaps with
blocking `Popen.wait()`. It maintains one monotonic deadline across interruptions,
closes descriptors, and kills/reaps the direct child on timeout or other failures.
Unsupported pidfd environments explicitly fall back to the existing timeout wait.
It neither installs signal handlers nor buffers child output; pipe capture is
rejected. The outer resource guard continues to supervise descendants. This
assumes normal child ownership without an independent SIGCHLD reaper.

Root can run the prepared host-only probe under its usual serial guard:

```sh
python3 -B selfhost/tools/performance/phase107/frontend/native/process-controls.py \
  --out selfhost/build/phase107/process-controls01 --rounds 7
```

The probe alternates the two wait methods for identical Python children sleeping
0, 10, 40, and 100 milliseconds, with complete stdout/stderr, exit status, child
timestamps, parent wall time, descriptor balance, and reaping checks. Separate
controls cover nonzero exits, checked failures, timeout kill/reap, unsupported
fallback, interrupted selection, unexpected selector failure, blocking wait, and
pipe rejection. Child startup/shutdown remains in both arms; the child-final to
parent-return interval helps distinguish polling from requested sleep.

Integration requires root approval after these actual controls and measurements.
Then change only the relevant host wait calls and include the helper in their
method pins/snapshots. Re-run the same source04 paired latency batch with fresh
outputs and unchanged image/API/source/toolchain pins; require matching QBE and
complete binary outputs. Preserve the earlier reports, and compare full pipeline
wall as well as components. A successful host-only probe alone cannot establish a
compiler-kernel speedup, a new backend improvement, or a 25% end-to-end gain.
