# Direct backend full45 comparison

All45 points,23 distinct sources and669 fresh samples passed. Direct/TS and direct/Phase51 below1 favor direct; Phase51/direct above1 favors direct.

| Weighting | Phase51 / TS | Direct / TS | Phase51 / direct |
|---|---:|---:|---:|
| Equal point | 2.630605× | 1.123799× | 2.340815× |
| Equal source | 3.582113× | 1.129112× | 3.172504× |

| Point | TS µs | Phase51 µs | Direct µs | Direct / TS | Direct / Phase51 | Flags |
|---|---:|---:|---:|---:|---:|---|
| local-pair | 1235.968131 | 1494.910379 | 1622.926796 | 1.313081× | 1.085635× | none |
| local-fold | 38.948932 | 60.518259 | 40.754862 | 1.046367× | 0.673431× | none |
| scalar-region-0 | 0.066963 | 4.236372 | 0.068113 | 1.017170× | 0.016078× | none |
| scalar-region-8192 | 99.281906 | 115.373490 | 111.199525 | 1.120038× | 0.963822× | none |
| complete-generic-row32 | 6.757217 | 27.806354 | 6.809087 | 1.007676× | 0.244875× | none |
| mandelbrot | 45.528044 | 126.017682 | 78.090573 | 1.715219× | 0.619679× | none |
| editdist | 4929.599803 | 5657.003481 | 6481.304065 | 1.314773× | 1.145713× | none |
| tree-bitonic | 281.317441 | 349.917015 | 279.688637 | 0.994210× | 0.799300× | none |
| lexer | 1669.151800 | 2467.676107 | 1747.814145 | 1.047127× | 0.708283× | none |
| symreg | 1112.667787 | 1498.343043 | 1323.959820 | 1.189897× | 0.883616× | none |
| test-morning-program | 3.343182 | 160.201127 | 2.899195 | 0.867196× | 0.018097× | none |
| test-evening-program | 2.598595 | 123.230041 | 2.606747 | 1.003137× | 0.021154× | none |
| test-rle-roundtrip | 0.549391 | 31.550820 | 0.579788 | 1.055329× | 0.018376× | none |
| test-map-set-ops | 20.482246 | 1012.073542 | 18.684585 | 0.912233× | 0.018462× | none |
| raytrace | 34205.299556 | 60147.463333 | 57404.716500 | 1.678240× | 0.954400× | none |
| variation-editdist-0-17 | 1234.101243 | 1500.803220 | 1610.370706 | 1.304894× | 1.073006× | none |
| variation-editdist-3-123 | 9845.755903 | 11278.146481 | 12968.399250 | 1.317156× | 1.149870× | none |
| variation-lexer-6-17 | 409.393570 | 625.495157 | 429.613782 | 1.049391× | 0.686838× | none |
| variation-lexer-10-123 | 6691.058261 | 9838.191355 | 7023.614233 | 1.049702× | 0.713913× | none |
| variation-tree-bitonic-6-17 | 37.003869 | 70.921608 | 37.347271 | 1.009280× | 0.526599× | none |
| variation-tree-bitonic-9-123 | 694.814722 | 798.740425 | 672.125625 | 0.967345× | 0.841482× | none |
| variation-symreg-4-17 | 550.758307 | 775.268987 | 637.861576 | 1.158152× | 0.822762× | none |
| variation-symreg-7-123 | 1867.828255 | 2492.532852 | 2223.358437 | 1.190344× | 0.892008× | none |
| variation-local-fold-128-0 | 1.428330 | 14.063752 | 1.461707 | 1.023368× | 0.103934× | none |
| variation-local-fold-8192-123 | 115.681490 | 109.434700 | 134.007261 | 1.158416× | 1.224541× | typescript |
| variation-mandelbrot-grid-4-7 | 14.738248 | 42.932998 | 29.393433 | 1.994364× | 0.684635× | none |
| variation-mandelbrot-grid-5-31 | 233.009277 | 420.241226 | 412.520975 | 1.770406× | 0.981629× | none |
| variation-ray-active-64-2440 | 300.409332 | 539.626136 | 467.711337 | 1.556913× | 0.866732× | none |
| variation-ray-active-256-2240 | 1246.578481 | 2183.922669 | 2012.779945 | 1.614644× | 0.921635× | none |
| coverage-closures-64 | 5.612168 | 9.700969 | 5.795915 | 1.032741× | 0.597457× | none |
| coverage-closures-256 | 21.098698 | 9.877670 | 21.899930 | 1.037975× | 2.217115× | candidate |
| coverage-list-pipeline-128 | 6.424482 | 12.692921 | 6.439527 | 1.002342× | 0.507332× | none |
| coverage-list-pipeline-512 | 27.563661 | 15.788300 | 28.122012 | 1.020257× | 1.781193× | none |
| coverage-unicode-text-16 | 21.348539 | 60.285166 | 19.813430 | 0.928093× | 0.328662× | none |
| coverage-unicode-text-64 | 84.640335 | 141.955409 | 84.849122 | 1.002467× | 0.597717× | none |
| coverage-map-churn-32 | 142.551221 | 251.628235 | 136.494782 | 0.957514× | 0.542446× | none |
| coverage-map-churn-128 | 760.512550 | 1056.774590 | 744.416671 | 0.978835× | 0.704423× | none |
| coverage-numeric-recurrence-256 | 2.037349 | 12.943284 | 1.981983 | 0.972824× | 0.153128× | none |
| coverage-numeric-recurrence-1024 | 7.620957 | 19.298863 | 7.629399 | 1.001108× | 0.395329× | none |
| coverage-bst-32 | 22.219413 | 60.214934 | 23.311794 | 1.049163× | 0.387143× | none |
| coverage-bst-64 | 51.408716 | 102.491541 | 55.886902 | 1.087109× | 0.545283× | none |
| coverage-expression-32 | 2.097727 | 19.173003 | 2.212979 | 1.054941× | 0.115422× | none |
| coverage-expression-128 | 8.795106 | 40.442731 | 9.123472 | 1.037335× | 0.225590× | none |
| coverage-record-aggregation-64 | 298.277506 | 441.754129 | 284.601262 | 0.954149× | 0.644253× | none |
| coverage-record-aggregation-256 | 1246.429558 | 1710.507443 | 1292.916067 | 1.037296× | 0.755867× | baseline |

Descriptive only: absolute half drift >20% or maximum/minimum fresh-round time >1.2. No rows excluded. Lack of flags is not proof of JIT convergence or statistical significance.

Regressions remain included. This report does not qualify an installed release or the extra legacy descriptor ABI.
