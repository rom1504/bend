# Phase132 incremental boundary census

`inventory.py` reads retained QBE and `nm -u` metadata only. It does not execute
the compiler, alter QBE or delete functions. It records the conservative global
reference graph including data and all exported roots; its output is explicitly
not a semantic reachability certificate.

```sh
taskset -c 1 python3 selfhost/tools/performance/phase132/boundaries/inventory.py \
  --qbe selfhost/build/phase130/p131-final-self01/program.ssa \
  --runtime-object selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out /tmp/phase132-boundary-fresh.json
```

The script requires a fresh output path. Evidence and source-grounded conclusions
are in [the audit](../../../../../research/phase132/incremental-boundaries.md).
The inventory lists functions with no incoming global reference separately from
the graph-unrooted count: a private unreachable cycle can have incoming edges.
Numeric runtime FIDs are not interpreted by the scanner; all dispatch-table
entries are retained as conservative roots.
