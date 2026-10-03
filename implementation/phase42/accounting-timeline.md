# Phase42 elapsed-time and complexity account

Enclosing recorded jobs only; nested intervals are not separately added. Category sums can overlap. Unclassified wall time is not idle time or model latency. Static canonical compiler counts use the maintained Phase32/40 definitions; generated program module bytes are separate from compiler/API size.

Campaign elapsed: 18303.651s; recorded union: 5327.678s; unclassified: 12975.973s.
Jobs: 335; failures: 43; incomplete: 0.

| Category | Jobs | Failures | Summed seconds | Union seconds |
|---|---:|---:|---:|---:|
| derivation, preservation and accounting | 61 | 8 | 173.124 | 173.124 |
| controls and verification | 126 | 20 | 1121.345 | 1121.345 |
| generated-program timing | 28 | 0 | 1807.578 | 1807.578 |
| profiling | 4 | 0 | 73.112 | 73.112 |
| checked build | 8 | 2 | 269.835 | 269.835 |
| checked acquisition | 47 | 4 | 663.097 | 663.097 |
| other recorded work | 55 | 9 | 784.202 | 784.202 |
| compiler-request sampling | 6 | 0 | 435.386 | 435.386 |

| Count | Phase41 baseline | Current | Delta |
|---|---:|---:|---:|
| physicalLines | 18898 | 20056 | 1158 |
| nonblankLines | 16187 | 17198 | 1011 |
| bytes | 777508 | 844184 | 66676 |
| defs | 2108 | 2249 | 141 |
| laws | 640 | 640 | 0 |
| types | 71 | 71 | 0 |
| modules | 70 | 70 | 0 |

| Started UTC | Job | Category | Status | Seconds |
|---|---|---|---|---:|
| 2026-10-03T18:20:11.381380+00:00 | freeze-baseline01 | derivation, preservation and accounting | pass | 0.983 |
| 2026-10-03T18:20:12.465294+00:00 | calls-derive01 | derivation, preservation and accounting | failed | 0.787 |
| 2026-10-03T18:21:32.829839+00:00 | frames-derive01 | derivation, preservation and accounting | pass | 0.509 |
| 2026-10-03T18:21:33.439977+00:00 | frames-adapters01 | controls and verification | pass | 0.157 |
| 2026-10-03T18:21:33.704921+00:00 | frames-controls01 | controls and verification | pass | 0.568 |
| 2026-10-03T18:21:34.371647+00:00 | fusion-derive01 | derivation, preservation and accounting | pass | 0.156 |
| 2026-10-03T18:21:34.581300+00:00 | fusion-controls01 | controls and verification | failed | 0.780 |
| 2026-10-03T18:21:35.416502+00:00 | layout-derive01 | derivation, preservation and accounting | pass | 0.578 |
| 2026-10-03T18:21:36.051207+00:00 | layout-controls01 | controls and verification | pass | 0.825 |
| 2026-10-03T18:22:08.109377+00:00 | calls-derive02 | derivation, preservation and accounting | pass | 0.993 |
| 2026-10-03T18:22:09.197215+00:00 | calls-controls02 | controls and verification | pass | 1.168 |
| 2026-10-03T18:22:54.433643+00:00 | tree-structure-screen01 | generated-program timing | pass | 53.410 |
| 2026-10-03T18:24:31.781378+00:00 | calls-screen01 | generated-program timing | pass | 52.617 |
| 2026-10-03T18:25:55.165575+00:00 | fusion-derive02 | derivation, preservation and accounting | pass | 0.155 |
| 2026-10-03T18:25:55.495474+00:00 | fusion-controls02 | controls and verification | pass | 0.861 |
| 2026-10-03T18:27:16.437920+00:00 | fusion-screen01 | generated-program timing | pass | 19.464 |
| 2026-10-03T18:29:44.541213+00:00 | whole-tree-derive01 | derivation, preservation and accounting | pass | 0.595 |
| 2026-10-03T18:29:45.229100+00:00 | whole-tree-controls01 | controls and verification | failed | 0.275 |
| 2026-10-03T18:30:42.871583+00:00 | compiler-profile01 | profiling | pass | 7.524 |
| 2026-10-03T18:32:01.222171+00:00 | whole-tree-controls02 | controls and verification | failed | 0.278 |
| 2026-10-03T18:32:23.452100+00:00 | fusion-shapes01 | controls and verification | pass | 6.077 |
| 2026-10-03T18:32:29.587642+00:00 | fusion-shapes-fixture01 | controls and verification | failed | 2.171 |
| 2026-10-03T18:34:35.742167+00:00 | checked01 | checked build | pass | 45.875 |
| 2026-10-03T18:36:33.002329+00:00 | whole-tree-controls03 | controls and verification | pass | 0.385 |
| 2026-10-03T18:37:36.500375+00:00 | whole-tree-screen01 | generated-program timing | pass | 29.849 |
| 2026-10-03T18:38:06.397586+00:00 | checked01-prepare | checked acquisition | pass | 12.398 |
| 2026-10-03T18:41:03.914556+00:00 | checked01-actual-derive | derivation, preservation and accounting | pass | 2.494 |
| 2026-10-03T18:41:06.457065+00:00 | checked01-actual-controls | controls and verification | pass | 0.761 |
| 2026-10-03T18:43:15.233872+00:00 | checked01-screen | generated-program timing | pass | 22.840 |
| 2026-10-03T18:49:13.390249+00:00 | whole-tree-orthogonal-derive01 | derivation, preservation and accounting | pass | 0.789 |
| 2026-10-03T18:49:37.017499+00:00 | whole-tree-array-bigint-controls01 | controls and verification | pass | 0.388 |
| 2026-10-03T18:49:39.676983+00:00 | whole-tree-flat-number-controls01 | controls and verification | pass | 0.360 |
| 2026-10-03T18:50:28.505187+00:00 | whole-tree-orthogonal-screen01 | generated-program timing | pass | 33.724 |
| 2026-10-03T18:51:31.136387+00:00 | checked02 | checked build | pass | 41.341 |
| 2026-10-03T18:53:23.256267+00:00 | checked02-bind | other recorded work | pass | 1.995 |
| 2026-10-03T18:53:55.304623+00:00 | checked02-preparation | checked acquisition | pass | 12.422 |
| 2026-10-03T18:54:59.988475+00:00 | checked03 | checked build | pass | 42.944 |
| 2026-10-03T18:56:42.768273+00:00 | fusion-gate-probe01 | controls and verification | failed | 1.888 |
| 2026-10-03T18:57:17.350618+00:00 | fusion-gate-probe02 | controls and verification | pass | 6.536 |
| 2026-10-03T18:58:01.930431+00:00 | checked03-preparation | checked acquisition | pass | 12.531 |
| 2026-10-03T18:59:09.229794+00:00 | ablation-owned-derive01 | derivation, preservation and accounting | pass | 2.401 |
| 2026-10-03T18:59:11.727298+00:00 | ablation-owned-controls01 | controls and verification | pass | 0.765 |
| 2026-10-03T18:59:12.549681+00:00 | ablation-postcalls-frames-derive01 | derivation, preservation and accounting | pass | 0.489 |
| 2026-10-03T18:59:13.086725+00:00 | ablation-postcalls-scopes-derive01 | derivation, preservation and accounting | pass | 0.519 |
| 2026-10-03T18:59:13.662997+00:00 | ablation-postcalls-controls-derive01 | controls and verification | pass | 0.767 |
| 2026-10-03T18:59:14.478896+00:00 | ablation-postcalls-controls01 | controls and verification | pass | 1.070 |
| 2026-10-03T18:59:15.606213+00:00 | ablation-actual-flat-derive01 | derivation, preservation and accounting | failed | 0.785 |
| 2026-10-03T19:00:09.203257+00:00 | fusion-gate-probe03 | controls and verification | pass | 5.928 |
| 2026-10-03T19:01:08.484453+00:00 | residual-tree-screen01 | generated-program timing | pass | 52.814 |
| 2026-10-03T19:02:27.474674+00:00 | checked04 | checked build | failed | 4.415 |
| 2026-10-03T19:04:14.569327+00:00 | fusion-gate-normalized01 | controls and verification | pass | 6.414 |
| 2026-10-03T19:05:33.586998+00:00 | ablation-actual-flat-derive02 | derivation, preservation and accounting | pass | 0.869 |
| 2026-10-03T19:05:34.513919+00:00 | ablation-actual-flat-clone-array-controls02 | controls and verification | pass | 0.358 |
| 2026-10-03T19:05:34.988323+00:00 | ablation-actual-flat-clone-flat-controls02 | controls and verification | pass | 0.359 |
| 2026-10-03T19:05:35.405272+00:00 | ablation-fixtures-baseline01 | checked acquisition | failed | 8.039 |
| 2026-10-03T19:07:13.729112+00:00 | checked05 | checked build | pass | 44.095 |
| 2026-10-03T19:08:58.253247+00:00 | actual-flat-screen01 | generated-program timing | pass | 29.793 |
| 2026-10-03T19:10:12.537823+00:00 | acquisition-fixtures-typescript02 | checked acquisition | failed | 1.964 |
| 2026-10-03T19:11:38.888714+00:00 | calls-fixture-ts-diagnose01 | other recorded work | failed | 0.297 |
| 2026-10-03T19:12:25.851532+00:00 | calls-fixture-ts-diagnose02 | other recorded work | failed | 0.697 |
| 2026-10-03T19:12:43.584256+00:00 | calls-fixture-ts-diagnose03 | other recorded work | failed | 0.711 |
| 2026-10-03T19:13:41.134644+00:00 | acquisition04-checked05-preparation | checked acquisition | pass | 11.742 |
| 2026-10-03T19:13:52.934081+00:00 | acquisition04-fixtures-candidate05 | checked acquisition | pass | 11.597 |
| 2026-10-03T19:14:04.617731+00:00 | acquisition04-fixtures-owned-baseline02 | checked acquisition | pass | 6.102 |
| 2026-10-03T19:14:10.813553+00:00 | acquisition04-fixtures-baseline02 | checked acquisition | failed | 3.288 |
| 2026-10-03T19:15:39.315935+00:00 | controls-facts-controls05 | controls and verification | pass | 0.309 |
| 2026-10-03T19:15:39.738146+00:00 | controls-fusion-actual-derive05 | controls and verification | pass | 0.157 |
| 2026-10-03T19:15:39.991953+00:00 | controls-fusion-actual-controls05 | controls and verification | failed | 0.257 |
| 2026-10-03T19:16:00.172118+00:00 | controls-fusion-fixture-controls05 | controls and verification | failed | 0.280 |
| 2026-10-03T19:16:25.810869+00:00 | controls-owned-fixture-derive05 | controls and verification | pass | 0.590 |
| 2026-10-03T19:16:26.495452+00:00 | controls-owned-fixture-controls05 | controls and verification | pass | 0.666 |
| 2026-10-03T19:16:27.218545+00:00 | controls-stack-derive01 | controls and verification | pass | 1.180 |
| 2026-10-03T19:16:28.457738+00:00 | controls-stack-controls01 | controls and verification | pass | 1.168 |
| 2026-10-03T19:17:46.393791+00:00 | stack-screen01 | generated-program timing | pass | 44.803 |
| 2026-10-03T19:19:33.141725+00:00 | calls-fixture-v3-ts-check01 | other recorded work | pass | 0.699 |
| 2026-10-03T19:20:02.785914+00:00 | checked06 | checked build | failed | 4.488 |
| 2026-10-03T19:22:39.968968+00:00 | checked07 | checked build | pass | 43.337 |
| 2026-10-03T19:24:56.324894+00:00 | acquisition07-checked07-preparation | checked acquisition | pass | 11.731 |
| 2026-10-03T19:25:08.151875+00:00 | acquisition07-fixtures-candidate07 | checked acquisition | pass | 15.826 |
| 2026-10-03T19:25:24.085665+00:00 | acquisition07-calls-fixture-baseline03 | checked acquisition | pass | 5.793 |
| 2026-10-03T19:25:29.937587+00:00 | acquisition07-calls-fixture-typescript03 | checked acquisition | pass | 1.575 |
| 2026-10-03T19:27:37.941463+00:00 | controls07-facts-controls07 | controls and verification | pass | 0.287 |
| 2026-10-03T19:27:38.318039+00:00 | controls07-fusion-actual-derive07 | controls and verification | pass | 0.157 |
| 2026-10-03T19:27:38.578668+00:00 | controls07-fusion-actual-controls07 | controls and verification | pass | 0.678 |
| 2026-10-03T19:27:39.316065+00:00 | controls07-fusion-fixture-controls07 | controls and verification | pass | 1.163 |
| 2026-10-03T19:27:40.526298+00:00 | controls07-owned-fixture-derive07 | controls and verification | pass | 0.582 |
| 2026-10-03T19:27:41.166109+00:00 | controls07-owned-fixture-controls07 | controls and verification | pass | 0.666 |
| 2026-10-03T19:27:41.890517+00:00 | controls07-calls-fixture-controls07 | controls and verification | pass | 2.375 |
| 2026-10-03T19:30:00.206242+00:00 | fusion-actual07-screen | generated-program timing | pass | 14.569 |
| 2026-10-03T19:31:12.099617+00:00 | bst-plan-probe01 | controls and verification | failed | 0.193 |
| 2026-10-03T19:34:50.248913+00:00 | bst-plan-probe02 | controls and verification | pass | 5.460 |
| 2026-10-03T19:36:06.189659+00:00 | checked08 | checked build | pass | 43.340 |
| 2026-10-03T19:39:42.021042+00:00 | screen08-checked08-preparation | checked acquisition | pass | 11.801 |
| 2026-10-03T19:39:53.879126+00:00 | screen08-flat-fixture-ts-check01 | other recorded work | failed | 0.699 |
| 2026-10-03T19:45:56.772511+00:00 | queue08-resume-map-native-derive01 | derivation, preservation and accounting | pass | 0.191 |
| 2026-10-03T19:45:57.053975+00:00 | queue08-resume-map-native-controls01 | controls and verification | pass | 0.682 |
| 2026-10-03T19:46:39.314337+00:00 | fusion-actual07-large-screen01 | generated-program timing | pass | 37.359 |
| 2026-10-03T19:48:12.534515+00:00 | map-native-screen01 | generated-program timing | pass | 15.970 |
| 2026-10-03T19:48:58.724584+00:00 | flat-admission-probe01 | controls and verification | failed | 0.349 |
| 2026-10-03T19:49:45.888063+00:00 | queue09-flat-fixture-ts-check02 | other recorded work | failed | 0.697 |
| 2026-10-03T19:49:57.585884+00:00 | queue09-resume-sequential-fixture-ts-check01 | other recorded work | pass | 0.799 |
| 2026-10-03T19:51:22.934018+00:00 | queue10-flat-admission-probe02 | controls and verification | pass | 4.910 |
| 2026-10-03T19:51:27.903385+00:00 | queue10-bst-plan-probe03 | controls and verification | failed | 1.863 |
| 2026-10-03T19:52:17.730789+00:00 | queue10-resume-flat-fixture-ts-check03 | other recorded work | pass | 0.741 |
| 2026-10-03T19:53:21.538330+00:00 | queue11-bst-sequential-baseline01 | checked acquisition | pass | 10.959 |
| 2026-10-03T19:53:32.628420+00:00 | queue11-bst-sequential-typescript01 | checked acquisition | pass | 2.216 |
| 2026-10-03T19:54:29.414418+00:00 | queue12-flat-admission-probe03 | controls and verification | pass | 5.032 |
| 2026-10-03T19:54:34.540130+00:00 | queue12-bst-plan-probe04 | controls and verification | pass | 5.284 |
| 2026-10-03T19:56:56.825071+00:00 | queue13-checked09 | other recorded work | pass | 43.856 |
| 2026-10-03T19:58:24.686278+00:00 | queue14-checked09-preparation | checked acquisition | pass | 11.811 |
| 2026-10-03T19:58:36.607873+00:00 | queue14-layout-actual09 | controls and verification | failed | 2.149 |
| 2026-10-03T20:00:29.412561+00:00 | queue15-layout-fixture-baseline-emit09 | checked acquisition | pass | 5.917 |
| 2026-10-03T20:00:35.435743+00:00 | queue15-layout-fixture-candidate-emit09 | checked acquisition | pass | 5.521 |
| 2026-10-03T20:00:41.059212+00:00 | queue15-layout-fixture09 | controls and verification | pass | 2.373 |
| 2026-10-03T20:00:43.540182+00:00 | queue15-checked10 | other recorded work | pass | 44.554 |
| 2026-10-03T20:02:07.189291+00:00 | queue16-layout-actual09-retry01 | controls and verification | pass | 2.679 |
| 2026-10-03T20:02:54.697820+00:00 | queue17-bst-sequential-candidate10 | checked acquisition | pass | 11.658 |
| 2026-10-03T20:03:06.454908+00:00 | queue17-flat-context-controls09 | controls and verification | failed | 5.028 |
| 2026-10-03T20:03:57.017956+00:00 | queue17-resume-bst-derive10 | derivation, preservation and accounting | failed | 3.614 |
| 2026-10-03T20:05:38.898934+00:00 | queue18-bst-plan-probe05 | controls and verification | pass | 6.929 |
| 2026-10-03T20:05:45.887222+00:00 | queue18-sequential-derive10 | derivation, preservation and accounting | failed | 3.680 |
| 2026-10-03T20:06:13.937227+00:00 | queue19-flat-context-controls09-retry01 | controls and verification | pass | 5.360 |
| 2026-10-03T20:06:19.395341+00:00 | queue19-flat-actual09-screen01 | generated-program timing | pass | 29.760 |
| 2026-10-03T20:10:16.045399+00:00 | queue20-native-proof-controls10 | controls and verification | pass | 6.636 |
| 2026-10-03T20:10:45.649910+00:00 | queue21-bst-plan-probe06 | controls and verification | pass | 6.329 |
| 2026-10-03T20:14:18.830546+00:00 | queue22-checked11 | other recorded work | pass | 40.345 |
| 2026-10-03T20:16:12.393696+00:00 | queue23-bst-sequential-candidate11 | checked acquisition | pass | 11.013 |
| 2026-10-03T20:16:23.604091+00:00 | queue23-sequential-derive11 | derivation, preservation and accounting | pass | 3.882 |
| 2026-10-03T20:16:27.592732+00:00 | queue23-sequential-controls11 | controls and verification | failed | 0.250 |
| 2026-10-03T20:19:48.267513+00:00 | queue24-fusion-entry-derive01 | derivation, preservation and accounting | pass | 0.174 |
| 2026-10-03T20:19:48.543335+00:00 | queue24-fusion-entry-counterexample01 | other recorded work | pass | 0.157 |
| 2026-10-03T20:23:24.870424+00:00 | queue25-sequential-derive11-retry01 | derivation, preservation and accounting | pass | 3.926 |
| 2026-10-03T20:23:28.854996+00:00 | queue25-sequential-controls11-retry01 | controls and verification | failed | 0.258 |
| 2026-10-03T20:26:17.688374+00:00 | preimport-bigint-counterexample01 | other recorded work | pass | 0.792 |
| 2026-10-03T20:37:12.604883+00:00 | q26-core-boundary-tree-BigInt-01 | other recorded work | pass | 0.895 |
| 2026-10-03T20:37:13.555609+00:00 | q26-core-boundary-tree-imul-01 | other recorded work | pass | 0.872 |
| 2026-10-03T20:37:14.491304+00:00 | q26-core-boundary-fusion-imul-01 | other recorded work | pass | 0.976 |
| 2026-10-03T20:40:13.760488+00:00 | q27-sequential-controls11-v4 | controls and verification | pass | 0.996 |
| 2026-10-03T20:40:47.684963+00:00 | q28-checked12 | other recorded work | pass | 47.489 |
| 2026-10-03T20:42:04.372524+00:00 | q29-bst-sequential-candidate12 | checked acquisition | pass | 12.361 |
| 2026-10-03T20:42:16.830956+00:00 | q29-bst-derive12 | derivation, preservation and accounting | pass | 4.290 |
| 2026-10-03T20:42:21.183933+00:00 | q29-bst-controls12 | controls and verification | failed | 0.495 |
| 2026-10-03T20:42:52.009954+00:00 | q29b-sequential-derive12 | derivation, preservation and accounting | pass | 4.323 |
| 2026-10-03T20:42:56.386960+00:00 | q29b-sequential-controls12 | controls and verification | pass | 0.956 |
| 2026-10-03T20:44:04.915212+00:00 | q30-checked13 | other recorded work | pass | 48.799 |
| 2026-10-03T20:45:05.192869+00:00 | q31-bst-sequential-candidate13 | checked acquisition | pass | 12.268 |
| 2026-10-03T20:45:17.552644+00:00 | q31-bst-derive13 | derivation, preservation and accounting | pass | 4.289 |
| 2026-10-03T20:45:21.963312+00:00 | q31-bst-controls13 | controls and verification | pass | 2.078 |
| 2026-10-03T20:45:24.152769+00:00 | q31-sequential-derive13 | derivation, preservation and accounting | pass | 4.186 |
| 2026-10-03T20:45:28.398129+00:00 | q31-sequential-controls13 | controls and verification | pass | 0.873 |
| 2026-10-03T20:45:29.334952+00:00 | q31-hybrid-flat-derive01 | derivation, preservation and accounting | failed | 0.480 |
| 2026-10-03T20:46:35.282776+00:00 | bst13-screen01 | generated-program timing | pass | 16.108 |
| 2026-10-03T20:47:15.404748+00:00 | q32-native-nat-baseline13 | checked acquisition | pass | 6.238 |
| 2026-10-03T20:47:21.740114+00:00 | q32-native-nat-candidate13 | checked acquisition | pass | 6.487 |
| 2026-10-03T20:47:28.291450+00:00 | q32-native-nat-typescript13 | checked acquisition | failed | 0.533 |
| 2026-10-03T20:48:15.547915+00:00 | q32b-hybrid-flat-derive02 | derivation, preservation and accounting | pass | 1.393 |
| 2026-10-03T20:48:17.003963+00:00 | q32b-hybrid-flat-controls02 | controls and verification | pass | 0.463 |
| 2026-10-03T20:48:37.634926+00:00 | q33-native-nat-typescript13-retry01 | checked acquisition | pass | 1.498 |
| 2026-10-03T20:48:59.119066+00:00 | hybrid-flat02-screen01 | generated-program timing | pass | 38.444 |
| 2026-10-03T20:50:37.752814+00:00 | q34-native-nat-derive13 | derivation, preservation and accounting | pass | 4.314 |
| 2026-10-03T20:50:42.173227+00:00 | q34-native-nat-controls13 | controls and verification | pass | 0.265 |
| 2026-10-03T20:52:16.689857+00:00 | q35-bst-catalog13 | checked acquisition | pass | 6.876 |
| 2026-10-03T20:52:23.628626+00:00 | q35-bst-diagnostics13 | other recorded work | pass | 8.944 |
| 2026-10-03T20:53:41.512726+00:00 | q36-native-nat-controls13-v2 | controls and verification | pass | 0.282 |
| 2026-10-03T20:56:06.391351+00:00 | compiler-cost-screen13 | compiler-request sampling | pass | 164.570 |
| 2026-10-03T20:59:08.785520+00:00 | q37-checked14 | other recorded work | pass | 47.278 |
| 2026-10-03T21:00:46.494810+00:00 | q39-checked14-preparation | checked acquisition | pass | 13.402 |
| 2026-10-03T21:00:59.984782+00:00 | q39-hybrid-actual14-derive | compiler-request sampling | pass | 0.671 |
| 2026-10-03T21:01:00.718431+00:00 | q39-hybrid-actual14-controls | controls and verification | pass | 0.496 |
| 2026-10-03T21:01:42.244717+00:00 | hybrid-actual14-screen01 | generated-program timing | pass | 22.703 |
| 2026-10-03T21:02:39.704480+00:00 | q40-layout-actual14 | controls and verification | pass | 2.983 |
| 2026-10-03T21:03:27.892255+00:00 | q38-bst-ablation-derive01 | derivation, preservation and accounting | failed | 0.388 |
| 2026-10-03T21:04:05.680719+00:00 | q41-map-bit-derive01 | derivation, preservation and accounting | pass | 0.222 |
| 2026-10-03T21:04:05.983202+00:00 | q41-map-bit-controls01 | controls and verification | pass | 0.763 |
| 2026-10-03T21:05:13.472940+00:00 | q42-bst-ablation-derive02 | derivation, preservation and accounting | pass | 0.996 |
| 2026-10-03T21:05:14.552650+00:00 | q42-bst-ablation-noise-controls02 | controls and verification | pass | 1.876 |
| 2026-10-03T21:05:16.518595+00:00 | q42-bst-ablation-noise-config02 | controls and verification | pass | 0.162 |
| 2026-10-03T21:05:16.744274+00:00 | q42-bst-ablation-transfer-controls02 | controls and verification | pass | 1.567 |
| 2026-10-03T21:05:18.400357+00:00 | q42-bst-ablation-transfer-config02 | controls and verification | pass | 0.161 |
| 2026-10-03T21:05:18.657335+00:00 | q42-bst-ablation-native-controls02 | controls and verification | pass | 1.675 |
| 2026-10-03T21:05:20.395953+00:00 | q42-bst-ablation-native-config02 | controls and verification | pass | 0.182 |
| 2026-10-03T21:05:20.649557+00:00 | q42-bst-ablation-combined-controls02 | controls and verification | pass | 1.701 |
| 2026-10-03T21:05:22.416196+00:00 | q42-bst-ablation-combined-config02 | controls and verification | pass | 0.205 |
| 2026-10-03T21:07:21.299682+00:00 | q43-bst-all-ablations02-screen01 | generated-program timing | pass | 29.959 |
| 2026-10-03T21:07:51.379066+00:00 | q43-map-bit-screen01 | generated-program timing | pass | 16.945 |
| 2026-10-03T21:13:04.619322+00:00 | q44-checked15 | other recorded work | pass | 43.052 |
| 2026-10-03T21:14:22.418722+00:00 | q45-bst-sequential-candidate15 | checked acquisition | pass | 12.372 |
| 2026-10-03T21:14:34.853538+00:00 | q45-bst-derive15 | derivation, preservation and accounting | pass | 4.288 |
| 2026-10-03T21:14:39.204745+00:00 | q45-bst-controls15 | controls and verification | pass | 2.070 |
| 2026-10-03T21:14:41.371156+00:00 | q45-sequential-derive15 | derivation, preservation and accounting | pass | 4.289 |
| 2026-10-03T21:14:45.723588+00:00 | q45-sequential-controls15 | controls and verification | pass | 0.974 |
| 2026-10-03T21:17:09.870825+00:00 | q46-native-owned-assay15 | other recorded work | pass | 0.505 |
| 2026-10-03T21:17:10.453855+00:00 | q46-bst15-screen01 | generated-program timing | pass | 19.944 |
| 2026-10-03T21:21:19.831505+00:00 | prepare-final01 | other recorded work | pass | 12.172 |
| 2026-10-03T21:23:08.970364+00:00 | q47-checked15-preparation | checked acquisition | pass | 13.319 |
| 2026-10-03T21:26:27.601716+00:00 | q48-hybrid-actual15-derive | compiler-request sampling | pass | 0.793 |
| 2026-10-03T21:26:28.461186+00:00 | q48-hybrid-actual15-controls | controls and verification | pass | 0.365 |
| 2026-10-03T21:26:28.881762+00:00 | q48-layout-actual15 | controls and verification | failed | 2.496 |
| 2026-10-03T21:33:33.656798+00:00 | queue49-layout-actual15-retry01 | controls and verification | pass | 2.978 |
| 2026-10-03T21:37:51.641342+00:00 | prepare-final02 | other recorded work | pass | 12.294 |
| 2026-10-03T21:38:17.869897+00:00 | final02-derive-frontend | controls and verification | pass | 0.055 |
| 2026-10-03T21:38:18.007398+00:00 | final02-derive-current-integration | derivation, preservation and accounting | pass | 0.054 |
| 2026-10-03T21:38:18.121470+00:00 | final02-preflight-counter-cohort | derivation, preservation and accounting | pass | 11.051 |
| 2026-10-03T21:38:29.249621+00:00 | final02-preflight-counter | controls and verification | failed | 0.866 |
| 2026-10-03T21:39:32.259810+00:00 | final02-independent-preflight-fold | controls and verification | pass | 12.655 |
| 2026-10-03T21:39:44.992567+00:00 | final02-independent-preflight-unary-cohort | derivation, preservation and accounting | pass | 11.671 |
| 2026-10-03T21:39:56.739896+00:00 | final02-independent-preflight-unary | controls and verification | pass | 0.888 |
| 2026-10-03T21:39:57.707170+00:00 | final02-independent-prepare-full | checked acquisition | pass | 132.168 |
| 2026-10-03T21:43:54.460813+00:00 | queue50-checked16 | other recorded work | pass | 45.476 |
| 2026-10-03T21:45:20.596521+00:00 | queue51-preflight-counter-cohort | derivation, preservation and accounting | pass | 11.913 |
| 2026-10-03T21:45:32.584483+00:00 | queue51-preflight-counter | controls and verification | pass | 0.583 |
| 2026-10-03T21:45:33.248698+00:00 | queue51-actual-list-emit | checked acquisition | pass | 5.442 |
| 2026-10-03T21:45:38.740087+00:00 | queue51-actual-tree-emit | checked acquisition | pass | 5.616 |
| 2026-10-03T21:46:14.228189+00:00 | queue52-phase42-native-proof | controls and verification | pass | 7.241 |
| 2026-10-03T21:48:27.779631+00:00 | queue53-actual-tree-derive | derivation, preservation and accounting | failed | 2.543 |
| 2026-10-03T21:49:37.415024+00:00 | queue54-prepare-tree16 | checked acquisition | pass | 6.436 |
| 2026-10-03T21:49:43.986777+00:00 | queue54-phase41-tree-derive | derivation, preservation and accounting | pass | 2.374 |
| 2026-10-03T21:49:46.417504+00:00 | queue54-phase41-tree-control | controls and verification | pass | 0.567 |
| 2026-10-03T21:50:21.412320+00:00 | queue55-actual-tree-derive | derivation, preservation and accounting | pass | 2.692 |
| 2026-10-03T21:50:24.168474+00:00 | queue55-actual-tree-control | controls and verification | pass | 1.567 |
| 2026-10-03T21:52:52.689998+00:00 | prepare-final04 | other recorded work | pass | 12.160 |
| 2026-10-03T21:53:22.203587+00:00 | final03-semantic-derive-frontend | controls and verification | pass | 0.048 |
| 2026-10-03T21:53:22.333133+00:00 | final03-semantic-derive-current-integration | derivation, preservation and accounting | pass | 0.051 |
| 2026-10-03T21:53:22.473618+00:00 | final03-semantic-preflight-counter-cohort | derivation, preservation and accounting | pass | 10.995 |
| 2026-10-03T21:53:33.541641+00:00 | final03-semantic-preflight-counter | controls and verification | pass | 0.565 |
| 2026-10-03T21:53:34.206964+00:00 | final03-semantic-preflight-fold | controls and verification | pass | 12.650 |
| 2026-10-03T21:53:46.915861+00:00 | final03-semantic-preflight-unary-cohort | derivation, preservation and accounting | pass | 11.562 |
| 2026-10-03T21:53:58.537716+00:00 | final03-semantic-preflight-unary | controls and verification | pass | 0.885 |
| 2026-10-03T21:53:59.483791+00:00 | final03-semantic-prepare-full | checked acquisition | pass | 130.751 |
| 2026-10-03T21:56:10.309733+00:00 | final03-semantic-prepare-historical-owner | checked acquisition | pass | 18.603 |
| 2026-10-03T21:56:28.995372+00:00 | final03-semantic-freeze-final-plan | derivation, preservation and accounting | pass | 2.509 |
| 2026-10-03T21:56:31.599438+00:00 | final03-semantic-remaining-phase35-owners | other recorded work | pass | 133.077 |
| 2026-10-03T21:58:44.735712+00:00 | final03-semantic-final-counter | controls and verification | pass | 0.584 |
| 2026-10-03T21:58:45.379938+00:00 | final03-semantic-map-current-owners | other recorded work | pass | 0.075 |
| 2026-10-03T21:58:45.515316+00:00 | final03-semantic-close-phase35-owners | other recorded work | pass | 0.063 |
| 2026-10-03T21:58:45.637941+00:00 | final03-semantic-preinstall-nonfrontend | controls and verification | pass | 454.972 |
| 2026-10-03T22:06:20.687493+00:00 | final03-semantic-frontend-main | controls and verification | pass | 415.174 |
| 2026-10-03T22:13:15.967941+00:00 | final03-semantic-frontend-broader | controls and verification | pass | 22.830 |
| 2026-10-03T22:13:38.886827+00:00 | final03-semantic-freeze-phase36 | derivation, preservation and accounting | pass | 0.458 |
| 2026-10-03T22:13:39.471925+00:00 | final03-semantic-run-phase36 | other recorded work | pass | 66.183 |
| 2026-10-03T22:14:45.716071+00:00 | final03-semantic-close-phase36 | other recorded work | pass | 3.501 |
| 2026-10-03T22:14:49.399536+00:00 | final03-semantic-freeze-phase37 | derivation, preservation and accounting | pass | 1.766 |
| 2026-10-03T22:14:51.271355+00:00 | final03-semantic-run-close-phase37 | other recorded work | pass | 44.074 |
| 2026-10-03T22:15:35.435967+00:00 | final03-semantic-inherited-countdown-cohort | other recorded work | pass | 10.664 |
| 2026-10-03T22:15:46.174844+00:00 | final03-semantic-inherited-countdown | controls and verification | pass | 0.682 |
| 2026-10-03T22:15:46.907591+00:00 | final03-semantic-inherited-guard-derive | derivation, preservation and accounting | pass | 2.475 |
| 2026-10-03T22:15:49.441864+00:00 | final03-semantic-inherited-guard | controls and verification | pass | 0.898 |
| 2026-10-03T22:15:50.419044+00:00 | final03-semantic-inherited-component-cohort | other recorded work | pass | 12.215 |
| 2026-10-03T22:16:02.707510+00:00 | final03-semantic-inherited-component-derive | derivation, preservation and accounting | failed | 2.290 |
| 2026-10-03T22:18:03.316171+00:00 | final03-independent-actual-list-emit | checked acquisition | pass | 5.816 |
| 2026-10-03T22:18:09.203758+00:00 | final03-independent-actual-tree-emit | checked acquisition | pass | 5.689 |
| 2026-10-03T22:18:15.015920+00:00 | final03-independent-actual-list-derive | derivation, preservation and accounting | pass | 0.574 |
| 2026-10-03T22:18:15.661354+00:00 | final03-independent-actual-list-control | controls and verification | pass | 0.882 |
| 2026-10-03T22:18:16.603814+00:00 | final03-independent-actual-list-typescript | other recorded work | pass | 0.149 |
| 2026-10-03T22:18:16.805933+00:00 | final03-independent-actual-tree-derive | derivation, preservation and accounting | pass | 2.470 |
| 2026-10-03T22:18:19.327981+00:00 | final03-independent-actual-tree-control | controls and verification | pass | 1.395 |
| 2026-10-03T22:18:20.784526+00:00 | final03-independent-actual-linear-acquire | other recorded work | pass | 12.485 |
| 2026-10-03T22:18:33.344278+00:00 | final03-independent-actual-linear-control | controls and verification | pass | 0.666 |
| 2026-10-03T22:18:34.098402+00:00 | final03-independent-scalar-island-emit | checked acquisition | pass | 7.933 |
| 2026-10-03T22:18:42.111889+00:00 | final03-independent-scalar-island-precedence | controls and verification | failed | 0.156 |
| 2026-10-03T22:20:27.963950+00:00 | final03-independent2-expanded-applications | other recorded work | pass | 8.942 |
| 2026-10-03T22:20:36.978983+00:00 | final03-independent2-phase41-tree-derive | derivation, preservation and accounting | pass | 2.473 |
| 2026-10-03T22:20:39.718677+00:00 | final03-independent2-phase41-tree-control | controls and verification | pass | 0.589 |
| 2026-10-03T22:20:40.433981+00:00 | final03-independent2-phase41-wrapper-emit | checked acquisition | pass | 5.372 |
| 2026-10-03T22:20:45.867726+00:00 | final03-independent2-phase41-wrapper-control | controls and verification | failed | 2.197 |
| 2026-10-03T22:26:56.025209+00:00 | final03-scalar-v2 | controls and verification | pass | 0.448 |
| 2026-10-03T22:27:16.716983+00:00 | final03-independent3-phase42-prepare-fixtures-v4 | checked acquisition | pass | 17.547 |
| 2026-10-03T22:27:34.368018+00:00 | final03-independent3-phase42-calls-derive | derivation, preservation and accounting | pass | 2.469 |
| 2026-10-03T22:27:36.897393+00:00 | final03-independent3-phase42-calls-actual | controls and verification | pass | 0.666 |
| 2026-10-03T22:27:37.628254+00:00 | final03-independent3-phase42-calls-fixture | controls and verification | pass | 2.480 |
| 2026-10-03T22:28:01.360148+00:00 | final03-independent4-phase42-fusion-derive | derivation, preservation and accounting | pass | 0.067 |
| 2026-10-03T22:28:01.497972+00:00 | final03-independent4-phase42-fusion-actual | controls and verification | pass | 0.683 |
| 2026-10-03T22:28:02.262637+00:00 | final03-independent4-phase42-fusion-fixture | controls and verification | pass | 1.205 |
| 2026-10-03T22:28:03.544388+00:00 | final03-independent4-phase42-request-facts | controls and verification | pass | 0.253 |
| 2026-10-03T22:28:03.858147+00:00 | final03-independent4-phase42-layout-actual | controls and verification | pass | 2.671 |
| 2026-10-03T22:28:06.590591+00:00 | final03-independent4-phase42-layout-fixture-baseline-emit | checked acquisition | pass | 5.418 |
| 2026-10-03T22:28:12.089669+00:00 | final03-independent4-phase42-layout-fixture-candidate-emit | checked acquisition | pass | 5.717 |
| 2026-10-03T22:28:17.869864+00:00 | final03-independent4-phase42-layout-fixture | controls and verification | pass | 2.392 |
| 2026-10-03T22:28:20.329737+00:00 | final03-independent4-phase42-layout-context | controls and verification | pass | 5.403 |
| 2026-10-03T22:28:25.793495+00:00 | final03-independent4-phase42-structural-fixtures-prepare | checked acquisition | pass | 11.242 |
| 2026-10-03T22:28:37.096096+00:00 | final03-independent4-phase42-bst-derive | derivation, preservation and accounting | pass | 3.874 |
| 2026-10-03T22:28:41.030558+00:00 | final03-independent4-phase42-bst-control | controls and verification | pass | 2.001 |
| 2026-10-03T22:28:43.092713+00:00 | final03-independent4-phase42-sequential-derive | derivation, preservation and accounting | pass | 4.283 |
| 2026-10-03T22:28:47.436806+00:00 | final03-independent4-phase42-sequential-control | controls and verification | pass | 0.854 |
| 2026-10-03T22:28:48.345437+00:00 | final03-independent4-phase42-native-proof | controls and verification | pass | 4.569 |
| 2026-10-03T22:28:52.989791+00:00 | final03-independent4-phase42-nat-fixture-prepare | checked acquisition | pass | 6.013 |
| 2026-10-03T22:28:59.307584+00:00 | final03-independent4-phase42-nat-derive | derivation, preservation and accounting | pass | 3.882 |
| 2026-10-03T22:29:03.279131+00:00 | final03-independent4-phase42-nat-control | controls and verification | pass | 0.260 |
| 2026-10-03T22:29:03.651224+00:00 | final03-independent4-phase42-hybrid-derive | compiler-request sampling | pass | 0.665 |
| 2026-10-03T22:29:04.416957+00:00 | final03-independent4-phase42-hybrid-control | controls and verification | pass | 0.362 |
| 2026-10-03T22:29:04.830852+00:00 | final03-independent4-phase42-native-owned-assay | other recorded work | pass | 0.482 |
| 2026-10-03T22:29:43.909646+00:00 | final03-cost-prepare-prepare-cost-baseline | checked acquisition | pass | 22.075 |
| 2026-10-03T22:30:06.036941+00:00 | final03-cost-prepare-freeze-cost-plan | compiler-request sampling | pass | 7.252 |
| 2026-10-03T22:30:37.649944+00:00 | final03-compiler-cost | compiler-request sampling | pass | 261.435 |
| 2026-10-03T22:35:32.674421+00:00 | final03-repaired-inherited-component-derive | derivation, preservation and accounting | pass | 2.572 |
| 2026-10-03T22:35:35.341542+00:00 | final03-repaired-inherited-component | controls and verification | pass | 1.694 |
| 2026-10-03T22:35:37.097042+00:00 | final03-repaired-inherited-component-tail | controls and verification | pass | 0.355 |
| 2026-10-03T22:35:37.513338+00:00 | final03-repaired-map-inherited | other recorded work | pass | 0.053 |
| 2026-10-03T22:35:37.671798+00:00 | final03-repaired-close-inherited | other recorded work | failed | 2.134 |
| 2026-10-03T22:36:13.904861+00:00 | final03-repaired-independent-phase41-wrapper-control | controls and verification | pass | 2.594 |
| 2026-10-03T22:36:16.552460+00:00 | final03-repaired-independent-close-phase41 | other recorded work | failed | 0.057 |
| 2026-10-03T22:36:54.000077+00:00 | final03-owned-phase42-owned-derive | derivation, preservation and accounting | pass | 3.984 |
| 2026-10-03T22:36:58.045757+00:00 | final03-owned-phase42-owned-actual | controls and verification | pass | 0.767 |
| 2026-10-03T22:36:58.873907+00:00 | final03-owned-phase42-owned-fixture-derive | derivation, preservation and accounting | pass | 3.882 |
| 2026-10-03T22:37:02.810750+00:00 | final03-owned-phase42-owned-fixture | controls and verification | failed | 0.157 |
| 2026-10-03T22:39:07.425481+00:00 | final03-measurement-bindings | other recorded work | pass | 3.266 |
| 2026-10-03T22:39:26.473346+00:00 | final03-runtime-batch-plan | other recorded work | pass | 0.411 |
| 2026-10-03T22:39:40.736142+00:00 | final03-runtime-plan-runtime-batch1-plan | generated-program timing | pass | 0.515 |
| 2026-10-03T22:39:41.330515+00:00 | final03-runtime-plan-runtime-batch2-plan | generated-program timing | pass | 0.500 |
| 2026-10-03T22:39:41.901082+00:00 | final03-runtime-plan-runtime-batch3-plan | generated-program timing | pass | 0.495 |
| 2026-10-03T22:40:53.771219+00:00 | final03-runtime-runtime-batch1 | generated-program timing | pass | 388.845 |
| 2026-10-03T22:47:45.234213+00:00 | final03-repaired06-close-inherited | other recorded work | pass | 3.835 |
| 2026-10-03T22:47:49.228627+00:00 | final03-repaired06-close-phase41 | other recorded work | pass | 0.065 |
| 2026-10-03T22:47:49.380625+00:00 | final03-repaired06-phase42-owned-fixture-derive | derivation, preservation and accounting | pass | 3.900 |
| 2026-10-03T22:47:53.342732+00:00 | final03-repaired06-phase42-owned-fixture | controls and verification | pass | 0.659 |
| 2026-10-03T22:47:54.063067+00:00 | final03-repaired06-close-phase42 | other recorded work | pass | 0.194 |
| 2026-10-03T22:47:54.310310+00:00 | final03-repaired06-audit-preinstall | controls and verification | pass | 6.069 |
| 2026-10-03T22:48:00.511949+00:00 | final03-repaired06-composite-preinstall | other recorded work | failed | 0.202 |
| 2026-10-03T22:49:37.531423+00:00 | final03-repaired07-composite-preinstall | other recorded work | pass | 0.275 |
| 2026-10-03T22:49:51.435018+00:00 | final03-runtime-runtime-batch2 | generated-program timing | pass | 401.331 |
| 2026-10-03T22:56:32.867018+00:00 | final03-runtime-runtime-batch3 | generated-program timing | pass | 385.068 |
| 2026-10-03T23:03:05.939559+00:00 | final03-runtime-close | other recorded work | pass | 3.945 |
| 2026-10-03T23:03:53.813172+00:00 | final03-results | other recorded work | failed | 0.144 |
| 2026-10-03T23:04:22.861666+00:00 | final03-expression-confirmation | generated-program timing | pass | 23.186 |
| 2026-10-03T23:05:21.120710+00:00 | final03-profile-tree | profiling | pass | 8.583 |
| 2026-10-03T23:05:44.230292+00:00 | final03-results-v2 | other recorded work | pass | 0.189 |
| 2026-10-03T23:06:03.666035+00:00 | final03-profile-list-bst-map | profiling | pass | 28.143 |
| 2026-10-03T23:06:53.102252+00:00 | final03-profile-lexer-ray | profiling | pass | 28.862 |
| 2026-10-03T23:08:08.343282+00:00 | final03-runtime-figure | other recorded work | pass | 0.058 |
| 2026-10-03T23:09:03.011496+00:00 | final03-postinstall-postinstall | other recorded work | pass | 59.259 |
| 2026-10-03T23:10:02.329937+00:00 | final03-postinstall-audit-postinstall | controls and verification | pass | 6.720 |
| 2026-10-03T23:10:09.114452+00:00 | final03-postinstall-composite-postinstall | other recorded work | pass | 0.254 |
| 2026-10-03T23:11:08.907296+00:00 | final03-freeze-current | derivation, preservation and accounting | pass | 2.263 |
| 2026-10-03T23:12:08.475906+00:00 | final03-portable-fast | generated-program timing | pass | 16.591 |
| 2026-10-03T23:12:25.142862+00:00 | final03-portable-targets | generated-program timing | pass | 9.968 |

All module identities and complete job commands are retained in report.json.
