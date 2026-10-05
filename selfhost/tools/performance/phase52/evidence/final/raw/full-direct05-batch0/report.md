# Generated-program execution

Status: **measured**; 15/15 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| local-pair | 5/5 | 1.49467 | 1.7421 | 1.24332 | 1.401× |
| local-fold | 5/5 | 0.0604405 | 0.0443432 | 0.0400119 | 1.108× |
| scalar-region-0 | 5/5 | 0.00422293 | 6.84339e-05 | 6.88468e-05 | 0.994× |
| scalar-region-8192 | 5/5 | 0.115417 | 0.112582 | 0.0996458 | 1.130× |
| complete-generic-row32 | 5/5 | 0.0278484 | 0.00686839 | 0.0067942 | 1.011× |
| mandelbrot | 5/5 | 0.124907 | 0.0803922 | 0.0457911 | 1.756× |
| editdist | 5/5 | 5.6389 | 7.02093 | 4.9611 | 1.415× |
| tree-bitonic | 5/5 | 0.341086 | 0.274504 | 0.279679 | 0.981× |
| lexer | 5/5 | 2.47405 | 1.87398 | 1.66899 | 1.123× |
| symreg | 5/5 | 1.46804 | 1.33768 | 1.10393 | 1.212× |
| test-morning-program | 5/5 | 0.159878 | 0.0029334 | 0.0031533 | 0.930× |
| test-evening-program | 5/5 | 0.124001 | 0.00265158 | 0.0026143 | 1.014× |
| test-rle-roundtrip | 5/5 | 0.0317152 | 0.000584329 | 0.000562886 | 1.038× |
| test-map-set-ops | 5/5 | 1.0021 | 0.0196346 | 0.0202022 | 0.972× |
| raytrace | 3/3 | 60.425 | 71.1035 | 34.3815 | 2.068× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
