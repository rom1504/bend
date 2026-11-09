# P186-003 — compose several pending frames with local recursive regions

Existing local recursive workers could handle particular individual pushes and
calls but rejected computations that push multiple frames before descending.
The experiment preserves each pending frame, then continues the same closed
region analysis. It does not replace the explicit stack with native recursion.

`stacked-frames.bend` adds a private PushFrame node and reuses the existing final
closure checks: at most eight known cases, bounded exact captures, incoming
results, reserved-name hygiene and scalar/call restrictions. Previously admitted
plans are returned unchanged. Unknown calls and incomplete closures retain the
original route. Each executed push increments depth once; unwind restores and
pops frames in LIFO order.

Fourteen admission/verification rows and two independent machine modes pass.
Each mode has 42 observations, including 100,001-level explicit descent,
alternating pushes/branches, full-width arithmetic, restored state and canaries.
These finite observations and structural checks are not a BendTT theorem.

The `stack-only-qbe-runtime01` comparison against the first candidate measures
21.06% less Unicode-text runtime and 13.78% less generic-row runtime. Map, tree
and record stay within 0.63%. This isolates the continuation addition after the
failed unique-take hook was removed. The final selected QBE source excludes both
unique-take prototypes. Actual native self-reproduction and finite qualification
are separate final integration gates; see [Phase186](../../implementation/phase186/README.md).
