# Expanded generated-program results

45/45 frozen points; 669 samples across 4 separate paired runs.

Execution includes exact output/checksum work. Source acquisition, compilation and profiling are separate. Ratios use the same-run TypeScript and Phase36 observations for each point. Ranges describe observed samples, not confidence intervals. No ratio average is reported.

| Point | Phase36 ms | Candidate ms | TS ms | Phase36 / candidate | Candidate / TS | Range relation |
|---|---:|---:|---:|---:|---:|---|
| mandelbrot | 0.191728 | 0.190756 | 0.045523 | 1.005× | 4.190× | overlap |
| editdist | 10.5297 | 10.5222 | 4.97321 | 1.001× | 2.116× | overlap |
| tree-bitonic | 19.5728 | 16.0265 | 0.280593 | 1.221× | 57.117× | candidate-faster-disjoint |
| lexer | 152.947 | 151.048 | 1.67287 | 1.013× | 90.293× | overlap |
| symreg | 3.87947 | 3.94271 | 1.10245 | 0.984× | 3.576× | candidate-slower-disjoint |
| test-morning-program | 0.199646 | 0.199656 | 0.00327285 | 1.000× | 61.004× | overlap |
| test-evening-program | 0.12869 | 0.128857 | 0.0025928 | 0.999× | 49.698× | overlap |
| test-rle-roundtrip | 0.0375318 | 0.0383422 | 0.000565612 | 0.979× | 67.789× | overlap |
| test-map-set-ops | 1.52129 | 1.49921 | 0.0211884 | 1.015× | 70.756× | overlap |
| raytrace | 717.943 | 693.194 | 34.3243 | 1.036× | 20.195× | overlap |
| local-pair | 2.64397 | 2.65273 | 1.23856 | 0.997× | 2.142× | overlap |
| local-fold | 0.092931 | 0.0893121 | 0.039563 | 1.041× | 2.257× | overlap |
| scalar-region-0 | 0.00376374 | 0.00379889 | 6.8918e-05 | 0.991× | 55.122× | overlap |
| scalar-region-8192 | 0.154784 | 0.139629 | 0.0997042 | 1.109× | 1.400× | overlap |
| complete-generic-row32 | 0.402784 | 0.430625 | 0.00740991 | 0.935× | 58.115× | overlap |
| variation-editdist-0-17 | 2.63523 | 2.65385 | 1.23903 | 0.993× | 2.142× | overlap |
| variation-editdist-3-123 | 20.9802 | 20.9198 | 9.92417 | 1.003× | 2.108× | overlap |
| variation-lexer-6-17 | 36.0373 | 36.6788 | 0.403815 | 0.983× | 90.831× | candidate-slower-disjoint |
| variation-lexer-10-123 | 546.504 | 537.676 | 6.67379 | 1.016× | 80.565× | overlap |
| variation-tree-bitonic-6-17 | 2.7728 | 2.37967 | 0.0379486 | 1.165× | 62.708× | candidate-faster-disjoint |
| variation-tree-bitonic-9-123 | 58.3332 | 45.931 | 0.708883 | 1.270× | 64.794× | candidate-faster-disjoint |
| variation-symreg-4-17 | 1.89974 | 1.91887 | 0.550977 | 0.990× | 3.483× | overlap |
| variation-symreg-7-123 | 6.57737 | 6.69147 | 1.86698 | 0.983× | 3.584× | overlap |
| variation-local-fold-128-0 | 0.00737373 | 0.00724558 | 0.00143094 | 1.018× | 5.064× | overlap |
| variation-local-fold-8192-123 | 0.176144 | 0.174034 | 0.115356 | 1.012× | 1.509× | overlap |
| variation-mandelbrot-grid-4-7 | 0.0507463 | 0.0508755 | 0.0152266 | 0.997× | 3.341× | overlap |
| variation-mandelbrot-grid-5-31 | 0.552889 | 0.555294 | 0.232141 | 0.996× | 2.392× | overlap |
| variation-ray-active-64-2440 | 25.9419 | 26.3763 | 0.300693 | 0.984× | 87.718× | overlap |
| variation-ray-active-256-2240 | 85.816 | 88.8849 | 1.2416 | 0.965× | 71.589× | candidate-slower-disjoint |
| coverage-closures-64 | 0.0468916 | 0.0458693 | 0.00591886 | 1.022× | 7.750× | overlap |
| coverage-closures-256 | 0.181307 | 0.187016 | 0.0224458 | 0.969× | 8.332× | overlap |
| coverage-list-pipeline-128 | 0.314221 | 0.318237 | 0.00649513 | 0.987× | 48.996× | overlap |
| coverage-list-pipeline-512 | 1.22934 | 1.28651 | 0.0289595 | 0.956× | 44.424× | candidate-slower-disjoint |
| coverage-bst-32 | 3.32582 | 3.29368 | 0.0217125 | 1.010× | 151.695× | overlap |
| coverage-bst-64 | 9.93314 | 10.3247 | 0.0493282 | 0.962× | 209.305× | overlap |
| coverage-unicode-text-16 | 0.471497 | 0.463938 | 0.021631 | 1.016× | 21.448× | overlap |
| coverage-unicode-text-64 | 2.01044 | 1.97376 | 0.0867979 | 1.019× | 22.740× | candidate-faster-disjoint |
| coverage-expression-32 | 0.0945855 | 0.0879064 | 0.00205852 | 1.076× | 42.704× | overlap |
| coverage-expression-128 | 0.346876 | 0.361951 | 0.00869139 | 0.958× | 41.645× | overlap |
| coverage-map-churn-32 | 15.0336 | 14.9798 | 0.141936 | 1.004× | 105.539× | overlap |
| coverage-map-churn-128 | 77.4642 | 77.5355 | 0.850268 | 0.999× | 91.190× | overlap |
| coverage-numeric-recurrence-256 | 0.03973 | 0.0148559 | 0.00201243 | 2.674× | 7.382× | candidate-faster-disjoint |
| coverage-numeric-recurrence-1024 | 0.131576 | 0.0254735 | 0.00763217 | 5.165× | 3.338× | candidate-faster-disjoint |
| coverage-record-aggregation-64 | 20.963 | 21.0342 | 0.293397 | 0.997× | 71.692× | overlap |
| coverage-record-aggregation-256 | 78.3074 | 77.4715 | 1.29392 | 1.011× | 59.874× | overlap |

## Protocols and uncertainty

- `/home/ai/bend2/build/publish/bend/selfhost/build/phase37/historical-final01/report.json`: 15 points / 219 samples; 385.774s process wall; 5 requested rounds, 1000ms warmup, 300ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase37/variation-final01/report.json`: 14 points / 210 samples; 375.127s process wall; 5 requested rounds, 1000ms warmup, 300ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase37/development-final01/report.json`: 10 points / 150 samples; 184.693s process wall; 5 requested rounds, 600ms warmup, 250ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase37/holdout-final01/report.json`: 6 points / 90 samples; 110.727s process wall; 5 requested rounds, 600ms warmup, 250ms sample target. The historical ray case retains its special maximum-three-round policy.

Per-role ranges and every half-drift observation are retained in report.json. Inspect those before describing a gain as stable. The sum of separate run wall times is a workflow cost, not a runtime denominator or a promise that the entire catalog fits one preset.
