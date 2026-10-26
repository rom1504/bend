# Warm native edit context capture

This reuses the exact retained Phase141 N2 `program.o` and the existing,
authenticated Phase131 context runtime object. It does **not** regenerate QBE,
assemble the compiler, rebuild its source, or change installed selection.
`prepare-context-v01.py` verifies source/build/runtime lineage, replays the
diagnostic runtime's reversible source transformation, and streams the exact
N2 QBE into the existing owner-map tool. It then writes guarded jobs; preparing
the plan does not execute the linker or compiler.

```sh
python3 -B selfhost/tools/performance/phase142/profile/prepare-context-v01.py \
  --out selfhost/build/phase142/native-context-plan01 \
  --capture selfhost/build/phase142/native-context01
```

Execute the generated `jobs.json` commands in order. The first relinks only
(historically about0.3s). The second repeats the exact previously measured
Phase141 N2 batch: seed the original full compiler source, then make the real
late product-policy edit under the same logical path. Both complete QBE products
must match the existing independent oracles. Historical clean execution took
466.5s plus10.7s transport; allow470–600s for this diagnostic capture, not a new
clean prediction. The guard reserves CPU3,3GiB RSS,16GiB available memory,
128MiB per file and750s. Extra disk budget is450MiB, principally complete
products, transport receipts and the34MiB owner map.

`run-batch-context-v01.py` is a narrow version of the existing batch runner. It
adds a pinned diagnostic build/plan, `BEND_SAMPLE_CONTEXT_OUT`, and explicit
`BEND_PROFILE_COUNTERS=0`. The exact runtime checks the **value** of that variable;
with no event-output path, counters allocate no table or output. Transport
receipts identify the actual diagnostic runtime separately from its unchanged
clean runtime ABI identity. The original runtime, image and batch runner remain
untouched.

Offline `analyze-context-v01.py` uses the generic ELF and dispatch attribution
tools. An explicit adapter binds their standard pairing receipt to the completed
batch's executable, sample/context vectors and independently verified outputs.
It reports physical leaves, active dispatch owners, selected owner families and
reclamation conditioned on active owner. These are separate observations, not
inclusive logical Bend stacks or allocation-creation sites. Private synchronous
calls can retain an outer dispatch owner.

The established sampler has **no per-sample timestamps**. Approximate stage
interiors use sample CPU ordinals, charge all unaccounted wall time to the latest
possible start, charge the complete wall-minus-main-CPU gap to the earliest
possible end, and trim one second at each edge. Quality checks must pass before
these windows are shown. On the older physical capture this would retain31.5s
of the40.1s backend, roughly1,575 samples at20ms. That illustrates feasibility;
the new capture computes its own bounds. Ambiguous edges are not attributed.

This is diagnostic acquisition and semantic-output comparison. It does not
establish a speed improvement or extend ordinary N2 qualification to general
incremental sessions.
