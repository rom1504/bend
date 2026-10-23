# Additional old-cache deduplication

Completed before 00:22 UTC on 2026-10-23, in the root-authorized I/O window.
No compiler/target ran, no current Phase126 artifact was eligible, and no file
was normalized, compressed, relocated or deleted.

The metadata scan found many equal-size historical generated cache files, but
equal size and equal basename were poor predictors of exact content equality:

- `tooling-old-cache-plan01/report.json`: 454,669,691 bytes hashed from old
  completed checked snapshots; zero exact duplicate pairs, no changes.
- `tooling-old-cache-plan02/report.json`: 295,780,763 bytes hashed from frozen
  phase63..66 generated snapshot/project caches; 17 exact duplicate pairs.
- `tooling-old-cache-apply02/report.json`: all 17 pairs replaced atomically by
  hardlinks after fresh SHA-256, exact-byte and metadata checks. Reclaimed
  allocated bytes: **20,094,976 (19.16 MiB)**. All original paths remain present
  and their post-link digests were checked. File mode and owner are unchanged;
  inode/mtime may differ.

Application took 0.32 seconds. Free-space readings were 606,724,096 before and
626,765,824 afterward; unrelated root writes can affect this global delta. The
reclaimed-byte figure counts the proven released one-link inodes, not the
global free-space difference. The old roots were closed and eligible files
predated the Phase126 campaign. Active artifacts and pinned bytes were unchanged.

This yielded less than the requested ~300 MiB. Do not count the large metadata
size-match totals as recoverable space, or normalize the differing cache
headers to manufacture equality. A later native hosted/self QBE, assembly and
object comparison may expose the separately estimated ~174 MiB exact duplicate
opportunity, but it requires actual completed products and byte equality.
