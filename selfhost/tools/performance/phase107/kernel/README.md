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
  closed-allocation scalar field replacement after the fast pipeline. Since
  kernel-source03, a necessary-condition scan returns allocation-free IR exactly
  unchanged before promotion's verifier and analysis. It scans every function and
  nested conditional/loop body, so an allocation in a branch is not skipped.

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

## Fast comparison loop

After acquiring matching native and JS images, run a small paired screen through
the serial resource guard. This command reuses source03 and creates fresh output
directories; change both output names for another run:

```sh
python3 selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase107/kernel-measure04-guard \
  --seconds 60 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase107/kernel/measure.py \
  --source selfhost/build/phase107/kernel-source03/producer.bend \
  --native selfhost/build/phase107/kernel-source03/producer \
  --api selfhost/build/phase107/kernel-source03/api.mjs \
  --out selfhost/build/phase107/kernel-measure04 \
  --rounds 3 --policies fast,promote --workloads many,shared,text --formats json
```

Use `--policies checked,fast` to isolate repeated verifier overhead on identical
transformation sequences. Use `--policies fast,promote` to measure promotion's
incremental cost; their products may differ on memory workloads. Use
`--formats json,qbe` when changing serialization or entry fusion. The runner
compares native versus JS output exactly for every workload/policy/format pair;
it does not automatically prove equivalence between different policies. Preserve
the separate correctness-audit receipts for that claim. Defaults still select
`raw,pure,memory`; explicitly select the new policies when testing them.

The source03 [paired screen](../../../../build/phase107/kernel-measure03/report.json)
passed 18 exact comparisons over three rounds in 10.06s. On allocation-free `many`,
complete-process medians were:

| Host | `fast` | `promote` |
|---|---:|---:|
| Native Bend |91.336ms|90.479ms|
| Bun-hosted Bend output |1273.854ms|1268.432ms|

The small difference is not evidence that adding promotion speeds up this graph;
the useful result is that its prior unnecessary overhead disappeared. Source02's
`promote` medians were 153.816ms native and 2314.036ms JS. That historical cross-image
comparison is descriptive, while the matched source03 policies isolate the no-op
cost. The allocation-bearing `shared` graph still has useful promotion work:
4.103/4.587ms native and 70.791/97.846ms JS for `fast`/`promote` respectively. These
are IR-kernel process times, not compiled-program execution or full source
compilation timings, and startup materially affects small cases.

The [promotion audit](../../../../build/phase107/promotion-audit03/report.json)
passes 28 families, 468 native outputs and 334 independent model executions, plus
two detected mutations. Its seven
[predicate controls](../../../../build/phase107/promotion-audit03/predicates.json)
pass, and [all 27 previous JSON products](../../../../build/phase107/promotion-audit03/prefilter-equivalence.json)
are byte-identical. The new native kernel's one-time acquisition cost 45.909s:
[7.891s C emission](../../../../build/phase107/kernel-emit03-guard/process.json)
plus [38.017s successful linking](../../../../build/phase107/kernel-link03b-guard/process.json).
The earlier bad executable-path attempt remains in `kernel-link03-guard`; it failed
before compiler execution and is not the successful-link receipt. Keep acquisition
cost separate from repeated research requests.
