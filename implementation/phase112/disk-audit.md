# Phase112 bounded artifact disk audit

The read-only audit began with about761MiB free. `selfhost/build` occupied49GiB;
Phase111 occupied475MiB. The other large inspected areas were Phase1022.4GiB,
Phase162.7GiB, Phase52.9GiB and Phase94/toolchain3.4GiB. The toolchain and current
runtime/selected executables were excluded from cleanup proposals.

The coordinator requested bytes-preserving hardlink deduplication, retaining
every path and raw byte. This avoids making frozen evidence dependencies absent.
No deletion, compression, compiler execution or target execution was performed
by the audit agent. Root owns application and separate execution receipts.

## Applied cleanup and retained proposals

| Proposal | Fully authenticated duplicate paths | Recoverable allocated bytes | Scope |
| --- | ---: | ---: | --- |
| `dedup-first-gib.json` |950|1,265,594,368 (1.18GiB)|First complete groups, selected by descending file size. Applied and byte-verified in `dedup01/report.json`. |
| `dedup-next.json` |1,027|213,897,216 (204MiB)|Applied and byte-verified in `dedup02/report.json`; no overlap with first-gib. |
| `dedup-proposal01.json` |539|337,117,184 (321MiB)|Earlier C/JS/object-only proposal. Overlaps first-gib; **do not apply again**. |
| `dedup-proposal02.json` |1,977|1,479,491,584 (1.38GiB)|Entire final census. Contains first-gib and next; **do not apply after either tier**. |

Both selected tiers completed. The recorded recovered allocation is
**1,479,491,584 bytes (1.48GB, or1.38GiB)** across1,977 duplicate paths.
Their complete application receipts, including original and post-link identities,
are preserved in the evidence capsule. The two unused overlapping proposals stay
local; the committed proposals are only the applied nonoverlapping tiers.

All proposal rows record SHA256, byte size, device/inode, mode, link count,
allocated blocks and mtime. Candidate files are regular generated artifacts of
at least128KiB. The first scan covered generated C/JS/objects in Phases5/16/102.
The bounded expansion added historical JSON/log copies, generated program
executables, and Phases95/98/99/111. It compared size first, then streaming SHA256
and same-device/mode identity; file metadata remained stable during each hash.
Only independently allocated single-link duplicate inodes earn space estimates.
No source `.bend`, host tools, runtime objects or toolchain files are selected.

The combined proposal estimates1.38GiB, not2–5GiB. With the original free space,
the first tier provides roughly1.9GiB headroom without losing evidence. Broad
scanning stopped after this bounded census; more reclamation was deprioritized
in favor of the optimization experiment.

## Application contract

`selfhost/tools/performance/phase112/apply-dedup.py --proposal FILE --out FRESH`
is the prepared coordinator tool. It was syntax-parsed by the audit agent, not
executed. It performs whole-proposal preflight and immediate per-replacement
checks, permits only regular admitted artifacts under `selfhost/build`, refuses
symlink parents/leaves and changed inode/mtime/size/mode/device/hash, checks
ownership and extended-attribute equality, creates a fresh temporary hardlink,
and atomically replaces the duplicate path. Original metadata and verified
post-replacement identities are recorded. Both content and every original path
remain available.

Hardlinks share inode metadata and future writes. These historical artifacts
must stay immutable: any later rebuild must use a fresh output directory or
replace a path atomically, never overwrite a shared inode in place. Original
per-path mtimes/inodes are recorded rather than falsely claimed preserved.
Proposal overlap is explicit; stale proposals must fail instead of silently
accepting a changed filesystem.

## Phase111 evidence and preserved failures

The Phase111 evidence capsule has a verified archive and index, but334 entries
are **hash-only**, not archived payloads. Its approximately49.7MB unique raw
payloads do not include the largest generated compiler products. Therefore the
capsule alone does not authorize deleting those products.

Three large pairs have exact hashes in the capsule and were also checked locally:

- `full-emission02/program.ssa` and `native-self02/program.ssa`:50,664,292 bytes,
  SHA256 `143521cc2e747a1af741aa8e62bd16bb476b2221836322ee5bb023e0da4466b2`.
- `full-native02/program.s` and `native-self02/build/program.s`:68,809,177 bytes,
  SHA256 `f2a11761dcc4ff5fd78f3000966968827500740a69192821e1e297c846424109`.
- `full-native02/program.o` and `native-self02/build/program.o`:25,163,016 bytes,
  SHA256 `133a8e75a1ac27b88a6c56eb454721e03ccadaf08c821c5799b78d4947ebc58e`.

The64MiB truncated `full-native01/program.s` is a distinct failed artifact. It
was not discarded or equated to a successful assembly file. The selected
`full-native03/program`, `native-self02/build/program`, runtime-source04 object,
compiler source and qualification/evidence receipts remain intact.

Historical Phase111 cleanup02 already reclaimed about1.09GiB through separately
verified lossless compression. Those original absent paths must be restored from
the recorded compressed artifacts before any validator requiring them; this
audit neither reclaims them twice nor weakens missing-input checks.
