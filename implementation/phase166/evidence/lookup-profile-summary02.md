# Native profiling comparison

Clean timings measure complete child processes. Sample and counter runs are diagnostic.
CPU attribution is approximate; event counts are not time percentages.

| Workload | Variant | Clean runs | Wall median (s) | CPU median (s) | Peak RSS median (KiB) |
|---|---|---:|---:|---:|---:|
| lookup10000 | qbe | 3 | 0.5369 | 0.5360 | 9560 |
| lookup10000 | c | 3 | 0.3566 | 0.3558 | 9540 |
| lookup10000 | bendc | 3 | 0.1544 | 0.1535 | 29476 |

## Clean comparisons

| Workload | Variant / reference | Wall ratio | CPU ratio |
|---|---|---:|---:|
| lookup10000 | qbe / bendc | 3.4783 | 3.4922 |
| lookup10000 | c / bendc | 2.3104 | 2.3179 |

## lookup10000 — qbe

Accepted samples: 2144; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 1.0024, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| p125_rt_take2 | 369 | 16.95% | 0.0909 |
| p113d_FID_$direct.p163r_scan | 298 | 13.62% | 0.0730 |
| p125_rt_ctor2 | 277 | 13.04% | 0.0699 |
| p125_rt_take1 | 219 | 10.33% | 0.0554 |
| p125_rt_ctor1 | 135 | 6.41% | 0.0344 |
| p113d_FID_$p118borrow.read.p88_string_eq_go | 122 | 5.57% | 0.0298 |
| rfc_wrap | 120 | 5.51% | 0.0296 |
| term_drop | 81 | 4.04% | 0.0217 |
| heap_alloc | 77 | 3.80% | 0.0204 |
| p111_rt_sink | 61 | 2.72% | 0.0146 |

## lookup10000 — c

Accepted samples: 1407; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 0.9980, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| NF_FID_p163r_scan | 615 | 43.91% | 0.1562 |
| term_drop | 222 | 15.55% | 0.0553 |
| rfc_wrap | 186 | 13.05% | 0.0464 |
| span_fade | 143 | 10.37% | 0.0369 |
| NF_FID_p88_string_eq | 112 | 7.83% | 0.0279 |
| NF_FID_lookup | 35 | 2.48% | 0.0088 |
| NF_FID_p137q_is_cache | 30 | 2.12% | 0.0075 |
| NF_FID_p137q_name_eq | 28 | 2.00% | 0.0071 |
| NF_FID_index_find | 8 | 0.64% | 0.0023 |
| NF_FID_index_lookup | 6 | 0.42% | 0.0015 |

## lookup10000 — bendc

Accepted samples: 585; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 1.0082, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| H_F_p163r__scan | 361 | 61.64% | 0.0946 |
| gc_refill | 57 | 9.97% | 0.0153 |
| L33 | 34 | 6.00% | 0.0092 |
| F_p88__string__eq__go | 20 | 3.46% | 0.0053 |
| F_lookup | 20 | 3.37% | 0.0052 |
| gc_mark | 20 | 3.37% | 0.0052 |
| apply | 13 | 1.97% | 0.0030 |
| gc_collect_locked | 13 | 1.97% | 0.0030 |
| L36 | 10 | 1.64% | 0.0025 |
| gc_rescan_items | 8 | 1.45% | 0.0022 |

## Limits

- No confidence intervals or causal speedup estimates are implied.
- Event counts overlap and are not CPU percentages or guaranteed machine memory traffic.
- Anonymous generated segment names are excluded from cross-version function deltas.
- Clean timings exclude diagnostic runtimes; explicit baseline mapping is required to scale their profiles.
- Complete run elapsed time includes harness analysis; summed child time is reported separately.

Evidence SHA256: `daa834b6a7d979aef3dd8f0d76900d5103f07562efb5f621c63fb95850c41a99`.
