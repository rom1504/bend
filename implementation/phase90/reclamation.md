# Phase90 evidence preservation and disk review

The read-only [review manifest](reclaim-review.json) identifies 14 historical
CPU profiles totaling **230,861,335 bytes (220.17 MiB)**. The six Phase73
baseline/candidate profiles and eight Phase75 compiler05/compiler14 profiles
each match both their manifest hash and the archived bytes. Archive pieces,
manifests and verification/publication receipts also match committed Git blobs
at `29da7dbe9e3fc6954d8cdacce236625f80af513d`. This review deleted nothing.
No selected path occurs in Phase89/90 JSON or executable-tool source, apart
from this new review manifest. Historical reports and all compiler inputs stay.

Root may reclaim only the manifest's `files[].path` entries after rechecking
their current hashes. Retain the committed evidence capsules. A selective
[restorer](../../selfhost/tools/performance/phase90/restore-reclaimed.py)
validates capsule identities and restores just these profiles to a fresh tree:

```sh
python3 selfhost/tools/performance/phase90/restore-reclaimed.py \
  --out /tmp/phase90-restored-profiles
```

The restorer needs approximately 221 MiB of output space and joins each capsule
in memory; it does not restore the roughly 1.7 GiB of unrelated raw evidence.
Its syntax was checked offline. No restoration or target execution was run.

Root subsequently repeated the archive/local/committed checks and removed the
14 raw duplicates, reclaiming all 230,861,335 bytes. The separate mutation
receipt is [prune04.json](prune04.json); the read-only review remains unchanged.

Phase90 itself contained only about 107 MiB at review time. Prior snapshots
`compiler01`, `compiler01-b2`, `compiler02` and `compiler03` account for 45.91 MiB,
so they cannot supply the requested 200 MiB. They are not safe to prune yet:
seal and commit a capsule containing their exact bytes and failure receipts
first. The current Phase90 acquisition/build is still writing; do not seal a
changing tree or treat a partial process receipt as completed evidence.

Keep these active groups intact:

- `compiler04`, `compiler04-b2`, their guarded build records and
  `qualification-method04`: current checked B1 and genuine B2 qualification.
- `native-tables-stack01`, its guard/build records and current native binary:
  the checked combined source `74b390d3…` and its emitted C.
- `selfhost/tools/performance/phase90/tables/`: frozen candidate/control
  sources, both original and normalized derivation receipts, and stack-fix
  snapshots. Keep the missing-law control failure as well as the passing V2.
- `js-self03` and other self-emission attempt records: current output oracle
  and preserved stack/deadline failures. Keep the rejected `late-self01`
  profile with its unchanged admission status.
- Phase89 native source `4584cf08…`, C `b1560234…`, binary `8bacae26…`, exact
  acquisition/build/admission records, all required shared Phase88 cached
  Base/runtime/effect assets, and their committed capsules. The admission
  asset lists, rather than directory age, determine these dependencies.

After all writers finish, reuse the Phase89 seal method's per-file hash/mode
verification and before/after stability checks for a new Phase90 capsule.
Include unsuccessful attempts and derivative recipes; verify archive members
against originals, commit capsule and manifest, and only then consider pruning
old Phase90 raw copies. Do not remove reusable active baseline assets merely
because a sealed duplicate exists.
