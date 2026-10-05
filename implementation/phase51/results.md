# Phase51: complete generated-program timing results

The validated comparison covers **45 points, 23 distinct sources, 23 families, and 669 samples**. All result checks passed. These timings do not independently establish compiler conformance or release qualification.

Baseline is the comparison baseline recorded in the summary; candidate is the selected experimental compiler recorded there. Ratios above 1 in baseline/candidate mean faster candidate execution. Positive time changes mean regressions.

| Weighting | Baseline / TypeScript | Candidate / TypeScript | Baseline / candidate |
| --- | ---: | ---: | ---: |
| Equal points | 3.007942× | 2.927825× | 1.027364× |
| Equal sources | 4.077637× | 3.929390× | 1.037728× |
| Equal families | 4.364108× | 4.206544× | 1.037457× |

Point medians: 34 faster, 11 slower, 0 exactly tied. This sign count has no significance threshold. Geometric means give each listed unit equal weight, not each application or elapsed second.

## Protocol and drift

Node: `v24.18.0`. Protocol: `{"calibrationMs": 50, "defaultSet": "full", "rounds": 5, "targetMs": 300, "warmupCalls": 3, "warmupMs": 1000}`. Raytrace uses the summarizer's explicit three-round/one-initial-warmup-call exception; other points use five rotated rounds.

Warmup duration and repeated rounds do not prove stationarity. Half drift compares the second sample half with the first; negative values mean it got faster. A single-call sample has no half drift (n/a), not zero drift. Medians can include continued tiering, feedback evolution, GC and scheduling effects. Do not interpret a small ratio as a confirmed gain or attribute it to an optimization mechanism from this table alone.

| Role | Largest absolute half drift | Point |
| --- | ---: | --- |
| typescript | +26.711% | `variation-symreg-4-17` |
| baseline | +68.880% | `coverage-closures-64` |
| candidate | +24.796% | `coverage-closures-64` |

## All points

Times are milliseconds per public call. The final column is the candidate sample with the largest absolute half drift, retaining its sign.

| Point | TypeScript ms | Baseline ms | Candidate ms | Candidate / TS | Speed ratio | Time change | Candidate drift |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `complete-generic-row32` | 0.00841228 | 0.0341761 | 0.0341429 | 4.0587× | 1.0010× | -0.10% | -1.5% |
| `coverage-bst-32` | 0.0222071 | 0.0674031 | 0.0668928 | 3.0122× | 1.0076× | -0.76% | +7.0% |
| `coverage-bst-64` | 0.0515658 | 0.109702 | 0.10913 | 2.1163× | 1.0052× | -0.52% | -3.7% |
| `coverage-closures-256` | 0.0257608 | 0.0117864 | 0.0115445 | 0.4481× | 1.0210× | -2.05% | -8.0% |
| `coverage-closures-64` | 0.00660204 | 0.0112731 | 0.0109461 | 1.6580× | 1.0299× | -2.90% | +24.8% |
| `coverage-expression-128` | 0.00910131 | 0.0464394 | 0.0459267 | 5.0462× | 1.0112× | -1.10% | -2.2% |
| `coverage-expression-32` | 0.00209054 | 0.0216657 | 0.0214279 | 10.2500× | 1.0111× | -1.10% | -3.6% |
| `coverage-list-pipeline-128` | 0.00671697 | 0.0145292 | 0.0141308 | 2.1037× | 1.0282× | -2.74% | +5.1% |
| `coverage-list-pipeline-512` | 0.0284129 | 0.0176809 | 0.0176656 | 0.6217× | 1.0009× | -0.09% | +5.0% |
| `coverage-map-churn-128` | 0.911635 | 1.34865 | 1.33252 | 1.4617× | 1.0121× | -1.20% | +7.1% |
| `coverage-map-churn-32` | 0.168638 | 0.327201 | 0.308462 | 1.8291× | 1.0607× | -5.73% | -1.2% |
| `coverage-numeric-recurrence-1024` | 0.00768176 | 0.0209032 | 0.0207864 | 2.7059× | 1.0056× | -0.56% | +1.6% |
| `coverage-numeric-recurrence-256` | 0.0020763 | 0.0153062 | 0.0154142 | 7.4239× | 0.9930× | +0.71% | +4.4% |
| `coverage-record-aggregation-256` | 1.54796 | 2.28691 | 2.26833 | 1.4654× | 1.0082× | -0.81% | +21.6% |
| `coverage-record-aggregation-64` | 0.361193 | 0.5726 | 0.555985 | 1.5393× | 1.0299× | -2.90% | -3.8% |
| `coverage-unicode-text-16` | 0.0272925 | 0.0926713 | 0.0746334 | 2.7346× | 1.2417× | -19.46% | +5.7% |
| `coverage-unicode-text-64` | 0.11947 | 0.211521 | 0.195296 | 1.6347× | 1.0831× | -7.67% | -2.5% |
| `editdist` | 5.00539 | 10.5062 | 10.1609 | 2.0300× | 1.0340× | -3.29% | +9.1% |
| `lexer` | 1.91515 | 2.85767 | 2.84619 | 1.4861× | 1.0040× | -0.40% | +4.4% |
| `local-fold` | 0.0396753 | 0.114969 | 0.11534 | 2.9071× | 0.9968× | +0.32% | -6.6% |
| `local-pair` | 1.25967 | 2.64489 | 2.54823 | 2.0229× | 1.0379× | -3.65% | -8.5% |
| `mandelbrot` | 0.0459165 | 0.133422 | 0.128322 | 2.7947× | 1.0397× | -3.82% | +3.3% |
| `raytrace` | 34.3058 | 59.2702 | 59.4707 | 1.7335× | 0.9966× | +0.34% | -1.4% |
| `scalar-region-0` | 9.24534e-05 | 0.00495751 | 0.00483293 | 52.2742× | 1.0258× | -2.51% | -6.2% |
| `scalar-region-8192` | 0.0994658 | 0.116557 | 0.118187 | 1.1882× | 0.9862× | +1.40% | -19.5% |
| `symreg` | 1.10363 | 1.48017 | 1.4957 | 1.3553× | 0.9896× | +1.05% | -4.9% |
| `test-evening-program` | 0.0030034 | 0.20687 | 0.141725 | 47.1881× | 1.4597× | -31.49% | -4.5% |
| `test-map-set-ops` | 0.0224383 | 1.34207 | 1.27541 | 56.8410× | 1.0523× | -4.97% | -19.0% |
| `test-morning-program` | 0.00369316 | 0.228349 | 0.218668 | 59.2091× | 1.0443× | -4.24% | -24.0% |
| `test-rle-roundtrip` | 0.000599018 | 0.0390411 | 0.0386649 | 64.5472× | 1.0097× | -0.96% | -3.7% |
| `tree-bitonic` | 0.278781 | 0.344839 | 0.353962 | 1.2697× | 0.9742× | +2.65% | -0.4% |
| `variation-editdist-0-17` | 1.24357 | 2.65264 | 2.54927 | 2.0500× | 1.0405× | -3.90% | +2.2% |
| `variation-editdist-3-123` | 9.97626 | 20.9241 | 20.0098 | 2.0057× | 1.0457× | -4.37% | +2.7% |
| `variation-lexer-10-123` | 7.6264 | 11.3967 | 11.4088 | 1.4960× | 0.9989× | +0.11% | +0.4% |
| `variation-lexer-6-17` | 0.470538 | 0.732181 | 0.727567 | 1.5462× | 1.0063× | -0.63% | -4.1% |
| `variation-local-fold-128-0` | 0.00186027 | 0.01831 | 0.0179789 | 9.6647× | 1.0184× | -1.81% | +4.1% |
| `variation-local-fold-8192-123` | 0.118638 | 0.20634 | 0.210559 | 1.7748× | 0.9800× | +2.04% | -2.3% |
| `variation-mandelbrot-grid-4-7` | 0.0149157 | 0.0478706 | 0.0478708 | 3.2094× | 1.0000× | +0.00% | +2.4% |
| `variation-mandelbrot-grid-5-31` | 0.231951 | 0.438516 | 0.438201 | 1.8892× | 1.0007× | -0.07% | +2.1% |
| `variation-ray-active-256-2240` | 1.24765 | 2.24705 | 2.20643 | 1.7685× | 1.0184× | -1.81% | -11.7% |
| `variation-ray-active-64-2440` | 0.301052 | 0.569499 | 0.556002 | 1.8469× | 1.0243× | -2.37% | +2.9% |
| `variation-symreg-4-17` | 0.552455 | 0.783922 | 0.783591 | 1.4184× | 1.0004× | -0.04% | +1.2% |
| `variation-symreg-7-123` | 1.86552 | 2.50523 | 2.51057 | 1.3458× | 0.9979× | +0.21% | -1.5% |
| `variation-tree-bitonic-6-17` | 0.0369425 | 0.0764616 | 0.0764798 | 2.0702× | 0.9998× | +0.02% | +2.5% |
| `variation-tree-bitonic-9-123` | 0.699138 | 0.818288 | 0.81528 | 1.1661× | 1.0037× | -0.37% | +1.7% |

## Largest observed regressions

- `tree-bitonic`: +2.65% time; 0.9742× speed ratio; candidate maximum half drift -0.4%.
- `variation-local-fold-8192-123`: +2.04% time; 0.9800× speed ratio; candidate maximum half drift -2.3%.
- `scalar-region-8192`: +1.40% time; 0.9862× speed ratio; candidate maximum half drift -19.5%.
- `symreg`: +1.05% time; 0.9896× speed ratio; candidate maximum half drift -4.9%.
- `coverage-numeric-recurrence-256`: +0.71% time; 0.9930× speed ratio; candidate maximum half drift +4.4%.

## Evidence identity

Summary: `/home/ai/bend2/build/publish/bend/selfhost/build/phase51/full-summary01.json`; SHA-256 `bc0a9b9b9812a2a9a6c16fab8d618217e608bc8f17089ddbe5fe22b49b7f54aa`.

Renderer: `selfhost/tools/performance/phase51/render-results.py`; SHA-256 `c1605319a4137d8a47051df44c9f6c0870c165f7d1bacc6d168fd01718d930ed`. It formats the validated summary and does not rerun its underlying evidence checks or any target. The summary retains exact compiler, module, node, raw report and protocol identities.
