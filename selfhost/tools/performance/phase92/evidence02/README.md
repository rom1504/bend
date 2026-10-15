# Phase92 native correctness and broad-product evidence

`raw.zip` preserves1,101 files (44,678,142 uncompressed bytes): both native69
reports, six rejection observations, full-source TS/Bun result, live-Base Small
control, the original disk-stopped broad campaign, verified continuation and45
Clang/program execution pairs. Every member was read back and hashed before
publication. ZIP metadata preserves modes; `manifest.json` preserves lengths
and SHA256 identities.

The completed TS full C output is deduplicated to evidence01 member
`selfhost/build/phase92/upstream-checked01/compiler.c`; its exact mapping and
verification are in `implementation/phase92/reclamation-reference.json`.
The two native full self outputs are likewise preserved in evidence01 and may
be restored through `reclaim-self.py restore --out /tmp/FRESH`.

Historical dependency paths retain their original capsules. Restore named
members only into a fresh directory and verify full manifest identities/modes
before an explicit restoration to missing canonical paths. Closed duplicate
broad C/executables may be reclaimed only after this capsule is committed and
reverified; any such action must have a separate receipt.
