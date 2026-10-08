# Closed Phase64 evidence capsule

All raw writers were closed before archival. The archive was reopened and every
member's path, size and SHA256 verified, followed by a complete recheck of the
original tree. Failed and rejected attempts retain their original statuses.
The [manifest](manifest.json) binds every member.

- Files: **15,922**.
- Uncompressed content: **503,536,103 bytes**.
- Archive: **82,603,477 bytes**.
- SHA256: `62785f6e59c5c7a1984d948bcf2cd0acbc2962da37a2d1a6b0ee160dc8f4a357`.
- Source: `selfhost/build/phase64`; producer: [`../archive.py`](../archive.py).

From the repository root, restore into an absent raw tree:

```sh
sha256sum selfhost/tools/performance/phase64/artifacts/raw-campaign.tar.gz
tar --keep-old-files -xzf selfhost/tools/performance/phase64/artifacts/raw-campaign.tar.gz
```

Members include the complete `selfhost/build/phase64/` prefix. Do not strip it or
extract inside that directory. Never overwrite an existing closed campaign;
restore into an isolated empty checkout or compare its inventory first.

The capsule contains checked snapshots/images, genuine B2/B3, exact compiler
and release qualification, broad timing, diagnostic profiles, local controls,
failed controllers, rejected candidates and the preserved previous release.
Compact selected evidence is also directly tracked in
[`implementation/phase64/evidence/`](../../../../../implementation/phase64/evidence/).
The [final report](../../../../../implementation/phase64/state09-results.md)
distinguishes these records and their measurement boundaries.

Historical prerequisites are not duplicated wholesale. Follow the existing
Phase58–63 capsule instructions and the exact source/tool/input pins, including
any earlier prerequisites. Retain the pinned upstream and Node identities.
Historical recipes contain the original absolute workspace paths; replaying in
another workspace requires fresh explicit bindings and a new output tree. The
archive preserves evidence, rather than claiming every external tool or old
path exists on another machine.

The installed equality-derived checked-B1 compiler is tracked separately in
`selfhost/dist/`. Its prior seven artifacts remain under
`release-history/4a208bffcf47b5d19f8ff18be1fc01b2faf988b37d38e7f5db9e6bd42d79905f/`.
The measured genuine B2 is in this capsule; those image roles remain distinct.

Writer closure, qualification, performance and archive integrity are separate
records. This README and publication metadata are outside the closed raw tree.
