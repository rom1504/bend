# Final Phase43 runtime charts

`final-corpus-charts-v1.py` is a read-only renderer of the final complete full45
runtime closure. It never compiles or runs a target and rejects exploratory
execution reports or partial/mixed corpora. Root runs it after final closure:

```sh
python3 selfhost/tools/performance/phase43/strings/final-corpus-charts-v1.py \
 "$RUNTIME_FULL45_CLOSE_JSON" \
 --catalog "$FROZEN_CATALOG_JSON" \
 --baseline-manifest "$FROZEN_BASELINE_MANIFEST_JSON" \
 --candidate-manifest "$FINAL_CANDIDATE_MANIFEST_JSON" \
 --out "$FRESH_CHART_DIRECTORY"
```

Manifest/catalog identities must match the exact closure plan. Outputs are
`corpus.svg`, `families.svg`, `family-wins.svg`, `report.md`, and `report.json`.
Keep the three SVGs beside the Markdown report, or copy them together to a tracked
report directory; all image links are relative. SVGs have a white background and
system fonts, without scripts, external assets or stylesheets, for GitHub images.

The renderer independently rederives role medians and min/max values from all669
complete fresh-process samples, checks their summaries, and pairs same-number
rounds. It preserves null half-drift values and known/missing counts. The first
chart shows all45 baseline/TS and candidate/TS median ratios by family, with
paired-round min/max whiskers (descriptive ranges, not confidence intervals).
TypeScript is the1× reference. Automatic logarithmic bounds show every value;
none is clipped or omitted.

The second chart distinguishes equal-point, equal-family and equal-source corpus
geometric weighting, then gives exact fixed-input family geometric means. It
never averages milliseconds across different work amounts. The third chart
counts strict median wins/regressions/unchanged points per family. Tiny median
differences count in this descriptive comparison; no significance claim follows.
Exact per-point medians, paired ratios, signed/missing drift, role/module inputs
and all weighting definitions remain in JSON and Markdown tables.

Phase42 maintained conventions were reused from evidence/final-results-v2.py and
plot-ratios.py, without modifying them. Static Python syntax, geometric-mean
arithmetic, HTML escaping and standalone SVG/XML checks pass. No actual final
corpus has been rendered before root supplies the final closure.
