# Phase51: V8-guided runtime experiments and replay

See the [design](../../../../design/phase51/v8-guided-runtime.md),
[report](../../../../implementation/phase51/README.md) and
[runtime guide](../../../../docs/self_hosted/v8-guided-runtime.md).
The phase report is authoritative for selection and installation status.

The portable comparison uses prior RNFA04 as `baseline`, the Phase51 checked
compiler as `candidate`, and upstream `018751270e800bc222a93dad7f257083ee53a5f7`
as `typescript`. There are 45 points, 23 Bend sources and 24 distinct emitted
libraries per role. Generated modules and their hashes are preserved; replay
does not require the ignored acquisition directories or an installed compiler.

## Choose the smallest useful check

From the repository root, after the bundles have been published:

```sh
P51_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
run51() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog selfhost/tools/performance/phase37/catalog.json \
    --baseline selfhost/tools/performance/phase51/bundles/baseline/manifest.json \
    --candidate selfhost/tools/performance/phase51/bundles/current/manifest.json \
    --node "$P51_NODE" --cpu 3 --rss-mib 2048 --available-mib 4096 "$@"
}
run51 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 \
  --out selfhost/build/phase51-live/compact-NEW
run51 --budget 60 --set core --out selfhost/build/phase51-live/core-NEW
run51 --budget 300 --set broad --out selfhost/build/phase51-live/broad-NEW
run51 --budget 600 --cases coverage-unicode-text-16,coverage-unicode-text-64 \
  --out selfhost/build/phase51-live/unicode-NEW
```

Every output must be fresh. Use `--plan` to verify inputs without executing.
Budget selects warmup/rounds/sample duration and a ceiling; `--set` or `--cases`
selects coverage independently. `core` has eight canaries; `broad` covers ten
points from five families. The full comparison uses three serial 15-point slices,
each with budget600, followed by the unchanged Phase44 summary verifier.
The final raw capsule preserves the exact `run-full.py` commands.

Keep generated-code execution, builds and compression stopped elsewhere during
timing. Use pinned Node24.18.0 for comparison with this report. Short screens are
rejection tools: inspect drift and use longer fixed-work warmups when tiering
makes a result ambiguous. Profiles and traces run separately from clean timing.
See the [V8 probe guide](../phase49/README.md) for CPU/allocation/inlining tools.

## Experiment sequence

- `freeze-reference.py` rebinds the exact RNFA04 and TS replay modules.
- `guards-derive.py` tests descriptor batching; it was rejected for speed.
- `dispatch-prepare*.py` make exact saved-JS derivatives for three application
  shapes. Only the IO helper was selected for compiler integration.
- `guards-count.mjs` tests duplicate String checks and argument-read order.
  `guards-token-derive.py` verifies structural preconditions before making the
  saved same-entry-proof derivative.
- `prepare-candidate.py` applies the reviewed source patches to an isolated
  checked snapshot and regenerates the runtime. The checked workflow then builds
  one B1; maintained `programs/prepare.py` acquires emitted modules once.
- `guards-checked-receipts-v2.py` binds unmodified semantic controllers to actual
  checked output. V1's replacement-string failure remains preserved.
- `qualify-selected.py` executes the [bounded qualification plan](qualification-plan.md).
  Its parent must remain unpinned; child guards select CPU3. The native sandbox
  refusal is resolved by `join-backend-native.py` using only the targeted retry.
- `render-results.py` formats the validated full summary. `publish-bundles.py`
  packages modules only after timing, then verifies them with the maintained
  reader. It performs no compilation or target execution.

`proposals/` contains reviewed patches, not additional installed paths. Counter
and private-export derivatives are untimed diagnostics; do not use them for speed
claims. The unused IO trace queue is retained as a prepared recipe, not evidence
of execution. Exact commands, successes and failed attempts are preserved in the
closed raw capsule linked by the final report. Do not append to closed phase
directories; use fresh `phase51-live` outputs for later experiments.
