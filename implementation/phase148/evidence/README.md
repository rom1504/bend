# Phase148 evidence capsule

`capsule.tar.gz` contains 761 distinct objects (36,208,017 uncompressed bytes;
6,710,806 archive bytes). `inventory.json` maps each original repository-relative
path to its content-addressed member, exact size/SHA-256 and file mode. Every
archive member was reopened and verified after writing. The inventory records
56 sealed guards and explicitly lists omitted generated bulk.

Included: successful and rejected source snapshots, exact historical methods,
checked APIs, controls, complete output oracles, paired timing samples,
experimental native executables, both profiler captures and maps, closure
receipts, and the original authenticated Phase147 function captures. The
committed current methods are under `experiments/phase148/`; `seal.py` records
the data-only packaging procedure. No compiler or benchmark is run by sealing.

Each inventory `members` row names `object` inside the archive. To recover a
historical file, read that member, verify its `bytes` and `sha256`, then restore
it to an isolated checkout at `file` with the recorded mode. Several original
paths can reference the same object. Do not assume today's method at a given
path matches a historical receipt: ownership-v01 and analysis-v01 preserve
earlier bytes, and the assembled checked Bend sources are also retained.

Historical scripts resolve imports relative to their original repository paths.
Restore exact methods in an isolated checkout or rebuild retained source with
fresh receipts; executing a relocated historical script in place is not a valid
reproduction. Some immutable toolchain, runtime, Base and Phase147 compiler
dependencies remain separately pinned operational inputs; this is not a
self-contained archive of the host system.

Large generated QBE, assembly and object files were omitted from this compact
Git capsule. They remain hot under `selfhost/build/phase148/` and in exact,
reopened-verified archives under `selfhost/build-retention/phase148/`. The closure
receipts included here locate those archives. No artifact was pruned, and a
rebuild recipe is not claimed to reproduce historical machine bytes exactly.

This capsule establishes evidence retention, not compiler qualification or a
performance promotion. The decision and limitations are in the parent report.
