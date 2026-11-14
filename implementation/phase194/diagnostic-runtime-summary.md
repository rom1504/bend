# Phase194 diagnostic runtime

Diagnostic-only; excluded from native45. Times are milliseconds per complete bench invocation.
Timing complete: True.
Both declared parameter points: 96 exact-output observations passed.
4 rounds rotate all four roles through every position. Per-role calibration targets 200–300 ms; pilots are excluded.

| Program | C ms | QBE ms | Baseline ms | Candidate ms | Candidate/baseline | Range flag |
|---|---:|---:|---:|---:|---:|---|
| value-identity-rebind | 0.00183748 | 0.00250457 | 0.00224348 | 0.00224785 | 1.001946 | — |
| value-identity-helpers | 0.00182999 | 0.00247493 | 0.00191615 | 0.00192749 | 1.005918 | — |
| register-pressure-few | 0.00617513 | 0.00831232 | 0.00994985 | 0.010275 | 1.032679 | — |
| register-pressure-many | 0.00617497 | 0.00858259 | 0.007875 | 0.00771833 | 0.980105 | — |
| f32-region-closed | 0.00244974 | 0.00384551 | 0.00464995 | 0.00355708 | 0.764971 | — |
| f32-region-mixed | 0.008425 | 0.010917 | 0.0122985 | 0.011665 | 0.948488 | — |
| predicate-flow-branch | 0.0013225 | 0.00122503 | 0.00229608 | 0.0022961 | 1.000009 | — |
| predicate-flow-mask | 0.00132036 | 0.00347179 | 0.00444998 | 0.00348582 | 0.783334 | — |
| product-ownership-unique | 0.00109875 | 0.001751 | 0.00209158 | 0.00209579 | 1.002016 | — |
| product-ownership-shared | 0.0266 | 0.0482688 | 0.058128 | 0.0612447 | 1.053619 | c,qbe,baseline,candidate |
| memory-dependence-sequential | 0.0081875 | 0.0298721 | 0.0379036 | 0.039148 | 1.032832 | — |
| memory-dependence-dependent | 0.00825 | 0.0291514 | 0.0389552 | 0.0375437 | 0.963767 | — |

Range flag means max/min > 1.10 across retained samples; it is not a confidence interval.
F32 mixed adds conversions; predicate mask evaluates both arms. Pairwise source differences are not equal-instruction-work claims.
Source sharing and pressure do not guarantee surviving allocations/spills. The 256-word memory pair is cache-resident.
Failed, incomplete or low-resolution timing sets do not qualify as passes; consult report.json and timing/report.json.
