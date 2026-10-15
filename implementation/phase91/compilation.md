# Phase91 compilation latency

Current checked B1/genuine B2 take **1.408×/1.307× TypeScript compilation time for JS23**, and **1.454×/1.230× for C3**. All 234 timed complete-output checks pass. These are JavaScript-hosted compiler measurements; the native compiler host is a different metric.

B1 is selected equality-derived checked image `6bf8e093…`; B2 is actual self-emitted `284f6e9b…`, both from source `4ffae2a3…`. Upstream is `059266225b77c8ca256ac6b25ee5c21449bab151`. All roles use the same pinned Node24.18.0 binary, CPU3, 4 MiB stack and 1 GiB V8 heap. The plan binds checked provenance, frozen source/host inputs, frontend36 and driver8.

| Target | B1 compilation/TS | B2 compilation/TS | B1 imports+API+first/TS | B2 imports+API+first/TS | Request wins B1 / B2 |
| --- | ---: | ---: | ---: | ---: | ---: |
| JS23 | 1.408445× | 1.306596× | 0.969726× | 0.981387× | 5/23 · 5/23 |
| C3 | 1.453748× | 1.230042× | 1.167128× | 1.039948× | 0/3 · 0/3 |

Ratios are equal-source geometric means of three-sample median ratios. Each source gets three fresh processes per role, with role positions rotated. Ranges below are observed minimum–maximum, not confidence intervals. The two corpora and clocks are never pooled.

## Compilation request times

Times are milliseconds, **median [minimum–maximum]**. JS uses the original 23 library sources. C uses the original Phase46 Numeric/Array/Lexer batch sources, not the Phase90 closed six-source screen.

### JavaScript target

| Source | B1 ms | B2 ms | TypeScript ms | B1/TS | B2/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| mandelbrot | 647.6 [645.0–649.7] | 626.3 [624.2–630.1] | 409.9 [407.0–411.2] | 1.580× | 1.528× |
| editdist | 568.9 [567.4–569.4] | 552.3 [550.0–553.1] | 387.6 [384.2–389.0] | 1.468× | 1.425× |
| tree-bitonic | 480.3 [479.6–487.9] | 468.8 [465.0–526.7] | 366.9 [364.7–398.4] | 1.309× | 1.278× |
| lexer | 598.3 [598.1–610.7] | 629.9 [629.3–631.3] | 387.8 [385.7–391.5] | 1.543× | 1.624× |
| symreg | 580.6 [563.0–616.1] | 538.8 [538.5–540.5] | 383.8 [372.3–410.5] | 1.513× | 1.404× |
| test-morning-program | 873.9 [873.2–970.1] | 711.3 [706.2–778.1] | 505.7 [504.5–550.1] | 1.728× | 1.407× |
| test-evening-program | 1109.4 [1108.1–1202.8] | 833.8 [833.0–954.8] | 615.1 [614.5–616.6] | 1.804× | 1.355× |
| test-rle-roundtrip | 476.8 [476.2–477.1] | 459.4 [457.1–471.2] | 363.7 [363.6–364.1] | 1.311× | 1.263× |
| test-map-set-ops | 1306.4 [1304.6–1335.9] | 1019.3 [1007.7–1100.8] | 561.5 [558.1–573.4] | 2.326× | 1.815× |
| raytrace | 909.5 [908.8–910.2] | 867.8 [847.5–888.7] | 498.4 [498.0–501.0] | 1.825× | 1.741× |
| local-row | 587.5 [586.1–588.4] | 591.3 [573.6–591.7] | 388.9 [388.3–389.5] | 1.511× | 1.521× |
| local-fold | 301.8 [300.5–302.0] | 285.3 [283.1–286.5] | 341.2 [340.9–360.6] | 0.885× | 0.836× |
| scalar-region | 327.4 [326.8–329.1] | 326.4 [324.5–330.7] | 355.1 [354.4–357.7] | 0.922× | 0.919× |
| mandelbrot-grid | 684.9 [684.1–687.5] | 662.3 [661.3–663.2] | 419.1 [418.3–419.7] | 1.634× | 1.580× |
| raytrace-active | 941.8 [931.6–1018.4] | 907.2 [882.3–994.6] | 503.0 [498.7–550.3] | 1.872× | 1.804× |
| closures | 307.9 [306.6–335.7] | 322.6 [320.0–350.2] | 341.6 [338.9–368.0] | 0.901× | 0.944× |
| list-pipeline | 821.1 [818.4–888.7] | 686.8 [668.1–765.8] | 487.0 [486.0–501.5] | 1.686× | 1.410× |
| bst | 465.4 [465.4–466.7] | 430.8 [426.3–440.4] | 366.0 [365.7–367.3] | 1.272× | 1.177× |
| unicode-text | 641.0 [639.1–648.0] | 611.4 [597.1–678.3] | 385.2 [385.2–385.8] | 1.664× | 1.587× |
| expression | 306.8 [303.7–335.5] | 336.4 [334.7–370.1] | 340.1 [334.8–369.2] | 0.902× | 0.989× |
| map-churn | 798.1 [795.8–800.4] | 674.3 [661.2–676.3] | 497.9 [489.1–498.0] | 1.603× | 1.354× |
| numeric-recurrence | 247.5 [246.1–248.8] | 218.0 [217.0–218.2] | 333.1 [331.7–333.9] | 0.743× | 0.654× |
| record-aggregation | 813.7 [812.8–814.8] | 660.6 [658.3–665.4] | 494.2 [493.7–516.3] | 1.647× | 1.337× |

### C target

| Source | B1 ms | B2 ms | TypeScript ms | B1/TS | B2/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| numeric | 1074.8 [1069.2–1171.1] | 952.1 [933.6–1024.9] | 762.0 [758.2–820.3] | 1.411× | 1.250× |
| array | 1121.3 [1117.7–1136.1] | 963.6 [925.5–1017.7] | 842.6 [794.0–849.0] | 1.331× | 1.144× |
| lexer | 1621.0 [1607.9–1622.2] | 1289.8 [1278.1–1393.0] | 990.5 [980.5–990.5] | 1.637× | 1.302× |

## Imports, API loading and first request

This sums separately timed compiler/host imports, ordinary API loading and the first request. It excludes process launch, benchmark preflight, output validation and serialization. It is not whole-process startup. The JSON retains each component and every round.

| Target / source | B1 ms | B2 ms | TypeScript ms | B1/TS | B2/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| JS / mandelbrot | 722.4 [718.8–723.3] | 749.3 [745.8–753.4] | 677.7 [675.2–681.1] | 1.066× | 1.106× |
| JS / editdist | 642.4 [640.8–642.9] | 674.7 [671.8–675.2] | 655.4 [653.8–657.6] | 0.980× | 1.030× |
| JS / tree-bitonic | 554.0 [553.2–562.2] | 600.0 [587.8–653.7] | 637.7 [633.8–689.4] | 0.869× | 0.941× |
| JS / lexer | 673.1 [672.7–686.9] | 752.0 [751.1–754.3] | 656.8 [653.5–659.5] | 1.025× | 1.145× |
| JS / symreg | 655.1 [636.9–697.9] | 660.9 [659.7–663.4] | 658.0 [641.3–702.4] | 0.996× | 1.005× |
| JS / test-morning-program | 948.2 [946.9–1052.3] | 832.7 [828.3–912.3] | 774.3 [772.4–840.5] | 1.225× | 1.075× |
| JS / test-evening-program | 1183.5 [1182.3–1284.4] | 956.6 [955.3–1089.3] | 883.9 [883.0–884.4] | 1.339× | 1.082× |
| JS / test-rle-roundtrip | 551.5 [550.9–554.7] | 581.4 [579.7–593.4] | 631.2 [631.1–631.4] | 0.874× | 0.921× |
| JS / test-map-set-ops | 1379.6 [1378.1–1409.5] | 1141.8 [1133.1–1230.7] | 828.7 [826.0–844.9] | 1.665× | 1.378× |
| JS / raytrace | 983.6 [983.3–984.0] | 989.8 [969.5–1011.4] | 767.7 [765.8–769.9] | 1.281× | 1.289× |
| JS / local-row | 661.2 [660.7–662.6] | 714.4 [694.6–715.3] | 657.0 [656.5–659.1] | 1.006× | 1.087× |
| JS / local-fold | 375.9 [374.0–376.1] | 407.0 [404.8–408.9] | 611.8 [608.8–630.1] | 0.614× | 0.665× |
| JS / scalar-region | 400.7 [400.6–403.5] | 449.3 [446.6–454.6] | 623.3 [621.5–626.9] | 0.643× | 0.721× |
| JS / mandelbrot-grid | 759.1 [758.1–768.6] | 784.6 [784.3–787.8] | 690.8 [686.6–699.2] | 1.099× | 1.136× |
| JS / raytrace-active | 1016.4 [1005.3–1100.7] | 1030.5 [1004.3–1128.7] | 769.0 [765.6–838.9] | 1.322× | 1.340× |
| JS / closures | 381.7 [379.9–416.0] | 445.9 [442.6–485.4] | 609.2 [608.4–659.6] | 0.626× | 0.732× |
| JS / list-pipeline | 895.2 [891.9–970.3] | 815.5 [797.4–900.4] | 758.2 [754.5–771.2] | 1.181× | 1.076× |
| JS / bst | 540.7 [539.1–540.7] | 554.7 [548.0–566.7] | 638.2 [633.4–641.0] | 0.847× | 0.869× |
| JS / unicode-text | 714.7 [712.9–721.6] | 733.6 [720.3–817.2] | 653.9 [653.6–654.0] | 1.093× | 1.122× |
| JS / expression | 380.6 [378.0–416.9] | 458.6 [457.5–505.6] | 609.3 [600.9–660.3] | 0.625× | 0.753× |
| JS / map-churn | 871.8 [869.4–873.4] | 796.6 [783.8–798.9] | 766.4 [766.3–768.0] | 1.138× | 1.039× |
| JS / numeric-recurrence | 321.2 [319.5–323.5] | 339.7 [338.2–340.3] | 601.6 [599.5–601.7] | 0.534× | 0.565× |
| JS / record-aggregation | 887.5 [887.1–887.9] | 786.1 [780.6–786.9] | 764.0 [761.4–793.8] | 1.162× | 1.029× |
| C / numeric | 1149.6 [1142.9–1255.1] | 1074.0 [1055.9–1158.3] | 1029.5 [1028.0–1108.7] | 1.117× | 1.043× |
| C / array | 1195.1 [1191.3–1210.6] | 1085.4 [1048.3–1152.4] | 1131.8 [1064.0–1136.4] | 1.056× | 0.959× |
| C / lexer | 1694.5 [1681.9–1698.2] | 1412.7 [1400.4–1528.6] | 1256.7 [1246.1–1258.6] | 1.348× | 1.124× |

## What remains slow

The JS request tail is concentrated in Map/set operations and raytracing. B2 Map takes 1019.3 ms versus 561.5 ms for TS (1.815×); active raytrace takes 907.2 ms versus 503.0 ms (1.804×). Numeric recurrence is faster at 218.0 ms versus 333.1 ms (0.654×). Both compiler generations have 5/23 request medians below TS. This distribution does not establish a single universal performance gap.

## Preserved boundaries and historical context

JS uses ordinary `D.inspect(file,{mode:"library",backend:"direct"})` and upstream `book_load`→`book_valid`→`js_lib(book,true)`. C uses `D.inspect(file,{mode:"native",withReport:true})` and upstream `compile_book` after load/check. Base preparation is separate; cached Base decoding stays inside ordinary Bend requests. TS loads/checks Base inside its request. Separate JS/C host projects preserve JS optional annotation products and the C mandatory-cache-only policy.

Historical JS workers included a few success assertions inside the request clock; this compact successor validates afterward. Output hashing, full-byte comparisons and writes stay outside clean clocks. This explicit instrumentation difference is not a compiler optimization.

| Historical campaign | B1 compilation/TS then | B2 compilation/TS then | Current B1 | Current B2 |
| --- | ---: | ---: | ---: | ---: |
| Phase66 final07 JS23 | 1.402065× | 1.321100× | 1.408445× | 1.306596× |
| Phase82 paired04 C3 | 1.672986× | 1.328356× | 1.453748× | 1.230042× |

The workloads, host binary and ordinary compiler boundaries are comparable. Historical images were not timed alongside the current campaign, so ratio differences are not paired causal improvements. This refresh does not isolate any Phase90 formatting or runtime change. It confirms that compilation-only parity remains open while the JS imports/API/first-request aggregate is near parity.

## Correctness evidence and execution cost

Setup retained 78 complete outputs: 69 JS and 9 C. Every JS output equals its historical independently executed oracle; TypeScript C equals retained historical full C. Current B1/B2 outputs are byte-identical for every source. All 234 timed calls match complete setup bytes. Current Bend C intentionally differs from historical C; its program-behavior continuity is a separate Phase91 gate, not inferred from timing.

All six setup jobs and 234 timing jobs finish successfully. Summed guarded process time is 341.74 s; maximum sampled process-tree RSS is 450.32 MiB. JS clean wall is 254.71 s; C clean wall is 50.93s. These process costs are not agent time or token/quota accounting. No compiler targets ran during this offline analysis.

[Full samples, ranges, identities and receipt hashes](compilation.json) · [Frozen plan](../../selfhost/build/phase91/compilation01/plan.json) · [Method and replay commands](../../selfhost/tools/performance/phase91/compilation/README.md).
