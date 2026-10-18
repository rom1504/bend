# Phase108 sealed evidence

`observations.tar.gz` contains 1,571 verified regular files, including all complete
compiler C products, Q0/Q1 native images, portable runtime profiles, commands,
clocks, full control outputs and unsuccessful attempts. `manifest.json` records
every size/hash and the explicit exclusions. `FILES.sha256` verifies extracted
files relative to the repository root.

The archive is 37,558,468 bytes, SHA-256
`677e9097db9493446fc944e8fa4103d429787999c5fb4f57df870eeeca45d8f5`.

Restore only into an absent `selfhost/build/phase108` directory:

```sh
tar -xzf implementation/phase108/evidence/observations.tar.gz
sha256sum -c implementation/phase108/evidence/FILES.sha256
```

This is a bounded research snapshot, not a hermetic distribution. It excludes
rebuildable object files and the cproc/QBE working source directories, while
recording their identities. The small atomics object must also be rebuilt.
`toolchain/setup.sh` acquires cproc and copies/patches the previously acquired
Phase107 QBE source; that Phase107 tree must exist. Selected native release/Base/
effect assets remain in their earlier capsules. The image manifest binds exact
host tools and absolute paths; another checkout/toolchain requires reacquisition
and qualification, not editing hashes to bypass checks.

The source plan predates the final ABI profile. `qualification01.json` in the
archive binds the actual v3 successor gates and explicitly records deviations,
including one full self-emission followed by a real successor build instead of
two fresh full self-emissions. Earlier failed/superseded evidence is retained.
