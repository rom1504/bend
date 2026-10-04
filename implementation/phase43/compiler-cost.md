# Phase43 compiler request costs

These are normal checked-library compilation requests, compared with the previous release and the pinned TypeScript compiler. They are separate from generated-program execution speed. Each source/role has three serial fresh-process samples on Node 24.18.0 and CPU3, with a 1 GiB heap and 2 GiB process-tree RSS limit.

`requestMs` includes checking and emission through the normal request, including Bend lazy API loading and normal Base cache handling. `importAndRequestMs` additionally includes host module import. `processWallMs` includes the complete worker process, including preflight and validation. `outputBytes` measures the emitted module; it is not heap use. Every table cell is **min / median / max**. Ratios use medians; a ratio above one means the candidate costs more.

Compiler request timing does not isolate emitter time, and these eight sources do not establish whole-compiler throughput. The tables retain both improvements and regressions. Tiny differences and three-sample ranges do not establish statistical significance.

Baseline API: `63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`. Candidate API: `222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb`.

## Core four

Raw report: `integration01/compiler-cost/report.json` in the [published raw evidence](../../selfhost/tools/performance/phase43/evidence/selected-release.json).

### requestMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| local-pair | 2047.630 / 2053.074 / 2064.373 | 2199.327 / 2232.180 / 2237.267 | 357.363 / 363.174 / 363.681 | 1.0872 |
| tree-bitonic | 2398.208 / 2447.340 / 2594.868 | 2926.021 / 2964.726 / 3020.366 | 329.656 / 341.454 / 367.969 | 1.2114 |
| coverage-numeric-recurrence-1024 | 1436.661 / 1465.895 / 1552.236 | 1411.073 / 1477.000 / 1502.752 | 298.770 / 300.030 / 313.885 | 1.0076 |
| coverage-list-pipeline-512 | 2398.994 / 2406.295 / 2442.624 | 2709.786 / 2743.306 / 2756.579 | 470.796 / 474.488 / 482.189 | 1.1401 |

### importAndRequestMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| local-pair | 2051.488 / 2056.912 / 2068.715 | 2203.432 / 2236.326 / 2241.457 | 568.127 / 586.166 / 590.525 | 1.0872 |
| tree-bitonic | 2402.333 / 2451.365 / 2598.672 | 2930.127 / 2968.766 / 3024.218 | 559.221 / 562.824 / 613.474 | 1.2111 |
| coverage-numeric-recurrence-1024 | 1440.876 / 1469.709 / 1556.329 | 1414.949 / 1481.021 / 1507.181 | 526.221 / 526.974 / 533.639 | 1.0077 |
| coverage-list-pipeline-512 | 2403.024 / 2410.623 / 2447.572 | 2713.749 / 2747.288 / 2760.950 | 685.753 / 695.558 / 704.847 | 1.1397 |

### processWallMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| local-pair | 6752.361 / 6842.721 / 7101.461 | 7051.620 / 7139.479 / 7182.179 | 5133.329 / 5230.746 / 5259.045 | 1.0434 |
| tree-bitonic | 7154.441 / 7300.887 / 7383.252 | 7728.049 / 7945.022 / 8104.639 | 5323.055 / 5340.591 / 5387.698 | 1.0882 |
| coverage-numeric-recurrence-1024 | 6218.764 / 6301.256 / 6509.689 | 6237.459 / 6321.264 / 6524.713 | 5069.584 / 5114.402 / 5215.759 | 1.0032 |
| coverage-list-pipeline-512 | 7108.719 / 7142.145 / 7275.980 | 7610.116 / 7617.125 / 7830.719 | 5234.593 / 5298.388 / 5435.857 | 1.0665 |

### outputBytes

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| local-pair | 126,998 / 126,998 / 126,998 | 129,511 / 129,511 / 129,511 | 12,457 / 12,457 / 12,457 | 1.0198 |
| tree-bitonic | 133,674 / 133,674 / 133,674 | 136,253 / 136,253 / 136,253 | 10,593 / 10,593 / 10,593 | 1.0193 |
| coverage-numeric-recurrence-1024 | 79,709 / 79,709 / 79,709 | 81,908 / 81,908 / 81,908 | 4,699 / 4,699 / 4,699 | 1.0276 |
| coverage-list-pipeline-512 | 140,303 / 140,303 / 140,303 | 143,875 / 143,875 / 143,875 | 40,351 / 40,351 / 40,351 | 1.0255 |

## Changed families four

Raw report: `integration01/compiler-cost-families/report.json` in the [published raw evidence](../../selfhost/tools/performance/phase43/evidence/selected-release.json).

### requestMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| lexer | 2158.681 / 2285.985 / 2297.663 | 3869.585 / 3920.465 / 4275.076 | 350.347 / 379.363 / 382.095 | 1.7150 |
| coverage-map-churn-128 | 2221.298 / 2302.125 / 2452.339 | 9405.094 / 9450.057 / 9451.344 | 493.532 / 509.488 / 510.218 | 4.1049 |
| coverage-closures-256 | 1469.839 / 1498.610 / 1513.835 | 1459.385 / 1508.834 / 1541.309 | 304.498 / 305.738 / 317.188 | 1.0068 |
| coverage-bst-64 | 2104.976 / 2206.018 / 2210.491 | 2856.946 / 2890.447 / 2957.310 | 335.949 / 338.403 / 376.824 | 1.3103 |

### importAndRequestMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| lexer | 2162.642 / 2290.457 / 2301.481 | 3873.738 / 3924.462 / 4279.373 | 594.729 / 597.847 / 630.573 | 1.7134 |
| coverage-map-churn-128 | 2225.287 / 2305.934 / 2456.599 | 9408.916 / 9454.035 / 9455.740 | 714.924 / 723.339 / 734.767 | 4.0999 |
| coverage-closures-256 | 1473.874 / 1502.533 / 1518.018 | 1463.217 / 1513.033 / 1545.463 | 520.469 / 524.136 / 538.015 | 1.0070 |
| coverage-bst-64 | 2109.128 / 2209.848 / 2214.456 | 2860.951 / 2894.660 / 2961.534 | 557.100 / 559.526 / 613.870 | 1.3099 |

### processWallMs

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| lexer | 7007.947 / 7216.698 / 7524.990 | 8703.182 / 8936.475 / 9507.640 | 5362.795 / 5474.313 / 5599.287 | 1.2383 |
| coverage-map-churn-128 | 6944.527 / 7300.645 / 7401.960 | 14217.563 / 14239.649 / 14329.028 | 5272.291 / 5396.048 / 5396.451 | 1.9505 |
| coverage-closures-256 | 6375.208 / 6441.031 / 6458.984 | 6191.141 / 6376.820 / 6381.682 | 5110.683 / 5272.826 / 5313.126 | 0.9900 |
| coverage-bst-64 | 6870.237 / 7218.833 / 7241.133 | 7788.044 / 7833.002 / 7963.883 | 5132.399 / 5334.558 / 5415.280 | 1.0851 |

### outputBytes

| Source | Previous release | Candidate | TypeScript | Candidate / previous median |
|---|---:|---:|---:|---:|
| lexer | 107,625 / 107,625 / 107,625 | 176,148 / 176,148 / 176,148 | 14,110 / 14,110 / 14,110 | 1.6367 |
| coverage-map-churn-128 | 122,580 / 122,580 / 122,580 | 271,639 / 271,639 / 271,639 | 46,419 / 46,419 / 46,419 | 2.2160 |
| coverage-closures-256 | 79,767 / 79,767 / 79,767 | 83,455 / 83,455 / 83,455 | 5,416 / 5,416 / 5,416 | 1.0462 |
| coverage-bst-64 | 98,703 / 98,703 / 98,703 | 105,972 / 105,972 / 105,972 | 9,080 / 9,080 / 9,080 | 1.0736 |
