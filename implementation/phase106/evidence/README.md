# Phase106 evidence capsule

[Manifest](manifest.json) · [Per-file SHA256](FILES.sha256) ·
[Compressed observations](observations.tar.gz).

The verified capsule contains 4658 files (3,867,589 compressed bytes): all
Phase106 run reports/child clocks/guard logs, generated C and JSON, measured
objects and executables, source snapshots and admission attempts, the runnable
Cranelift adapter, method sources, and positive/negative proof evidence. Failed
attempts remain present. `archive.py` checked every archived file against its
recorded SHA256 after compression.

Convenient uncompressed reports:

- [Repeated matrix](measurements.json): 120 measured build/link/run products.
- [Analysis and training-only choices](analysis.json).
- [Fresh two-size and one-shot confirmation](confirmation.json).
- [Independent laws](laws.json) and [semantic mutations](mutations.json).
- [Accepted law-source manifest](law-source.json).

Extract into an empty directory, preserving repository-relative paths:

```sh
mkdir phase106-evidence
tar -xzf implementation/phase106/evidence/observations.tar.gz -C phase106-evidence
(cd phase106-evidence && sha256sum -c ../implementation/phase106/evidence/FILES.sha256)
```

The archive deliberately excludes Cargo caches/intermediate builds and duplicate
full compiler C/ELF files. Their exact hashes remain in the attribution records;
those artifacts already belong to the authenticated candidate04/Phase105 baseline.
It does not vendor earlier installed assets, Bun/Lean/Clang or the old reference
checkouts. Exact executable replay requires those separately authenticated
prerequisites and the recorded Linux x86-64 ABI. Receipts retain original absolute
paths and CPU/resource settings; extraction alone does not rewrite them or make
performance portable to other hardware.

Important paths inside the capsule are `selfhost/build/phase106/{artifacts02,
producer-native02,controls04,measure01,confirm01,fullself-profile01,
self-clang-clean01}` and `selfhost/build/phase98/phase106-law-{check02,mutants02}`.
Earlier numbered attempts explain the rejected source/proof/harness versions.
Top-level report copies are byte-identical to their originals; the archive
manifest binds the complete originals, not only rounded summary tables.

The capsule records methods at archival time. Later documentation edits and
plot-label cleanup do not alter measured executable products or their input pins.
