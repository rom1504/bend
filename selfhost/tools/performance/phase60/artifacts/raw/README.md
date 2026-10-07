# Closed Phase60 evidence

The [publication index](publication.json) binds the [member inventory](archive.json)
and [raw campaign archive](raw-campaign.tar.gz). All writers closed at
2026-10-07 05:42:28 UTC. The archive was reopened, every member verified, and
the original raw tree rechecked for stability. No split was needed.

- Members: **2,286** regular files.
- Raw content: **463,038,119 bytes**.
- Gzip archive: **18,788,706 bytes**.
- SHA-256: `a02e1bed02335b8bb35451cd129f2c85fe23484ca0f4f68da2daaa30a0b9ef6b`.

The capsule includes methods, preparations, source bindings, all target receipts,
whole output modules, profiles, data-reader attempts, figures, accounting,
preservation and writer closure. It preserves the unexecuted method derivation
failure, unavailable external timing-wrapper launch and first diagnostic-reader
failure. These are distinct from the 300 successful target processes.

Report links into `selfhost/build/phase60` refer to archived members; that ignored
directory is not checked into Git separately. In a fresh checkout, restore to a
new directory without overwriting existing evidence:

```sh
mkdir -p selfhost/build && mkdir selfhost/build/phase60 && \
  tar -xzf selfhost/tools/performance/phase60/artifacts/raw/raw-campaign.tar.gz \
      -C selfhost/build/phase60
```

Receipts preserve absolute paths from the measurement workspace. Historical
Phase58/59 qualification artifacts remain in their own closed campaigns; this
capsule references them rather than duplicating every historical compiler image.
Replaying methods requires those exact dependencies and the pinned Node/upstream
versions. The archive is experiment evidence, not an installed compiler release.

See [publication procedure](../../publication/README.md) and the
[final report](../../../../../../implementation/phase60/README.md).
