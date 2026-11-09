# Native45 runtime comparison

Source report: `/home/ai/bend2/build/publish/bend/selfhost/build/phase184/runtime01/report.json` (SHA256 `ccc44250f1951a2b445e6f35c7e58de25116e5f94c0b26b82dac30d71bc78111`).

All 45 cases admitted; aggregate uses 44 timed cases. `scalar-region-0` is correctness-only. Times are normalized in-program microseconds per invocation, including validation and success-count printing. Dispersion below is median absolute deviation (MAD), not a confidence interval. Ratios above 1 mean Bend is slower than handwritten C. This excludes acquisition/build time.

| Backend | Point geomean | Equal-family geomean | Equal-source geomean | >1.1× | >2× | >10× |
|---|---:|---:|---:|---:|---:|---:|
| Bend QBE | 1.671× | 1.746× | 1.813× | 33 | 25 | 4 |
| Bend C | 1.071× | 1.052× | 1.111× | 23 | 13 | 0 |
| Best Bend envelope | 0.878× | 0.865× | 0.921× | 23 | 13 | 0 |

Post hoc per-case minimum of Bend medians; not a single backend configuration.

Best Bend backend counts: bend-qbe 9, bend-c 35, tie 0.
Fastest among all three roles: handwritten-c 26, bend-qbe 6, bend-c 12, tie 0.

Weighting first averages log ratios within each family/source group, then weights groups equally. The timed cohort has 22 families and 23 source groups.

Bend QBE: lowest ratio `coverage-closures-256` 0.012×; highest `coverage-map-churn-128` 11.940×.
Bend C: lowest ratio `coverage-list-pipeline-512` 0.105×; highest `raytrace` 4.206×.
Best Bend envelope: lowest ratio `coverage-closures-256` 0.012×; highest `raytrace` 4.206×.

Sorted by the best Bend envelope, slowest relative case first. Full min/max dispersion is in `cases.csv`.

| Case | C µs ± MAD | QBE µs ± MAD | Bend C µs ± MAD | QBE/C | Bend C/C | Envelope/C |
|---|---:|---:|---:|---:|---:|---:|
| raytrace | 6737 ± 26.3 | 3.242e+04 ± 83.3 | 2.833e+04 ± 0 | 4.812× | 4.206× | 4.206× |
| coverage-record-aggregation-256 | 97.04 ± 0 | 1013 ± 2.55 | 393.4 ± 0 | 10.437× | 4.054× | 4.054× |
| coverage-record-aggregation-64 | 27.36 ± 0 | 263 ± 0.649 | 99.13 ± 0 | 9.612× | 3.623× | 3.623× |
| coverage-map-churn-128 | 67.89 ± 0 | 810.7 ± 0 | 230.7 ± 0 | 11.940× | 3.398× | 3.398× |
| variation-ray-active-64-2440 | 32.66 ± 0.13 | 118.3 ± 0.473 | 108.1 ± 0 | 3.621× | 3.310× | 3.310× |
| variation-ray-active-256-2240 | 137 ± 0.544 | 498 ± 0 | 449 ± 0 | 3.634× | 3.277× | 3.277× |
| coverage-map-churn-32 | 14.36 ± 0.114 | 164.5 ± 0 | 46.27 ± 0.184 | 11.456× | 3.222× | 3.222× |
| variation-symreg-4-17 | 371.5 ± 0 | 1059 ± 3.47 | 1167 ± 20.8 | 2.851× | 3.141× | 2.851× |
| symreg | 751.5 ± 2.99 | 2118 ± 0 | 2299 ± 0 | 2.818× | 3.059× | 2.818× |
| variation-symreg-7-123 | 1291 ± 10.2 | 3534 ± 11.4 | 3841 ± 11.4 | 2.738× | 2.976× | 2.738× |
| tree-bitonic | 62.21 ± 0 | 579.4 ± 8.95 | 169.3 ± 3.06 | 9.314× | 2.722× | 2.722× |
| variation-tree-bitonic-6-17 | 9.109 ± 0.1 | 98.28 ± 0.359 | 24.58 ± 0.09 | 10.789× | 2.698× | 2.698× |
| variation-tree-bitonic-9-123 | 170.9 ± 0.692 | 1476 ± 11.8 | 418.2 ± 9.43 | 8.638× | 2.447× | 2.447× |
| variation-editdist-3-123 | 988.1 ± 0 | 2108 ± 0 | 1687 ± 0 | 2.134× | 1.707× | 1.707× |
| test-evening-program | 0.6106 ± 0.00244 | 3.82 ± 0.0147 | 1.04 ± 0.00385 | 6.256× | 1.704× | 1.704× |
| editdist | 496.1 ± 1.97 | 1054 ± 0 | 841.2 ± 0 | 2.125× | 1.696× | 1.696× |
| local-pair | 123.9 ± 0 | 264.6 ± 0 | 210 ± 0 | 2.136× | 1.695× | 1.695× |
| variation-editdist-0-17 | 123.9 ± 0.494 | 262.6 ± 0 | 209.2 ± 0 | 2.119× | 1.689× | 1.689× |
| mandelbrot | 16.05 ± 0 | 67.01 ± 0 | 26.45 ± 0 | 4.176× | 1.649× | 1.649× |
| test-map-set-ops | 6.45 ± 0 | 31.45 ± 0 | 10.42 ± 0 | 4.876× | 1.616× | 1.616× |
| test-morning-program | 2.033 ± 0.0161 | 9.645 ± 0 | 2.861 ± 0.0114 | 4.744× | 1.407× | 1.407× |
| complete-generic-row32 | 57.95 ± 1.57 | 296.6 ± 1.37 | 79.8 ± 0 | 5.118× | 1.377× | 1.377× |
| variation-mandelbrot-grid-4-7 | 7.972 ± 0 | 14.95 ± 0.0408 | 9.106 ± 0.0364 | 1.875× | 1.142× | 1.142× |
| test-rle-roundtrip | 0.4377 ± 0.00103 | 1.169 ± 0.0508 | 0.4758 ± 0.00103 | 2.670× | 1.087× | 1.087× |
| variation-mandelbrot-grid-5-31 | 138.6 ± 0 | 216.8 ± 0 | 144.8 ± 0 | 1.564× | 1.044× | 1.044× |
| coverage-numeric-recurrence-1024 | 3.245 ± 0 | 4.86 ± 0 | 3.248 ± 0.0129 | 1.498× | 1.001× | 1.001× |
| scalar-region-8192 | 37.3 ± 0.149 | 61.51 ± 0.179 | 37.12 ± 0 | 1.649× | 0.995× | 0.995× |
| coverage-numeric-recurrence-256 | 0.819 ± 0 | 1.222 ± 0 | 0.8101 ± 0 | 1.493× | 0.989× | 0.989× |
| variation-local-fold-8192-123 | 6.586 ± 0.0262 | 11.01 ± 0.0328 | 5.472 ± 0.0219 | 1.672× | 0.831× | 0.831× |
| local-fold | 3.309 ± 0 | 5.537 ± 0 | 2.746 ± 0 | 1.673× | 0.830× | 0.830× |
| variation-local-fold-128-0 | 0.1319 ± 0 | 0.266 ± 0 | 0.1062 ± 0 | 2.016× | 0.805× | 0.805× |
| coverage-unicode-text-16 | 13.66 ± 0 | 27.78 ± 0.331 | 8.994 ± 0 | 2.034× | 0.658× | 0.658× |
| coverage-unicode-text-64 | 66.83 ± 0.265 | 116.5 ± 0 | 40.02 ± 0 | 1.744× | 0.599× | 0.599× |
| coverage-expression-32 | 4.7 ± 0 | 2.04 ± 0.00673 | 2.181 ± 0 | 0.434× | 0.464× | 0.434× |
| variation-lexer-10-123 | 3688 ± 0 | 3938 ± 15.6 | 1543 ± 0 | 1.068× | 0.418× | 0.418× |
| lexer | 921.6 ± 3.92 | 986.5 ± 4.48 | 384 ± 0 | 1.071× | 0.417× | 0.417× |
| variation-lexer-6-17 | 229 ± 0 | 245.8 ± 0 | 95.07 ± 0 | 1.073× | 0.415× | 0.415× |
| coverage-expression-128 | 19.21 ± 0 | 7.527 ± 0 | 8.587 ± 0 | 0.392× | 0.447× | 0.392× |
| coverage-bst-64 | 24.17 ± 0 | 22.9 ± 0 | 7.35 ± 0.0293 | 0.947× | 0.304× | 0.304× |
| coverage-bst-32 | 32.38 ± 0 | 21.27 ± 0 | 5.975 ± 0.0238 | 0.657× | 0.185× | 0.185× |
| coverage-list-pipeline-128 | 13.21 ± 0 | 0.3128 ± 0.00499 | 1.426 ± 0 | 0.024× | 0.108× | 0.024× |
| coverage-list-pipeline-512 | 53.86 ± 0 | 1.228 ± 0 | 5.638 ± 0.0226 | 0.023× | 0.105× | 0.023× |
| coverage-closures-64 | 4.526 ± 0 | 0.05861 ± 0.000209 | 0.7749 ± 0 | 0.013× | 0.171× | 0.013× |
| coverage-closures-256 | 18.16 ± 0 | 0.2122 ± 0 | 2.935 ± 0.0235 | 0.012× | 0.162× | 0.012× |
| scalar-region-0 | 0 ± 0 | 0 ± 0 | 0 ± 0 | — | — | — |
