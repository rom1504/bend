# Real-source lowering-context controls

These six small Bend programs challenge the context change in JDPlan. They are
source candidates until root executes the runner; creating them is not a pass.

Under the root's serial CPU3 process-tree supervisor:

```sh
node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase63/backend-context-controls/run.mjs \
  selfhost/build/phase63/CHECKED_ATTEMPT \
  selfhost/build/phase63/NEW_CONTEXT_OUTPUT
```

An optional list of case IDs selects a smaller retry. Output must be new, and
must live under Phase63 build storage. The runner expects a verified strict
checked B1 containing the four JDPlan exports. It creates an append-only
diagnostic API with private context helpers; that derivative is not installed
or given a checked sidecar.

Ordinary library compilation roots every user definition, including user type
aliases. Consequently a superficially relevant alias fixture might never cross
the full/pruned context boundary. This runner explicitly restricts diagnostic
library roots to each manifest's public probes, while preserving the real
frontend, checking, source closure, annotation, layouts and lowering. It requires
every named alias to occur in the initial selected set, disappear from runtime
reachability, and have a different `value` in the two lookup contexts.

For each source it compares retained definitions, call facts, SCC membership and
bounce flags, then three complete emitted libraries:

1. Fresh lowering under the old pruned annotation overlay.
2. Fresh lowering under JDPlan's complete immutable annotation overlay.
3. Rendering the actual saved JDPlan.

All three must have identical bytes and pass the manifest's independent runtime
oracles. There are 15 points (45 executions), including native floats, BigInt Nat,
recursive public aggregates, unequal-width mutual tail recursion and a dead
recursive computation that must never execute. BigInts use `{"bigint":"12"}` in
JSON evidence. Every input/output identity is recorded; failures are preserved
per case. The recursive host fixture specifically challenges nested annotation
keys and Nat marshalling inside `List` through a type alias.

Exact/over reach budgets and malformed emitted metadata belong to the separate
`../controls/plan-reach-v1.mjs` controls. These source fixtures cannot establish
universal annotation equivalence or qualify all refusal boundaries. They provide
real checked examples of the boundary that mock graph tests do not exercise.
