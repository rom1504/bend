# Cold native compiler development

[Phase144](../../implementation/phase144/README.md) contains the latest measured
ordinary-native compiler work. Use its separately recorded qualification and
[candidate](../../implementation/phase144/final04/candidate.json), not a similarly
named experimental image. The immutable
[final03 fallback](../../implementation/phase144/candidate.json), Phase143 and
selected Phase137 remain available. Nothing silently installs a new default.

The final04 ordinary image is
`selfhost/build/phase134/p144-final04-n2/program`; its checked source is
`selfhost/build/phase144/final04-source01/compiler.bend`. Use the exact runtime,
prepared Base and carrier identities from the candidate receipt. The selected
serial runtime requires one Bend heap mutator: `--threads 1 --gpu off`.
Concurrent arbitrary foreign embedding is outside this runtime contract.

`selfhost/tools/performance/phase130/native-request.py` handles the ordinary
native argv and complete-output protocol. For example, with fresh output paths:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase144/my-request-guard \
  --seconds 630 --rss-mib 3072 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase134/p144-final04-n2/program \
  --source selfhost/build/phase142/indexed-source02/compiler.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/my-request --seconds 600
```

This consumes a prebuilt compiler/runtime and prepared Base. Cold means a new
native process without source-specific semantic state, edit state or reused
machine objects; OS caches are not flushed. Time compiler execution and fresh
QBE/assembly/linking separately, then add them. Acquisition and qualification are
additional costs. Do not substitute warm edits or historical JS emission clocks.

On the frozen Phase142 compiler input, the fresh Phase143 parent takes304.534s
for compiler execution and15.118s for machine construction. Final04 takes231.682s
and15.318s: **319.652→247.000s**,22.73% less target time. These are single matched
observations, not confidence intervals;50s remains an open architectural target.

Start with the [Phase144 methods](../../selfhost/tools/performance/phase144/README.md)
and finite controls. Keep one CPU3 target lane,3GiB tree RSS and16GiB available
memory floor. Run independent source, complete-output and final-verifier gates.
Do not nest supervisors or overwrite consumed methods/evidence.

Use the [generic profiler](../../selfhost/tools/profiler/README.md) and
[stage contract](../../selfhost/tools/profiler/STAGES.md). The final03 full profile
uses its exact machine object and serial diagnostic runtime. Stage entries,
physical samples and active source owners answer different questions. Diagnostic
clocks are not clean speed measurements; missing markers invalidate attribution.
The optional concat counters distinguish failed preflight from successful reuse.

Ordinary final04 skips one redundant outer range pass; the existing batch/session
route retains it. Therefore ordinary and incremental QBE need not be byte-identical.
Use independent **mode-matched** references and keep warm-versus-cold comparisons
within the same policy. The historical cross-route equality failure is retained.
Finite session smokes do not constitute broad incremental qualification; use the
[separate incremental guide](incremental-native-development.md) for that frontier.
