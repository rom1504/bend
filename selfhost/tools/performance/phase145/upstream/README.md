# Phase145 upstream operation comparison

Read [method and limits](../../../../../research/phase145/upstream-method.md).
The current frozen root-only plan is
`selfhost/build/phase145/upstream03/jobs.json`. Its first four commands prepare
generated diagnostic artifacts and gate original/clean/counted Lexer. Only
continue to the other cases after all four pass. The investigating subagent
executes no target commands.

- `prepare-v03.py`: metadata-only input authentication and root job preparation.
- `generate-v03.mjs`: Bun transpilation, reversible generated-JS instrumentation,
  exact source/method pins; no source edits or compiler image build.
- `worker.mjs`: original, transpiled-clean or diagnostic request. Requires exact
  original C bytes for complete programs and identical loaded/checked summaries.
- `summarize.py`: metadata-only aggregation; fresh output required.

The older files and `upstream02` failed preparation remain as evidence. Do not
edit frozen methods or rerun into their existing output directories. Derive a
new plan/version for corrections. Every workload is guarded individually; the
only compiler prefix is explicitly parse-only. Source Base participates in the
upstream process, while our native comparator has a prepared Base; preserve
that accounting distinction. There is no machine compilation or execution of
generated programs in these jobs.

Optional full-source parse extension:
`selfhost/build/phase145/upstream-full-parse01/jobs.json` reuses the same generated
artifacts on exact frozen Phase142 input. It contains only original/counted load
jobs, each30s/3GiB. No check/emission follows. The three-variant summarizer above
intentionally cannot certify this two-variant plan; interpret its two receipts
separately, retaining the matching loaded summaries and actual source pins.
