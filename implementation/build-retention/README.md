# Build retention rollout — 2026-10-28

Reclaimed **7.00 GiB of allocated file blocks** from reviewed, closed experiments
and added disk admission plus explicit archive/close/prune tooling for new runs.
The working compiler, runtime and installed selectors were not changed.

This implements the [design](../../design/build-retention/README.md) following the
[proposal review](../../research/build-storage/2026-10-28-review.md). It does not
execute the original broad directory-deletion proposal. Start commit: `e08be5c`.

## Measured result

| Item | Result |
| --- | ---: |
| Reviewed phase roots with full existing capsules | 23, across Phase42–65 |
| Archived file paths unlinked | 321,270 |
| Original-path restoration control | 1 file restored afterward |
| Selected allocated blocks | 7,511,109,632 bytes / 7.00 GiB |
| Logical file bytes | 6,825,184,529 bytes / 6.36 GiB |
| Free space before first prune | 3.00 GiB |
| Free space after tranche | 9.80 GiB |
| Free space after recovery-evidence packaging | 9.77 GiB |
| Protected artifact hash checks | 30 / 30 unchanged |
| Isolated tool tests | 50 passed |
| Native request and restored product | Byte-identical to frozen QBE oracle |

Exact totals and per-phase receipts are in [summary.json](summary.json).
The selected recovery is not identical to the observed free-space increase:
plans/journals occupy about 219 MiB, evidence packaging adds 19.94 MiB, and other
projects write to this filesystem. The restored control accounts for 4 KiB.
The 10 GiB free-space target was narrowly missed; we exhausted the reviewed
tranche rather than widening deletion to reach a round number.

All selected bytes were authenticated against existing complete archives before
removal. We retained 15,147 protected archive members and 4,534 shared-inode
members; 24 members were already absent. In particular, Phase66 prerequisites
inside Phase55/58/63/65 remain. Phase4/5 are required by unfinished Phase6 work
and were excluded. Phase6/68 work, Phase32 coordination, Phase107 toolchain
acquisition, Phase102 installed selection, Phase137 research checkpoint and
Phase144/146 qualified generations remain available. No directory was removed.

The measured archive-verification sections totaled 1,015 seconds and unlink
sections 148 seconds. The serial campaign after the initial Phase61 control took
23.84 minutes, including subprocess setup, lock acquisition and receipt work.
This was a one-off check of hundreds of thousands of files; no compiler rebuild
or full benchmark campaign was needed.

## What is enforced now

New compiler jobs use [guard.py](../../selfhost/tools/build-retention/guard.py)
with a declared disk budget and fresh output roots. Admission checks
`free >= 5 GiB reserve + budget` after taking the unchanged Phase32 execution
lock. During execution, the guard monitors filesystem pressure and output
allocation and stops only its owned process tree on a resource failure.
Historical guards and their pinned hashes remain unchanged.

[close.py](../../selfhost/tools/build-retention/close.py) explicitly classifies
finished runs, packs cold output roots, authenticates the capsule and optionally
prunes verified files. Qualified outputs stay online. Closure records distinguish
successful execution from compiler qualification, and sealing is committed only
when the guard's retention record points to the immutable closure report.
The current close tool bounds each packed root to 1 GiB and 100,000 files.

Pruning authenticates the policy and full archive, checks current bytes and
metadata, preflights every candidate, records durable intent, then journals each
unlink. It excludes shared inodes, unusual ownership, extended attributes and
special modes. Recovery never overwrites a differing file. Older archives had
normalized executable modes; the new recovery plans preserve the actual modes
and mtime collected before pruning. Inode/ctime/original atime are not restored.

The [policy](../../docs/self_hosted/build-retention.md),
[usage guide](../../selfhost/tools/build-retention/README.md), AGENTS and the cold
development guide now specify this workflow. The 30/40 GiB project thresholds
remain review targets during migration, not enforced global quotas. Sampled
accounting cannot stop external projects from consuming the shared filesystem.
There is no unattended age-based deletion or cron cleanup.

## Validation and evidence

The 50 controls cover corrupt/truncated/multipart archives, unsafe paths, stale
plans and policies, protected files, exact mode/content restoration, interrupted
pruning, no-overwrite behavior, lock contention, simulated disk exhaustion and
closure atomicity. They completed in 18.86 seconds. Tests used temporary fixtures
and injected disk pressure, never filled the real disk.

The Phase146 native compiler then compiled `coverage-closures-256.bend` under
the new guard in 0.486 seconds of native request time, producing exactly the
99,841-byte frozen Phase144 QBE product. The real close command archived and
pruned its five output files. Restoring `program.ssa` into separate scratch
again matched the independent oracle byte for byte. The guard was sealed and
all 30 protected artifact entries still matched their pre-cleanup identities.
This is a workflow smoke check, not new compiler qualification or a speed claim.

The first read-only Phase61 plan used `archive.py`. Before any unlink, its
successor `archive-v02.py` added receipt-ancestor directory fsyncs. All actual
pruning and restoration used v02; both exact method versions are preserved.
No real archive failed verification and no compiler regression was observed.

[evidence/archive.json](evidence/archive.json) authenticates
[evidence/receipts.tar.gz](evidence/receipts.tar.gz): 229 verified members,
20,913,091 compressed bytes. It contains plans, per-file metadata, durable
intents/journals, results, tests and the native smoke/restore receipts.
[seal-evidence.py](seal-evidence.py) records how this evidence was packaged and
reopened. Historical product bytes remain in the original pinned archives under
`selfhost/tools/performance/phase42` through `phase65`; they were not duplicated.
Live recovery maps remain under `selfhost/build-retention/2026-10-28` and are
ignored by Git because this verified evidence capsule preserves them.

For example, recover one Phase61 member with:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/2026-10-28/phase61-verify/plan.json \
  --member final-state08/b2-semantics/source-controls/proof-main--program.json \
  --out selfhost/build-retention/phase61-recovery-NEW
```

Use a fresh receipt output. Omit `--member` to recover every selected file in
that plan. If live maps are lost, recover their two files (`plan.json` and
`files.jsonl`) from the pinned evidence capsule at the recorded workspace paths
first. Verify its digest using the manifest; do not overwrite existing maps.
The original archive receipts and exact method/policy files are also required.
Historical documents that link directly to archived raw files require this
restoration step; current workflow links point to retained reports or capsules.
Same-disk archives provide recoverability, not an independent offsite backup.

The next useful step is to use run closure routinely, then review another bounded
cold tranche only when needed. Do not rerun the one-shot initial campaign or
delete old phase directories wholesale.
