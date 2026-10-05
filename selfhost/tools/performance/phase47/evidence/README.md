# Phase47 experiment preservation

**Published and verified.** The closed campaign contains **16,355 files /
314,323,510 logical bytes**, stored as a **51,899,688-byte gzip stream** in two
ordered parts of at most 40 MiB. Every archived member was reopened and hashed;
the complete original inventory was checked again after capture. The parts were
reopened and their concatenation verified against the original stream.

Stream SHA-256:
`7d312239ed0ebec6aa535da7fb711f0e58fea44a9c3352a09019e6c9a68332da`.

- [Evidence index](index.json): selected release, archive, prerequisites and maintained inputs.
- [Selected qualification](selected-qualification.json): installed array06, four
  Array control groups, eight maintained suites, 42 CLI checks, full 45-point /
  669-sample performance run and 27 compiler requests.
- [Installed receipt](installed-release.json): byte-identical copy of the verified
  v2 join. Its failed v1 predecessor is retained inside the raw capsule.
- [Writer closure](writers-closed.json): raw writes stopped at
  `2026-10-05T01:32:22.046438+00:00`.
- [Protected-file audit](protected-final.json): all 103 unrelated starting files
  unchanged and unstaged, against the original 21,503-byte inventory with SHA-256
  `c5e803405d3c8267bd2f3741a638c77b4ce58c561cc5c829d0abac2ac8d67288`.
- [Archive manifest](raw/archive.json): every relative member, size and hash.
- [Parts manifest](raw/parts.json): ordered part sizes/hashes and concatenation check.

The capsule retains every regular file below `selfhost/build/phase47`, including
failed builds and fixtures, rejected or uninstalled attempts, priming, controls,
timings, profiles, consumed tools and exact generated artifacts. Archive membership
does not change an experiment's verdict or grant release qualification. No new
raw files or ledger events may be added after closure.

The reused [archive producer](../../phase42/validation/archive-campaign-v1.py)
streams the tree, rejects symlinks, reopens all members and rehashes the complete
source inventory. Its historical Phase42 name/kind remains unchanged; the receipt
identifies the actual Phase47 root. The [parts publisher](publish-archive-parts.py)
retains the original archive metadata and ignores only the reconstructed unsplit
local gzip. Neither the archive nor its metadata was edited after capture.

## Recovery

The [portable benchmark](../README.md) can run independently from this large raw
archive. To inspect historical experiments, reconstruct the archive into a fresh
path using the exact ordered names in `raw/parts.json`; verify every part first,
then the concatenated size and SHA-256 against `raw/archive.json`. Do not guess a
part count or overwrite an existing archive. For the published two-part stream:

```sh
cat selfhost/tools/performance/phase47/evidence/raw/raw-campaign.tar.gz.part-000 \
    selfhost/tools/performance/phase47/evidence/raw/raw-campaign.tar.gz.part-001 \
  > /tmp/phase47-recovered-NEW.tar.gz
sha256sum /tmp/phase47-recovered-NEW.tar.gz
mkdir selfhost/build/phase47-recovered-NEW
tar -xzf /tmp/phase47-recovered-NEW.tar.gz \
  -C selfhost/build/phase47-recovered-NEW
```

Choose a genuinely fresh output path before running those commands. Recheck each
extracted file against `archive.json.files`; metadata/member names are relative
to the raw root. Original absolute execution paths remain in receipts. Relocation
does not authorize rewriting provenance or make historical commands portable.

Repository fixtures and producers, pinned upstream `018751270e800bc222a93dad7f257083ee53a5f7`,
Node v24.18.0 and referenced earlier evidence remain prerequisites. In particular,
worker23 provenance and earlier diagnostics refer to the closed
[Phase45 capsule](../../phase45/evidence/README.md); the backend study is retained
in [Phase46](../../../../../implementation/phase46/README.md). The index binds
those manifests. Existing Phase47 raw bytes are fully retained; an external
hash/source recipe alone does not claim executable-byte retention.

New experiments must use a fresh successor directory and fresh receipts. The
publication scripts deliberately refuse to overwrite this completed evidence.
