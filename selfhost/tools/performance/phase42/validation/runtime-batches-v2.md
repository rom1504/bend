# Full45 unchanged sample protocol in three serial batches

A single --budget600 --setfull cannot complete:669 fresh samples each require at least1000ms warmup, exceeding the enclosing600s deadline before imports/calibration/measurement. --plan validates inputs and prints a plan; it does not detect this scheduling impossibility. The previous final-measurement-v1.md single-full45 command is superseded by this handoff.

Use the supported --budget600 --cases interface with three exact15-ID catalog slices, executed serially. Every point retains the same preset: five balanced fresh rounds/three roles, three warmup calls plus1000ms floor,50ms calibration and300ms target. Raytrace keeps one warmup call/three rounds. The669 requested samples are unchanged. Only campaign ordering and deadline grouping change: each batch executes all its balanced rounds before the next batch, with an independent600s enclosing budget. Record this change explicitly; do not claim a15-case report is full45.

All commands belong in the root serial queue. No timed sessions may overlap. Runtime planners and collectors also hash inputs and must be queued away from other timing.

```sh
python3 selfhost/tools/performance/phase42/validation/check-measurement-bindings-v2.py \
  "$RECIPE" --cost --receipt "$OUT/measurement-bindings.json"
python3 selfhost/tools/performance/phase42/validation/prepare-runtime-batches-v2.py \
  "$RECIPE" --binding "$OUT/measurement-bindings.json" \
  --plan "$OUT/runtime-batches.json"
python3 selfhost/tools/performance/phase41/recipe-run.py \
  "$OUT/runtime-batches.json" runtime-batch1-plan,runtime-batch2-plan,runtime-batch3-plan \
  --ledger "$LEDGER" --jobs "$JOBS" --prefix final-runtime-plan
python3 selfhost/tools/performance/phase41/recipe-run.py \
  "$OUT/runtime-batches.json" runtime-batch1,runtime-batch2,runtime-batch3 \
  --ledger "$LEDGER" --jobs "$JOBS" --prefix final-runtime
python3 selfhost/tools/performance/phase42/validation/close-runtime-batches-v2.py \
  "$OUT/runtime-batches.json" "$OUT/runtime-full45-close.json"
```

The materialized plan stores three exact case configurations, all concrete argv, their report paths, frozen attempt/API/baseline/candidate/catalog identities, unchanged preset and expected sample counts. Existing recipe-run/job/campaign tools preserve enclosing intervals and stop on first failure. Each historical runner owns its supervisor. Fresh outputs only; failed/partial batches remain raw evidence and must be retried with new plan/output paths.

The summarizer requires all three reports measured/complete/pass, exact protocol/CPU/Node/memory/compiler identities, exact15 IDs per batch, exact per-case rounds and balanced role/round pairs, successful processes, and all45 IDs once/669 samples. It rehashes consumed inputs, preserves case summaries and ratios separately, and records performanceAdmitted=false. It does not pool unrelated case timings or infer admission. Root reviews each same-run point comparison using its own complete batch, then explicitly admits the full campaign.

Run compiler cost separately with final-measurement-v1.md commands. Profiles must use exact successful copied modules from the containing batch. Locate tree-bitonic and coverage-list-pipeline-512 in runtime-batches.json batches, then run diagnose.py --from-run the matching runtime-batchN with that case only, fresh output and the established60s/all/CPU3/2GiB protocol. Never pass a case absent from the containing batch.

Scheduling: mandatory warmup alone11.15min across all batches; requested calibration/target add roughly3.9min, before imports, hashing, process scheduling and expensive calls. Reserve15–20min for runtime, up to30min if all three independent600s deadlines are used. Historical inherited semantic23.35min plus compiler cost~4.2min/new owners/install implies roughly45–55min final critical path, subject to observed host/candidate changes. No completion is guaranteed by preset or batch sizing. AST reviewed only; no execution here.


Version2 binds Node file and SHA from the frozen attempt into measurement receipt and batch plan, rehashes it at materialization/closure, and requires each runtime report Node input to match that exact hash. This closes executable drift between measurement binding and timing. Version1 tools/docs are retained as predecessors.
