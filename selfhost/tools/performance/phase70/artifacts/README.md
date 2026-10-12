# Phase70 preservation producer

`seal.py` is prepared source. No Phase70 archive has been created here. Root
must close every Phase70 raw and method writer before running it. The producer
runs no compiler or benchmark and never changes or removes original inputs.

From the repository root, after that freeze:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/artifacts/seal.py \
  --frozen --out selfhost/tools/performance/phase70/artifacts/evidence01
```

Use a fresh output directory for every attempt. All files and directories under
`selfhost/build/phase70/` and `selfhost/tools/performance/phase70/` are captured,
including failed attempts, source snapshots, target receipts, analysis tools and
this producer. Python caches/bytecode and generated subdirectories of this
artifacts folder are excluded. Previous packaging attempts remain unchanged and
are pinned as external dependencies instead of recursively archived.

The manifest records repository-relative paths, regular files, symbolic-link
target bytes, directory entries, SHA-256, byte sizes and Unix modes. The producer
reopens every ZIP member and verifies its bytes and mode against the manifest
and unchanged original. It then rechecks the input path set, every input and
every pinned external file. `verification.json` must report `complete: true`;
partial ZIPs and failure receipts are retained on failure.

A ZIP of at most 50 MiB remains one file. Larger ZIPs are split into ordered
byte partitions of at most 40 MiB. Every partition is reread, and their
concatenation must equal the verified ZIP before only the redundant generated
unsplit copy is removed. To restore, concatenate parts in the order recorded in
`verification.json`; extract into an empty scratch directory using an extractor
that preserves Unix modes and symbolic links, then check the manifest.

External inputs are pinned by file hash at sealing:

- [Phase69 baseline capsule](../../phase69/artifacts/evidence01/README.md).
- [Phase68 compiler23 facts capsule](../../phase68/facts-calls/evidence/README.md).
- [Phase68 parity investigation capsule](../../phase68/parity-survey/evidence02/README.md).

Those capsules preserve the baseline evidence referenced by Phase70 receipts.
Their own dependencies, system toolchains, upstream checkout and separately
tracked designs/reports are not duplicated. This archive preserves experimental
evidence; it is not a hermetic build environment. Historical absolute paths in
receipts need fresh replay plans.

The open-writer inventory at 2026-10-12 01:50:29 UTC contained 10,005 raw files
totalling 470,711,959 bytes and 278 method files totalling 958,090 bytes. This is
an estimate, not the final manifest. Phase69 compressed to 20.49% of its input
size; the same ratio would yield roughly 92 MiB here, likely three partitions.
Allow extra temporary space for both the compressed ZIP and its partitions.

The producer is derived from the successfully verified
[Phase69 seal implementation](../../phase69/artifacts/seal.py).
`seal.derivation.json` pins both source hashes and every substitution; independent
review reproduced the successor byte for byte. Archive logic is unchanged;
campaign paths/labels and the explicit Phase69 external dependency differ.
Python 3.9 syntax was checked without importing or executing the writer. Root
owns the freeze and execution decision.
