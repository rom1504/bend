# Closed Phase40 evidence

All raw Phase40 writers are [closed](../raw-closure.json). This capsule preserves
**26,793 files and 6,419 directories**, with **320,047,611 logical file bytes**.
It includes all checked attempts, rejected candidates, source acquisitions,
semantic controls and their failures, clean execution timings, compiler costs,
profiles, corrected diagnostic successors and installed-release checks. Nothing
is filtered according to success. Bytecode-cache exclusions are explicit.

The single gzip/PAX tar stream is split into two ordered volumes, each at most
40 MiB. Combined compressed size: **49,947,767 bytes**. Stream SHA256:
`68e2fbac1cefe532b55b8a4be60efce6905eeda66bc983499e903e8fd8b990be`.
The [manifest](manifest.json) records every member and volume hash;
[capture](capture.json) records archive reopening and a complete source rehash.

Capture passed in **24.505 seconds**, peaking at **70,873,088 bytes** process-tree
RSS. A separate verification with another complete source rehash passed in
**9.644 seconds**, peaking at **63,041,536 bytes**. These are preservation costs,
not compiler or program-speed measurements. See [capture supervision](../preservation-run01/run.json)
and [verification supervision](../preservation-verify-run01/run.json).

The [preserver derivation](preserve.derivation.json) retains Phase39 streaming
inventory, bounded volumes, reopened verification and failed-attempt preservation.
The [supervisor derivation](bounded-preserve.derivation.json) changes only its
outer lock path so the inner preserver can retain the shared execution lock.
No raw Phase40 writer may reopen after this capture; future work uses a new phase.

## Verify and inspect a restored copy

From the repository root, without the original raw build directory:

```sh
python3 implementation/phase40/evidence/preserve.py --verify-only
```

This verifies archive contents against the manifest without executing a compiler.
After verification, extract into a new directory:

```sh
PHASE40_RESTORE=$(mktemp -d /tmp/bend-phase40-restore.XXXXXX)
cat implementation/phase40/evidence/validation.tar.gz.part-00001 \
    implementation/phase40/evidence/validation.tar.gz.part-00002 \
  | tar -xz -C "$PHASE40_RESTORE"
```

Original receipt paths remain unchanged. Historical audit replay can require
referenced earlier-phase evidence, the pinned upstream checkout and recorded
host tools; extraction does not invent relocated provenance. For routine program
comparisons, use the smaller [portable bundles](../../../selfhost/tools/performance/phase40/README.md)
without reconstructing those historical build trees.

Tracked narrative summaries and installed artifacts accompany this capsule.
The [release record](../release-06.json) binds the selected image. The final
[execution selection](../execution/report.json) explicitly retains 42 measured
exact-byte comparisons and three fresh corrected rays; it does not relabel
rejected outputs or claim all points were retimed after the correction.
