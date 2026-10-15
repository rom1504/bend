# Same combined B1:90-second prefix

Reuses the actual successful exact-image sampler build. No new build or target run by preparation.

## capturePrefix

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/guard --seconds 120 --rss-mib 4096 --available-mib 16384 --cpu 3 -- env LD_PRELOAD=/home/ai/bend2/build/publish/bend/selfhost/build/phase90/watchdog01.so:/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-sample01.so BEND_SAMPLE_OUT=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/samples.txt BEND_SAMPLE_PERIOD_US=16000 BEND_CAPTURE_SECONDS=90 /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --threads 1 --gpu off -- /home/ai/bend2/build/publish/bend/selfhost/build/phase98/permission-tag-source02/compiler.bend /home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase66/bend2/base.bend /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/runtime.c /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/program 1 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/base/carrier01/base.p88 p88-private-base-text-1:8dec5b64d3900d61a208e51d92113194b91364c4f4d35d1903edb481d678ed03
```

## analyzeStoppedOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase89/partial-capture/analyze.py --samples /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/samples.txt --binary /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --table /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-table01/table.json --stderr /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/guard/stderr.log --process /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/guard/process.json --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/analysis.json
```

## ownershipWindowsOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase90/profiling/windows.py --analysis /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/analysis.json --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-prefix02/windows.json
```

Expected target exit77 / guard wrapper exit1, incomplete compilation and no C correctness claim.
Strict zero-loss analysis remains required. The second capture targets the75–90s transition absent from the first.
