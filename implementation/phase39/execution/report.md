# Expanded generated-program results

45/45 frozen points; 729 samples across 5 separate paired runs.

Execution includes exact output/checksum work. Source acquisition, compilation and profiling are separate. Ratios use the same-run TypeScript and installed Phase37 observations for each point. Ranges describe observed samples, not confidence intervals. No ratio average is reported.

| Point | Phase37 ms [min–max] | Candidate ms [min–max] | TS ms [min–max] | Gain | Candidate / TS | Paired wins | Bytes Δ | Range relation |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| mandelbrot | 0.208732 [0.204164–0.226774] | 0.200314 [0.199882–0.202456] | 0.0455036 [0.0453355–0.0460291] | 1.042× | 4.402× | 5/5 | +215 | candidate-faster-disjoint |
| editdist | 15.0853 [14.9882–15.1832] | 15.0386 [14.968–15.0921] | 4.99055 [4.98417–5.13484] | 1.003× | 3.013× | 3/5 | +188 | overlap |
| tree-bitonic | 18.3023 [18.2662–18.3919] | 10.2073 [10.0934–10.4466] | 0.277365 [0.274352–0.309365] | 1.793× | 36.801× | 5/5 | +7010 | candidate-faster-disjoint |
| lexer | 173.239 [173.075–191.392] | 171.057 [169.542–172.352] | 1.9157 [1.91106–1.92218] | 1.013× | 89.292× | 5/5 | +0 | candidate-faster-disjoint |
| symreg | 4.29985 [4.24374–4.77831] | 2.42968 [2.40753–2.67668] | 1.10412 [1.10178–1.10866] | 1.770× | 2.201× | 5/5 | +186 | candidate-faster-disjoint |
| test-morning-program | 0.234717 [0.231425–0.243227] | 0.229666 [0.2283–0.23266] | 0.00367834 [0.00363192–0.00382191] | 1.022× | 62.437× | 5/5 | +0 | overlap |
| test-evening-program | 0.245436 [0.160373–0.250402] | 0.163511 [0.156469–0.229768] | 0.00301458 [0.00297494–0.00358161] | 1.501× | 54.240× | 4/5 | +0 | overlap |
| test-rle-roundtrip | 0.0456917 [0.0451115–0.0525486] | 0.0466309 [0.0456312–0.0526571] | 0.00061376 [0.000575281–0.000667993] | 0.980× | 75.976× | 2/5 | +0 | overlap |
| test-map-set-ops | 1.67075 [1.60029–2.12312] | 1.84281 [1.65054–2.15375] | 0.0228038 [0.02234–0.0245527] | 0.907× | 80.812× | 2/5 | +0 | overlap |
| raytrace | 784.125 [776.901–861.151] | 778.364 [770.702–781.695] | 34.1557 [34.1048–34.3904] | 1.007× | 22.789× | 2/3 | +0 | overlap |
| local-pair | 3.78512 [3.76168–3.81193] | 3.77893 [3.75463–4.0928] | 1.24152 [1.23448–1.34719] | 1.002× | 3.044× | 2/5 | +188 | overlap |
| local-fold | 0.139054 [0.138867–0.150526] | 0.138971 [0.138762–0.13929] | 0.0409713 [0.0400839–0.0442262] | 1.001× | 3.392× | 4/5 | +0 | overlap |
| scalar-region-0 | 0.00467463 [0.00457679–0.00493039] | 0.00478317 [0.00474017–0.0052319] | 9.24798e-05 [9.18305e-05–9.46103e-05] | 0.977× | 51.721× | 1/5 | +121 | overlap |
| scalar-region-8192 | 0.141353 [0.140659–0.156815] | 0.117468 [0.116119–0.128806] | 0.100024 [0.0993323–0.110719] | 1.203× | 1.174× | 5/5 | +121 | candidate-faster-disjoint |
| complete-generic-row32 | 0.449211 [0.4469–0.451503] | 0.453551 [0.453118–0.461048] | 0.00855911 [0.00814192–0.00947224] | 0.990× | 52.990× | 0/5 | +188 | candidate-slower-disjoint |
| variation-editdist-0-17 | 3.77737 [3.76163–4.11219] | 3.77759 [3.74428–4.09097] | 1.24082 [1.23363–1.36138] | 1.000× | 3.044× | 3/5 | +188 | overlap |
| variation-editdist-3-123 | 30.3176 [29.8515–32.4049] | 30.084 [30.0039–32.5914] | 9.9795 [9.90966–10.9461] | 1.008× | 3.015× | 2/5 | +188 | overlap |
| variation-lexer-6-17 | 41.366 [41.2125–41.5034] | 41.8506 [41.736–42.1985] | 0.469539 [0.467656–0.470743] | 0.988× | 89.131× | 0/5 | +0 | candidate-slower-disjoint |
| variation-lexer-10-123 | 641.724 [639.418–719.809] | 644.048 [638.538–719.18] | 7.62648 [7.59214–7.73519] | 0.996× | 84.449× | 3/5 | +0 | overlap |
| variation-tree-bitonic-6-17 | 2.86865 [2.8651–2.90995] | 1.62926 [1.61719–1.64598] | 0.0370263 [0.0368647–0.038286] | 1.761× | 44.003× | 5/5 | +7010 | candidate-faster-disjoint |
| variation-tree-bitonic-9-123 | 50.0104 [49.7905–51.0186] | 22.2058 [22.0266–22.3375] | 0.697282 [0.696444–0.711539] | 2.252× | 31.846× | 5/5 | +7010 | candidate-faster-disjoint |
| variation-symreg-4-17 | 2.07008 [2.06124–2.1223] | 1.18151 [1.17723–1.18912] | 0.552123 [0.55118–0.556563] | 1.752× | 2.140× | 5/5 | +186 | candidate-faster-disjoint |
| variation-symreg-7-123 | 7.36992 [7.2909–8.0969] | 4.0298 [3.99548–4.0576] | 1.87598 [1.86371–1.88196] | 1.829× | 2.148× | 5/5 | +186 | candidate-faster-disjoint |
| variation-local-fold-128-0 | 0.0104941 [0.010156–0.0115297] | 0.0105776 [0.0101364–0.0115832] | 0.00185035 [0.001841–0.00212132] | 0.992× | 5.717× | 3/5 | +0 | overlap |
| variation-local-fold-8192-123 | 0.275264 [0.27298–0.307941] | 0.294047 [0.274592–0.296911] | 0.124107 [0.117991–0.140792] | 0.936× | 2.369× | 3/5 | +0 | overlap |
| variation-mandelbrot-grid-4-7 | 0.0544734 [0.0538359–0.0585829] | 0.0539367 [0.0469109–0.054671] | 0.0159345 [0.0157876–0.0177284] | 1.010× | 3.385× | 4/5 | +383 | overlap |
| variation-mandelbrot-grid-5-31 | 0.576023 [0.568516–0.663885] | 0.444701 [0.437992–0.484984] | 0.232463 [0.232289–0.254636] | 1.295× | 1.913× | 5/5 | +383 | candidate-faster-disjoint |
| variation-ray-active-64-2440 | 29.2307 [28.9893–34.7567] | 10.1942 [9.91436–12.5145] | 0.302925 [0.3019–0.341839] | 2.867× | 33.653× | 5/5 | +167 | candidate-faster-disjoint |
| variation-ray-active-256-2240 | 101.304 [99.3423–110.755] | 38.7067 [37.7498–51.3659] | 1.24752 [1.2454–1.39877] | 2.617× | 31.027× | 5/5 | +167 | candidate-faster-disjoint |
| coverage-closures-64 | 0.0576999 [0.0567486–0.0658445] | 0.05796 [0.0567912–0.0657906] | 0.00686531 [0.00658834–0.00712804] | 0.996× | 8.442× | 2/5 | +0 | overlap |
| coverage-closures-256 | 0.224182 [0.222317–0.227095] | 0.225928 [0.222521–0.22924] | 0.0260521 [0.0258081–0.026792] | 0.992× | 8.672× | 0/5 | +0 | overlap |
| coverage-list-pipeline-128 | 0.444675 [0.440712–0.446593] | 0.448839 [0.447712–0.450769] | 0.00712104 [0.00704416–0.00719408] | 0.991× | 63.030× | 0/5 | +0 | candidate-slower-disjoint |
| coverage-list-pipeline-512 | 1.65699 [1.64773–1.66989] | 1.63876 [1.62905–1.65531] | 0.029274 [0.0291307–0.0296411] | 1.011× | 55.980× | 5/5 | +0 | overlap |
| coverage-bst-32 | 4.22113 [4.19292–4.68237] | 4.06827 [4.03853–4.08375] | 0.022244 [0.0217633–0.0222821] | 1.038× | 182.893× | 5/5 | +0 | candidate-faster-disjoint |
| coverage-bst-64 | 11.393 [11.3108–17.6029] | 11.3795 [11.1816–12.7741] | 0.0510231 [0.0503956–0.0538134] | 1.001× | 223.027× | 4/5 | +0 | overlap |
| coverage-unicode-text-16 | 0.619589 [0.616534–0.624864] | 0.612538 [0.588672–0.618171] | 0.0277172 [0.02745–0.0277893] | 1.012× | 22.100× | 5/5 | +0 | overlap |
| coverage-unicode-text-64 | 2.59566 [2.5344–3.05644] | 2.55802 [2.53912–2.59021] | 0.119756 [0.119014–0.13038] | 1.015× | 21.360× | 3/5 | +0 | overlap |
| coverage-expression-32 | 0.105447 [0.104402–0.11769] | 0.0236367 [0.0213332–0.0240108] | 0.00225859 [0.00210578–0.00239623] | 4.461× | 10.465× | 5/5 | +1037 | candidate-faster-disjoint |
| coverage-expression-128 | 0.391518 [0.385809–0.430375] | 0.0486259 [0.0477648–0.0531515] | 0.00928168 [0.00886279–0.0100218] | 8.052× | 5.239× | 5/5 | +1037 | candidate-faster-disjoint |
| coverage-map-churn-32 | 17.3278 [17.271–17.5887] | 17.3343 [17.2645–17.4793] | 0.168832 [0.168661–0.171349] | 1.000× | 102.672× | 1/5 | +0 | overlap |
| coverage-map-churn-128 | 88.4444 [88.4131–95.7265] | 88.3094 [88.1226–88.9855] | 0.918964 [0.914604–0.928694] | 1.002× | 96.097× | 4/5 | +0 | overlap |
| coverage-numeric-recurrence-256 | 0.0167844 [0.0164211–0.0170959] | 0.0157162 [0.015091–0.0161509] | 0.00209084 [0.00201836–0.00209765] | 1.068× | 7.517× | 5/5 | +74 | candidate-faster-disjoint |
| coverage-numeric-recurrence-1024 | 0.027083 [0.0270537–0.0305937] | 0.0221811 [0.022065–0.0247367] | 0.00793755 [0.0076671–0.00801681] | 1.221× | 2.794× | 5/5 | +74 | candidate-faster-disjoint |
| coverage-record-aggregation-64 | 25.4248 [22.9988–30.6155] | 27.115 [23.23–30.1414] | 0.361883 [0.359826–0.395946] | 0.938× | 74.927× | 3/5 | +0 | overlap |
| coverage-record-aggregation-256 | 94.1941 [93.5079–103.035] | 94.255 [93.377–102.791] | 1.59475 [1.56039–1.78616] | 0.999× | 59.103× | 2/5 | +0 | overlap |

## Explicit confirmations (not pooled)

| Point | Report | Gain | Candidate / TS | Paired wins | Candidate change | Range relation |
|---|---|---:|---:|---:|---:|---|
| complete-generic-row32 | `final-canary-confirm01` | 0.984× | 54.320× | 0/5 | +1.66% | overlap |
| test-map-set-ops | `final-canary-confirm01` | 0.987× | 74.583× | 1/5 | +1.30% | overlap |
| variation-local-fold-8192-123 | `final-canary-confirm01` | 1.071× | 2.215× | 3/5 | -6.62% | overlap |
| variation-lexer-6-17 | `final-canary-confirm01` | 0.979× | 89.931× | 2/5 | +2.15% | overlap |

## Half-run drift (all observed samples)

| Point | Role | Drift percentages |
|---|---|---|
| mandelbrot | baseline | +0.52, -1.65, -0.38, -1.26, -0.64 |
| mandelbrot | candidate | +0.73, +0.39, +0.38, +1.50, +2.23 |
| mandelbrot | typescript | +1.32, -0.57, -0.72, -0.11, -0.62 |
| editdist | baseline | -0.95, +0.66, +0.72, +0.31, +0.88 |
| editdist | candidate | +0.41, +0.51, +0.39, -0.87, +0.10 |
| editdist | typescript | -0.71, +1.72, +4.10, +0.49, +0.13 |
| tree-bitonic | baseline | +1.39, -1.19, +0.11, -0.74, -0.31 |
| tree-bitonic | candidate | -15.63, -13.71, -13.49, -12.27, -14.81 |
| tree-bitonic | typescript | -2.36, -2.13, -1.98, -2.44, +0.58 |
| lexer | baseline | -6.74, -8.03, -6.86, -2.67, +5.21 |
| lexer | candidate | -7.68, -6.20, -8.54, +7.81, +7.53 |
| lexer | typescript | -0.36, +0.18, +0.17, +0.11, +0.62 |
| symreg | baseline | -10.95, +0.99, +0.70, -1.85, -0.06 |
| symreg | candidate | -2.01, +6.04, -2.65, -1.05, -1.61 |
| symreg | typescript | -0.63, +0.66, -0.22, -1.07, -0.32 |
| test-morning-program | baseline | +39.21, +41.05, +41.13, +45.32, +45.94 |
| test-morning-program | candidate | +36.77, +37.36, +39.36, +36.99, +37.79 |
| test-morning-program | typescript | -6.34, -6.78, +0.59, -5.98, +1.59 |
| test-evening-program | baseline | -59.88, -3.63, -16.37, -47.03, -45.66 |
| test-evening-program | candidate | -15.78, -20.80, -14.85, -13.07, -32.86 |
| test-evening-program | typescript | +0.58, -12.46, -0.42, -0.96, -0.32 |
| test-rle-roundtrip | baseline | +4.17, +7.26, -0.88, -0.58, -0.74 |
| test-rle-roundtrip | candidate | +0.41, +3.71, -2.70, -0.84, -0.93 |
| test-rle-roundtrip | typescript | -3.56, -8.43, -7.14, +0.35, +0.68 |
| test-map-set-ops | baseline | +1.57, -24.34, +8.96, -27.62, +4.90 |
| test-map-set-ops | candidate | +1.40, -27.20, -26.26, -25.75, +2.92 |
| test-map-set-ops | typescript | -0.29, +0.53, -1.82, -1.62, -1.20 |
| raytrace | baseline | missing, missing, missing |
| raytrace | candidate | missing, missing, missing |
| raytrace | typescript | +0.35, -0.36, +0.07 |
| local-pair | baseline | -0.04, -0.35, -0.06, +0.33, -1.41 |
| local-pair | candidate | -0.40, -0.65, +0.04, -0.08, -0.68 |
| local-pair | typescript | +0.12, -0.50, -0.14, -2.31, -0.52 |
| local-fold | baseline | +0.34, -1.06, -0.29, -2.97, +0.83 |
| local-fold | candidate | -0.40, -0.00, -0.69, +0.24, -0.02 |
| local-fold | typescript | -0.14, -1.37, -0.11, -4.16, -1.78 |
| scalar-region-0 | baseline | -0.34, -5.11, -0.73, +0.40, -0.71 |
| scalar-region-0 | candidate | -6.61, -5.78, -5.59, -3.36, -7.34 |
| scalar-region-0 | typescript | -0.21, +0.63, -0.88, +0.02, -0.12 |
| scalar-region-8192 | baseline | -0.04, +0.48, +0.41, -3.04, -0.04 |
| scalar-region-8192 | candidate | -0.62, -7.53, -6.37, +7.54, -0.77 |
| scalar-region-8192 | typescript | -0.94, -0.53, -0.12, -3.53, -1.55 |
| complete-generic-row32 | baseline | +0.86, +1.08, +1.05, +2.07, +2.02 |
| complete-generic-row32 | candidate | +0.78, +0.67, +1.76, +1.29, +0.97 |
| complete-generic-row32 | typescript | -6.34, -6.55, +0.34, -7.94, -2.82 |
| variation-editdist-0-17 | baseline | -0.76, -1.38, +0.02, -0.26, +0.53 |
| variation-editdist-0-17 | candidate | -0.13, -0.15, -0.39, +0.09, +0.43 |
| variation-editdist-0-17 | typescript | -0.06, -0.28, -0.19, +2.05, -0.67 |
| variation-editdist-3-123 | baseline | -0.06, +5.67, -0.57, +0.58, -1.11 |
| variation-editdist-3-123 | candidate | -0.02, +0.12, -0.05, -0.65, -0.82 |
| variation-editdist-3-123 | typescript | +0.35, -0.63, +0.48, -1.14, -0.37 |
| variation-lexer-6-17 | baseline | +0.37, -0.02, +0.38, +0.70, +0.69 |
| variation-lexer-6-17 | candidate | +1.65, +0.83, +1.39, -0.53, +0.70 |
| variation-lexer-6-17 | typescript | +0.57, -0.02, -0.04, +0.15, +0.17 |
| variation-lexer-10-123 | baseline | missing, missing, missing, missing, missing |
| variation-lexer-10-123 | candidate | missing, missing, missing, missing, missing |
| variation-lexer-10-123 | typescript | -0.17, -0.66, +0.66, +0.96, +0.06 |
| variation-tree-bitonic-6-17 | baseline | +0.39, -0.50, +0.72, -1.43, +1.21 |
| variation-tree-bitonic-6-17 | candidate | -1.03, +0.45, +0.04, -0.32, +0.50 |
| variation-tree-bitonic-6-17 | typescript | -1.61, -2.74, -1.60, -1.96, -2.19 |
| variation-tree-bitonic-9-123 | baseline | +20.54, +22.47, +21.42, +22.19, +22.25 |
| variation-tree-bitonic-9-123 | candidate | -0.38, -1.76, -0.60, -0.94, -1.58 |
| variation-tree-bitonic-9-123 | typescript | +3.40, +4.38, +4.38, +4.68, +4.39 |
| variation-symreg-4-17 | baseline | -7.49, -1.45, -2.88, -2.03, -0.99 |
| variation-symreg-4-17 | candidate | -9.32, -9.28, -9.83, -8.61, -8.56 |
| variation-symreg-4-17 | typescript | -0.83, -0.23, -0.05, -0.04, -1.48 |
| variation-symreg-7-123 | baseline | +1.30, +1.02, -4.14, +1.10, +1.46 |
| variation-symreg-7-123 | candidate | -1.04, +0.74, -0.01, +0.03, -0.27 |
| variation-symreg-7-123 | typescript | +0.16, -1.54, +0.85, -1.15, -1.88 |
| variation-local-fold-128-0 | baseline | -6.17, -0.12, -9.44, -2.68, -5.72 |
| variation-local-fold-128-0 | candidate | -4.91, -0.26, -7.44, +0.03, -7.04 |
| variation-local-fold-128-0 | typescript | -4.03, -4.91, +2.46, -14.59, -4.33 |
| variation-local-fold-8192-123 | baseline | +0.31, +0.16, +0.54, -0.83, -0.02 |
| variation-local-fold-8192-123 | candidate | -2.12, -2.02, -0.14, -1.02, +3.62 |
| variation-local-fold-8192-123 | typescript | +3.14, -5.00, +6.29, -10.54, -0.22 |
| variation-mandelbrot-grid-4-7 | baseline | +0.08, +4.49, +0.41, +0.56, +4.84 |
| variation-mandelbrot-grid-4-7 | candidate | +1.98, -0.88, +7.18, -0.49, +6.80 |
| variation-mandelbrot-grid-4-7 | typescript | +5.01, +4.32, +4.49, +4.66, +0.38 |
| variation-mandelbrot-grid-5-31 | baseline | -0.25, -0.74, -11.21, -0.72, -11.15 |
| variation-mandelbrot-grid-5-31 | candidate | -2.66, +1.94, -1.74, +0.18, -0.09 |
| variation-mandelbrot-grid-5-31 | typescript | -1.36, +0.28, +1.21, -0.84, -0.59 |
| variation-ray-active-64-2440 | baseline | -33.54, -39.63, +50.76, -34.25, -33.75 |
| variation-ray-active-64-2440 | candidate | -20.01, -15.33, +45.52, -14.24, +15.11 |
| variation-ray-active-64-2440 | typescript | -0.03, -0.43, +3.75, +0.70, +0.01 |
| variation-ray-active-256-2240 | baseline | +6.27, +4.45, -8.65, +6.38, +6.99 |
| variation-ray-active-256-2240 | candidate | -2.83, -2.79, -4.63, -5.55, -27.49 |
| variation-ray-active-256-2240 | typescript | -0.46, -1.17, -3.56, -0.05, +0.10 |
| coverage-closures-64 | baseline | -0.83, -1.31, -8.67, -0.94, -0.96 |
| coverage-closures-64 | candidate | -0.21, +0.21, -4.86, +0.30, -0.86 |
| coverage-closures-64 | typescript | -0.03, -0.36, +0.36, -7.42, -7.75 |
| coverage-closures-256 | baseline | +0.26, +0.41, -0.18, +1.76, +0.19 |
| coverage-closures-256 | candidate | +0.56, +0.24, -0.35, +1.00, +0.88 |
| coverage-closures-256 | typescript | -0.58, -6.53, -0.72, -0.80, -0.15 |
| coverage-list-pipeline-128 | baseline | +12.15, +11.24, +12.71, +11.22, +10.57 |
| coverage-list-pipeline-128 | candidate | +11.96, +12.44, +11.05, +12.20, +11.85 |
| coverage-list-pipeline-128 | typescript | -9.29, -9.95, -9.83, -9.99, -9.21 |
| coverage-list-pipeline-512 | baseline | -1.63, -2.75, -1.76, -1.29, -1.61 |
| coverage-list-pipeline-512 | candidate | -1.15, -1.72, -1.22, -0.66, -1.99 |
| coverage-list-pipeline-512 | typescript | -0.16, -0.35, -0.17, -1.03, -0.08 |
| coverage-bst-32 | baseline | -4.36, -3.98, -7.43, -3.77, -4.04 |
| coverage-bst-32 | candidate | +5.25, -4.12, -4.39, -4.09, -3.29 |
| coverage-bst-32 | typescript | +0.36, +1.09, +2.39, +1.06, +0.22 |
| coverage-bst-64 | baseline | +1.71, +0.13, -17.83, +0.75, -1.05 |
| coverage-bst-64 | candidate | +0.16, +2.11, -1.37, -1.23, +0.29 |
| coverage-bst-64 | typescript | +3.57, +3.05, +2.01, +3.23, +3.63 |
| coverage-unicode-text-16 | baseline | -8.55, -7.78, -7.98, -7.53, -7.60 |
| coverage-unicode-text-16 | candidate | -7.62, -6.60, -2.11, -0.98, -6.59 |
| coverage-unicode-text-16 | typescript | -0.86, -0.09, -0.64, +1.52, +0.04 |
| coverage-unicode-text-64 | baseline | +2.28, -0.32, -14.29, -1.59, -0.14 |
| coverage-unicode-text-64 | candidate | +1.87, -0.13, +0.89, +1.27, +0.30 |
| coverage-unicode-text-64 | typescript | -0.35, -0.62, -0.31, -0.03, -1.53 |
| coverage-expression-32 | baseline | +0.67, -0.49, -1.96, -0.22, -0.71 |
| coverage-expression-32 | candidate | -0.20, -0.40, +1.18, -0.60, +2.02 |
| coverage-expression-32 | typescript | +0.33, -11.00, -1.66, +0.71, -8.54 |
| coverage-expression-128 | baseline | -0.02, +0.20, +0.41, +0.14, +0.52 |
| coverage-expression-128 | candidate | +1.04, +9.65, +3.09, -1.53, -0.98 |
| coverage-expression-128 | typescript | -10.34, -7.54, -10.13, -7.36, +0.90 |
| coverage-map-churn-32 | baseline | +6.38, +1.95, +6.39, +6.57, +6.14 |
| coverage-map-churn-32 | candidate | +4.45, +4.69, +5.74, +5.95, +6.74 |
| coverage-map-churn-32 | typescript | +0.02, -0.82, +1.22, +0.05, -0.32 |
| coverage-map-churn-128 | baseline | +1.59, +13.07, +2.03, +1.24, +1.09 |
| coverage-map-churn-128 | candidate | +1.48, +1.07, -0.63, +1.72, +0.15 |
| coverage-map-churn-128 | typescript | -3.66, -2.80, -2.41, -2.53, -2.95 |
| coverage-numeric-recurrence-256 | baseline | -2.70, +4.56, -0.62, +5.38, -1.97 |
| coverage-numeric-recurrence-256 | candidate | +6.75, +5.03, +4.82, -0.53, +5.55 |
| coverage-numeric-recurrence-256 | typescript | -3.63, -7.84, -0.86, -7.11, -7.58 |
| coverage-numeric-recurrence-1024 | baseline | -1.04, -1.00, -1.55, -1.93, +0.06 |
| coverage-numeric-recurrence-1024 | candidate | -1.19, -0.31, -0.56, -0.34, -1.45 |
| coverage-numeric-recurrence-1024 | typescript | -7.71, +0.01, -7.45, +0.05, -7.46 |
| coverage-record-aggregation-64 | baseline | -10.62, -19.27, -20.96, +4.08, +5.32 |
| coverage-record-aggregation-64 | candidate | +4.36, -19.62, -18.19, +3.55, -19.16 |
| coverage-record-aggregation-64 | typescript | -0.19, -0.75, +0.23, -0.46, +0.18 |
| coverage-record-aggregation-256 | baseline | -11.92, -13.16, -15.45, -12.76, -12.87 |
| coverage-record-aggregation-256 | candidate | -12.42, -11.63, -9.70, -12.30, -12.44 |
| coverage-record-aggregation-256 | typescript | -12.95, -12.82, +18.88, -12.08, -11.57 |
| complete-generic-row32 (confirmation: final-canary-confirm01) | baseline | -0.05, +1.71, +0.84, +0.20, +1.34 |
| complete-generic-row32 (confirmation: final-canary-confirm01) | candidate | +1.19, +0.18, +0.05, +0.32, -0.37 |
| complete-generic-row32 (confirmation: final-canary-confirm01) | typescript | -5.97, -7.10, +0.37, -6.51, -6.89 |
| test-map-set-ops (confirmation: final-canary-confirm01) | baseline | -25.84, +10.77, +0.64, +10.01, +5.81 |
| test-map-set-ops (confirmation: final-canary-confirm01) | candidate | -29.54, +8.71, +4.74, +2.75, +7.97 |
| test-map-set-ops (confirmation: final-canary-confirm01) | typescript | -2.37, +0.29, +0.01, -1.75, -1.64 |
| variation-local-fold-8192-123 (confirmation: final-canary-confirm01) | baseline | -2.62, -2.29, -0.16, +4.36, +0.66 |
| variation-local-fold-8192-123 (confirmation: final-canary-confirm01) | candidate | -0.52, -0.16, -0.17, -0.37, +0.41 |
| variation-local-fold-8192-123 (confirmation: final-canary-confirm01) | typescript | +0.44, -10.91, -3.27, -2.12, -0.42 |
| variation-lexer-6-17 (confirmation: final-canary-confirm01) | baseline | +4.86, +0.69, -3.19, +0.02, +0.41 |
| variation-lexer-6-17 (confirmation: final-canary-confirm01) | candidate | +0.95, +0.89, +0.27, +0.60, +2.41 |
| variation-lexer-6-17 (confirmation: final-canary-confirm01) | typescript | -0.71, -0.64, -1.93, -2.54, +0.13 |

## Protocols and uncertainty

- `/home/ai/bend2/build/publish/bend/selfhost/build/phase39/final-historical01/report.json`: 15 points / 219 samples; 391.506s process wall; 5 requested rounds, 1000ms warmup, 300ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase39/final-variation01/report.json`: 14 points / 210 samples; 386.839s process wall; 5 requested rounds, 1000ms warmup, 300ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase39/final-development01/report.json`: 10 points / 150 samples; 183.761s process wall; 5 requested rounds, 600ms warmup, 250ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase39/final-exposed01/report.json`: 6 points / 90 samples; 114.107s process wall; 5 requested rounds, 600ms warmup, 250ms sample target. The historical ray case retains its special maximum-three-round policy.
- `/home/ai/bend2/build/publish/bend/selfhost/build/phase39/final-canary-confirm01/report.json`: 4 points / 60 samples; 98.328s process wall; 5 requested rounds, 1000ms warmup, 300ms sample target. The historical ray case retains its special maximum-three-round policy.

Per-role ranges and every half-drift observation are retained in report.json. Inspect those before describing a gain as stable. The sum of separate run wall times is a workflow cost, not a runtime denominator or a promise that the entire catalog fits one preset. Paired wins compare each balanced round; they are descriptive counts, not a significance test. Byte deltas are per-point module sizes; shared source modules must not be summed as separate code.
