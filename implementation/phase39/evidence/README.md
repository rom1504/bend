# Closed Phase39 evidence

All raw Phase39 writers are [closed](../raw-closure.json). This capsule preserves
**26,974 files and 6,668 directories**, with **374,749,255 logical file bytes**.
It includes checked candidates, failed/superseded attempts, source acquisitions,
semantic controls, compiler-cost samples, clean timings, profiles, installation
and the sandbox-denied CLI smoke followed by its successful unchanged retry.
Nothing is filtered according to whether it passed.

The one gzip/PAX tar stream is split into two ordered volumes, each at most
40 MiB. Combined compressed size: **52,380,683 bytes**. Stream SHA256:
`dff4cb2df3796aba73123e1d9b0e9ad4c38cd57983934cc36e04b0c2745f9fcf`.
[Manifest](manifest.json) records every member and volume hash;
[capture](capture.json) records reopening verification and a complete source
rehash. Bytecode cache exclusions are explicitly listed in the manifest.

Capture took **27.218 seconds**, peaking at **72,376,320 bytes** process-tree RSS.
A separate verification, including another source rehash, passed in **10.247
seconds**, peaking at **63,987,712 bytes**. See the bounded receipts in
[capture supervision](../preservation-run01/run.json) and
[verification supervision](../preservation-verify-run01/run.json).

`preserve.py` is a phase-only successor of the retained Phase37 streaming
preserver; [derivation](derivation.json) records that relationship. The reviewed
outer [supervisor](bounded-preserve.py) differs from the maintained bounded
runner only in its lock path, as [recorded](bounded-preserve.derivation.json).
This avoids nested acquisition of the same lock. The inner preserver keeps the
shared execution lock. Capture requires root to confirm that raw writers are closed; the shared lock
excludes concurrent supervised jobs. The outer process monitors time,
process-tree RSS and available memory.

## Verify without the original workspace

From the repository root:

```sh
python3 implementation/phase39/evidence/preserve.py --verify-only
```

This reopens the volumes and checks every archived file against the completed
manifest. It does not require the original raw build directory or execute the
compiler. To inspect a restored copy in a new directory after verification:

```sh
PHASE39_RESTORE=$(mktemp -d /tmp/bend-phase39-restore.XXXXXX)
cat implementation/phase39/evidence/validation.tar.gz.part-00001 \
    implementation/phase39/evidence/validation.tar.gz.part-00002 \
  | tar -xz -C "$PHASE39_RESTORE"
```

Original receipt paths remain unchanged. Full historical audit replay may also
require referenced earlier-phase evidence, the pinned upstream checkout and
recorded tools; extraction does not fabricate relocated provenance. For normal
fast execution comparisons, use the much smaller portable
[Phase39 bundles and guide](../../../selfhost/tools/performance/phase39/README.md),
which do not require reconstructing those historical build trees.

Final narrative/aggregate documents and installed artifacts are tracked alongside
the capsule. The [release record](../release-05.json) binds them to the selected
image. Future experiments must use a new raw phase directory; do not reopen this
closed tree or overwrite failed results.
