# Exact origin B2 full-self ownership capture

Prepared data only. The unchanged Phase88 ELF generator accepted 55 unwind rows for
`c481bd2c…` (the actual origin B2 image). No sampler build or capture has run.

Root executes these commands serially, in order. The image uses the `phase90-native`
argv sentinel. Capture uses 300 s / 2 GiB, a 4 GiB available-memory floor, CPU 3,
one worker and 16 ms samples, with no watchdog. Reserve 512 MiB disk space.

## buildSampler

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-build01 --seconds 60 --rss-mib 512 --available-mib 4096 --cpu 3 -- /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang -std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared -I /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-table01 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/ownership/sample-ownership.c -o /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-sample01.so -pthread -ldl -lrt
```

## bindSampler

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase98/comparison/ownership-origin-b2-check.py --preparation /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase98/comparison/ownership-origin-b2-preparation01.json --bind-sampler --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-binding01.json
```

## capture

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/guard --seconds 300 --rss-mib 2048 --available-mib 4096 --cpu 3 -- env LD_PRELOAD=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-sample01.so BEND_SAMPLE_OUT=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/samples.txt BEND_SAMPLE_PERIOD_US=16000 /home/ai/bend2/build/publish/bend/selfhost/build/phase98/origin-b2/compiler --threads 1 --gpu off -- phase90-native /home/ai/bend2/build/publish/bend/selfhost/build/phase98/origin-guard-source01/compiler.bend /home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase66/bend2/base.bend /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/runtime.c /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/program 1 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/base/carrier01/base.p88 p88-private-base-text-1:8dec5b64d3900d61a208e51d92113194b91364c4f4d35d1903edb481d678ed03
```

## analyzeOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/ownership/analyze.py --samples /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/samples.txt --binary /home/ai/bend2/build/publish/bend/selfhost/build/phase98/origin-b2/compiler --table /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-table01/table.json --stderr /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/guard/stderr.log --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/analysis.json
```

## verifyAndWindowsOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase98/comparison/ownership-origin-b2-check.py --preparation /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase98/comparison/ownership-origin-b2-preparation01.json --binding /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-binding01.json --analysis /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/analysis.json --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-origin-b2-self01/windows.json
```

The oracle is the successful unsampled **same-image, same-source** request in
`origin-b2-self01`, including complete C and the exact diagnostic after removing only
the existing clock lines. Binding and final checking are offline data operations.

The unchanged Phase88 analyzer must accept complete clocks and coverage. The final
postprocessor separately requires zero loss, successful target exit, exact C/diagnostic
and unchanged inputs. It produces 30 s windows measured from request start, clipping
the final window to completion. They are wall-time windows, not compiler stages.

Physical ownership callers do not reconstruct eliminated Bend ancestors or inline RC
operations. Sampled times include profiler overhead and are not speed comparisons.
A failed or partial capture stays failed/partial; no full-profile claim is permitted.
