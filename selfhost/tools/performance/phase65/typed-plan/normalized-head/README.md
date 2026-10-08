# Normalized annotation head: diagnostic only

Read [the experiment report](../../../../../../implementation/phase65/typed-plan.md).
The isolated `candidate.patch` applies only to `selfhost/src/check/annotate.bend`;
`candidate.json` pins before/after source and the patch. Root should freeze a
checked diagnostic snapshot, then restore live source immediately. Public
annotation product compatibility is not established by this experiment.

Root-supervised command, inside the usual bounded CPU3 attempt:

```sh
node selfhost/tools/performance/phase65/typed-plan/normalized-head/compare.mjs \
  selfhost/build/phase65/checked-state02 \
  selfhost/build/phase65/state02-head-controls01
```

For a fast subset, append the explicit `cases.json` path, then case IDs:
`recursive-host-alias scc-alias-v2 erased-demand numeric-recurrence test-map-set-ops`.
Omitting the catalog runs all 16 cases. A supplied broader catalog must have
`cases`, each with `id` and `file` (or `source.file`); paths are relative to that
catalog. Optional `roots`, `points`, `status`, `diagnosticIncludes` and
`definitionBudget` fields define stronger oracles. Unexpected equal failures
are failures, not proof of conformance.

The append-only controller is intended for named checked B1 APIs and preflights
all private declarations. It does not mutate the verified parent image. Full
output equality is stronger than a work counter, and neither is a timing result.
No target has been run by the artifact author.
