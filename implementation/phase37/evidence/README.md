# Closed Phase37 evidence capsule

Capture and independent verification both pass. The capsule preserves **26,651
files / 289,733,456 logical bytes** from the complete closed
`selfhost/build/phase37` tree. Its two volumes contain **42,819,822 compressed
bytes**. Successful, failed, rejected and superseded attempts all remain;
archiving does not change their result status.

| Volume | Bytes | SHA256 |
| --- | ---: | --- |
| [part 00001](validation.tar.gz.part-00001) | 41,943,040 | `c2675747fb3a8e12d7be5ab936a144d622118b2adfd2a28e46bcb3766a1a8f64` |
| [part 00002](validation.tar.gz.part-00002) | 876,782 | `3f6ddaa47109118bb06975d2de6054e2a8aaf7d2abbf3c6af45053d66fb43c74` |

The concatenated gzip SHA256 is
`c40b526828bc235bd38921db78fee605430556108173c1972cd4c5d67d19304e`.
The [manifest](manifest.json) SHA256 is
`d314699a12ae27ca92fce495f0ce61783bfc002ef0f250eb6852c845b0d6a177`.
It records every member's path, mode, size and hash, all 6,659 directories and
the ordered volumes. No files were excluded in this capture.

Capture took **20.099 seconds**, peaking at **73,347,072 bytes** process-tree
RSS. Independent reopening/source verification took **8.025 seconds**, peaking
at **63,389,696 bytes**. Both used CPU3, a 1 GiB process-tree ceiling, 2 GiB
available-memory floor and 600-second deadline. The
[capture receipt](capture.json), [capture supervisor](capture-run/process.json) and
[verification supervisor](verify-run/process.json) retain the exact commands and
results. Every archived member was reopened and checked, and the entire source
tree was rehashed on both passes.

Root closed all target jobs and observed all three agents completed before
writing `writers-closed.json` and capturing. Raw Phase37 evidence is now
immutable. Publication records and these archive supervisors live outside it.
The [derivation](derivation.json) preserves the exact Phase36 producer lineage;
its prospective preparation status is distinct from the completed runs here.

## Verify and restore

From the repository root, standalone verification writes nothing and does not
need the original raw tree:

```sh
python3 implementation/phase37/evidence/preserve.py --verify-only
mkdir /tmp/bend-phase37-evidence
cat implementation/phase37/evidence/validation.tar.gz.part-* \
  | tar -xzf - -C /tmp/bend-phase37-evidence
```

These files are consecutive parts of **one gzip/PAX tar stream**, not separate
tar archives. The manifest defines their order. Restore into a fresh directory;
members are relative to the original `selfhost/build/phase37` root. Reports use
acquisition-time absolute paths. Restoring or relocating them does not change
those historical identities.

The capsule contains checked snapshots, compiler attempts, generated modules,
timing samples, oracles, profiles, diagnostic copies, consumed tools, failures
and release-control receipts. It does not copy every external file merely
because a receipt names it. Reproduction also needs the tracked tooling and
fixtures, pinned upstream `018751270e800bc222a93dad7f257083ee53a5f7`, Node24.18.0,
and historical Phase35/36 artifacts where specified. Their separate capsules
and release history retain their original provenance. The portable
[Phase37 benchmark reference](../../../selfhost/tools/performance/phase37/baseline/manifest.json)
supports ordinary timing without rebuilding either compiler.

The [streaming producer](preserve.py) never holds the whole archive in memory.
It rejects special files and symlinks, preserves empty directories, checks for
source changes, and caps each volume at40MiB. The bounded launcher uses a
distinct outer lock while the producer owns the shared campaign execution
lock. The completed invocations were:

```sh
python3 implementation/phase37/evidence/capture-run.py capture \
  implementation/phase37/evidence/capture-run
python3 implementation/phase37/evidence/capture-run.py verify \
  implementation/phase37/evidence/verify-run
```

Those output directories are immutable and must not be reused for a new run.
