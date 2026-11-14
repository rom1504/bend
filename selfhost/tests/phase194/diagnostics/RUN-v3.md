# Version 3 memory diagnostics

Use `catalog-v3.json`, `oracle-v3.py`, `build-programs-v3.py`, and
`runtime-loop-v3.py`. The original and v2 files remain unchanged, including
their failed emission evidence. The first ten programs and all expected
values remain unchanged.

The accepted `variation-local-fold-128-0.bend` fixture supplies the v3 memory
structure: `read_step` destructures its `got` parameter, `read_cell`
destructures its state parameter/fields, `read_loop` directly recurses on a
cell result, and `read_finish` extracts the accumulator. There are no forward
laws, computed-value scrutinees, mutual helper recursion, or unsafe markers.
Both variants carry `((array,index),accumulator)` and preserve the same loads,
successor cycle, and outputs. Their new source pins and precise lineage pin
are recorded in the v3 catalog.

For the memory-only checked emission, use `emit-programs-v2.mjs` with:

```sh
--catalog selfhost/tests/phase194/diagnostics/catalog-v3.json \
--cases memory-dependence-sequential,memory-dependence-dependent
```

This emitter version accepts any nonempty unique CSV subset of the existing
twelve IDs, in addition to `first3` and `full12`. Every selection still
authenticates the complete twelve-case catalog and all source/oracle pins.
`build-programs-v3.py` permits exactly first3, the ordered memory pair, or
full12. The additionally preserved `emit-programs-v3.mjs` offers the narrower
named `memory2` selection, but the CSV-capable v2 emitter is the recommended
transport for the fast check.

After memory-only acceptance, use `--cases full12` for the complete emission.
The runtime adapter still requires full12 products in each of four roles;
memory-only evidence cannot qualify a complete diagnostic timing run.
Follow RUN-v2.md's merge/run commands with `runtime-loop-v3.py` and
`catalog-v3.json` substituted. Its 96 both-point checks, balanced calibrated
timing, exact output validation, and diagnostic-only scope are unchanged.

The original failures are distinct: v1 used a live unfilled forward law;
v2 attempted to destructure a computed `Array.get` result. V3 follows the
language's parameter/field restriction directly. Metadata/oracle/Python
syntax checks pass at handoff; root-owned source checking and target
execution remain required for the two new sources.
