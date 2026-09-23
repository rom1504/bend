# P5-020 evidence

The archive contains the two checked prototypes, their source/tool snapshots and
bootstrap reports, original checked API lineage, all selected baseline/candidate
runs and failures, corrected and superseded fixtures, final auditor, cost tool,
primed caches, raw timings and complete seed-equality gate metadata.

`archive.py` verifies final consumed identities, writes a fresh archive and reads
every compressed member back against `manifest.json`. Restore at the repository
root to recover recorded relative paths; original absolute paths remain in the
reports. The exact Node binary/Linux tools and original clean pinned upstream Git
metadata remain external prerequisites. Extraction does not fabricate a new
bootstrap, clean checkout or conformance pass.

The first two fixture versions are retained under
`selfhost/build/phase5/imported-freshness/fixtures-v1` and `fixtures-v2`. Earlier
reports refer to the original fixture paths: restore the corresponding version
there before replaying those historical failures. Final reports use the final
tracked fixtures. No invalid initial fixture is counted as successful coverage.

See [the scoped result](../imported-freshness.md). Four imported-law-fill semantic
differences and28 exact differences remain in the final selection.
