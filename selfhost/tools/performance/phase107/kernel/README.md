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
kernel WORKLOAD raw|pure|memory json|qbe
```

The manifest explicitly records all policies. `pure` runs self-tail conversion,
entry-first inlining with4096-node budget, folding and reachability. `memory` adds
leaf inlining after initial reachability, then folds and removes unreachable
functions again. Raw performs no transform. QBE entry fusion is enabled only for
pure/memory; its512-node cap remains unchanged.

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
