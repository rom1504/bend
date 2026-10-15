# Phase91 closed evidence

`raw.zip` contains all 1,496 files from the completed Phase91 raw tree:
59,227,662 uncompressed bytes, including inputs/plans, complete current compiler
outputs, reports, progress, resource guards and the observed diagnostic failures.
The archive is 8,979,466 bytes, SHA-256
`db146c52cafa84faa318b1dba7c4456b105050d32b70b3eb789c399791363695`.

[receipt.json](receipt.json) pins the archive, [manifest.json](manifest.json),
and the sealing method. Every archived member was compared against both its
recorded digest/length and unchanged raw file while holding the execution lock.
Historical images, fixtures and oracles retain their earlier committed capsules;
this is a complete Phase91 delta, not a standalone compiler distribution.

Extract only into a fresh directory, preserving the original repository-relative
layout, for inspection:

```sh
python3 -m zipfile -e selfhost/tools/performance/phase91/evidence01/raw.zip /tmp/phase91-evidence
```

Verify extracted file digests against the manifest before using them. Stored
plans intentionally retain the canonical checkout paths and completed output
directories; make a fresh plan/output path for a rerun. Do not overwrite a closed
attempt or treat `complete:true` measurement as all-pass conformance. The strict
frontend failure and observational `passed:false` record remain in the report.
