# P6-005 retained evidence

`raw.tar.gz` contains 3,135 deduplicated byte objects for 4,243 historical file
identities. Compressed size: 12,680,028 bytes. SHA-256:
`19142ccd8c465889574b4d12d5d83e5ce944d3bd12ff8a372631fa96cfce32dd`.
Every archive object and original input byte was verified after writing.

The [manifest](manifest.json) maps each original absolute filename to an
`objects/<sha256>` member and records its original mode. Retained material
includes the full isolated source, checked bootstrap and equality derivation,
validated Base caches, all fixture copies, incorrect initial fixture gate,
unsupported/EPERM native attempts, successful reports, generated C, actual native
binaries, scheduler reexecution logs, tools, audit and preregistration.

Node and the existing Clang/LLVM toolchain are external prerequisites with hashes;
the exact CC/CPATH/library environment is retained in the manifest. Host system
libraries and physical GPU hardware are not bundled. No GPU result is claimed.

Extracting the tar creates only the content-addressed `objects/` directory. To
inspect a historical file, find its manifest identity and read the named object.
To reconstruct a tree, copy verified objects into a fresh directory using an
explicit original-root mapping, preserving recorded executable modes for native
binaries. Do not overwrite current source or recreate arbitrary absolute paths.
Historical metadata still names the original paths; relocation does not silently
create new bootstrap provenance.

[The archive script](archive.py) documents selection and verification. The
[report](../native-scalar-words.md) separates observed correctness and C-size
results from the unmeasured timing and pending combined integration. Its tracked
version may contain later archive/promotion links; the archive preserves the
report bytes at the evidence-freeze checkpoint.
