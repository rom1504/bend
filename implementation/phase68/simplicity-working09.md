# Working09 source size and concepts

The [frozen module census](evidence/source-census-working09.json) compares the
actual installed Phase67 source snapshot (`scalars-build01`, B1 `c76f1113…`)
with Phase68 working09 (`inline-build09`, B1 `8894d861…`). It counts the Bend
modules listed in each compiler manifest once. It excludes the unused legacy
`src/compiler.bend`, generated assembly, fixtures, proposals, tests,
documentation, host tooling, native/JS
runtimes and generated images. This is a development comparison, not release
qualification or a complete repository-maintenance cost.

| Metric | Phase67 | Working09 | Change |
| --- | ---: | ---: | ---: |
| Modules | 115 | 117 | +2 |
| Physical lines | 28,536 | 29,040 | +504 (+1.77%) |
| Code lines | 23,388 | 23,797 | +409 (+1.75%) |
| Definitions | 3,288 | 3,356 | +68 |
| Laws | 642 | 643 | +1 |
| Types | 119 | 121 | +2 |

The source grew. Sharing typed arity queries removes a duplicated conceptual
boundary between JavaScript and C, but does not offset the new native worker
machinery. Three types were added (`NC_Target`, `NF_Worker`,
`NC_EnvPartition`); the intrinsic template change removed `ni_Op`.
The existing `N_Emitted` prefix/value representation and 32-bit trie are reused.
There is no defensible single numeric count of semantic concepts: the main
additional obligations are destination-aware control flow, dependency-based
worker admission and preserving ordered ownership operations with summaries.
The [architecture guide](../../docs/self_hosted/native-value-lowering.md)
describes those boundaries and their fallbacks.

Counts follow the Phase66 method: UTF-8 `splitlines`, excluding blank and
full-line `#` comments for code lines, and anchored `def`, `law`, `type`
declarations. Every manifest/module hash is checked against its recorded
frozen attempt. The receipt uses repository-relative paths and contains all
module hashes and counts. Product candidates are outside this snapshot.

To reproduce from the retained frozen snapshots, choose a fresh output file:

```sh
taskset -c 0 python3 implementation/phase68/source-census.py /tmp/phase68-census-replay.json
```

This command reads files and writes the receipt; it executes no compiler,
Clang or generated program.
