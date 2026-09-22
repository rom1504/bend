# Measure persistent frontend scheduling

P4-021 tests whether the existing four-worker harness materially shortens the
full validation loop while preserving every observation. This changes scheduling
and available CPU resources, not compiler algorithms or emitted code.

Freeze the completed Phase 4 B1 frontend sweep's harness, adapter and host, its
checked B1, runtime, canonical Base and fixture identities. Copy the same
previously validated Base cache into the new frozen host; verify compiler/Base
keys, canonical source path and serialized-book hash, then hash it before/after
every run. `prepareBase` already writes PID-specific temporary files and renames
atomically. Warm-cache runs avoid concurrent cache creation; any unexpected
cache modification invalidates the measurement.

First compare a bounded mixed positive/negative/import selection using one and
four persistent workers restricted to CPU 0. This is a correctness smoke, not a
scaling measurement. Force short recycling in this smoke to exercise distinct
worker histories. Only after exact parity, run all 1,378 fixtures / 2,756
parse/check observations with one worker on CPU 0. Then wait for explicit
resource clearance before running four workers across four physical cores.
Both full runs use a 4 MiB stack, 4 GiB heap/RSS recycling threshold, 64 requests
per worker generation and a five-minute per-request deadline.

Use unchanged existing worker/session/replay machinery. Each slot owns its
queue and work directories; completion order may differ. Compare complete raw
compiler results and harness verdicts by fixture/lane against the completed
serial B1 inventory, including existing failures. Parse rejection must never
count as successful checking. Retain all session histories, failed reproductions,
commands, logs, actual CPU masks and consumed hashes. A scheduling crash, timeout,
missing observation or changed input prevents a successful run designation.

Measure complete child-process wall, including harness startup/verification and
worker recycling. Record per-worker observed RSS and sampled aggregate live RSS;
do not confuse sums of independent peaks with a simultaneous peak. Report the
speed ratio as one-core versus four-core workflow throughput, not a compiler
optimization or full-language conformance. The prior serial sweep is a historical
reference; prefer a new serial run for the resource comparison. Preserve any
interference, retries and null result. Do not edit the active `frontend-sweep`
tool or compiler source during this experiment.
