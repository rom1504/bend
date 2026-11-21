# Recurrence residency screen

Candidate / Phase197-combined runtime; lower is faster.

| Case | Session1 | Session2 | Geometric ratio |
| --- | ---: | ---: | ---: |
| editdist | 0.9922 | 1.0104 | 1.0013 |
| local-fold | 1.0072 | 1.0055 | 1.0063 |
| variation-local-fold-8192-123 | 0.9972 | 1.0063 | 1.0017 |
| mandelbrot | 1.0432 | 1.0351 | 1.0392 |

Development geometric ratio: 1.0038. All four cases: 1.0120.

Two balanced four-round finite screens. Per-role calibration, original complete value/count oracles, all cases/dispersion retained. Does not establish compiler speed, native reproduction, full-suite improvement or a correctness theorem.

Dispersion flags (>5% range/median):
- editdist, session1: baseline, loops
