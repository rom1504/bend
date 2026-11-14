# Phase193 budget compiler cost

The four-request geometric ratio is **0.906848 for direct-x86 N2: 9.32% less request time**. Under the common QBE producer, N1 takes 2.94% more time (1.029446×).

Each screen has **two balanced rounds**, four fixed development requests and sixteen successful complete-output checks. All 32 outputs were revalidated against their own frozen role objects. Baseline and candidate emit different objects; within each role, N1/N2 expected objects agree.

Fresh process startup, checking, lowering, optimization and direct-object emission to stdout. Cached Base preparation is identical. Linking and generated-program execution are excluded. Same input source, not same compiler source: Phase192 source is 1,803,092 bytes; selected Phase193 budget source is 1,819,134 bytes.

| Request | N1 baseline s | N1 candidate s | N1 ratio | N2 baseline s | N2 candidate s | N2 ratio |
|---|---:|---:|---:|---:|---:|---:|
| coverage-numeric-recurrence-256 | 0.934247 | 0.913813 | 0.978128 | 1.277697 | 1.141350 | 0.893287 |
| coverage-expression-32 | 1.006387 | 1.076365 | 1.069534 | 1.389595 | 1.261587 | 0.907881 |
| tree-bitonic | 1.260549 | 1.284201 | 1.018763 | 1.755861 | 1.589352 | 0.905170 |
| test-map-set-ops | 3.984729 | 4.199037 | 1.053782 | 5.613055 | 5.171159 | 0.921274 |

In the N1 screen, both compiler executables are built by the same frozen QBE seed producer and QBE backend. This screens the cost of the changed compiler implementation under the common producer; it is not an isolated optimizer-pass attribution.

Net direct-x86 compiler request cost includes the changed compiler algorithms and the machine-code improvements generated into that compiler. Two rounds on four development requests do not establish significance, broad throughput, cold-build gains or research acceleration.

The N1 and N2 screens were collected separately; their ratios are not a paired causal decomposition. All individual samples and max/min spreads are retained in the adjacent JSON.

## Full build observations

| Operation | Historical Phase192 s | Phase193 budget s |
|---|---:|---:|
| QBE seed acquires N1 | 167.904249 | 170.598877 |
| QBE-built N1 emits N2 | 254.875094 | 278.214321 |
| Direct-x86 N2 reproduces N3 | 354.521095 | Not included at cutoff |

Historical single acquisition observations on different compiler input sources. Whole pipeline includes machine construction after preflight and uses cached Base. Not controlled paired cold-build comparisons. Current budget N3 is omitted because it was in progress at the requested cutoff; no wait or completed N3 claim.

The selected Phase193 budget source is 16,042 bytes (0.89%) larger. Full-build observations therefore provide cost context, not a same-input speed comparison.

Sources: [N1 screen](../../selfhost/build/phase193/budget-compiler-cost-n1-01/report.json), [N2 screen](../../selfhost/build/phase193/budget-compiler-cost-n2-01/report.json), [N1 acquisition](../../selfhost/build/phase193/budget-native-image01/report.json), [N2 acquisition](../../selfhost/build/phase193/budget-native-self01/report.json). Exact report, executable, source and oracle identities are retained in [the JSON summary](budget-compiler-cost.json).
