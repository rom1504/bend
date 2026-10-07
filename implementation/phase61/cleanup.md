# Lossless profile cleanup — October 7, 2026

Disk exhaustion interrupted state05; its incomplete supervisor and partial
snapshot remain retained. The separate cleanup compacted **49 old raw CPU and
allocation profiles**. Each gzip was decompressed and checked against the old
raw length and SHA256 before its raw copy was removed. This was storage work;
no compiler or benchmark was executed and no historical result changed.

The [original instructions](../../selfhost/build/cleanup-20261007/README.md) and
[summary](../../selfhost/build/cleanup-20261007/summary.json) record
**5,054,062,592 allocated bytes reclaimed** and **140,575,698 newly compressed
bytes**. These are attributed file-allocation changes, not the change in total
drive free space. Payloads remain in 46 new gzip files under the cleanup's
`profiles/` directory and three previously existing archives at their original
implementation evidence locations.

The [Phase9 mapping](../../selfhost/build/cleanup-20261007/phase9-profile-verified.json)
and [other-profile mapping](../../selfhost/build/cleanup-20261007/profile-compression-report.json)
bind every former raw path to its retained archive, compressed digest, raw digest
and raw size. Source, reports, Phase6 and active Phase58–61 were excluded. The
[installed-file verification](../../selfhost/build/cleanup-20261007/installed-verification.json)
passes all seven original Phase61 starting hashes, including installed API
`641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.

Historical readers that require an uncompressed path need an explicit restore:

```sh
python3 selfhost/build/cleanup-20261007/restore-profile.py \
  selfhost/build/phase16/populated-span-profile-01/checking.cpuprofile
```

The restore tool verifies compressed and raw digests and refuses to overwrite an
existing file. Keep the actual gzip payloads and these mappings together: this
tracked report and hashes do not independently store the multi-gigabyte profiles.

Receipt identities at this documentation checkpoint:

| File under `selfhost/build/cleanup-20261007/` | SHA256 |
|---|---|
| `summary.json` | `4492a596368a89d9a19ce25afdc74cf1a149fca397b7b94670dd8c35a36987a7` |
| `installed-verification.json` | `a9a305a83cf82f9a2b39ad1a4239be912b2690a70b3b60aead2ee0a1229a50ba` |
| `phase9-profile-verified.json` | `4203400657923311947249fa8840586efd7604c62f3359aa677268ae01ca82ec` |
| `profile-compression-report.json` | `aa5663be9270c767dbd5daaec8dc8e546a03c18edf5701e271fb5f00f21e331d` |
| `restore-profile.py` | `8edc1442ae79345d6349a79949d45cd84d40a2cbabe5ae54277a429610995993` |
