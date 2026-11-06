# Combined candidate stage profile

Both captures execute the same original Phase170 full-source request and match
the 97,488,970-byte Q3 oracle. They use the same 32ms sampler, runtime instrumentation,
CPU3 policy and semantic marker labels, with fresh FIDs bound to each image.
The candidate compiler's own source is different; the measured input is not.

| Capture | Child wall | Disjoint marked wall | Samples | Main/process CPU |
| --- | ---: | ---: | ---: | ---: |
| Installed Phase170 diagnostic |180.095s|179.961s|5,584|99.375%|
| Combined candidate diagnostic |172.745s|172.609s|5,358|99.345%|

Both reports are complete, exact-output, stage-order/multiplicity-valid and
zero-loss. Candidate peak RSS is794,788KiB. These are diagnostic observations,
not the clean 188.620→180.677s whole-build comparison. No machine construction or
allocation counters are included here. Boundaries outside first-entry/exit-hook
clocks remain outside the sums.

| Disjoint region | Original seconds | Candidate seconds | Change |
| --- | ---: | ---: | ---: |
| Parse/load |28.742|29.545|+0.803|
| Check/publication |21.239|19.027|−2.212|
| Frontend after checking |18.080|18.281|+0.201|
| Raw private candidates |25.514|24.985|−0.529|
| Scalar finish/retry composition |8.635|3.807|−4.828|
| Demanded generic families/adapters |8.443|8.508|+0.065|
| Original/static/adapter verifier |8.914|9.283|+0.369|
| View/certificate/direct verifier |3.129|3.474|+0.345|
| IDs/tables/index/registry |12.182|12.271|+0.090|
| Cursor rendering/output/exit |32.451|30.454|−1.997|
| Other disjoint intervals |12.631|12.973|+0.342|

The last row groups the remaining adjacent intervals; use the full 29-interval table
in `implementation/phase171/metrics.json` for totals. The large retry decrease is
consistent with catalogue reuse, and publication decreases in the expected
region. Neither establishes causality for an isolated patch: all four overlays
change together, execution order is unbalanced, and the current early markers
include continuations/argument evaluation. Render improvement may include lazy
planning and altered ownership; it is not measured pure formatting time.

The two expensive construction regions remain about 33.49s combined, and registry
plus rendering remains 42.73s. This supports the original conclusion that small
cleanup alone is insufficient for 100s. Raw-candidate fail-fast does not produce
the large region reduction hoped for on this workload. Do not scale the 4.83s
retry reduction across unrelated stages or declare the whole region eliminated.

Only parse/load, checking, raw candidates and rendering exceed the 500-sample
per-interval threshold in both captures. Smaller-region clock observations remain
valid, but their physical-owner distributions are descriptive. Unknown lexical
ownership remains explicit; matching labels do not establish inclusive source
cost. The existing [original analysis](current-profile.md) explains those limits.

Exact receipts: `selfhost/build/phase171/{profile-full01,candidate-profile-full01}/report.json`
and `{profile-full-stages01,candidate-profile-stages01}.json`.
Methods and fresh-output commands are in [candidate-profile-plan.md](candidate-profile-plan.md).
No code changes or new target jobs were performed by this offline comparison.
