# Bounded post-H profile plan

Profile final `selected-build01` candidate and the retained mature C products
for **tree-bitonic, coverage-expression-32, and lexer**. These are the three
cases with pre-H physical baselines and direct witnesses of removed dispatch.
Use one clean process and two sampled processes per case-role: 18 processes,
2.9 calibrated CPU seconds each, approximately **52.2 CPU seconds** total.
The explicit outer guard caps the lane at **60 wall seconds**. A timeout remains
an incomplete capture, not permission to weaken admission or reuse partial pools.

Numeric/local-fold are omitted from this lane: the maintained planner requires
at least 2.6 seconds per run, so five cases × two roles × three processes would
cost at least 78 CPU seconds. Do not lower that bound or change sampling policy
merely to claim all five fit. They can be a separate later capture if needed.

## Preparation and exact inputs

[inputs.json](../../selfhost/build/phase192/profile-posth-preparation02/inputs.json)
pins the selected-build01 program manifest, Phase192 reference manifest,
runtime-manifest02, maintained planner, all-created-thread sampler, and its
successful build receipt. Preparation explicitly checks that every candidate
and C binary in the runtime manifest equals its authoritative product manifest.

`runtime02/report.json` retains 30 admitted cases and an incomplete calibration
for a later case; it will remain immutable and incomplete. The continuation
receipt is `runtime-combined01/report.json`, authenticated from the original
30 cases and the remaining 15 under the same frozen roles and policy. Its
composition metadata retains the segment boundary. Preparation version 02
binds that combined report; version 01 remains preserved. The ready offline
command below refuses an absent or incomplete receipt; once available it calls
the unchanged maintained
planner, which verifies the exact manifest, calibrated commands/counts, executable
identities, independent outputs, and all pinned inputs before creating a recipe.

```sh
python3 -B selfhost/build/phase192/profile-posth-preparation02/prepare.py
```

This preparation command executes no compiler or target. It creates fresh
`profile-plan02/{recipe.json,manifest.json,plan.json}` and
`profile-posth-preparation02/bounded-execution.json`, then prints exact capture
and offline-analysis commands. The latter receipt binds the plan and records
the sole execution-policy override: shortening the generic outer wall guard
to 60 seconds. It leaves the frozen recipe and all admission gates unchanged.

Run from the repository root only after successful preparation:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase192/profile02-guard \
  --run-root selfhost/build/phase192/profile02 \
  --seconds 60 --disk-mib 128 --rss-mib 2048 \
  --available-mib 16384 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase192/profile-plan02/manifest.json \
  --out selfhost/build/phase192/profile02 \
  --modes clean,sample --rounds 1 --periods-us 8000,13000
```

Use the absolute command printed by preparation for the exact Python binding.
The generic disk guard retains its 5 GiB reserve. Outputs are bounded at
128 MiB, RSS at 2 GiB, with a 16 GiB available-memory floor. Expected sample
count is about 586 per within-role pool. Capture duration/admission is an
estimate, not a guarantee; roots must be fresh and no frozen evidence is edited.

After a completed capture, the printed offline commands run the existing
`compare.py` and `render.py` into `profile-plan02/comparison.json` and `summary.md`.
They execute no targets. Raw analyses can be recomputed with the same method
as `profile-analysis01`, without reusing old worker address spans.

## Questions and interpretation

For tree/expression, compare actual selected `p114r` worker, remaining public
wrapper, runtime dispatch, anonymous continuations, and ctor/take physical
shares. For lexer, distinguish generator/continuation work from `product.lex`
classification and `product.step.at`; the scoped frame expansion's changed
argument snapshots make whole-worker attribution especially useful. Report the
new dominant leaves before proposing further register or constructor changes.

Preserve exact executable identity, complete output, zero drops/overruns, thread
lifecycle, process/window coverage, at least 500 pooled samples, and both sample
periods. Retain unknown PCs in the denominator and state whether the additional
historical zero-unknown rule would fail. One clean observation and two periods
do not provide confidence intervals or a causal speedup estimate.

Each case-role is a distinct workload with independently calibrated repetitions.
The comparator must produce **zero cross-role pooled comparisons**. Normalize
each role's clean or attributed CPU by its own repetition count; do not compare
unequal-duration command totals as identical work. Startup/warmups/validation
remain included. Pre-H and post-H sample shares identify physical changes, not
removable overhead or inclusive source costs. The authenticated combined runtime report remains the performance
authority, separate from diagnostic sampling.
