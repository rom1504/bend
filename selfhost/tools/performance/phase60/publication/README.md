# Phase60 survey preservation and publication

Prepared commands only; root owns execution and writer closure. This survey
changes no compiler source, runtime, ordinary driver or installed release.
Tools derive narrowly from the reviewed Phase59 producers; no historical input
is rewritten and no copied raw tree is needed.

`build/phase60/closed-inventories.json` references existing Phase58/59 archive
metadata, with this root-created schema:

```json
{"complete": true, "archives": [
  {"phase": "phase58", "archiveMetadata": {"file": "ABSOLUTE_ARCHIVE_JSON", "bytes": 0, "sha256": "EXACT_SHA"},
   "files": 0, "rawRoot": "ABSOLUTE_CLOSED_TREE", "unchanged": true}
]}
```

The actual document must contain both distinct phase58 and phase59 roots, their
real hashes/counts, and `unchanged:true` from starting audits. The producer checks
metadata hashes and declared counts, hashes every member file in 1 MiB chunks,
rejects symlinks and compares exact relative file sets. The two referenced
inventories are reused, not embedded/copied into the Phase60 raw campaign.

Root runs start/final audits outside timing, each to a fresh receipt:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase60/publication/preservation-v1.py \
  --out selfhost/build/phase60/preservation-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase51/check-protected.py \
  selfhost/build/phase60/protected-final.json
```

The audit also checks installed-start's seven files, protected103/staged status,
and live compiler/runtime/driver against pinned Phase58 publication, its source
accounting and selected checked snapshot. It writes counts and input identities,
not duplicate executable artifacts. The unchanged Phase51 receipt supplies the
archive producer's required protected schema. Preserve failures and retry to
fresh output names; no audit can certify later writer activity.

After **all** measurement, summary, accounting and raw writers stop, root writes
`build/phase60/writers-closed.json` with `complete:true`, `writersClosed:true`,
absolute `rawRoot`, and exact `attempt`/`api` file/hash rows from Phase58's selected
attempt and the survey's actual B2. This records existing provenance, not a new
checked image. Thereafter no stdout, errors, receipts or ledger writes go into
raw. Final publication metadata and archive remain outside raw.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase60 --out selfhost/tools/performance/phase60/artifacts/raw \
  --writers-closed selfhost/build/phase60/writers-closed.json \
  --protected-final selfhost/build/phase60/protected-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase60/publication/publish-parts-v1.py \
  --archive-dir selfhost/tools/performance/phase60/artifacts/raw
```

Destination must be fresh. The inherited producer SHA256 is
`4d393286e9a3e26892ff52bb242f53f1ea3211a82caeee3ef79a52b4597cfaa6`.
It streams deterministic tar/gzip, hashes each member, reopens every member,
compares exact hashes and inventory/stat tokens, then rehashes raw contents.
Limits: 2 GiB/file, 64 GiB/total, 500,000 members; 1 MiB streaming chunks.
Historical `phase42` kind labels describe method lineage, not the survey date.

Profiler artifacts remain ordinary capsule members; no JSON/trace format is
relabeled a clean timing measurement. The full capsule stays a single Git file
below 100,000,000 bytes. **At or above** that threshold the publisher creates
48 MiB ordered parts, stream-verifies concatenation to the original hash and
ignores the full local capsule. `archive.json` preserves every member identity;
`publication.json` binds metadata/archive/parts. Reassemble ordered parts before
using the archive inventory. Capsule publication is not release qualification.
