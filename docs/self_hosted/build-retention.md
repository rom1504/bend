# Build artifact retention

Initial implementation, 2026-10-28. The user authorized the reviewed cleanup and
policy rollout. New jobs have disk admission/monitoring and an explicit close
workflow; the first cleanup uses authenticated existing archives. See the
[implementation report](../../implementation/build-retention/README.md),
[proposal review](../../research/build-storage/2026-10-28-review.md), and
[tool instructions](../../selfhost/tools/build-retention/README.md).
Existing frozen evidence tools keep their current hashes. No scheduled garbage
collector or whole-phase deletion rule is enabled.

The retention unit should be an **artifact within a closed experiment**, not a
phase number. A recent phase can contain disposable duplicates; an old phase can
contain an installed compiler, a toolchain dependency or the shared execution lock.

## What to retain

| Class | Keep available | After the experiment closes |
| --- | --- | --- |
| Operational roots | Installed selections, latest qualified compiler, previous qualified fallback, distinct supported routes, active work, tools/runtime/Base/carrier and required dependencies | Retain until explicitly superseded; age alone never expires them |
| Coordination state | Shared execution lock, active-job records, retention manifests | Never include in build-output cleanup |
| Scientific evidence | Source snapshots/patches, exact methods/configuration, input identities, results, raw timing samples, qualification/refusal evidence and informative failed attempts | Keep permanently in compact experiment capsules; do not leave millions of loose files |
| Exact binary evidence | Qualified compiler images and required runtime/object files; retained profiles' instrumented ELF, owner/symbol map and samples together | Keep hot when in use, otherwise in a verified restorable archive; a hash or rebuild recipe alone is insufficient |
| Generated bulk | QBE, assembly, generated C/JS, per-round executable copies and intermediate caches | Keep one canonical copy for each required unique product; archive useful unique bytes, discard redundant/reproducible scratch after its evidence is sealed |
| Failed/interrupted scratch | Diagnostic and negative evidence, unique source changes | Seal useful failure evidence promptly; partial bulk outputs need no permanent retention unless they explain the failure |

Protect **files and their required dependencies**, not every output in the same
phase directory. Initially seed roots from:

- `selfhost/tools/native/selection.json` and all other actual installed selectors.
  This native selector currently names Phase102 B2; do not infer installation
  from the largest phase number or a research README.
- Phase146's candidate, Phase144 final04 fallback, and the Phase137 research
  checkpoint/distinct incremental workflow until explicitly retired.
- Active/unfinished experiment manifests and uncommitted work, regardless of age.
- Frozen benchmark inputs/oracles, required toolchain acquisition inputs, and the
  current shared lock at `selfhost/build/phase32/execution.lock`.

Distinguish dependency edges. An input that a command reads or hash-verifies is
an operational dependency even if that check looks historical. A source/tool
needed to reacquire a toolchain is a rebuild dependency. A historical citation is
provenance, not necessarily a requirement to keep every old binary online. Follow
actual tool imports, receipt reads, dynamic paths and setup procedures; a string
search is a candidate generator, not a proof of non-use.

Do not recursively classify every provenance link as hot storage: that would
retain the entire history forever. Conversely, do not stop supplying bytes which
existing preflight code actually opens. New qualified releases should describe a
bounded operational/rebuild dependency set separately from historical evidence.

## Lifecycle and simple metadata

Use `active → finished → sealed`, with an explicit close classification of
`completed`, `qualified`, `rejected` or `failed`. The tools record the command,
artifact roots, method/input identities, lifecycle status, classification,
retained roots and exact archived/pruned members. Record owner/purpose, source
commit, operational/rebuild dependencies and next review trigger in the campaign
report: those policy fields are not automatically inferred by the current tools.
A status of `failed` does not mean its evidence is trash.
Record whether recovery is byte-exact, a rebuild recipe only, or deliberately
retired. Keeping a source recipe does not promise historical binary identity.
Unregistered/orphaned runs go to review after seven days, using recorded lifecycle
events rather than filesystem mtime; uncertainty is not automatic permission to
delete. Uncommitted files flag unfinished ownership, not proof of a running job.

The implementation uses an inventory and a file-level retention plan with
explicit protection rules and reasons for retained members. It does not need a general
compiler cache, service or new IR. New runs use fresh directories. A benchmark
round should store its measurements and product identity, not another copy of the
same compiler/program. Compare before removing duplicates and retain an exact
canonical copy plus the comparison receipt. Different output remains evidence.

Use streaming emission and the existing pipe builder where appropriate. Keep
one required full self-reproduction reference rather than a separate copy of
each equal stream. Avoid materializing assembly/IR solely to retain it forever.

## Disk budgets

Suggested initial settings, subject to the protected-set inventory:

- Start cleanup review at **30 GiB** of hot `selfhost/build` storage; stop starting
  discretionary campaigns at **40 GiB**. Reduce these limits after measuring the
  minimum protected working set. These are planning limits, not eviction orders.
- At mount level, aim to recover **at least 10 GiB free** and keep a **5 GiB reserve**.
  This is a shared filesystem; a project budget cannot control other writers.
- Each run declares its expected **peak additional disk**, including retained
  products, simultaneous machine-build outputs, logs, temporary archives and
  restoration space. Admit only when `free >= reserve + peak_additional_disk`,
  checking after acquiring the execution lock and before starting the child.
- Monitor free space during the run. If it approaches the reserve, stop only the
  owned job and preserve its diagnostic record; do not launch deletion in the
  middle of an active compiler run. External writers can race monitoring, so this
  is not a hard filesystem quota.

The current Phase111 guard checks only `(160 + 2 * file_mib) MiB` before acquiring
the lock: 416 MiB at the default. Its per-file limit cannot bound a multi-file
campaign. The successor is `selfhost/tools/build-retention/guard.py`, with whole-run
admission and monitoring; the historical guard consumed by pinned receipts stays
unchanged. Current workflow instructions require the successor for new jobs.
The 30/40 GiB project levels remain review targets during migration: grandfathered
storage still exceeds them. They are not a new automatic eviction threshold or
a currently enforced global quota. The 5 GiB mount reserve and explicit per-run
budgets are enforced for new guarded jobs.

## Safe reclamation

1. Confirm the run is closed and no owned/other active work uses its files. Use
   the shared execution lock; never remove or replace the lock inode. Exclude
   symlinks, toolchains and unclassified files from a first deletion tranche.
2. Resolve the protected dependencies and produce a specific file list. Treat
   unresolved dynamic dependencies as review items. Recheck identities before
   applying, since a dry run can become stale.
3. Preserve exact unique artifacts when needed. An archive must contain the
   actual member, not just its filename/hash in an inventory. Verify archive
   integrity, member bytes/hash and required modes; restore a bounded capsule
   into isolated scratch as a practical check.
4. Deduplicate immutable files only after exact identity/equality and metadata
   checks. Existing Phase131/146 tools demonstrate journaled hardlink workflows.
   Shared files must never be rebuilt in place. Prefer these existing mechanisms
   to a new general content-addressed storage system initially.
5. Journal the reviewed unlink list and archive/member recovery location. Keep
   source, results, negative evidence and the cleanup receipt. Use small batches
   when archive scratch space is tight. A same-filesystem rename/quarantine
   releases no disk; same-filesystem compression saves space but is not a backup.
6. Measure actual free-space change. Count allocated blocks once per
   `(device,inode)`, and estimate release only when **all hardlinks** are removed.
   Open files, filesystem metadata and concurrent writes affect the observed
   result. Do not sum earlier cleanup receipts as new available savings.

Use an independent storage destination for durable exact archives when one is
available and authorized. Until then, preserve the explicitly retained exact
artifacts locally and be clear about the limits of historical reproducibility.

## First rollout

The [completed first cleanup](../../implementation/build-retention/README.md)
reclaimed approximately 7 GiB through file-level plans in 23 closed phases with
existing full archives, leaving approximately 9.8 GiB free before evidence
packaging. This is slightly below the 10 GiB headroom target; the reviewed tranche
was exhausted rather than expanding deletion merely to reach a round number.

Active Phase6/68 work, Phase32 coordination state, Phase107 acquisition, installed
and qualified compiler roots remain available. Phase4/5 also remain: unfinished
Phase6 work reads their files. Phase16 was not pruned in this campaign. No phase
directory was deleted. New jobs now use disk admission and explicit closure;
review storage at campaign close rather than waiting for the disk to fill again.
