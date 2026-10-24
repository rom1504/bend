# Object-reuse evidence capsule

This capsule records the bounded [Phase132 object-reuse experiment](../incremental.md).
It contains 924 authenticated files in `evidence.tar.xz` (2,724,932 bytes),
SHA-256 `52ff741140266d6d4378a5f24207a4ba8efbfd9e59067a2517f3d199dd2fc1e8`.
Every member was reopened and checked against its original byte count and hash.
The XZ publication retains the exact original tar stream and all members. The
original 18,177,513-byte gzip remains under ignored
`selfhost/build/phase132/object-publication-compression01/evidence.tar.gz`;
its original `receipt.json` is unchanged. `publication-compression.json`
authenticates this relocation and both encodings, without repeating semantic
qualification. Recompression and verification took 31.88s on CPU1.

The archive preserves the exact source edit, source-check and full-emission
receipts, original/edited partition plans, preparation and three build receipts,
cache receipts and child logs, all 15 complete-output gates and their oracles,
the declaration-change census, supplemental ELF comparison, five cache-refusal
controls and the methods used to interpret the evidence. No compiler or program
was executed by the archiver.

Readable copies are available beside the archive:

- `census.json`: exact changed function/data declarations and invalidated units.
- `literal-patterns.json`: bounded textual +12 operand classification, without
  semantic pool-value equivalence claims.
- `elf.json`: cached/cold allocated-section and ELF-header equality.
- `outputs.json`: all 15 commands, exit statuses and elapsed times.
- `cache-refusals.json`: five actual refusal controls before child execution.
- `inventory.json`: every included member and 438 excluded artifact identities.
- `receipt.json`: archive/method/copy hashes and scope.
- `publication-compression.json`: lossless XZ encoding, preserved gzip identity,
  exact raw tar stream identity and all-member verification.

The excluded artifacts are regenerable large compiler/unit QBE, assembly,
objects and executable images. The original and independently acquired edited
full QBE, selected native producer, runtime and toolchain remain explicitly
pinned prerequisites; this is not a self-contained native compiler distribution
or a recursive requalification of historical evidence. Small compiler-request
QBE outputs and independent program stdout oracles are included.

To inspect offline, extract into a fresh empty directory:

```sh
mkdir evidence-copy
tar -xJf evidence.tar.xz -C evidence-copy
```

Members use repository-relative names. Archived JSON retains original absolute
paths as provenance; those paths need remapping to the fresh extraction for
offline tooling, and excluded dependencies must be restored separately before
rerunning builds. Extracting the capsule does not authorize overwriting an active
build tree. This prototype was not promoted to the production compiler.
