# Phase81 complete measurement evidence

The verified manifest contains678 regular files and343 unique content objects:
all fresh clean/profile/region receipts, C outputs, CPU/heap profiles, isolated
projects, generated diagnostic derivative and consumed methods. The archive is
7,266,401bytes. Every archived object and original file's bytes/mode were checked.
Hashes are recorded in [verification.json](verification.json).

```sh
python3 selfhost/tools/performance/phase81/restore-evidence.py selfhost/tools/performance/phase81/evidence01 /tmp/phase81-restored
```

The destination must be new. Historical Phase78 images/oracles/plans, upstream
and toolchains are external pinned prerequisites, preserved by their original
phases and identified by the frozen plans. Restoring evidence does not install
the observation-only compiler derivative. Private quota telemetry is excluded.
Read the [report](../../../../../implementation/phase81/README.md) for diagnostic
boundaries and conditional estimates. Production remains Phase78.
