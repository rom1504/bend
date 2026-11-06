# Phase171 headroom review

This is a bounded metadata audit, not a deletion plan. No compiler ran, archive was created, original artifact was changed, or file was removed. The recorded starting HEAD is `25dda2f`.

The already-archived pool is effectively exhausted: only about **13.9 MiB** of clearly nonfinal Phase170 fixture assembly/object files remain. Another roughly 71 MiB belongs to final/public/installed validation products and remains protected. The much larger earlier Phase169/170 cleanup totals are historical reclaimed space, not new available savings.

The best remaining option is to archive selected old **assembly/object files only**, leaving all executables and exact QBE products hot. `retention-candidates.json` identifies 36 exclusive regular files in 18 exact Phase111/134 artifact roots used by Phase127–144 experiments:

| Scope | Raw allocated storage | Estimated net after new archives |
|---|---:|---:|
| 17 completed historical builds | 1,694.16 MiB | 1,486.97 MiB |
| One terminal failed `session-native-pipe01` build | 96.95 MiB | 85.09 MiB |
| **All 18** | **1,791.10 MiB** | **1,572.05 MiB (1.54 GiB)** |

The estimate uses the measured 12.23% archive/raw ratio from six previously verified same-format assembly/object capsules. Compression and concurrent writes can change actual net recovery. No candidate is currently eligible for unlinking: these unique bytes need fresh, fully verified archives first.

Every candidate has a pinned original report and terminal writer guard; the single failed build is explicitly labeled, with exit 1 and a finished timestamp. Failure is not treated as proof that its evidence is disposable. Its diagnostics, source, methods and executable remain hot, and its two intermediates require the same exact archive/restore guarantee. Existing successful-build capture tooling refuses failed reports, so this row needs an explicit failed-run admission path or should be deferred rather than relabeled.

Only metadata and original recorded hashes were inspected. Some old assembly files lack original report hashes; they are labeled as requiring an exact current-byte hash before capture. Sizes, regular-file status, exclusive links and empty extended attributes were checked. No selected file was referenced by the bounded current selector/assets/build-tool and Phase171 recipe checks. This does not turn every historical provenance edge into an operational requirement; root must confirm that no newly active measurement needs these particular intermediates before capture.

The Phase170 installed and final N1/N2/Q3 artifacts, rollback, Phase152 reference, Phase169 final quality/performance, every ELF, every source/API and every QBE reference are excluded. Runtime objects, owner maps, timing samples and reports are also excluded.

## Initial Phase170 chain

Its N1/N2 assembly/object files occupy **179.16 MiB**, but the original guard is explicitly `qualified`, retained hot, with no archive. They are **not selected**. The policy permits file-level supersession; it does not permit silently rewriting a qualified close into a failed/completed one. A separate optional proposal would need to identify the final installed chain as successor, establish that these particular intermediates are no longer operational/rebuild/profile dependencies, retain both original ELFs and exact QBE references, create and verify exact archives, then authorize only those four unlink operations. This is unnecessary if the older 18-root proposal meets the workspace need.

## Recommended sequence

1. Root reviews the explicit old-product list and the failed-run distinction.
2. With the target lane idle, capture one small exact root at a time. Bound temporary archive storage; do not allocate a whole-phase archive.
3. Reopen every archive member and verify bytes/modes, recheck current identities, then let maintained `archive-v02.py` issue the exact selective plan.
4. Root applies each verified plan and records actual free-space change. Keep archives, plans and restore commands.
5. Stop once sufficient workspace is recovered. Keep all current/qualified/fallback dependencies and the initial Phase170 chain unchanged.

No fresh archive campaign or prune command was executed by this audit. The existing preverified pool alone cannot supply the requested roughly 1.5 GiB.

## Root-authorized completed-build sequence

Root approved fresh exact archival of the **17 successful builds only**. The failed root remains excluded. `retention-approved-completed.json` freezes this narrower scope, terminal guard/report pins, current file metadata, and the two retained capture/verifier method identities. Its SHA-256 is `aa91825c9d1698894b4eff9b537866850a6c117c2373f7601af8d03fe26430df`.

The root-operated command is:

```sh
python3 -B experiments/phase171/reclaim-closed.py check
python3 -B experiments/phase171/reclaim-closed.py apply --limit 3
```

Three initial roots should recover about 240 MiB net; that is an estimate until the resulting receipts exist. Run `apply --limit 17` later to process the remaining roots. `--limit` counts additional roots, not previously completed roots. The script never invokes a compiler. It refuses an occupied shared execution lock, requires 5 GiB reserve plus 34 MiB scratch headroom, and caps each streamed gzip archive at 32 MiB. Each root is captured, reopened, verified, and pruned before the next archive starts. Uncontrolled external writers can consume free space; a reserve check then stops the sequence, with current source artifacts retained if pruning has not begun.

All exact pruning uses maintained `archive-v02.py`. Its generated plan must select precisely that root's `program.s` and `program.o`; every other regular file's metadata must remain unchanged. Fully completed roots can be authenticated on a later invocation. Any partial archival, verification, or deletion failure stops for review; the script does not silently overwrite evidence or delete an incomplete archive.

Per-root capsules, exact plans, capture receipts, removal intents/journals, and results are retained under:

```text
selfhost/build-retention/phase171/reclaim-completed/<root-name>/
```

Exact recovery of a selected root uses its retained plan, with a fresh restoration receipt directory:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase171/reclaim-completed/<root-name>/verified/plan.json \
  --out selfhost/build-retention/phase171/reclaim-completed/<root-name>/restored-01
```

Preparation validated Python syntax, the CLI schema, all 17 successful terminal guard statuses, and the frozen current metadata. The child agent did not run capture or prune. Actual storage recovery must be reported from the root-operated apply receipts, not these predictions.

## Actual first sequence and safe stop

Root reported successful reclamation of the first three roots, then ten further roots (13 total). The last completed root was `p144-native-profile03-n1`. The next root's unselected-file preservation audit refused a shared inode. This is a safe stop, not evidence of a disposable alias: the remaining four roots stay untouched, the exclusivity check remains unchanged, and no retry that relaxes it is authorized. Root reported approximately 6.51 GiB free afterward. Exact reclaimed storage must be read from the 13 per-root apply receipts; the original 17-root estimate is not an actual completed total.

## Shared retained siblings: narrow successor

Root authorized a successor for the remaining four already-approved roots. Read-only inspection showed that the selected `program.s`/`program.o` leaves still have one link; the rejection came from two **unselected** `program.ssa` siblings with two links. Those QBE files must remain hot.

`reclaim-closed-v2.py` leaves the v1 script, proposal and 13 completed receipts unchanged. It retains exclusive-file admission for every archive/prune target and the unchanged maintained verifier/applicator. Only the kept-sibling observation changes: an unselected shared regular file is checked for identity, mode, owner/group, link count, allocation, modification/change timestamps and empty extended attributes, then hashed, then checked again for stability. These facts and SHA must agree before and after capture/pruning. Access time is deliberately excluded because reading can update it. Such a sibling is never put in the archive's two-member selection or the prune plan.

The original unshared retained-file metadata format is preserved exactly, so earlier receipts can be revalidated rather than rewritten. Existing incomplete output directories still cause a safe stop. The remaining four roots contain 448,081,920 allocated bytes (427.32 MiB); predicted net recovery after new capsules is approximately 375 MiB, not a measured result.

Root may run, while the shared target lane is idle:

```sh
python3 -B experiments/phase171/reclaim-closed-v2.py check
python3 -B experiments/phase171/reclaim-closed-v2.py apply --limit 4
```

Successor SHA-256: `8c70db943f52aa39cf7862d39b76ad50e454e96ccba9395bc700008bb14bf785`. Four isolated metadata controls passed (`selfhost/build/phase171/retention-kept-controls01/report.json`): shared kept files record hash/link count; shared selected files are still rejected; writes through an alias change the retained identity; unshared retained identities remain byte-for-byte compatible with the old metadata schema. These controls created only their own tiny fixtures. No existing artifact was changed, archived or pruned by the child agent.
