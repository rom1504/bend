# Portable runtime profiles

`runtime-recipes.json` stores fourteen exact edits to the authenticated selected
runtime `9e1c5907…`. The materializer verifies the input and every intermediate
and output hash. This replaces three duplicated85KiB runtime copies.

- **v1**, `d56fe7a0…`: portable trampoline, wide scalar arguments plus state pointer.
- **v2**, `17cece2e…`: one state pointer per segment, unchanged ownership/atomics.
- **v3**, `bffb4258…`: five typed, single-evaluation scalar accessor macros for cproc.

`prepare.py --out FRESH` materializes v3 by default and authenticates its cached
bytes. `--variant v1|v2|v3` replays earlier candidates; `--runtime PATH` accepts an
explicit experimental template with the same five-part reconstruction checks.
For source-only materialization without preparing the compiler:

```sh
python3 -B selfhost/tools/performance/phase108/runtime/materialize.py \
  --variant v3 --out selfhost/build/phase108/my-runtime/runtime.c
```

Outputs and adjacent materialization receipts must be fresh. Exact materialized
runtime snapshots remain in the build evidence. Recipes do not inspect or alter
Bend-generated program bodies. `rebind.py` changes only complete authenticated
literal runtime parts of an already emitted image during research, checks its
inverse exactly, and leaves the intervening program text unchanged. Ordinary
compilation emits the chosen template through Bend instead.

`bridge-metadata.py` is the temporary Q0 bootstrap bridge. It adds exactly four
register metadata definitions missing from the old trusted producer. The compiler
source implements these definitions in Bend, so subsequent emissions need no bridge.
