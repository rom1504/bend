# Phase82 sealed evidence

8,977 files,2,644 unique content objects,435,143,659 input bytes. The verified
ZIP archive is44,367,605 bytes, split into32MiB-or-smaller parts. All original
content, modes and links are recorded in `manifest.json`; every archived object
was rehashed and every source reverified after compression.

Archive SHA256: `6bfbff75ecb62341f6dc1ecd206e6c93562da3ae03033f3ee458d207b4851a6b`.
Manifest SHA256: `a77e6910961aec2d0303e584d5a001938f2c543c9f9598513447a53b5ce8d97a`.

Restore into a new directory, from the repository root:

```sh
python3 selfhost/tools/performance/phase82/restore-evidence.py \
  selfhost/tools/performance/phase82/evidence01 /tmp/phase82-restored
```

Historical phase evidence, the pinned upstream checkout and toolchains remain
external dependencies. This archive preserves all Phase82 raw candidates,
failures, controls, measurements, profiles and methods. Private usage files are
excluded. The current installed package and lineage are separately tracked in
Git. See the [report](../../../../../implementation/phase82/README.md).
