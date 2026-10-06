# Direct backend full45 comparison

All45 points,23 distinct sources and669 fresh samples passed. Direct/TS and direct/Prior direct06 below1 favor direct; Prior direct06/direct above1 favors direct.

| Weighting | Prior direct06 / TS | Direct / TS | Prior direct06 / direct |
|---|---:|---:|---:|
| Equal point | 1.129266× | 1.069599× | 1.055785× |
| Equal source | 1.135543× | 1.078076× | 1.053305× |

| Point | TS µs | Prior direct06 µs | Direct µs | Direct / TS | Direct / Prior direct06 | Flags |
|---|---:|---:|---:|---:|---:|---|
| local-pair | 1236.932383 | 1616.192627 | 1385.884074 | 1.120420× | 0.857499× | none |
| local-fold | 39.328413 | 40.701675 | 41.581130 | 1.057280× | 1.021607× | none |
| scalar-region-0 | 0.068351 | 0.068050 | 0.067391 | 0.985944× | 0.990313× | none |
| scalar-region-8192 | 99.579907 | 111.156435 | 99.252311 | 0.996710× | 0.892907× | none |
| complete-generic-row32 | 6.767309 | 6.767816 | 6.921580 | 1.022796× | 1.022720× | none |
| mandelbrot | 45.390081 | 78.252075 | 68.484814 | 1.508806× | 0.875182× | none |
| editdist | 4955.446033 | 6490.945723 | 5606.154759 | 1.131312× | 0.863688× | none |
| tree-bitonic | 274.967119 | 265.740645 | 266.665924 | 0.969810× | 1.003482× | none |
| lexer | 1676.136799 | 1746.630289 | 1712.871364 | 1.021916× | 0.980672× | none |
| symreg | 1103.984505 | 1324.354693 | 1101.826630 | 0.998045× | 0.831972× | none |
| test-morning-program | 3.242823 | 2.895986 | 2.816205 | 0.868442× | 0.972451× | none |
| test-evening-program | 2.617278 | 2.609691 | 2.698156 | 1.030902× | 1.033899× | none |
| test-rle-roundtrip | 0.565496 | 0.583444 | 0.568206 | 1.004792× | 0.973882× | none |
| test-map-set-ops | 20.370895 | 19.078325 | 19.318218 | 0.948324× | 1.012574× | none |
| raytrace | 34329.258556 | 57473.842167 | 48936.917000 | 1.425516× | 0.851464× | none |
| variation-editdist-0-17 | 1241.485485 | 1617.206011 | 1390.742770 | 1.120225× | 0.859966× | none |
| variation-editdist-3-123 | 9903.981065 | 13044.141792 | 11108.954593 | 1.121666× | 0.851643× | none |
| variation-lexer-6-17 | 403.484961 | 430.701488 | 415.149965 | 1.028911× | 0.963893× | none |
| variation-lexer-10-123 | 6732.308348 | 6985.269442 | 6759.391622 | 1.004023× | 0.967664× | none |
| variation-tree-bitonic-6-17 | 36.899098 | 36.916859 | 36.948577 | 1.001341× | 1.000859× | none |
| variation-tree-bitonic-9-123 | 698.071653 | 691.182071 | 690.404521 | 0.989017× | 0.998875× | none |
| variation-symreg-4-17 | 553.418472 | 641.444271 | 558.545709 | 1.009265× | 0.870763× | none |
| variation-symreg-7-123 | 1894.518211 | 2243.628867 | 1874.956700 | 0.989675× | 0.835680× | none |
| variation-local-fold-128-0 | 1.437573 | 1.455298 | 1.466231 | 1.019935× | 1.007513× | none |
| variation-local-fold-8192-123 | 116.738725 | 134.889116 | 127.946594 | 1.096008× | 0.948532× | candidate |
| variation-mandelbrot-grid-4-7 | 15.287580 | 33.203881 | 29.228136 | 1.911888× | 0.880263× | none |
| variation-mandelbrot-grid-5-31 | 233.140652 | 413.833548 | 367.146861 | 1.574787× | 0.887185× | none |
| variation-ray-active-64-2440 | 302.926468 | 468.472179 | 413.235619 | 1.364145× | 0.882092× | none |
| variation-ray-active-256-2240 | 1244.366851 | 2015.300102 | 1696.503173 | 1.363346× | 0.841812× | none |
| coverage-closures-64 | 5.586829 | 5.959625 | 5.558767 | 0.994977× | 0.932738× | none |
| coverage-closures-256 | 20.960008 | 22.802498 | 21.280237 | 1.015278× | 0.933241× | typescript |
| coverage-list-pipeline-128 | 6.293566 | 6.649250 | 6.546553 | 1.040198× | 0.984555× | none |
| coverage-list-pipeline-512 | 27.378727 | 28.346509 | 27.894090 | 1.018823× | 0.984040× | typescript |
| coverage-unicode-text-16 | 21.292453 | 19.968559 | 20.208417 | 0.949088× | 1.012012× | none |
| coverage-unicode-text-64 | 84.715696 | 84.743553 | 84.084370 | 0.992548× | 0.992221× | none |
| coverage-map-churn-32 | 141.828313 | 136.750137 | 136.069105 | 0.959393× | 0.995020× | none |
| coverage-map-churn-128 | 761.839755 | 745.259657 | 747.015466 | 0.980541× | 1.002356× | none |
| coverage-numeric-recurrence-256 | 1.991083 | 1.985600 | 2.045073 | 1.027116× | 1.029952× | none |
| coverage-numeric-recurrence-1024 | 7.862171 | 7.864495 | 7.622943 | 0.969572× | 0.969286× | none |
| coverage-bst-32 | 22.102353 | 23.303929 | 23.536898 | 1.064905× | 1.009997× | none |
| coverage-bst-64 | 53.932278 | 55.562908 | 56.215519 | 1.042335× | 1.011745× | none |
| coverage-expression-32 | 2.061576 | 2.189325 | 2.094487 | 1.015964× | 0.956682× | none |
| coverage-expression-128 | 8.861021 | 9.586084 | 9.224742 | 1.041047× | 0.962306× | candidate |
| coverage-record-aggregation-64 | 299.807775 | 284.689988 | 278.902297 | 0.930270× | 0.979670× | typescript |
| coverage-record-aggregation-256 | 1217.041335 | 1263.439502 | 1239.682909 | 1.018604× | 0.981197× | candidate |

Descriptive only: absolute half drift >20% or maximum/minimum fresh-round time >1.2. No rows excluded. Lack of flags is not proof of JIT convergence or statistical significance.

Regressions remain included. This report does not qualify an installed release or the extra legacy descriptor ABI.
