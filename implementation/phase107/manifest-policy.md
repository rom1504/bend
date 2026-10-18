# Phase107 evidence capsule policy

The capsule preserves the experiment record and the source needed to rebuild
its tools. It is not a hermetic toolchain distribution or a claim that all
historical prerequisites are present. The archive builder is
`selfhost/tools/performance/phase107/archive.py`. The coordinator closes writers
before creation; actual completion and contents are recorded by `evidence/manifest.json`.

The selected input roots are the complete `selfhost/build/phase107` tree,
every `selfhost/build/phase98/phase107-*` proof-attempt tree, the Phase106 and
Phase107 method source trees, native launcher sources, current `selfhost/src`,
and Phase107 design/report documents. Top-level tool modules include the
typed-driver import closure. Explicit dependencies include the Phase98 law
checker, Phase86 guard, common program support, Phase46 process recorder,
negative typed fixture and unequal-label proof fixture. Direct JSON-referenced
source/method files up to 4 MiB and historical JSON up to 2 MiB are also copied
when available. Older JSON dependencies are not recursively traversed: this
capsule does not silently rearchive every prior campaign.

Every failure and rejected attempt remains represented. JSON, SSA, assembly,
logs, source snapshots, small generated C and oracles are retained regardless
of a result's success status. Malformed JSON fixtures remain byte-exact and
are listed as unparsed; they are not silently removed. The selected
`native-source04/compiler` executable and its executable mode are retained,
together with its Bend source and acquisition receipt. Source and image hashes
must agree with that receipt.

The exclusions have a complete per-file inventory with mode, size, SHA256 and
reason. They include the QBE toolchain/build tree, Python caches, older compressed
release capsules, generated C and nonselected binary/object products larger
than 1 MiB, and generated API bundles larger than 512 KiB. Small objects,
executables and API bundles are retained, including corruption-test payloads;
there is no blanket deletion of binary failure evidence.
The large native `compiler.c` and kernel `producer.c` files can be regenerated
from retained sources and recorded acquisition commands, using the stated
external compiler/toolchain prerequisites. Their existing exact hashes remain
in both the exclusion inventory and original receipts. Nothing is deleted from
the working repository.

Historical receipts sometimes name an older version at a path whose current
bytes differ. For example, earlier native host controls pin a 4,714-byte
`frontend/native/run.py`, while the later method is 5,258 bytes. The builder
preserves the old declared pin and searches all retained content for an exact
hash/size match. It records matching capsule paths or an unresolved reference;
it does not relabel the current method as the older one. These occurrence-level
references include both `file` and `path` pin schemas and retain the source
receipt and JSON location. An unresolved reference can be an excluded product,
a system tool, a historical version, or another external prerequisite.

Installed compiler/Phase103 assets, previous native admissions, the historical
Cranelift executable, Clang, Bun and Lean 4.34 are external when not copied.
Their declared identities remain in the raw receipts and reference inventory.
The Phase106 Rust sources and Cargo manifest/lock are retained so the adapter
can be rebuilt with the recorded Rust dependency/toolchain prerequisites.
QBE's existing build receipt has an empty input list: the local excluded
source tree receives exact hashes, but this does not establish a verified
upstream source acquisition. The capsule makes that limitation explicit.

Creation requires a fresh output directory and `--writers-closed`. It streams
one gzip tar directly to disk, with no uncompressed tar or copy tree. The total
archive, manifest and checksum-list budget is **100,000,000 bytes**; metadata
space is reserved before compression. A budget failure leaves any partial
archive for inspection. Unexpected symlinks, inaccessible directories, changed
inputs or changed inventories fail closed. No source is executed.

The builder reopens and streams every archive member, checking its path, type,
mode, size and hash. It then rechecks every included and excluded local file,
all input inventories and the proof-root list. Only after those checks does it
publish `manifest.json` with `complete: true`. Completion certifies the capsule
contents, not the availability of unresolved prerequisites, a new compiler
qualification, or a rerun of the archived observations.

After final results and writer closure, the coordinator can run:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase107/archive.py \
  --writers-closed --out implementation/phase107/evidence
```

Use a fresh successor directory if that path already exists. Verification
requires only Python's standard library and does not execute archived tools:

```sh
python3 -B selfhost/tools/performance/phase107/archive.py \
  --verify-only implementation/phase107/evidence
```

Members use repository-relative paths and contain only regular files. After
verification, extract into an empty directory to inspect the capsule without
overwriting the working checkout. `FILES.sha256` checks extracted bytes;
Verification also requires exactly the three published capsule files, with no
extra directories or symlinks. `manifest.json` additionally records original modes, exclusions, reference
resolution and the selected image's acquisition provenance. Recorded absolute
paths identify the original workspace; rebuilding elsewhere requires adjusting
those paths or recreating the original layout while retaining the pinned inputs.
