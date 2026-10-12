# Phase70 sealed evidence

18240 files/symlinks and their directories are preserved. Every member was reopened and verified against its manifest and unchanged original.

Archive SHA-256: `df2c83ef7ff2c81ecd981e049348c1d912ad57ec41b1ca93f2191baf457f0f0e`. Part sizes and hashes are in `verification.json`; each is at most 50 MiB. For split output, concatenate parts in recorded order before opening the ZIP.

Extract only into an empty scratch directory with an extractor preserving Unix modes and symbolic links (Python extractall does not preserve these reliably). Verify extracted paths, bytes and modes against manifest.json before replay. Absolute paths in receipts need fresh replay plans.

External dependencies: Phase69 artifacts/evidence01, Phase68 facts-calls/evidence and parity-survey/evidence02; their exact files are pinned in manifest.json. System tools, upstream checkout and dependencies of those capsules remain external. Repository design/reports remain tracked separately. No hermetic-build claim.
