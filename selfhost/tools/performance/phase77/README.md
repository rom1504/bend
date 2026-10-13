# Phase77 methods and evidence

[Design](../../../../design/phase77/native-parity.md) ·
[Report](../../../../implementation/phase77/README.md) ·
[Native session](../../../../docs/self_hosted/NATIVE_COMPILATION.md).

The selected compiler is `compiler01`, checked B1 `f058269d…`, genuine/default
B2 `35d7a606…`. Production source is in `selfhost/src/back/native/`; experimental
image rewrites in this directory are diagnostic methods, never release artifacts.

## Shortest useful loops

Use the ordinary installed session for consecutive Bend-to-C requests:

```sh
node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/native-session.mjs
```

Use fresh output paths for controls. For example, from the repository root:

```sh
python3 selfhost/tools/performance/phase46/job.py \
  --out /tmp/native-session-control-guard --seconds 60 -- \
  python3 selfhost/tools/performance/phase77/session-cli-controls.py \
  /tmp/native-session-control "$(command -v node)"
```

This takes a few seconds with the installed image. The actual guard uses CPU3,
2GiB aggregate RSS and4GiB available-memory floor. Do not run multiple heavy
trees simultaneously. Node children use1GiB heap/4MiB stack. If a managed sandbox
rejects Node PIPE creation, run the same guarded job with the environment's
authorized execution permission; changing the benchmark command invalidates a
paired comparison.

For compiler edits use the checked workflow in
[PHASE5_DEVELOPMENT.md](../../../../docs/PHASE5_DEVELOPMENT.md). Keep the unchanged
image and a three-source emission screen first. The held-out `fixtures/small.bend`
and `fixtures/functions65.bend` avoid the shared IO argument-reader shape.
`word-controls-v4.mjs` is the independent scalar-pattern gate. Broader runtime and
conformance validation should follow a measured gain, not every diagnostic edit.

## Historical one-shot controllers

These scripts bind fixed Phase77 paths and assert fresh output directories. They
document the executed experiment; they are not safe to rerun over archived output.
Copy/adapt a method into a new phase or choose new output roots before executing.

| Method | Purpose |
| --- | --- |
| `run-candidate.py` | Acquire candidate, genuine B2 and controlled timing inputs |
| `runtime-candidate.py` | 108 rotated execution intervals across12 families |
| `qualify-candidate.py` | Raw/native/pattern/threaded gates, self-check and B3 |
| `diagnose.py`, `profile-candidate.py` | Instrumented internal clocks and V8 profiles; exact C required |
| `prepare-string-prototype.py`, `string-controls.mjs` | Rejected diagnostic string-kernel image and independent Unicode oracle |
| `prepare-products.py`, `products-request.mjs` | Base annotation-product discriminator |
| `prepare-warm.py`, `run-warm.py`, `warm-request.mjs` | Ordinary/memo/upstream repeated requests |
| `mixed-session.mjs` | Actual session versus equally reused upstream on five sources |
| `prepare-generalization.py` | Two non-IO held-outs, fresh B1/B2/upstream |
| `session-controls-v2.mjs`, `session-cli-controls.py` | Identity/edit/error/recycle and installed protocol controls |
| `summarize.py`, `finalize.py` | Read existing receipts, assert joins, produce committed summaries |

Compilation45 medians are in `implementation/phase77/measurements.json`;
`runtime.json`, `heldout.json`, `session.json`, `simplicity.json` and
`qualification.json` preserve the other metrics. Diagnostic and clean clocks are
separate. Inclusive nested phase measurements must not be added as independent
savings. `compare-native.py` retains a historical field name mentioning baseline69;
its per-row roles and final summaries identify the actual Phase73 artifact set.

## Evidence restore

`evidence01/manifest.json` and `verification.json` bind all Phase77 raw outputs
and method bytes, including failures. After sealing, restore to a NEW directory:

```sh
python3 selfhost/tools/performance/phase77/restore-evidence.py \
  selfhost/tools/performance/phase77/evidence01 /tmp/phase77-restored
```

The split ZIP stores content-addressed objects and verifies every SHA/size/mode.
No historical inputs are overwritten. Pinned upstream, older phase baselines and
toolchains are external dependencies, identified by the reports. Absolute paths
inside raw historical plans are provenance and may require explicit relocation
for a new experiment. The shipped release uses local inventoried lineage and
does not depend on this raw-evidence restore for ordinary verification.
