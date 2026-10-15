# Combined native B1 ownership capture: root-run commands

Actual ELF `02d471e67f6b325c861cc991358ad1f58fa982106bc0b11e5fb7a61495c2d12e`; source `59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714`.
The unchanged Phase88 generator has already created55 accepted unwind rows.
No sampler build or target execution has been performed. Manifest pins all existing inputs.

Do not run the hardcoded Phase95 `profile-v2.py`: it selects historical native B1.
Reuse its sampler/analyzer and quality rules with these exact current-image commands.

## buildSampler

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-build01 --seconds 60 --rss-mib 512 --available-mib 4096 --cpu 3 -- /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang -std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared -I /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-table01 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/ownership/sample-ownership.c -o /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-sample01.so -pthread -ldl -lrt
```

## capture

```sh
/usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase86/guard.py --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/guard --seconds 300 --rss-mib 4096 --available-mib 16384 --cpu 3 -- env LD_PRELOAD=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-sample01.so BEND_SAMPLE_OUT=/home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/samples.txt BEND_SAMPLE_PERIOD_US=16000 /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --threads 1 --gpu off -- /home/ai/bend2/build/publish/bend/selfhost/build/phase98/permission-tag-source02/compiler.bend /home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase66/bend2/base.bend /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/runtime.c /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/program 1 /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/base/carrier01/base.p88 p88-private-base-text-1:8dec5b64d3900d61a208e51d92113194b91364c4f4d35d1903edb481d678ed03
```

## analyzeOffline

```sh
taskset -c 0 /usr/bin/python3 -B /home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase88/ownership/analyze.py --samples /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/samples.txt --binary /home/ai/bend2/build/publish/bend/selfhost/build/phase98/combined-checked01/compiler --table /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-table01/table.json --stderr /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/guard/stderr.log --out /home/ai/bend2/build/publish/bend/selfhost/build/phase98/ownership-combined-self01/analysis.json
```

## Acceptance and limits

- Pin the actual sampler SO and successful build guard, plus unchanged prepared inputs, before capture.
- Require successful normal compiler exit, complete C and exact diagnostics equal the successful unsampled same-image same59b36 request. Historical D04 C is not the changed-backend oracle.
- Require sampler END, unchanged image/table, analyzer coverage acceptance, and zero overruns/dropped/thread_overflow/thread_clock_failures/timer_disarm_failures.
- Reject or explicitly label exploratory any failed resource guard, incomplete capture, changed inputs or loss. Historical analyzer acceptance alone does not enforce all zero-loss counters.

- Sampler flushes only at normal destructor execution. RSS/deadline SIGKILL gives no usable profile; do not spend another failing full run solely for this sampler.
- One CPU worker,16ms sampling,physical cleanup caller chain of at most3 frames; tail-dispatched logical ancestry and inline allocations unavailable.
- Observed runtime includes diagnostic overhead; use unsampled matched requests for speed.
- Existing64MiB file limit and160MiB guard disk floor remain. Reserve at least512MiB for the complete C+raw capture as Phase95 does.

The output oracle is deliberately pending the successful unsampled retry.
A successful capture is additional evidence, not a native release admission.
