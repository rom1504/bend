# Native profiling comparison

Clean timings measure complete child processes. Sample and counter runs are diagnostic.
CPU attribution is approximate; event counts are not time percentages.

| Workload | Variant | Clean runs | Wall median (s) | CPU median (s) | Peak RSS median (KiB) |
|---|---|---:|---:|---:|---:|
| canonical-compiler | n2-imports | 0 | — | — | — |

## canonical-compiler — n2-imports

Accepted samples: 5484; rejected captures: 0; unknown leaf samples: 251. Adequate pooled sample count/quality: True. Absolute CPU estimate available: False.

Estimate limits: Independent clean CPU denominator unavailable.

| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |
|---|---:|---:|---:|
| term_drop | 582 | 10.61% | — |
| p113d_FID_$p118borrow.read.p88_string_eq_go | 467 | 8.52% | — |
| span_fade | 424 | 7.73% | — |
| [library_unresolved] | 244 | 4.45% | — |
| p125_rt_take2 | 243 | 4.43% | — |
| p111_rt_sink | 220 | 4.01% | — |
| work_loop.constprop.0 | 146 | 2.66% | — |
| p111_rt_special_ctor | 140 | 2.55% | — |
| p111_rt_take | 131 | 2.39% | — |
| p111_set_regs | 113 | 2.06% | — |
| p111_rt_jump | 102 | 1.86% | — |
| p113d_FID_$p118borrow.read.String.cmp | 101 | 1.84% | — |
| p111_rt_return | 97 | 1.77% | — |
| p111_rt_op | 91 | 1.66% | — |
| p118_rt_borrow_scalar_safe | 87 | 1.59% | — |
| p113d_FID_$p118borrow.read.index_hash | 86 | 1.57% | — |
| p125_rt_take2.cold | 84 | 1.53% | — |
| p125_rt_take4 | 80 | 1.46% | — |
| p113d_FID_$p118borrow.read.p98_tag_eq | 79 | 1.44% | — |
| p118_rt_extend1 | 79 | 1.44% | — |
| p111_rt_keep | 74 | 1.35% | — |
| heap_alloc | 62 | 1.13% | — |
| p125_rt_ctor2 | 57 | 1.04% | — |
| p118_destination_fill | 55 | 1.00% | — |
| io_cbuf | 53 | 0.97% | — |
| rfc_wrap | 51 | 0.93% | — |
| p111_rt_ctor | 41 | 0.75% | — |
| p113d_FID_$direct.index_find | 39 | 0.71% | — |
| p113d_FID_$p118.trmc.$direct.String.append | 34 | 0.62% | — |
| p113d_FID_$direct.p98_tag_eq | 25 | 0.46% | — |

## Limits

- No confidence intervals or causal speedup estimates are implied.
- Event counts overlap and are not CPU percentages or guaranteed machine memory traffic.
- Anonymous generated segment names are excluded from cross-version function deltas.
- Clean timings exclude diagnostic runtimes; explicit baseline mapping is required to scale their profiles.
- Complete run elapsed time includes harness analysis; summed child time is reported separately.

Evidence SHA256: `fdf5f0c1f20cd41b009ab0bfebcfd85df70caec32f8a24fbbb15b404e83830ef`.
