# Phase73 sealed evidence

The original 128,696,585-byte ZIP passed per-file hash and executable-mode
verification for17,277 files. It is published as four32MiB-or-smaller pieces.
[publication.json](publication.json) records each piece and the joined identity;
[verification.json](verification.json) describes the original archive check;
[manifest.json](manifest.json) lists restored paths and file identities.

From this directory, restore the archive in piece order:

```sh
cat evidence.zip.part-* > /tmp/phase73-evidence.zip
sha256sum /tmp/phase73-evidence.zip
```

Expected SHA-256:
`4805478633009567b01653a8cd34c958c8b61665ee82754a548b801fd35efb7b`.
Extract with a ZIP utility that preserves Unix executable modes into a separate
restoration directory; do not overwrite a live experiment tree. Paths inside the
archive are repository-relative. Recorded absolute paths need adaptation, and
earlier-phase baselines, upstream and toolchains remain pinned external inputs.
Private `usage-*` snapshots/logs are excluded. Failed experiments are included.

The original [seal method](../seal.py) is itself in the archive. The later
[publication method](../publish-evidence.py) and this README are tracked outside
that sealed input set. Publication verified each piece and the complete joined
identity before removing the redundant unsplit ZIP. No target evidence changed.
