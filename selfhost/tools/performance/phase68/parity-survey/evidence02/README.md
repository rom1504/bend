# Compiler23 parity survey capsule

This verified archive preserves 975 files
(55,759,495 uncompressed bytes): every frozen
`selfhost/build/phase68/parity-survey23*` file and every parity-survey tool,
including failed attempts and preserved producer versions. Python bytecode
and the old/current generated evidence directories are excluded. Original raw files were
not edited, removed or deduplicated.

`manifest.json` records repository-relative member paths, SHA-256, byte count
and Unix modes. `verification.json` records the reopened archive check and a
second comparison against every unchanged original. `capsule.zip` is
12,461,641 bytes, below the50MiB publication limit, SHA-256:

`e2675e102ed8482dcbab9571bebeed10dd7efbaf716d7b962b1fffe9c8a1afb1`

Inspect the manifest and extract into an empty scratch directory; never
overwrite an existing evidence tree:

```sh
sha256sum capsule.zip
unzip -l capsule.zip
mkdir /tmp/bend-c23-parity-survey
unzip capsule.zip -d /tmp/bend-c23-parity-survey
```

The ZIP stores Unix executable bits and symlink modes. Use an extractor that
preserves them; Python's basic `ZipFile.extractall` does not restore all Unix
attributes. Verify extracted bytes and modes against the manifest before
running saved binaries. Receipts retain their original absolute machine paths;
replay uses fresh output paths and may require a fresh plan.

The [first packaging attempt](../evidence/README.md) failed a name-order
comparison despite identical member sets. Its producer, manifest, failure
receipt and partial ZIP remain separately preserved; the successor manifest
binds their hashes as external dependencies. No earlier failure is relabeled
successful.

This is not a hermetic build environment. Earlier candidate/upstream C, native
binaries, compiler images and qualification receipts come from the
[facts-calls capsule](../../facts-calls/evidence/README.md), with its own stated
historical dependencies. System Clang/linker/binutils, pinned upstream checkout
and unrelated previous receipts remain external. Main reports and small
summaries are tracked repository files rather than duplicate ZIP members.

[Investigation methods](../README.md) ·
[Central report](../../../../../../implementation/phase68/c23-parity-survey.md).
