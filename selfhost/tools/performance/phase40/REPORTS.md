# Reused final report helpers

Root runs these static readers after final source/measurements settle. They run
no compiler, program or profile. Outputs must be new. Keep one authoritative
execution table, with confirmations separately labeled and never pooled.

```sh
python3 selfhost/tools/performance/phase40/summarize-execution.py \
  --attempt FINALATTEMPT \
  --baseline-api 04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f \
  --report HISTORICAL_RUN --report VARIATION_RUN \
  --report DEVELOPMENT_RUN --report HOLDOUT_RUN \
  --require-full --out selfhost/build/phase40/execution-summary01
python3 selfhost/tools/performance/phase40/source-counts.py \
  --baseline-attempt selfhost/build/phase39/checked05 \
  --baseline-api 04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f \
  --attempt FINALATTEMPT --out selfhost/build/phase40/source-counts01.json
```

The execution summarizer changes only Phase39's hardcoded baseline API/display
label and phase report identity. Same-run pairings, sample ranges, drift,
provenance and45point completeness remain. Supplemental prototype compare.py
reports are a different schema and cannot replace checked execution reports.
Static counts reuse Phase32's line/declaration definitions on both frozen checked
snapshots; runtime support is separate. Counts are not compilation/request speed.
