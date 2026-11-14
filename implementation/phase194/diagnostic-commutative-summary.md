# Phase194 diagnostic runtime

Diagnostic-only; excluded from native45. Times are milliseconds per complete bench invocation.
Timing complete: True.
Both declared parameter points: 96 exact-output observations passed.
4 rounds rotate all four roles through every position. Per-role calibration targets 200–300 ms; pilots are excluded.

| Program | C ms | QBE ms | Baseline ms | Candidate ms | Candidate/baseline | Range flag |
|---|---:|---:|---:|---:|---:|---|
| value-identity-rebind | 0.00182784 | 0.0024601 | 0.00218369 | 0.00199499 | 0.913586 | — |
| value-identity-helpers | 0.00183731 | 0.00249963 | 0.00202124 | 0.00201739 | 0.998094 | — |
| register-pressure-few | 0.00625 | 0.00883193 | 0.0104858 | 0.00811774 | 0.774167 | — |
| register-pressure-many | 0.00617497 | 0.008575 | 0.0077375 | 0.00773411 | 0.999562 | — |
| f32-region-closed | 0.00243531 | 0.00381748 | 0.00354288 | 0.00355344 | 1.002983 | — |
| f32-region-mixed | 0.0084375 | 0.010875 | 0.0116419 | 0.011665 | 1.001984 | — |
| predicate-flow-branch | 0.00132 | 0.00122498 | 0.00229527 | 0.00229078 | 0.998044 | — |
| predicate-flow-mask | 0.001325 | 0.00347497 | 0.00350084 | 0.0033875 | 0.967626 | candidate |
| product-ownership-unique | 0.0011022 | 0.0017112 | 0.00209999 | 0.00186749 | 0.889286 | — |
| product-ownership-shared | 0.024599 | 0.0440945 | 0.054163 | 0.0531058 | 0.980480 | — |
| memory-dependence-sequential | 0.00813424 | 0.029627 | 0.0377231 | 0.037594 | 0.996577 | candidate |
| memory-dependence-dependent | 0.00875754 | 0.0294806 | 0.0382322 | 0.039673 | 1.037685 | c,baseline,candidate |

Range flag means max/min > 1.10 across retained samples; it is not a confidence interval.
F32 mixed adds conversions; predicate mask evaluates both arms. Pairwise source differences are not equal-instruction-work claims.
Source sharing and pressure do not guarantee surviving allocations/spills. The 256-word memory pair is cache-resident.
Failed, incomplete or low-resolution timing sets do not qualify as passes; consult report.json and timing/report.json.
