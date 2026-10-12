# Phase69 sealed evidence

10385 files/symlinks and their directories are preserved. Every member was reopened and verified against its manifest and unchanged original.

Archive SHA-256: `d4ac0df9787abed50e49d7a4d48cd1e5dbde41290e80f8908d259b1b62f6cfb2`. Part sizes and hashes are in `verification.json`; each is at most 50 MiB. For split output, concatenate parts in recorded order before opening the ZIP.

Extract only into an empty scratch directory with an extractor preserving Unix modes and symbolic links (Python extractall does not preserve these reliably). Verify extracted paths, bytes and modes against manifest.json before replay. Absolute paths in receipts need fresh replay plans.

External dependencies: Phase68 facts-calls/evidence and parity-survey/evidence02; their exact files are pinned in manifest.json. System tools, upstream checkout and dependencies of those capsules remain external. Repository design/reports remain tracked separately. No hermetic-build claim.
