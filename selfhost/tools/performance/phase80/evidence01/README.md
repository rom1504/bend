# Phase80 complete evidence

The manifest records4,807 regular files and1,089 unique content objects, covering
all five candidate snapshots, failed setup, clean requests, diagnostics, generated
controls, methods and restored-release verification. All object bytes, original
file bytes/modes and the archive were verified. The archive occupies27,012,289
bytes. Its hashes and the manifest hash are in `verification.json`.

```sh
python3 selfhost/tools/performance/phase80/restore-evidence.py selfhost/tools/performance/phase80/evidence01 /tmp/phase80-restored
```

The destination must be new. Historical Phase78 baselines, upstream and toolchains
remain external pinned prerequisites, preserved by their own phases. Restoring
this capsule does not install an experimental compiler. Private quota telemetry
is excluded. Read the [report](../../../../../implementation/phase80/README.md)
before applying any prototype: the installed compiler remains unchanged.
