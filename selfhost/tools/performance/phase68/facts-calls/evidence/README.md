# Compiler23 campaign capsule

This archive preserves 5,135 files (402,706,695 uncompressed bytes), including
compiler21/22/23 snapshots, genuine B2 images, failed bootstrap22, native C and
binaries, all timing/control receipts, four new V8 profiles, diagnostic sources
and the saved compiler20/upstream runtime baselines. Python bytecode is excluded.
The two parts are 40 MiB and 12.7 MiB; together they are 55,290,380 bytes.

`manifest.json` records every member's SHA-256/size and each part's hash. Every
member was reopened and compared both with its recorded hash and the unchanged
original file. The parts were reread and their concatenation verified against
the original archive hash. No original raw file was removed or rewritten.

The first packaging attempt exceeded the 50 MiB single-file publication cap.
`attempt01.json` and `attempt01-capsule.py` retain that failure and its producer.
The successor verified and split the same archive bytes, then removed only the
redundant unsplit copy. This was a packaging limit, not a compiler/test failure.

To inspect, concatenate the parts in order:

```sh
cat facts-and-fallback23.zip.part001 facts-and-fallback23.zip.part002 > /tmp/facts-and-fallback23.zip
sha256sum /tmp/facts-and-fallback23.zip
```

Expected SHA-256:
`e894c83dd4a082e9872c955ee4a524250fd211226e1875644ed0736566cbb58a`.
Extract into an empty scratch directory; never overwrite an existing raw tree.
Members have repository-relative paths under `selfhost/build`. Saved binaries
named `program` need their executable bit restored before running. Reverify
their manifest hashes and use the recorded work counts/oracles.

Receipts preserve original absolute machine paths. Fresh runs need fresh plans
with current paths, the pinned upstream checkout 0592662, Node 24.18.0 and the
recorded Clang 22 toolchain/environment. System toolchains and the full upstream
checkout are external. Older compiler20 CPU profiles and unrelated historical
receipts referenced by plans remain in their original evidence collections;
this capsule is not a hermetic build environment or a complete Phase68 archive.

[Report](../../../../../../implementation/phase68/native-facts-and-calls.md) ·
[methods](../README.md).
