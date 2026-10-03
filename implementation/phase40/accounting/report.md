# Phase40 campaign accounting

| Quantity | Seconds |
|---|---:|
| wallSeconds | 115553.184 |
| recordedToolElapsedSeconds | 2185.206 |
| toolCoveredWallSeconds | 2185.278 |
| unclassifiedWallSeconds | 113367.906 |
| declaredWindowWallSeconds | 7936.179 |
| outsideDeclaredWindowsWallSeconds | 107617.005 |

Recorded tool intervals are merged for wall coverage. Unclassified includes reasoning, editing, waiting and unrecorded tools; it is not model latency. Declared windows bound observed sessions, not continuous active work; outside-window time includes interruption and uncertain agent continuation. One campaign establishes no model-speed comparison.

| Event | Tool seconds | Decision |
|---|---:|---|
| design-baseline | 0.000 | Prospective design committed and pushed; portable Phase39+TS baseline verified |
| resume-2026-10-03 | 0.000 | Known root resume 2026-10-03 06:18:35 UTC (epoch1791008315). Prior root tool receipt ends1790900697.9951153; agents reportedly continued until about00:50UTC Oct2, exact active end unknown. Raw elapsed includes interruption; do not treat it as active work. |
| list-control-run01 | 0.605 | Recorded original bounded receipt; complete=False; failure retained |
| list-control-run02 | 0.706 | Recorded original bounded receipt; complete=True; failure retained |
| tree-control-run01 | 1.710 | Recorded original bounded receipt; complete=True; failure retained |
| tree-derive-run01 | 0.102 | Recorded original bounded receipt; complete=False; failure retained |
| tree-derive-run02 | 0.705 | Recorded original bounded receipt; complete=True; failure retained |
| list-screen01 | 0.000 | Comparison report evidence only; no inferred process interval. {"wallSeconds": 12.135163783008466, "complete": true} |
| tree-screen01 | 0.000 | Comparison report evidence only; no inferred process interval. {"wallSeconds": 8.211796855990542, "complete": true} |
| checked01-supervisor | 42.995 | Original completed bounded receipt; complete=True; retain any failure |
| checked02-supervisor | 44.932 | Original completed bounded receipt; complete=True; retain any failure |
| lexer-control-run01 | 3.821 | Original completed bounded receipt; complete=True; retain any failure |
| lexer-control-run02 | 4.123 | Original completed bounded receipt; complete=True; retain any failure |
| lexer-derive-run02 | 0.706 | Original completed bounded receipt; complete=True; retain any failure |
| lexer-derive-run03 | 0.806 | Original completed bounded receipt; complete=True; retain any failure |
| tree-nat-baseline-run01 | 3.118 | Original completed bounded receipt; complete=False; retain any failure |
| lexer-screen01 | 0.000 | Comparison evidence only; absent absolute process intervals not inferred. {"wallSeconds": 10.143597168003907, "complete": true, "passed": true} |
| list-confirm01 | 0.000 | Comparison evidence only; absent absolute process intervals not inferred. {"wallSeconds": 24.652314164995914, "complete": true, "passed": true} |
| tree-confirm01 | 0.000 | Comparison evidence only; absent absolute process intervals not inferred. {"wallSeconds": 47.17689125900506, "complete": true, "passed": true} |
| list-plan-probe-run01 | 6.031 | Original completed bounded receipt; complete=True; retain any failure |
| tree-nat-baseline-run02 | 3.217 | Original completed bounded receipt; complete=False; retain any failure |
| tree-nat-baseline-run03 | 5.126 | Original completed bounded receipt; complete=True; retain any failure |
| tree-nat-candidate-run03 | 5.628 | Original completed bounded receipt; complete=True; retain any failure |
| tree-nat-derive-run03 | 2.314 | Original completed bounded receipt; complete=False; retain any failure |
| tree-nat-typescript-run03 | 0.705 | Original completed bounded receipt; complete=True; retain any failure |
| lexer-confirm01 | 0.000 | Comparison evidence only; no inferred absolute intervals. {"wallSeconds": 227.09658211900387, "complete": true, "passed": true} |
| checked03-supervisor | 43.892 | Completed original bounded receipt; complete=True; failure status retained |
| checked04-supervisor | 44.195 | Completed original bounded receipt; complete=True; failure status retained |
| list-baseline-emit-run01 | 4.724 | Completed original bounded receipt; complete=True; failure status retained |
| list-baseline-emit-run02 | 4.825 | Completed original bounded receipt; complete=True; failure status retained |
| list-candidate-emit-run02 | 5.326 | Completed original bounded receipt; complete=True; failure status retained |
| list-typescript-emit-run01 | 0.705 | Completed original bounded receipt; complete=True; failure status retained |
| list-typescript-emit-run02 | 0.102 | Completed original bounded receipt; complete=False; failure status retained |
| checked05-supervisor | 43.797 | Finished original bounded receipt; complete=True; failed status retained |
| linear-order-control-run02 | 0.705 | Finished original bounded receipt; complete=True; failed status retained |
| list-actual-control-run01 | 0.203 | Finished original bounded receipt; complete=False; failed status retained |
| list-actual-control-run02 | 0.806 | Finished original bounded receipt; complete=True; failed status retained |
| list-actual-derive-run01 | 0.504 | Finished original bounded receipt; complete=True; failed status retained |
| list-actual-derive-run02 | 0.504 | Finished original bounded receipt; complete=True; failed status retained |
| list-candidate-emit-run05 | 5.830 | Finished original bounded receipt; complete=True; failed status retained |
| list-typescript-emit-run03 | 0.705 | Finished original bounded receipt; complete=False; failed status retained |
| list-typescript-emit-run04 | 0.705 | Finished original bounded receipt; complete=True; failed status retained |
| tree-nat-candidate-run04 | 6.131 | Finished original bounded receipt; complete=True; failed status retained |
| tree-nat-candidate-run05 | 5.830 | Finished original bounded receipt; complete=True; failed status retained |
| tree-nat-control-run04 | 0.404 | Finished original bounded receipt; complete=False; failed status retained |
| tree-nat-control-run05 | 1.309 | Finished original bounded receipt; complete=True; failed status retained |
| tree-nat-derive-run04 | 2.413 | Finished original bounded receipt; complete=True; failed status retained |
| tree-nat-derive-run05 | 2.514 | Finished original bounded receipt; complete=True; failed status retained |
| lexer-controls01 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-manual-lexer-controls-v2", "oracle": 376, "boundaries": 102, "admission": 4} |
| lexer-controls02 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-manual-lexer-controls-v3", "oracle": 376, "boundaries": 109, "admission": 4} |
| linear-order-controls02 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-linear-order-controls", "oracles": 160, "boundaries": 36, "order": 12} |
| list-actual-controls01 | 0.000 | Original report evidence; intervals not inferred. {"complete": false, "pass": false, "kind": "phase40-list-actual-controls", "oracle": 7, "boundaries": 0, "admission": 0} |
| list-actual-controls02 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-list-actual-controls", "oracle": 52, "boundaries": 106, "admission": 1} |
| list-controls01 | 0.000 | Original report evidence; intervals not inferred. {"complete": false, "pass": false, "kind": "phase40-list-controls", "oracle": 49, "boundaries": 68, "admission": 2} |
| list-controls02 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-list-controls", "oracle": 53, "boundaries": 75, "admission": 2} |
| tree-controls01 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-tree-controls", "oracle": 626, "boundaries": 112, "admission": 22} |
| tree-nat-controls04 | 0.000 | Original report evidence; intervals not inferred. {"complete": false, "pass": false, "kind": "phase40-actual-nat-component-controls", "oracle": 255, "boundaries": 0, "admission": 0} |
| tree-nat-controls05 | 0.000 | Original report evidence; intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-actual-nat-component-controls", "oracle": 302, "boundaries": 84, "admission": 1} |
| final-source-counts01 | 0.000 | Static checked05 snapshots vs starting39: +138physical/+122nonblank/+17defs; laws/types/modules unchanged. Runtime identity separately retained; no speed claim. |
| final-plan01/run-owner-vector-cohort | 0.102 | Original finished bounded receipt; complete=False; failed status retained |
| checked06-supervisor | 45.845 | Original finished bounded receipt; complete=True; failed status retained |
| development-final01 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 184.47247646801407, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| historical-final01 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 402.06982045798213, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| holdout-final01 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 114.72087811402162, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| precedence-screen06 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 47.62036773801083, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| tree-actual-screen01 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 29.340252485999372, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| variation-final01 | 0.000 | Original report evidence; absolute intervals not inferred. {"wallSeconds": 387.56324136297917, "complete": true, "pass": true, "status": "measured", "kind": "bend-program-execution-report"} |
| checked06-source-counts02 | 0.000 | Static39→06: +141physical/+125nonblank/+17defs; same runtime/types/laws/modules. checked05counts01 retained. No speed claim. |
| final-plan02/run-owner-aliases | 0.203 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-counter-hooks-fold | 0.303 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-counter-hooks-pair | 1.408 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-emit-scope | 4.623 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-emit-vectors | 4.623 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-fold | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-nat-guards | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-nested | 0.404 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-order | 0.303 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-pair | 7.136 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-ray | 1.709 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-ray-cohort | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-regions | 0.705 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-scope | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-types | 2.112 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-vector-cohort | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| final-plan02/run-owner-vectors | 0.202 | Original finished bounded receipt; complete=True; preserve failed status |
| linear-order-control-run06 | 0.604 | Original finished bounded receipt; complete=True; preserve failed status |
| list-actual-control-run06 | 0.705 | Original finished bounded receipt; complete=True; preserve failed status |
| list-actual-derive-run06 | 0.504 | Original finished bounded receipt; complete=True; preserve failed status |
| list-candidate-emit-run06 | 5.326 | Original finished bounded receipt; complete=True; preserve failed status |
| list-typescript-control-run06 | 0.605 | Original finished bounded receipt; complete=True; preserve failed status |
| tree-candidate-emit-run06 | 5.126 | Original finished bounded receipt; complete=True; preserve failed status |
| tree-nat-control-run06 | 1.208 | Original finished bounded receipt; complete=True; preserve failed status |
| tree-nat-derive-run06 | 2.212 | Original finished bounded receipt; complete=True; preserve failed status |
| linear-order-controls06 | 0.000 | Original report evidence; absolute intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-linear-order-controls", "oracles": 160, "boundaries": 36, "order": 12} |
| list-actual-controls06 | 0.000 | Original report evidence; absolute intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-list-actual-controls", "oracle": 52, "boundaries": 106} |
| list-typescript-controls06 | 0.000 | Original report evidence; absolute intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-list-typescript-controls", "oracle": 49} |
| tree-nat-controls06 | 0.000 | Original report evidence; absolute intervals not inferred. {"complete": true, "pass": true, "kind": "phase40-actual-nat-component-controls", "oracle": 302, "boundaries": 84} |
| checked06-static-module-identities | 0.000 | 05→06samebytes42/45;39→06samebytes30/45. Three restoredraypoints/2sources. No timingclaim; identical modules are negativecontrols. |
| closed-receipt:counter-successor-run06 | 0.604 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:expanded-correctness-run06 | 8.543 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-backend-pilot | 256.914 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-component-and-hvm | 14.182 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-corpus | 110.038 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-frontend-broader | 37.354 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-frontend-main | 784.390 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-nested | 5.432 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-owner-colf | 5.528 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-owner-colf-cohort | 0.202 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-owner-pure-guards | 0.202 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-owner-region-extra | 0.403 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-primitive | 7.048 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-primitive-guards | 1.409 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-release-install | 7.036 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-release-smoke | 50.700 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-release-verify | 0.906 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-upstream-selected | 39.326 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-worker | 5.839 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:final-plan02/run-worker-admission | 0.303 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:fold-controls-v2-run06 | 0.504 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:fold-guards-run06 | 0.202 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-array | 0.202 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-derive-guards | 0.604 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-error | 0.202 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-guardcolf | 4.623 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-guardscope | 0.504 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-producerfixture | 0.303 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-producerreviewed | 0.705 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase36-owners02/run-selector | 0.504 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-cast | 0.303 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-cast-acquire | 17.795 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-cast-derive | 2.212 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-close | 2.412 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-dataview | 0.203 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase37-owners03/run-finite | 1.409 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase39-owners02/run-countdown | 0.605 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase39-owners02/run-derive-component | 2.112 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase39-owners02/run-derive-guard | 2.313 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase39-owners02/run-guard | 0.805 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:phase39-owners02/run-unary | 0.303 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:postinstall-audit-run06 | 7.034 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-fold-controls-v3-06 | 0.705 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-component-controls03 | 1.611 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-component-derive03 | 2.213 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-component-tail03 | 0.303 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-component-tail04 | 0.404 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-owner-close04 | 4.522 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-inherited-unary-controls03 | 1.308 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-owner-close06 | 0.102 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-preinstall-audit06 | 6.331 | Preserved original completion/failure; receipt is not itself promotion. |
| closed-receipt:run-selected-execution06 | 4.724 | Preserved original completion/failure; receipt is not itself promotion. |
| launcher-step:closure-launch04:ray-final06 | 79.625 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| launcher-step:closure-launch04:ray-summary06 | 1.689 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| launcher-step:closure-launch04:cost-baseline01 | 20.774 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| launcher-step:closure-launch04:cost-plan06 | 7.741 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| launcher-step:closure-launch04:cost-run06 | 257.734 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| launcher-step:closure-launch04:diagnostics06 | 22.743 | Exact launcher interval for self-supervised/unwrapped command; no nested bounded receipt counted. |
| final-checked06-admitted-and-installed | 0.000 | Selected runtime gains retained with explicit compilation/source costs; 42CLI/15audit groups pass;45points42reuse+3fresh;18profiles; portable5point smoke20.36s including0.36s over preset. No PR comment. |

| Declared window | UTC epoch start | UTC epoch end | Evidence / uncertainty |
|---|---:|---:|---|
| initial-root-observed | 1790900329.0 | 1790900697.9951153 | Campaign start through last preserved initial root tool receipt. Agents reportedly continued until about2026-10-02 00:50UTC; exact continuation endpoint unknown. This window is observed session bounds, not continuous active time. |
| resumed-root-through-evidence-close | 1791008315.0 | 1791015882.1842082 | Observed resumed session bounds from2026-10-03 06:18:35UTC through selected-image validation and raw-evidence closure preparation. Includes reasoning/waiting; not continuous active compute. Final archive/publication after cutoff excluded. |
