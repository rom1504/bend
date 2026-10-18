# Native IR kernel comparison

This small producer isolates Bend workload construction, optimization, verification
and QBE/JSON emission from source parsing/checking and backend tool processes. It
tests whether large optimizer costs persist when the same Bend code runs natively.
It is not a complete compiler or a source-frontend benchmark.

`prepare.py --out NEW_DIR` assembles existing checked modules and snapshots every
input. No compiler runs during preparation. Acquire `producer.bend` with the
installed native compiler and the same pinned startup as Phase106, with
`BEND_NATIVE_HOST=1`. The native invocation is:

```text
kernel WORKLOAD raw|pure|memory|checked|fast|promote json|qbe
```

The manifest explicitly records all policies. `pure` runs self-tail conversion,
entry-first inlining with a 4096-node budget, folding and reachability. `memory` adds
leaf inlining after initial reachability, then folds and removes unreachable
functions again. Raw performs no transform. These three policies are unchanged
from kernel-source01. New policies are:

- `checked`: public self-tail, demand inlining (4096), reachability, leaf inlining
  (4096), reachability, memory forwarding, then constant folding.
- `fast`: `nx_pipeline_fast`, with the same transformation order and bounded
  internal pass cores; verifies admission and final output rather than repeatedly
  verifying every public pass boundary.
- `promote`: `nx_scalar_promote(nx_pipeline_fast(program))`, adding bounded
  closed-allocation scalar field replacement after the fast pipeline.

QBE entry fusion is enabled for every policy except raw; its 512-node cap remains
unchanged. Compare exact JSON/IL output for checked and fast before interpreting
their timing difference as validation overhead. `promote` can change code shape
and requires independent output equivalence, not byte-for-byte output equality.

For a matching JS run, build a checked API from the same `producer.bend` exporting
the four names in the manifest, then invoke:

```text
bun kernel.mjs API.mjs WORKLOAD POLICY FORMAT FRESH_OUTPUT FRESH_REPORT
```

The adapter calls the same Bend policy/text functions, avoiding a second host
implementation of the pipeline. It retains construction, optimization, verifier,
emission and API-load clocks. Native process clocks include those operations and
startup/printing, so compare complete process clocks separately from JS inner
optimization clocks. Output includes the same final newline as native `IO.print`;
exact JSON/IL equality should precede performance claims. Benchmark both `many`
and a smaller workload to distinguish graph-size costs from process overhead.

This raw policy differs from older benchmark rows labelled budget0 that still
ran constant folding. The memory policy also performs final reachability, so it
must not be silently equated with an older leaf/reach/fold-only row.
