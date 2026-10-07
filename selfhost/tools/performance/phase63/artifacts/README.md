# Closed Phase63 evidence capsule

All raw writers were closed before archival. The archive was reopened and every
member's path, size and SHA256 verified; the complete original input inventory
and hashes were then checked again. Failed and rejected attempts retain their
original statuses. The [manifest](manifest.json) binds every member.

- Files: **16,691**.
- Uncompressed content: **521,756,245 bytes**.
- Archive: **78,204,174 bytes**.
- SHA256: `8dc20dcc3961cc479a343a275ae7d0d9b3eaca4401f10336da72aae9d7c63c22`.
- Source: `selfhost/build/phase63`; producer: [`../archive.py`](../archive.py).

From the repository root, restore into an absent raw tree:

```sh
sha256sum selfhost/tools/performance/phase63/artifacts/raw-campaign.tar.gz
tar --keep-old-files -xzf selfhost/tools/performance/phase63/artifacts/raw-campaign.tar.gz
```

Members include the full `selfhost/build/phase63/` prefix. Do not strip it or
extract inside that directory. Never overwrite an existing raw campaign: compare
its inventory first, or restore into an isolated empty checkout. The tree
contains final qualified receipts, frozen methods/snapshots, compiler images,
all earlier failed candidates, negative experiments and their measurements.
Final reports link to the restored raw paths; compact selected results also
remain directly tracked in `implementation/phase63/evidence/`.

Historical Phase58–62 prerequisite paths are not duplicated here. Restore their
published capsules using their individual README instructions; retain the pinned
upstream checkout and toolchain identities named in the receipts. Old recipes
include the original absolute workspace paths and are evidence, not portable
new-run configuration. Replaying in another workspace requires fresh explicit
bindings and a new output tree, preserving original provenance. This archive is
not a claim that historical paths or toolchains exist on another machine.

The installed equality-derived checked-B1 release is tracked separately under
`selfhost/dist/`; its previous seven artifacts are preserved in
`release-history/97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8/`.
The measured genuine B2 is inside this capsule. Those image roles remain distinct.

Raw writer closure, target qualification, measured compiler latency and archive
integrity are separate records. This file and publication metadata are outside
the immutable archived raw tree.
