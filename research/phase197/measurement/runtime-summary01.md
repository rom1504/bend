# Phase197 checked compiler runtime screen

Ratios are candidate / qualified Phase195 runtime; lower is faster. Each cell shows the two independent sessions. Four rounds balance all four roles in each session.

| Case | Minimum | Decrement | Combined |
| --- | ---: | ---: | ---: |
| editdist | 0.8725/0.8784 | 1.0047/0.9966 | 0.8563/0.8547 |
| local-pair | 0.8748/0.8792 | 0.9927/1.0019 | 0.8431/0.8540 |
| coverage-bst-64 | 1.0042/1.0021 | 0.9399/0.9544 | 0.9370/0.9575 |
| coverage-bst-32 | 0.9942/1.0039 | 0.9884/1.0039 | 0.9963/0.9955 |
| variation-editdist-3-123 | 0.8643/0.8789 | 0.9854/1.0020 | 0.8436/0.8630 |
| mandelbrot | 0.9921/0.9557 | 0.9881/0.9607 | 1.0139/0.9566 |

Geometric ratios across both sessions:

| Partition | Minimum | Decrement | Combined |
| --- | ---: | ---: | ---: |
| allSix | 0.9314 | 0.9847 | 0.9120 |
| development | 0.9166 | 0.9814 | 0.8826 |
| heldout | 0.9331 | 0.9949 | 0.9218 |
| unrelatedWorkload | 0.9737 | 0.9743 | 0.9849 |

Dispersion flags: editdist session1: baseline, minimum, decrement, combined; editdist session2: baseline; local-pair session1: minimum; coverage-bst-32 session1: minimum, decrement, combined; coverage-bst-32 session2: decrement; mandelbrot session1: baseline, combined; mandelbrot session2: baseline.

Two four-round position-balanced finite six-workload screens versus exact qualified Phase195 products. Ratios use independent per-role calibration. All regressions retained. No confidence interval, full45, compiler-speed, native qualification or installation claim.

Unchanged emitted objects: coverage-bst-64: minimum; coverage-bst-32: minimum; mandelbrot: minimum, decrement, combined. Timing differences on these rows do not establish an optimization effect.
