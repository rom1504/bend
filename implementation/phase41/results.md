# Phase41 final tree results

The checked Phase41 tree change passes the final postinstall correctness audit and improves all three fresh tree workload comparisons against Phase40 checked06. Across five paired rounds, the candidate is 1.506× faster on `tree-bitonic`, 1.592× on tree depth6, and 1.506× on depth9. It remains 9.33–12.18× slower than pinned TypeScript. The unchanged controls are effectively flat.

The change costs compiler time: the `tree-bitonic` checked-library request median rises from 2,248.0 ms on Phase40 to 2,460.6 ms on Phase41 (+9.46%), with Phase41 slower in all three paired requests. Other sampled compile sources range from 0.16% faster (`local-pair`) to 6.95% faster (numeric recurrence); no aggregate compiler-speed claim follows from these four sources.

## Fresh program timings

These are clean same-run Phase41 execution measurements, not profiler samples. The maintained runner performed five rotated rounds per point across Phase40 checked06 baseline, Phase41 candidate, and pinned TypeScript. Every one of the 90 process samples passed its expected result. Rows report median and observed range in milliseconds per call. “Half drift” is the observed minimum–maximum split-half drift across rounds; it is not a confidence interval.

| Point | Phase40 median [range] | Phase41 median [range] | TypeScript median [range] | Phase40 / Phase41 | Candidate paired wins | Half drift Phase40 / Phase41 |
|---|---:|---:|---:|---:|---:|---:|
| tree-bitonic | 4.223 [4.137–4.638] | 2.804 [2.732–3.337] | 0.2722 [0.2701–0.2836] | 1.506× | 5/5 | −14.43%…+10.03% / −7.68%…+6.85% |
| tree depth6, seed17 | 0.7147 [0.7060–0.7798] | 0.4490 [0.4383–0.4874] | 0.03687 [0.03677–0.04079] | 1.592× | 5/5 | +1.66%…+11.93% / −5.07%…+6.19% |
| tree depth9, seed123 | 9.598 [9.481–10.504] | 6.371 [6.332–7.037] | 0.6826 [0.6792–0.7457] | 1.506× | 5/5 | −1.34%…+0.52% / −0.75%…+3.23% |
| local-pair control | 2.628 [2.605–2.850] | 2.626 [2.619–2.846] | 1.236 [1.225–1.383] | 1.001× | 3/5 | −1.13%…+0.96% / −0.70%…+2.51% |
| scalar8192 control | 0.1119 [0.1115–0.1238] | 0.1143 [0.1120–0.1217] | 0.09984 [0.09932–0.1095] | 0.979× | 2/5 | −0.77%…+2.31% / −3.34%…+3.14% |
| numeric1024 control | 0.02028 [0.02014–0.02242] | 0.02042 [0.02010–0.02242] | 0.007911 [0.007692–0.008073] | 0.993× | 3/5 | −0.46%…+2.83% / −1.42%…+0.28% |

The earlier three-round screen used actual checked Phase41 source emission for the tree wrapper against fresh Phase40 outputs. It reported 1.441×, 1.396×, and 1.449× on the same three tree points. The final five-round run uses the actual checked Phase41 emitted modules and pinned Phase40 starting bundle. Its gains are consistent with that screen, with a different measurement protocol and fresh comparisons; the two sets are not pooled. A separate manual saved-output experiment is recorded under `tree-screen01` and is not the screen summarized here.

## Compiler cost and source size

The normal checked-library cost worker completed all 36 source/sample/role requests: four sources, three rotations, and baseline, candidate, and TypeScript roles. Times below are median [minimum–maximum] request milliseconds. Host import is separate, while normal API loading, inspection, and Base cache behavior remain inside the request measurement. The worker's inner measured wall was 252.734 seconds; its enclosing campaign interval was 253.324 seconds.

| Source | Phase40 median [range] | Phase41 median [range] | Change | TypeScript median [range] |
|---|---:|---:|---:|---:|
| tree-bitonic | 2248.0 [2230.3–2424.3] | 2460.6 [2389.7–2606.8] | +9.46%; slower in 3/3 paired requests | 318.2 [317.7–349.1] |
| local-pair | 1784.1 [1767.7–1959.1] | 1781.1 [1778.5–1781.4] | −0.16% | 338.2 [337.6–338.7] |
| numeric recurrence1024 | 1443.8 [1329.4–1482.0] | 1343.4 [1336.0–1347.1] | −6.95% | 266.3 [265.8–299.3] |
| list pipeline512 | 2000.0 [1975.1–2016.8] | 1993.5 [1980.4–1994.2] | −0.32% | 430.4 [429.9–432.2] |

Source accounting covers 70 selfhost modules. The only source difference is `src/back/js/tree.bend`: +35 physical lines, +31 nonblank lines, +1,963 bytes, and +4 definitions; laws and types are unchanged. The generated tree module grows from 107,990 to 109,624 bytes (+1,634 bytes). The compiler-cost worker took 252.734 seconds; its enclosing campaign interval was 253.324 seconds.

## Correctness and scope

The final runtime report is complete/pass with six selected points, five rounds, and 90/90 validated samples. The final postinstall selected-image audit passes 15/15 gates; Phase41 checked01 is installed, release verification passes, and all 42 ordinary/relocated CLI checks pass. Its frontend owners preserve exact agreement on 3,026 main and 196 broader observations, including the same 497 main and one broader historical observed cases; the independent tree/list/Nat controls and owner closures are recorded in the audit. See the [final integration account](integration.md). Independent release review remains separate.

The earlier screen's focused actual-emission controls recorded 124 oracle cases, 17 boundary checks, and a 60,002-node/60,003-leaf deep input. The final diagnostic run profiles only `tree-bitonic`; its sampled CPU attribution is descriptive and separate from the timing table. See [profile findings](profile-findings.md).

Canonical raw receipts and source counts are summarized in [results.json](results.json). The main sources are [final-runtime01](../../selfhost/build/phase41/final-runtime01/report.json), [compiler-cost01](../../selfhost/build/phase41/compiler-cost01/report.json), [final-diagnostics01](../../selfhost/build/phase41/final-diagnostics01/report.json), and [source-counts01](../../selfhost/build/phase41/source-counts01.json).
