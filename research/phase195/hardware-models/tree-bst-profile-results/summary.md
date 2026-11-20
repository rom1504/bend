# Native profiling comparison

Clean timings measure complete child processes. Sample and counter runs are diagnostic.
CPU attribution is approximate; event counts are not time percentages.

| Workload | Variant | Clean runs | Wall median (s) | CPU median (s) | Peak RSS median (KiB) |
|---|---|---:|---:|---:|---:|
| 12-tree-bitonic-candidate | candidate | 1 | 3.0086 | 3.0071 | 11684 |
| 12-tree-bitonic-c | c | 1 | 3.0033 | 3.0024 | 11820 |
| 12-tree-bitonic-qbe | qbe | 1 | 3.0044 | 3.0035 | 11844 |
| 15-coverage-bst-64-candidate | candidate | 1 | 2.9723 | 2.9712 | 11844 |
| 15-coverage-bst-64-c | c | 1 | 2.9863 | 2.9855 | 11876 |
| 15-coverage-bst-64-qbe | qbe | 1 | 3.0065 | 3.0056 | 11900 |

## 12-tree-bitonic-candidate — candidate

Accepted samples: 597; rejected captures: 0; unknown leaf samples: 10. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 0.9868, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| p114r_FID_$direct.warp | 128 | 21.28% | 0.6400 |
| p125_rt_ctor2 | 92 | 15.74% | 0.4732 |
| p125_rt_take2 | 90 | 15.21% | 0.4575 |
| p113d_FID_$direct.warp_leaf | 46 | 7.83% | 0.2353 |
| p111_FID_$direct.flow | 34 | 5.44% | 0.1637 |
| p113d_FID_$direct.warp_zip | 23 | 4.38% | 0.1317 |
| work_loop.constprop.0 | 26 | 4.36% | 0.1311 |
| p111_FID_$direct.warp | 26 | 4.28% | 0.1286 |
| p111_FID_$p111.k.9473 | 22 | 3.82% | 0.1149 |
| p111_FID_$direct.warp_node | 18 | 2.77% | 0.0834 |

## 12-tree-bitonic-c — c

Accepted samples: 599; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 0.9909, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| WL_FID_$direct.warp_zip | 165 | 27.14% | 0.8149 |
| WL_FID_$direct.warp | 89 | 15.63% | 0.4692 |
| WL_FID_native_k_22984 | 67 | 11.90% | 0.3573 |
| WL_FID_$direct.warp_leaf | 64 | 10.49% | 0.3148 |
| WL_FID_native_k_22985 | 58 | 9.25% | 0.2779 |
| WL_FID_$direct.flow | 37 | 5.83% | 0.1751 |
| WL_FID_native_k_20831 | 26 | 4.60% | 0.1382 |
| WL_FID_native_k_20832 | 25 | 4.21% | 0.1265 |
| WL_FID_$direct.stat_join | 11 | 1.99% | 0.0597 |
| WL_FID_native_k_20839 | 11 | 1.82% | 0.0547 |

## 12-tree-bitonic-qbe — qbe

Accepted samples: 602; rejected captures: 0; unknown leaf samples: 18. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 0.9971, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| p125_rt_take2 | 106 | 17.89% | 0.5372 |
| p114r_FID_$direct.warp | 92 | 15.09% | 0.4532 |
| p113d_FID_$direct.warp_zip | 66 | 10.35% | 0.3109 |
| p113d_FID_$direct.warp_leaf | 58 | 9.86% | 0.2963 |
| p111_FID_$direct.flow | 46 | 8.01% | 0.2404 |
| work_loop.constprop.0 | 45 | 7.62% | 0.2289 |
| p111_FID_$direct.warp_node | 29 | 4.72% | 0.1419 |
| p111_FID_$direct.warp | 22 | 3.53% | 0.1061 |
| [library_unresolved] | 18 | 3.08% | 0.0926 |
| p111_FID_$p111.k.9473 | 17 | 2.61% | 0.0785 |

## 15-coverage-bst-64-candidate — candidate

Accepted samples: 600; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 1.0039, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| p113d_FID_$product.bst.down | 187 | 31.05% | 0.9226 |
| p125_rt_ctor3 | 117 | 19.95% | 0.5927 |
| p125_rt_take3 | 97 | 16.25% | 0.4828 |
| p113d_FID_$direct.bst.up | 74 | 12.06% | 0.3583 |
| p125_rt_ctor2 | 41 | 6.78% | 0.2014 |
| p125_rt_take2 | 37 | 5.99% | 0.1779 |
| p111_rt_op | 14 | 2.30% | 0.0685 |
| p114r_FID_$direct.inorder | 13 | 2.25% | 0.0670 |
| p113d_FID_$product.insert.fin | 9 | 1.46% | 0.0435 |
| p113d_FID_$direct.p37.bst.build | 7 | 1.19% | 0.0355 |

## 15-coverage-bst-64-c — c

Accepted samples: 602; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 1.0046, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| NF_FID_p37.bst.insert | 549 | 91.56% | 2.7335 |
| WL_FID_$direct.inorder | 28 | 4.25% | 0.1270 |
| NF_FID_p37.bst.build | 18 | 3.08% | 0.0920 |
| WL_FID_native_k_13553 | 7 | 1.11% | 0.0330 |

## 15-coverage-bst-64-qbe — qbe

Accepted samples: 601; rejected captures: 0; unknown leaf samples: 0. Adequate pooled sample count/quality: True. Absolute CPU estimate available: True.

Diagnostic wall-time ratios against explicit clean baseline: sampling 0.9924, context-only —, counters —.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| p113d_FID_$product.bst.down | 290 | 48.38% | 1.4541 |
| p125_rt_take3 | 123 | 20.65% | 0.6205 |
| p113d_FID_$direct.bst.up | 84 | 13.72% | 0.4125 |
| p125_rt_take2 | 54 | 9.02% | 0.2711 |
| p113d_FID_$product.insert.fin | 15 | 2.60% | 0.0783 |
| p114r_FID_$direct.inorder | 11 | 1.65% | 0.0495 |
| p113d_FID_$direct.p37.bst.build | 10 | 1.60% | 0.0480 |
| p113d_FID_$direct.p37.bst.insert | 9 | 1.55% | 0.0464 |
| p111_FID_$p111.k.8402 | 3 | 0.57% | 0.0172 |
| p111_FID_$direct.inorder | 1 | 0.13% | 0.0040 |

## Limits

- No confidence intervals or causal speedup estimates are implied.
- Event counts overlap and are not CPU percentages or guaranteed machine memory traffic.
- Anonymous generated segment names are excluded from cross-version function deltas.
- Clean timings exclude diagnostic runtimes; explicit baseline mapping is required to scale their profiles.
- Complete run elapsed time includes harness analysis; summed child time is reported separately.

Evidence SHA256: `2b4d2b070fd423707d83facba71f44383ed51384cc9c392ae5e1287c8b73f329`.
