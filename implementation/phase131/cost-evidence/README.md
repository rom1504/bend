# Preserved guard evidence

The three small archives are incremental: restore `native-cost01`, then
`native-cost02`, then `native-cost03` into a fresh evidence tree. They retain the
raw guard receipts, bounded logs and method snapshots. The final complete
[ledger](report.json) records every guard and its identity, timings, lane and
classification. Its `cumulativeArchivedFiles` binds the latest archived members.
[The identity index](index.json) pins the published archives and original files.

The first snapshot's purpose classifier was corrected later. Use the final
ledger for categories; retain earlier artifacts as historical evidence.
Guard wall sums are not CPU time, model-token counts, quota or money. No compiler
images or large generated outputs are copied into this archive set.
