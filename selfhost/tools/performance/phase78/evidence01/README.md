# Phase78 complete evidence

All19,795 regular files, literal symlink targets, empty directories and modes are
recorded in `manifest.json`;4,316 unique objects occupy88,450,934 compressed bytes.
Every archived object and unchanged input was verified before splitting into
32MiB parts. `verification.json` pins the manifest, archive and parts. Private
usage telemetry is excluded; external toolchains and previous sealed phases are
not duplicated.

Restore into a new directory with:

```sh
python3 selfhost/tools/performance/phase78/restore-evidence.py selfhost/tools/performance/phase78/evidence01 /tmp/phase78-restored
```

Historical absolute aliases are restored literally for evidence, not executed.
The first sealing attempt refused a session-CLI alias symlink; the final method
records and verifies its target without following it.
