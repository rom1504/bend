# Phase59 preservation and publication

Completed: preservation passed and all 518 raw files are retained in the
[verified capsule](../artifacts/raw/README.md). The commands below document the
executed method; their current output paths are consumed and must not be reused.

Information only: no compiler/runtime/driver change or release installation.
Root runs these data-only commands after measurement and report writers finish.
No command below invokes a compiler or generated target. New receipts are fresh;
closed Phase58, installed files and historical producers remain untouched.

1. Before closure, audit Phase58's exact 30,169-file set, seven installed files,
   protected103, and live compiler/runtime/driver against Phase58 publication and
   its selected snapshot. The audit hashes in 1 MiB chunks; do not overlap timing.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase59/publication/preservation-v1.py \
  --out selfhost/build/phase59/preservation-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase51/check-protected.py \
  selfhost/build/phase59/protected-final.json
```

The second command is the unchanged protected-file producer/schema required by
archive-campaign-v1.py. Both must succeed; preserve failures and retry to fresh
receipt names. The audit pins Phase58 publication SHA256
`0338c3a7bb88a0564e692fb09e2b8ede6c0e24352a239525e6d8b892f5f0cf90`.
It neither relies on start status alone nor treats successful tests as byte proof.

2. Root then stops **all** Phase59 raw writers, finishes reporting/accounting,
   and explicitly writes `selfhost/build/phase59/writers-closed.json`:

```json
{
  "complete": true,
  "writersClosed": true,
  "rawRoot": "/home/ai/bend2/build/publish/bend/selfhost/build/phase59",
  "attempt": {"file": "EXACT_PHASE58_SELECTED_ATTEMPT", "sha256": "EXACT_SHA"},
  "api": {"file": "EXACT_CURRENT_B2_COMPILER", "sha256": "EXACT_SHA"}
}
```

Use actual selected attempt/B2 rows from Phase58 publication, not placeholder
bytes. This declaration records image provenance, not a new checked attempt.
Thereafter add no logs, receipts, ledger entries or failure reports inside raw.
The archive destination must be absent and outside raw; redirect stdout/errors
outside raw as well.

3. Reuse the inherited streamed producer, SHA256
`4d393286e9a3e26892ff52bb242f53f1ea3211a82caeee3ef79a52b4597cfaa6`:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase59 --out selfhost/tools/performance/phase59/artifacts/raw \
  --writers-closed selfhost/build/phase59/writers-closed.json \
  --protected-final selfhost/build/phase59/protected-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase59/publication/publish-parts-v1.py \
  --archive-dir selfhost/tools/performance/phase59/artifacts/raw
```

The inherited tool makes deterministic streamed tar/gzip, hashes every member,
reopens every member and compares hashes, checks before/after stat inventory and
rehashes raw contents. It rejects symlinks and limits files to 2 GiB, total bytes
to 64 GiB and members to 500,000. Its `archive.json` contains the full member
inventory and archive digest **outside** the capsule; historical phase42 kind
labels identify method lineage only.

The publisher keeps a single capsule below 100,000,000 bytes. Only if larger,
it creates 48 MiB ordered parts, streams them to verify the original hash, and
ignores the complete local capsule for Git. `publication.json` binds the archive
metadata and parts. Reassemble ordered parts before consuming `archive.json`.
A preserved capsule is evidence, not an executable release or new qualification.
