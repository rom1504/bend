# Phase69 preservation producer

`seal.py` is prepared source, not a completed archive. Root must close every
Phase69 raw/method writer before running it. It runs no compiler or benchmark.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase69/artifacts/seal.py \
  --frozen --out selfhost/tools/performance/phase69/artifacts/evidence01
```

Use a fresh output directory for every attempt. The input inventory includes all
of `selfhost/build/phase69/` and `selfhost/tools/performance/phase69/`, including
the producer itself. Python cache/bytecode and generated subdirectories of this
artifacts folder are excluded. Previous packaging outputs, if any, are pinned as
external dependencies instead of being recursively archived.

The manifest preserves repository-relative paths, regular files, symlink target
bytes, directory entries, SHA-256, sizes and Unix modes. The writer reopens every
ZIP member and compares it with both its recorded hash/mode and unchanged
original; it also checks the final input path set and every pinned external file.
No original input is changed or removed.

A ZIP of at most50 MiB remains one file. Larger ZIPs become ordered byte
partitions of at most40 MiB, following the Phase68 facts-calls capsule convention.
Each partition is reread, and their concatenated bytes must match the verified
ZIP before only the redundant generated unsplit copy is removed. Concatenate
parts in the order listed in `verification.json` before using an unzip tool.

Explicit external dependencies are the
[Phase68 compiler23 facts capsule](../../phase68/facts-calls/evidence/README.md)
and [Phase68 parity investigation capsule](../../phase68/parity-survey/evidence02/README.md).
Their files are hashed at sealing. Their own dependencies, system toolchains,
pinned upstream checkout and report/design files tracked separately in Git are
not duplicated here. This is preserved experimental evidence, not a hermetic
build environment. Extract into an empty scratch directory using a tool that
preserves Unix modes and symbolic links; verify against the manifest before use.

Independent source review found no remaining blocker under root's writer freeze.
The review covered exact partition boundaries, concatenation verification,
unchanged originals, output exclusion and failure receipts. Only Python3.9 syntax
and source inspection were used before handoff; the writer has not run here.
