# Phase101 evidence

`phase101.tar.xz` preserves all 5,532 files in the local experiment tree,
including failed preparations/captures, rejected variants, generated C and ELF,
full application outputs, independent expected bytes, guard receipts, profiles
and method snapshots. It contains 568,733,673 uncompressed bytes in 3,338,592
compressed bytes. Every member's path, size, mode and SHA256 was checked after
archive creation; see [manifest.json](manifest.json) and [receipt.json](receipt.json).

Archive SHA256:
`ca878cc9391758af47b7fa94c2e97b1ceb8764e723031b2b8d0d89078022b828`.

Restore into a fresh repository tree, preserving existing experiments:

```sh
tar --keep-old-files -xJf implementation/phase101/evidence/phase101.tar.xz
```

The [archiver](../../../selfhost/tools/performance/phase101/archive.py) is tracked.
Receipts contain the original absolute repository root
`/home/ai/bend2/build/publish/bend`. Existing paths are intentional evidence,
not portable new installations. At another location acquire new products with
explicit new bindings rather than relabeling old receipts.

The capsule references, but does not duplicate, installed Phase98 compiler
images/assets, pinned Clang/Bun and Phase100 baseline/upstream products and
fixtures. Restore those from their earlier evidence/release instructions before
replaying a dependent job. The [Phase100 capsule](../../phase100/evidence/README.md)
contains its saved applications and expected outputs. Final changed candidates
and their outputs are included here; current methods and control sources are
tracked outside the archive too.

Earlier preparation revisions were not all snapshotted before editing. Their
recorded source/method hashes, generated C, diagnostic locations and expected
bytes remain; this archive does not claim to recover every old source body from
its hash. Later final runs snapshot the transformation/runtime methods and use
the tracked final control sources. In particular the earlier computed-match
Array rejection is preserved as a failed admission, not relabeled a passing
control. All profile overruns and adapter failures retain their original status.
