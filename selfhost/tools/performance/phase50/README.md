# Brief V8 guard survey

See the [45-point report](../../../../implementation/phase50/README.md) and
[generic-dispatch investigation](../../../../implementation/phase50/generic-dispatch.md).
The compiler and generated programs are unchanged. This is diagnostic evidence,
not a new clean performance comparison.

`run-profiles.py --jobs JOBS_JSON --out FRESH_DIRECTORY` reuses the maintained
`programs/profile.mjs` for numeric and full-string observations. Jobs contain a
unique label, an exact module `{file,bytes,sha256}` identity and a config path.
Configs retain the original export, arguments and expected result, plus
`profileKind`, `warmupCalls`, `warmupMs`, `targetMs` and `maxRepetitions`.
The queue runs serially under the existing resource guard; targets have 30-second
deadlines and 64 MiB output-file limits. The report records commands and hashes.

For this survey, CPU profiles used 1000 ms warmup / 800 ms sampling; allocation
used 1000 / 400 ms. The existing Phase49 queue collected the separate numeric
opt/deopt/inlining traces. No profile or trace duration belongs in a clean ratio.

`summarize-cpu.py QUEUE_REPORT NEW_JSON` audits all 45 RNFA04 points against
`inputs.json` beside the queue directory and their historical manifest. It sums
exclusive raw sample weights and counts guard ancestry once per sample.
`summarize-followup.py RAW_ROOT NEW_JSON` recomputes allocation totals, trace
markers and serial process intervals. Both tools read data only.

The [archive manifest](evidence/raw/archive.json) inventories every retained
module, config, raw profile, log and consumed producer. Verify the recorded
compressed hash before extracting `evidence/raw/raw-campaign.tar.gz` into a
fresh directory. Rehash members against the manifest after extraction.
Historical absolute paths remain exact; replay in a different location needs
fresh configs with local paths and unchanged module hashes, not edited receipts.
The Node binary and prior Phase48 evidence are prerequisites, not duplicated here.

Phase50 raw writers are closed. Further experiments require fresh output roots.
The archive producer's historical Phase42 schema does not change its Phase50
`rawRoot`; attempt/API fields identify unchanged installed RNFA04, not a new build.
