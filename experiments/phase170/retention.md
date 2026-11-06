# Phase170 selective retention

Three reviewed tranches reclaimed **1,148,809,216 allocated bytes (1,095.59 MiB)** across 51 old artifact roots: exactly 130 generated assembly/object files and five cold diagnostic JSONs. Existing verified archives retain every removed byte. No new archive, compiler job, whole-directory deletion, or target reserve change was needed.

The first tranche reclaimed **712,404,992 bytes (679.40 MiB)** by removing only `program.s` and `program.o` from eight closed Phase169 builds:

| Phase169 root | Reclaimed MiB |
|---|---:|
| native-n1 | 94.11 |
| native-n2 | 76.43 |
| native-n3 | 76.43 |
| single-native-n1 | 76.67 |
| single-native-n2 | 76.67 |
| canonical-baseline01 | 105.77 |
| single-canonical01 | 86.66 |
| quality-canonical01 | 86.66 |

Before application, every compressed archive, archive member, selected live-file identity/mode and sealed lifecycle→closure binding was authenticated. Fresh policies protected every archive member except the two named intermediates. The original broad capsule plans were **not** applied.

The aggregate plan is `selfhost/build-retention/phase170/reclaim169-plan.json`, SHA-256:

```text
1c13f0ed92a413e69b4328d67f36318d8ba952dd28a856faf2a08d5a909aec09
```

Each row retains its exact archive receipt, lifecycle, closure, policy and verification-plan pins, selected member hashes, and apply/restore commands. Per-root verification/application receipts are under `selfhost/build-retention/phase170/reclaim169-NAME/`.

Reproducible commands:

```sh
# Metadata/exact-selection check; does not prune.
python3 -B selfhost/build-retention/phase170/reclaim169-command.py check

# Executed successfully by root, once, with the target lane idle.
python3 -B selfhost/build-retention/phase170/reclaim169-command.py apply

# Recovery route if those exact historical intermediates are needed again.
python3 -B selfhost/build-retention/phase170/reclaim169-command.py restore
```

The runner pins the aggregate digest and checks the exact two-file selection before delegating to maintained `archive-v02.py`, which reauthenticates inputs before unlinking. Application receipts report two removals per root and the allocation totals above. These are recovered allocated blocks, not a claim that system free space increased by the same amount despite concurrent writers.

The post-apply audit in `retention-audit.json` passed: all **80 nonselected archived members** remain byte-identical, including the eight ELF executables and all reports/requests/logs. Both `quality-native-n1` and `quality-native-n2` images match their archived hashes; their assembly/object files remain present. The protected Phase152 N3 image and all three installed component images also match their recorded identities at audit time. Source, APIs, SSA/oracles, current inputs and qualification artifacts were outside the deletion set. No additional deletion or semantic target was executed during this audit.

## Additional tranche: 271.37 MiB

Root subsequently applied 40 fresh selective plans from closed Phase165–169 runs, removing **114** named `program.s`/`program.o` files and reclaiming **284,549,120 allocated bytes (271.37 MiB)**. Every quality root, runtime object, ELF, source, API, SSA/oracle and all Phase170 artifacts were excluded. The requested additional GiB was unavailable in the existing-archive pool; the smaller verified tranche was retained rather than expanding scope. The 38.07 MiB failed checker pilot SSA remains hot.

The additional aggregate plan is `selfhost/build-retention/phase170/reclaim-extra/plan.json`, SHA-256:

```text
c367ac0a09ef464156bd1f9335fbe17fc2677156f5836196c0c45da4ec2ab625
```

```sh
python3 -B selfhost/build-retention/phase170/reclaim-extra/command.py check
# Executed by root after review; do not repeat an already completed application.
python3 -B selfhost/build-retention/phase170/reclaim-extra/command.py apply
# Recovery if these historical intermediate files are needed again.
python3 -B selfhost/build-retention/phase170/reclaim-extra/command.py restore
```

Per-root apply receipts confirm exactly the reviewed sets and totals. The subsequent read-only audit verified all **976 nonselected archived members**, including **55 retained ELF images**; none was missing or changed. Phase152 N3, both final Phase169 quality compiler images and their assembly/object files remain intact. Seven Phase170 compiler/API images were checked against their completed producer reports: first-chain N1/N2, session-bootstrap builds A/B, checked B1, and the two lexer APIs. All three installed component images also match their current binding identities at audit time. The additional receipt pins and exact image hashes are in `retention-audit.json` under `extraTranche`; `combinedTotals` records both cleanup batches. No further deletion or semantic target was performed for this audit.

## Cold diagnostic tranche: 144.82 MiB

Root subsequently reclaimed **151,855,104 allocated bytes (144.82 MiB)** from five superseded Phase154/156 graph/book JSON captures. They were exact payload members of existing published archives; the Phase154 inventory was authenticated and projected for the maintained verifier. No alias reconstruction, new archive, compiler source, API, SSA, binary, or current/reference/quality product was involved.

The reviewed proposal is `selfhost/build-retention/phase170/reclaim-diagnostics/proposal.json`, SHA-256:

```text
d28e39b09f6d6b14958fdf9caabe0999829f0704c6e32252a44bd90146985587
```

```sh
# Executed by root after the active guard finished.
python3 -B selfhost/build-retention/phase170/reclaim-diagnostics/command.py verify
python3 -B selfhost/build-retention/phase170/reclaim-diagnostics/command.py apply
# Exact recovery route for the old diagnostic captures.
python3 -B selfhost/build-retention/phase170/reclaim-diagnostics/command.py restore
```

The first verification attempt correctly refused the occupied execution lock; its failure log remains. Subsequent maintained verification/application receipts confirm exactly five removals. All other files in the three affected roots remain identical to their archived payloads or aliases. The post-apply audit additionally verified Phase152 N3, both Phase169 quality images, both initial and both final Phase170 native generations, and final Phase170 B1/B2/B3 images, plus the three installed component images. Their exact identities and the application receipts are in `retention-audit.json` under `diagnosticTranche`. The 38.07 MiB checker pilot SSA and every Phase170 artifact remain hot. No further deletion or target execution occurred during the audit.
