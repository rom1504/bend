# Phase45 complete execution comparison

**Pending worker23's three complete runtime batches and their validated summary.** No final aggregate, point table or chart is claimed yet. Historical screens remain in [the phase report](README.md); they will not be pooled into this comparison.

This report will compare fresh executions of Phase44 checked04 saved output, the checked worker23 candidate and pinned TypeScript output on all 45 maintained points across 23 source files. The benchmark catalog is `selfhost/tools/performance/phase37/catalog.json`; its exact source/point identities, compiler/runtime identities, role samples and resource protocol must agree with the three reports before summarization.

## Required evidence

- `selfhost/build/phase45/qualification23/runtime-0/report.json`
- `selfhost/build/phase45/qualification23/runtime-1/report.json`
- `selfhost/build/phase45/qualification23/runtime-2/report.json`
- The completed identity-bound runtime summary for those three reports.

The intended full protocol has five fresh rotated rounds per role and three for the raytrace point, totaling 669 samples. The final report will use median milliseconds per call, fresh same-point ratios, equal-point and equal-source geometric means, and an explicit family-weighted result if present. Compilation/import/first-call latency remain separate. All measurements describe warmed repeated windows; half-window drift will remain visible as a limitation.

## Final presentation

The completed report will include the aggregate comparison, all 45 point medians and ratios, source/family weighting, material regressions and remaining gaps. A standalone logarithmic SVG will compare Phase44/TypeScript and worker23/TypeScript per point, with a 1× parity line and the same fresh TypeScript denominator for each pair. No chart is generated from incomplete or invented values.

Passing execution values and fast timings do not establish complete compiler conformance, host-observation coverage, resource qualification or release installation. Those are separate selected-image checks linked from the phase report. Earlier failures and interrupted batches remain preserved and excluded from this final aggregate.
