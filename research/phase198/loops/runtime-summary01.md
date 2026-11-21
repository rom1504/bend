# Recurrence residency screen

Candidate / Phase197-combined runtime; lower is faster.

| Case | Session1 | Session2 | Geometric ratio |
| --- | ---: | ---: | ---: |
| editdist | 1.1527 | 1.1542 | 1.1535 |
| local-fold | 0.8029 | 0.8020 | 0.8024 |
| variation-local-fold-8192-123 | 0.8072 | 0.8118 | 0.8095 |
| mandelbrot | 0.9752 | 0.9714 | 0.9733 |

Development geometric ratio: 0.9621. All four cases: 0.9241.

Two balanced four-round finite screens. Per-role calibration, original complete value/count oracles, all cases/dispersion retained. Does not establish compiler speed, native reproduction, full-suite improvement or a correctness theorem.

Dispersion flags (>5% range/median):
- editdist, session1: baseline
- editdist, session2: baseline
- mandelbrot, session2: loops
