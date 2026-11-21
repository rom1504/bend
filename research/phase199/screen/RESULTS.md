# Phase199 checked scan results

All three folds passed ordinary C output checks, extra argument checks, actual helper activation, and independent real-worker state/ownership controls. Both unrelated sentinel objects were byte-identical. Timing used5role positions×5rounds, two live-runtime layouts and one original-runtime cross-check;225samples, minimum 130ms.

| Case | Runtime / layout | SIMD / matched baseline | SIMD / mature C | SIMD / scalar delegate |
|---|---|---:|---:|---:|
| local-fold | original/program-helper-runtime | 0.2730 | 0.5531 | 0.4391 |
| local-fold | live/program-helper-runtime | 0.2743 | 0.5451 | 0.4398 |
| local-fold | live/program-runtime-helper | 0.2683 | 0.5455 | 0.4391 |
| variation-local-fold-128-0 | original/program-helper-runtime | 0.5297 | 1.3913 | 0.7164 |
| variation-local-fold-128-0 | live/program-helper-runtime | 0.5455 | 1.4338 | 0.7386 |
| variation-local-fold-128-0 | live/program-runtime-helper | 0.5466 | 1.4723 | 0.7335 |
| variation-local-fold-8192-123 | original/program-helper-runtime | 0.2605 | 0.5237 | 0.4284 |
| variation-local-fold-8192-123 | live/program-helper-runtime | 0.2614 | 0.5227 | 0.4299 |
| variation-local-fold-8192-123 | live/program-runtime-helper | 0.2599 | 0.5234 | 0.4299 |

The short128 case remains slower than mature C. The no-helper and matched-baseline results are separately retained in results.json; they are not silently substituted. These observations do not include the independently authored transfer, which has a separate native-integrated protocol. No full45 projection is claimed without the remaining42 exact-object condition.
