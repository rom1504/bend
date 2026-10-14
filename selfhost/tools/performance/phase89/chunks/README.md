# Deferred NC_Code bodies, v1 (source rejection retained)

This is the frozen first attempt. Its small checked acquisition failed because
`nct_within_work(todo, current, remaining)` matched `current` and then the
earlier binder `todo`, which Bend forbids. See
`selfhost/build/phase89/chunks-control01/report.json`. No v1 program was emitted;
the subsequent attempted JS launch therefore failed on a missing file as a
separate harness sequencing error.

All candidate, baseline, helper, control and derivative files remain unchanged.
The corrected attempt is [../chunks-v2/](../chunks-v2/README.md). Do not treat
the v1 source-derivation receipts as checked compiler receipts.
