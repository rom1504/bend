# External upstream runtime comparison

Elapsed wall seconds on one Intel Xeon E3-1245 v2 core with GPU disabled. Parentheses divide the same-input time by handwritten C. The medium rows are medians of five fresh executions per successful implementation. The original defaults have one completed observation per successful implementation. Small controls include substantial process startup time.

## Medium comparison

| Workload | Handwritten C | Upstream Bend→C | AGY x86 | Our Bend→C | Our QBE |
|---|---:|---:|---:|---:|---:|
| histogram | 0.0240 s | 0.0376 s (1.57×) | 0.3401 s (14.17×) | 0.0812 s (3.38×) | 0.3297 s (13.74×) |
| gameoflife | 0.2415 s | 0.2882 s (1.19×) | 3.3366 s (13.82×) | 0.6673 s (2.76×) | 1.9500 s (8.07×) |
| nbody | 0.0747 s | 0.0779 s (1.04×) | 0.3155 s (4.22×) | 0.0791 s (1.06×) | 0.6266 s (8.39×) |

## Untouched upstream defaults

| Workload | Handwritten C | Upstream Bend→C | AGY x86 | Our Bend→C | Our QBE |
|---|---:|---:|---:|---:|---:|
| histogram | 7.5097 s | 11.4522 s (1.52×) | 130.2121 s (17.34×) | 26.8535 s (3.58×) | 110.2178 s (14.68×) |
| gameoflife | 17.4611 s | 24.4644 s (1.40×) | 227.6527 s (13.04×) | 68.0584 s (3.90×) | 133.2150 s (7.63×) |
| nbody | 10.7390 s | 10.4266 s (0.97×) | 54.5373 s (5.08×) | 10.0623 s (0.94×) | 95.0818 s (8.85×) |

## Published small control

| Workload | Handwritten C | Upstream Bend→C | AGY x86 | Our Bend→C | Our QBE |
|---|---:|---:|---:|---:|---:|
| histogram | 0.0020 s | 0.0024 s | 0.0026 s | 0.0044 s | 0.0025 s |
| gameoflife | 0.0019 s | 0.0023 s | 0.0023 s | 0.0039 s | 0.0030 s |
| nbody | 0.0117 s | 0.0119 s | 0.0423 s | 0.0133 s | 0.0810 s |

