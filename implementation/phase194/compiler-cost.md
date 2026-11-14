# Phase194 compiler-cost guardrail

Across four requests, **N1 takes 0.78% more time** (1.007781×), while **N2 takes 1.43% less time** (0.985722×) than Phase193 budget compilers.

Each stage uses **two balanced rounds**. All 32 measured complete outputs were revalidated against their own frozen role objects and empty-stderr oracles; medians and aggregates were recomputed. No measurement is excluded. Individual samples and spreads remain in the JSON.

| Request | N1 baseline s | N1 candidate s | N1 ratio | N2 baseline s | N2 candidate s | N2 ratio |
|---|---:|---:|---:|---:|---:|---:|
| coverage-numeric-recurrence-256 | 0.953529 | 0.955332 | 1.001890 | 1.172157 | 1.130418 | 0.964391 |
| coverage-expression-32 | 1.029671 | 1.066661 | 1.035924 | 1.260407 | 1.249728 | 0.991527 |
| tree-bitonic | 1.297819 | 1.290425 | 0.994303 | 1.582379 | 1.572857 | 0.993982 |
| test-map-set-ops | 4.250692 | 4.248714 | 0.999535 | 5.167611 | 5.132992 | 0.993301 |

Four development requests, two balanced rounds per stage. Fresh compiler process startup, checking, lowering/optimization and object emission; cached Base preparation, no linking or generated-program execution. Identical request input source does not mean identical compiler implementation source.

N1 compares changed compiler implementations produced by the same frozen QBE seed/toolchain. N2 measures the net changed compiler implementation and its generated x86 code. Screens are separate, not a paired causal decomposition. A small two-round guardrail establishes neither rigorous statistical confidence nor broad compiler/research throughput.

## Qualification acquisition observations

| Operation | Historical Phase193 s | Phase194 s |
|---|---:|---:|
| QBE seed acquires N1 | 170.598877 | 170.329157 |
| QBE-built N1 emits N2 | 278.214321 | 280.493491 |
| Direct-x86 N2 reproduces N3 | 341.379045 | 342.028427 |

Historical single pipeline observations on different compiler input source versions, including machine construction after preflight. Cached Base, not a controlled cold-build speed comparison. Object reproduction does not require whole-executable bytes to match.

## Size and identity

| Artifact | Phase193 bytes | Phase194 bytes | Growth |
|---|---:|---:|---:|
| Assembled compiler source | 1,819,134 | 1,835,600 | +16,466 (0.905%) |
| N2 executable | 24,804,208 | 24,963,272 | +159,064 (0.641%) |

Final source: `selfhost/build/phase194/selected-source02/compiler.bend`, SHA256 `4b29752fec8fbdb593a86b80f99ea18b7705dfc9fe56a364280bebb1f46c5e63`.

N2 executable SHA256: `5148debe7f21391ed784ba487840fd501693aafd161f231d004f29846151c982`.

Sources: [N1 screen](../../selfhost/build/phase194/compiler-cost-n1-02/report.json), [N2 screen](../../selfhost/build/phase194/compiler-cost-n2-01/report.json), [N1 acquisition](../../selfhost/build/phase194/native-image01/report.json), [N2 acquisition](../../selfhost/build/phase194/native-self01/report.json), [N3 reproduction](../../selfhost/build/phase194/native-reproduction01/report.json). Exact baseline/candidate source, binary, report and oracle pins are retained in [the JSON](compiler-cost.json).
