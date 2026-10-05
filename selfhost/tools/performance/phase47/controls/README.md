# Phase47 independent controls

These are untimed semantic experiments. Root executes all compiler/program jobs
serially with the maintained resource guard. A passing fixture alone does not
prove the optimization was selected: the Array controllers separately check
raw-entry activation and public/host refusal.

- `array-view-v1.bend` / `array-view-catalog-v1.json`: four-cell recurrence and
  public Array boundaries. `array-view-controls-v2.mjs` is the final expanded
  controller: 24 scalar oracles and 39 host/alias/demand boundaries. Version1
  remains the consumed historical controller.
- `array-layout-v3.bend` / `array-layout-catalog-v3.json`: renamed two/four-array
  records, role swaps, aliases, public records and ordered writes.
  `array-layout-controls-v3.mjs` checks 77 scalar results, 56 public states and
  seven order/demand boundaries, plus separate activation/refusal witnesses.
- `jw-optimize-v1.bend` preserves an affine-field fixture error; v2 fixes only
  that declaration. Worker IR/source controllers remain evidence for the
  deferred worker cleanup, not qualification of the selected Array compiler.
  `jw-ir-controls-v2.mjs` was prepared but has not been executed in this campaign.

Acquire each catalog with `programs/prepare.py --attempt CHECKED --set fast`
using a fresh output directory, then pass exact baseline/candidate module paths
and a fresh report directory to the corresponding controller. The retained
[control plan](../../../../../implementation/phase47/control-plan.md) gives
commands, cases and measured scope. Controller diagnostics are never included
in clean execution timing.
