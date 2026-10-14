# Late native-self capture without rebuilding the compiler

Reuse the exact Phase89 native binary, sampler and unwind table. Only
`watchdog.c` changes: its maximum accepted duration is 240 rather than 120 s.
`watchdog.derivation.json` binds both sources and the exact reverse edit. Default
duration, ordinary-thread exit, atomic exit ownership and sampler-destructor
behavior are unchanged. Root built the tiny library at
`selfhost/build/phase90/watchdog01.so`; its guarded receipt is
`selfhost/build/phase90/watchdog-build01/process.json`.

`run.py` reuses the old complete native/cache/effect admission in check-only mode,
requires the previously successful normal/stopped Map controls, authenticates the
new watchdog build and pins 343 inputs before and after execution. It executes
one unchanged full-source request at a 16,000 µs CPU sampling period. At 180 s
this is approximately 11,250 samples; at 240 s, 15,000. Both fit the existing
25,000-sample per-thread buffer. It does not increase capacity or alter the
original sampler or compiler.

From the repository, root runs serially:

```sh
python3 -B selfhost/tools/performance/phase90/profiling/run.py \
  selfhost/build/phase90/late-self01 --seconds 180 \
  --watchdog selfhost/build/phase90/watchdog01.so \
  --watchdog-build selfhost/build/phase90/watchdog-build01/process.json
```

Add `--check-only` for authentication without a target. This passed during
preparation with 343 inputs. The outer guard is 210 s for a 180 s capture,
CPU3, 2 GiB RSS, at least 4 GiB available memory, and the existing disk/output
limits. A 240 s selection has a 270 s outer guard; use a fresh directory.

Intentional exit77 remains an incomplete compilation. The unchanged Phase89
strict stopped reader must accept the image identity, intact END and zero
drops/overruns/clock/thread errors before `diagnosticUsable` becomes true. Any
loss preserves the rejection, raw file and stderr; no automatic retry or
qualification relaxation. If the compiler unexpectedly returns0 first, preserve
its output and use the original complete analyzer, but still do not set
`compilationPassed`: the new output needs an independent exact-C oracle.

`windows.py` is offline only. It verifies an accepted strict prefix and all its
input identities, then recovers physical ownership return sites in 30 s
**monotonic wall-time windows**. Sample count times period is labeled as an
approximate sampled-thread CPU amount, not an exact stage clock. Existing IO.now
marks are retained without inventing parser/checker/emitter boundaries. Musttail
callers remain absent. It was checked against the previously accepted stopped
Map capture: 752 samples, one window, targetComplete:false. No target or compiler
build was run by this preparation lane.

For a fresh offline output after a successful stopped capture:

```sh
python3 -B selfhost/tools/performance/phase90/profiling/windows.py \
  --analysis selfhost/build/phase90/late-self01/strict-analysis.json \
  --out /tmp/phase90-late-self-windows-fresh.json
```

Do not change the watchdog/sampler sources or tools while a capture is running:
the before/after identities deliberately reject that. The historical 60 s self
capture with one overrun remains rejected and separately described as exploratory.
