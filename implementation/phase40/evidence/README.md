# Phase40 preservation preparation

Preservation derivatives are prepared; no archive has been captured. Root must
close every raw job and report writer before using --closed. The inner preserver
keeps the shared execution lock; the outer supervisor has a separate Phase40
preservation lock. Streaming inventory,40MiB volume cap, reopened byte verification,
failed-attempt retention and complete source rehash remain unchanged from Phase39.
Exact parent/output identities are recorded in the two derivation JSON files.

After closure, root runs from the repository root:

```sh
python3 implementation/phase40/evidence/bounded-preserve.py \
  --seconds 900 --rss-mib 2048 --available-mib 2048 \
  implementation/phase40/preservation-run01 -- \
  python3 implementation/phase40/evidence/preserve.py --closed
python3 implementation/phase40/evidence/bounded-preserve.py \
  --seconds 900 --rss-mib 2048 --available-mib 2048 \
  implementation/phase40/preservation-verify-run01 -- \
  python3 implementation/phase40/evidence/preserve.py --verify-only --check-source --closed
```

Do not put new supervision receipts inside the closed raw source tree. The
future capsule records all raw Phase40 files, not only successful artifacts.
Installed images, report/tool sources and referenced older-phase evidence remain
separate dependencies; restoring raw bytes does not fabricate relocated provenance.
