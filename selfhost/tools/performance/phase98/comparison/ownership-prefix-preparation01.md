# Combined B1:75-second intentionally stopped ownership capture

No new sampler, format, guard or compiler code. Exact55-row table is already prepared.
Existing controlled watchdog binary is reused; its successful build receipt and SHA256 are pinned.
Only the exact-image sampler library needs building by root. No targets have run in preparation.

## buildSampler

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-build01 --seconds 60 --rss-mib 512 --available-mib 4096 --cpu 3 -- /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang -std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared -I /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-table01 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/ownership/sample-ownership.c -o /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-sample01.so -pthread -ldl -lrt
```

## capturePrefix

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/guard --seconds 105 --rss-mib 4096 --available-mib 16384 --cpu 3 -- env LD_PRELOAD=/home/ai/bend2/build/publish/bend/selfhost/build/phase90/watchdog01.so:/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-sample01.so BEND_SAMPLE_OUT=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/samples.txt BEND_SAMPLE_PERIOD_US=16000 BEND_CAPTURE_SECONDS=75 /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --threads 1 --gpu off -- /home/ai/bend2/build/publish/bend/selfhost/build/phase98/permission-tag-source02/compiler.bend /home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase66/bend2/base.bend /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/runtime.c /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/program 1 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/base/carrier01/base.p88 p88-private-base-text-1:8dec5b64d3900d61a208e51d92113194b91364c4f4d35d1903edb481d678ed03
```

## analyzeStoppedOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase89/partial-capture/analyze.py --samples /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/samples.txt --binary /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --table /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-table01/table.json --stderr /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/guard/stderr.log --process /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/guard/process.json --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/analysis.json
```

## ownershipWindowsOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase90/profiling/windows.py --analysis /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/analysis.json --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix01/windows.json
```

## Required interpretation

- Pin actual sampler after its successful guarded build, then verify all manifest inputs before and after capture.
- Require exact target returncode77, one BEND_CAPTURE_STOP seconds=75 exit=77 marker, no resource/deadline stoppedFor and complete sample END. Guard complete=false and wrapper exit1 are expected for intentional nonzero target.
- Use the unchanged strict stopped analyzer; it requires zero lost/delayed/thread/clock/timer samples and correct exact image/table.
- Run unchanged windows.py only on an accepted partial analysis; inspect physical ownership sites against current generated C.
- Do not treat missing C or intentional exit as a successful compilation. If target unexpectedly exits0, preserve outputs and assess separately; stopped analyzer must reject.

- No MAP_SHARED format, signal-handler file I/O or guard stop changes. Reuses previously controlled ordinary-thread watchdog exit77.
- Capture ends at75s of wall time after wrapped main, before the observed83s/101s limits if progress is comparable; resource guard remains independently decisive.
- Physical leaf/caller samples only. Prefix timing includes observer overhead; this is not a speed or full-request correctness result.
- Do not retry merely to obtain zero loss; preserve every failed diagnostic attempt.
