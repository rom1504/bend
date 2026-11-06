# Phase169 bounded retention review

The initial free-space snapshot was about 5,016 MiB, below the ordinary 5 GiB compiler-job reserve. This review is metadata/archive maintenance only: no compiler, benchmark, or semantic validation target was executed.

## Existing verified archives

`retention-policy.json` selects 79 individual generated QBE, assembly, or object files across 20 completed Phase147/148/154 component runs. Their exclusive allocated storage is **139,116,544 bytes (132.67 MiB)**. `archive-v02.py verify` authenticated the compressed streams, every archive member, and each selected current file. The exact planned file set and allocated-byte totals were checked against the policy. Root subsequently reviewed and applied this tranche.

All ELF executables, qualified images, source, hosted APIs, receipts, logs and reports remain. No directory deletion or execution-lock modification is authorized. The policy and verified plans preserve exact restore routes. `retention-plan.py` is a narrow command list over the maintained archive verifier, with exact-set checking before application.

The preferred Phase149–164 run-capsule inventories were mostly exhausted by earlier cleanup. The only large exclusive remaining component set was the 52 MiB Phase154 build included above. Several apparent full-compiler products in Phase156/160/161 are hardlink aliases to protected Phase152 output: they were excluded, and their logical sizes were not counted as reclaimable storage. Four Phase156 pilot SSA copies could recover about 60 MiB, but their deduplicated archive mapping would require additional restore machinery. Fresh capture of much larger, clearly identified old products has better return.

## Fresh, narrow archival proposal

`fresh-archive-proposal02.json` identifies ten old **SSA files only**, totaling **1,115,389,952 bytes (1,063.72 MiB)**, under individually named Phase130 request directories for Phase131/134/137/140/144 experiments. Every request is complete and has an exact-output successful writer guard. The request's original SHA-256 is retained. These payloads were excluded from old bounded evidence capsules; an identity receipt alone does not authorize removing them.

No selected path appears in the maintained build tools/manifests or Phase168 methods inspected. Every other file in each request directory remains hot. Phase152's qualified compiler and canonical output, all current Phase168 products, and all ELF/source/API dependencies remain outside scope. Old historical reproduction may need an explicit restore before reusing these emitted SSA files; that requirement is intentional and recoverable.

Root approved first capture, `p140-acquire04/program.ssa`. `archive-selected.py` preserved the one exact regular file in a 15,902,391-byte gzip archive, reopened it, checked bytes/mode and unchanged source metadata, drained gzip through its footer, then used the maintained `archive-v02.py verify` to produce the exact prune/restore plan. It does not prune. Its archive scratch allowance is explicitly capped at 20 MiB per file. The ordinary 5 GiB target-job reserve is not being lowered; this is separately reviewed maintenance during low-space recovery.

The first source occupies 117,809,152 allocated bytes, so archive retention makes its net recovery about 97.19 MiB. Capturing the remaining nine sequentially, with root review and application, should recover roughly another 820 MiB; exact net recovery must use actual archive blocks and filesystem measurements, not this compression estimate. Combined recovery should be around 1 GiB. Do not create a full-phase archive or delete any whole phase.

The first capture pins `fresh-archive-proposal.json`; version02 adds the final guard evidence without changing that consumed proposal. Keep both. Root subsequently approved selective capture/verification of the remaining nine; root alone owns application. To capture an approved named row:

```sh
python3 -B experiments/phase169/archive-selected.py \
  --proposal experiments/phase169/fresh-archive-proposal02.json \
  --name p140-acquire03 \
  --out selfhost/build-retention/phase169/fresh-p140-acquire03
```

Apply and restore use the maintained `archive-v02.py` with the resulting `verified/plan.json`. Every application reauthenticates the archive and selected live bytes before unlinking. Do not remove a source payload if capture, stream verification, source stability, or exact selection fails.

## Completed capture result

All ten approved fresh captures and exact maintained verification plans completed. SSA allocation is **1,115,389,952 bytes**, archive allocation **150,736,896 bytes**, giving **964,653,056 bytes (919.96 MiB)** net once root applies all ten. Together with the original verified tranche, nominal net recovery is **1052.64 MiB**, before small plan/receipt storage and unrelated writers. `fresh-archive-verification.json` pins every archive/receipt/plan. `fresh-prune-plan.json` lists the remaining nine exact apply and restore commands; first-file application was handled by root separately. This agent removed no files.
