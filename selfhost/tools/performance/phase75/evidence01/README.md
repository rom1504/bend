# Phase75 sealed evidence

The capsule preserves 21,413 files (1,024,377,119 bytes), deduplicated to 5,297
content objects in a 94,377,103-byte ZIP split into three 32 MiB-or-smaller pieces.
[manifest.json](manifest.json) maps every repository-relative file to content,
size and Unix mode. [verification.json](verification.json) records the pieces,
joined hash and archive/original-file verification. [restoration-check.json](restoration-check.json)
records a full independent restoration and verification of all hashes/modes.
Failed attempts and unexecuted plans are included; inclusion is not acceptance.

Restore into a new directory, leaving live experiments untouched:

```sh
python3 selfhost/tools/performance/phase75/restore-evidence.py \
  selfhost/tools/performance/phase75/evidence01 /tmp/phase75-restored
```

The restorer checks piece, joined-archive, manifest and individual content hashes
and restores recorded executable modes. It never overwrites an existing destination.
The ZIP is content-addressed; extracting it directly gives object blobs, not the
original paths. Use the manifest-aware restorer above.

Joined ZIP SHA-256:
`d81b5ccb3907d38dc4b58fa5659d8935133454f26554f29b5e227ca995c42462`.

[Seal method](../seal.py) and [restorer](../restore-evidence.py) are included in
the archive. This README and the restoration verification are publication records
outside the sealed input set. Private usage telemetry and Python caches are
excluded. Earlier-phase baselines, pinned upstream and toolchains remain external;
recorded absolute paths require restoration/adaptation. This is an experiment
capsule, not a hermetic toolchain bundle. Phase75 target writers are now closed.
