# Closed Phase41 evidence

Capture and independent reopen/source verification both pass. This capsule
contains every file in the closed raw Phase41 tree: 20,302 files,
4,373 directories, 162,222,128 logical bytes, including
failed/superseded attempts. No files were excluded. One streamed volume contains
29,044,527 compressed bytes; no volume exceeds40 MiB.

[Manifest](manifest.json), [capture receipt](capture.json),
[raw closure](../raw-closure.json), [capture supervisor](../preservation-run01/run.json),
and [independent verification supervisor](../preservation-verify-run01/run.json)
bind the scope. Manifest SHA-256:
`6dfa51706124bcb98c32ce98d453d8482ee4f1325bba641b2a191d88a9156928`.
Compressed stream SHA-256: `47f5fe067abffb076e116e0d5618fde8de952b05c0ea380639abd2e1774f6483`.

Capture took14.062s, peak tree RSS56.1 MiB.
Independent verification/source rehash took5.625s,
peak tree RSS49.3 MiB. These operations follow raw
closure and are excluded from benchmark and campaign-process intervals.

Verify the capsule without the original checkout paths:

```sh
python3 implementation/phase41/evidence/preserve.py --verify-only
```

Restore into a fresh directory after verification (do not overwrite live raw
results):

```sh
mkdir -p /tmp/phase41-restored
cat implementation/phase41/evidence/validation.tar.gz.part-* | \
  tar -xz -C /tmp/phase41-restored
```

The tar records raw-tree-relative paths; restoring into
`selfhost/build/phase41` in a fresh repository recreates the original layout.
Absolute paths in historical receipts describe the acquisition machine and are
not portable execution instructions. For timing use the separate
[portable baseline/current bundles](../../../selfhost/tools/performance/phase41/README.md).
Their45 points can run without restoring this capsule. Historical Phase40 and
older referenced owners remain in their already preserved phase capsules.

Root closed all raw writers before capture and will not modify that source tree.
Further documentation/publication receipts live outside the capsule.
