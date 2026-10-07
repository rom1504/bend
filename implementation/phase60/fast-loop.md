# A measured short compiler loop

The frozen first-only screens completed successfully: **17.528899 seconds for
four workers** and **49.509634 seconds for twelve workers**, including the runner's
CLI preflight. They provide a practical early screen for this machine and image;
they do not replace the [23-source survey](measurements.md) or semantic controls.

## What the subsets distinguish

| Source | Purpose | Included in |
|---|---|---|
| `numeric-recurrence` | Small source with little text/backend work; a negative control for String/dependency optimizations and a contrast for fixed frontend/index cost. | 20 and 60 |
| `test-map-set-ops` | Largest observed final-library stage, with substantial String and primitive-metadata work. | 20 and 60 |
| `raytrace-active` | A 14,680-byte F32 source with more loading/checking work, complementing the backend-heavy case. | 60 |

Lexer and Evening remain **holdouts**, preserving the original Phase59 anchors.
All 23 inputs and their 45 inherited runtime-point oracles remain the broad gate.
The subsets were selected after the full clean, stage and CPU surveys; their
purpose is mechanism coverage at low iteration cost, not an unbiased estimate of
population performance. The original selection preceded the allocation survey.

## Frozen projections and observed completion

| Plan | Sources × roles × rounds | Later calls | Projected queue | Actual queue stage | Actual whole CLI | Result |
|---|---:|---:|---:|---:|---:|---|
| `screen20` | 2 × 2 × 1 = 4 workers | 0 | 15.745861 s | 15.572574 s | **17.528899 s** | 4/4 PASS |
| `confirm60` | 3 × 2 × 2 = 12 workers | 0 | 47.682072 s | 47.600960 s | **49.509634 s** | 12/12 PASS |

The [frozen plan](../../selfhost/tools/performance/phase60/analysis/fast-subsets-v1.json)
(SHA-256 `b4fba95599b68d00566dbf60c1023afa71e24da0efa1fff88570c32d09ba4a33`)
used diagnostic first-only worker durations plus average observed runner overhead
for its projections. Those estimates excluded initial CLI preflight. Its original
`qualified:false` and `targetExecuted:false` fields remain historical plan facts;
completed execution is recorded separately:

- [20-second screen report](../../selfhost/build/phase60/fast20-01/report.json)
  and [whole-command receipt](../../selfhost/build/phase60/fast20-01-command-time.json).
- [60-second confirmation report](../../selfhost/build/phase60/fast60-01/report.json)
  and [whole-command receipt](../../selfhost/build/phase60/fast60-01-command-time.json).

Whole-CLI time includes the child's argument handling and artifact preflight.
It excludes the outer wrapper's plan audit, reused preparation, private cache
priming and image generation. The runner's queue budget starts after its initial
preflight; it is not a guaranteed whole-command deadline. Actual durations were
below 20/60 seconds here, but later machines, load or candidates may differ.

Each worker imports its compiler, loads the B2 API where applicable, and compiles
one source once. This is `clean`, `warmRequests=0`, with no inspector. It differs
from the full survey's first plus three later requests. The one-round screen has
no role-order balance or variability estimate; two rounds reverse role order in
the confirmation. Neither short run establishes steady-state performance.

All four/twelve fresh compilations matched their role's complete qualified raw
module bytes. The three/five mapped runtime points retain earlier successful
value oracles through artifact identity; **no runtime values were newly executed**
by these screens. Compilation timing and generated-program runtime are distinct.

## Replay the frozen baseline

From the repository root, choose fresh output names and run these commands
serially. The [wrapper](../../selfhost/tools/performance/phase60/run-screen.py)
verifies the frozen plan, launches its exact argument vector, and writes a sibling
`*-command-time.json` receipt. Existing outputs are never overwritten.

```sh
python3 -B selfhost/tools/performance/phase60/run-screen.py \
  screen20 selfhost/build/phase60/fast20-replay01

python3 -B selfhost/tools/performance/phase60/run-screen.py \
  confirm60 selfhost/build/phase60/fast60-replay01
```

Do not add an outer execution guard or launch the parent under CPU0 affinity.
The maintained runner owns the single guard and pins its targets to CPU3:
1 GiB Node heap, 2 GiB process-tree RSS, 4 GiB available-memory floor, 4 MiB stack,
20-second child bounds, and the plan's 20/60-second queue budget.

These commands replay **the frozen Phase58 B2 versus pinned TypeScript**. Changing
the output directory does not select a new compiler. A future candidate needs an
explicit qualified image binding, fresh private preparation and qualified raw
output references under a reviewed successor method. Preserve this baseline and
its receipts, run relevant semantic controls, then use the short loop for early
rejection. Recheck Lexer/Evening and the full 23-source population before making
broad claims or selecting an optimization.
